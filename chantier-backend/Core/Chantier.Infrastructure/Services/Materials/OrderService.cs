using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Common;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Specifications.Materials;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// Commandes (une par demande, sans numero propre) : enregistrement idempotent par <c>clientId</c>, modification avec la version lue, annulation sans livraison.
/// <b>Tout se passe sous le verrou de la demande</b> (comme valider ou recevoir) et dans une transaction ; le statut et le recu de la demande ne sont jamais ecrits ici
/// mais par <see cref="IRequestRecalculator"/>. Le prix, le montant et le n° de bon de commande ne sortent que par <see cref="CommercialProjection"/> ;
/// les modifications commerciales ont leur propre evenement (<c>OrderCommercialEdited</c>), jamais montre sans <c>Prices.View</c>.
/// </summary>
public sealed class OrderService(
    ApplicationDbContext db,
    IRepositoryBase<Site> sites,
    IRepositoryBase<Supplier> suppliers,
    IRepositoryBase<MaterialRequest> requests,
    IRequestRecalculator recalculator,
    IRequestEventWriter events,
    RequestProjector projector,
    ICurrentUser currentUser,
    IUserPermissions permissions,
    IOptions<MaterialsOptions> options,
    TimeProvider time) : IOrderService
{
    private MaterialsOptions Rules => options.Value;

    public async Task<RequestCreationResult> CreateAsync(Guid siteId, Guid requestId, CreateOrderDto dto, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.OrdersCreate, cancellationToken);

        if (dto.ClientId == Guid.Empty)
        {
            throw new Core.Exceptions.ValidationException("clientId", "L'identifiant client est invalide.");
        }

        try
        {
            return await LockedAsync(requestId, () => CreateLockedAsync(siteId, requestId, dto, cancellationToken), cancellationToken);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            // Deux envois du meme clientId en parallele (sur une autre demande) ou deux commandes actives : l'index unique tranche.
            db.ChangeTracker.Clear();
            if (dto.ClientId is { } clientId && await db.MaterialOrders.AsNoTracking().FirstOrDefaultAsync(order => order.SiteId == siteId && order.ClientId == clientId, cancellationToken) is { } winner
                && winner.RequestId == requestId)
            {
                return new RequestCreationResult(await DetailAsync(await LoadRequestAsync(siteId, requestId, cancellationToken), cancellationToken), Created: false);
            }

            throw new DomainRuleException(ErrorCodes.CommandeExistante, "Cette demande est déjà commandée.");
        }
    }

    private async Task<RequestCreationResult> CreateLockedAsync(Guid siteId, Guid requestId, CreateOrderDto dto, CancellationToken cancellationToken)
    {
        var request = await LoadRequestAsync(siteId, requestId, cancellationToken);

        // Renvoi du meme clientId : meme commande, aucun effet.
        if (dto.ClientId is { } clientId
            && await db.MaterialOrders.AsNoTracking().FirstOrDefaultAsync(order => order.SiteId == siteId && order.ClientId == clientId, cancellationToken) is { } known)
        {
            if (known.RequestId != requestId)
            {
                throw new Core.Exceptions.ValidationException("clientId", "Cet identifiant client est déjà utilisé.");
            }

            return new RequestCreationResult(await DetailAsync(request, cancellationToken), Created: false);
        }

        if (await db.MaterialOrders.AnyAsync(order => order.RequestId == requestId && order.CancelledAt == null, cancellationToken))
        {
            throw new DomainRuleException(ErrorCodes.CommandeExistante, "Cette demande est déjà commandée.");
        }

        if (request.Status != RequestStatus.Validated)
        {
            throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Seule une demande validée peut être commandée.");
        }

        var validated = OrderRules.Validate(dto.Fields, Rules, AlgeriaDate.Today(time));
        await EnsureSupplierAsync(validated.SupplierId, cancellationToken);
        await EnsureSiteWritableAsync(siteId, cancellationToken);

        var order = MaterialOrder.Create(siteId, requestId, dto.ClientId, validated, request.Ordered);
        db.MaterialOrders.Add(order);

        var from = request.Status;
        request.PlaceOrder();
        events.Add(
            request, MaterialEventType.Ordered, RequestActionContext.Api, from, request.Status,
            changes: [new FieldChange(OrderFieldNames.SupplierId, null, validated.SupplierId.ToString())]);
        await db.SaveChangesAsync(cancellationToken);

        // Des livraisons deja retenues (recues avant la commande) sont prises en compte tout de suite : Ordered, puis eventuellement Livree (deux evenements).
        await recalculator.RecomputeAsync(request, RecalculationTriggers.OrderPlaced, null, RequestActionContext.Api, cancellationToken);
        await db.SaveChangesAsync(cancellationToken);

        return new RequestCreationResult(await DetailAsync(request, cancellationToken), Created: true);
    }

    public async Task<MaterialRequestDetailResponse> UpdateAsync(Guid siteId, Guid requestId, UpdateOrderDto dto, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.OrdersUpdate, cancellationToken);
        return await LockedAsync(requestId, () => UpdateLockedAsync(siteId, requestId, dto, cancellationToken), cancellationToken);
    }

    private async Task<MaterialRequestDetailResponse> UpdateLockedAsync(Guid siteId, Guid requestId, UpdateOrderDto dto, CancellationToken cancellationToken)
    {
        var request = await LoadRequestAsync(siteId, requestId, cancellationToken);
        var order = await ActiveOrderAsync(requestId, cancellationToken) ?? throw new NotFoundException();

        if (!BasicEntity.TryParseVersion(dto.Version, out var version))
        {
            throw new Core.Exceptions.ValidationException("version", "La version est invalide.");
        }

        if (version != order.RowVersion)
        {
            throw new ConflictException(await DetailAsync(request, cancellationToken));
        }

        // Tant que la demande n'est pas livree : modifier une commande d'une demande livree n'a plus de sens.
        if (request.Status is not (RequestStatus.Ordered or RequestStatus.PartiallyDelivered))
        {
            throw new DomainRuleException(ErrorCodes.TransitionInterdite, "La commande ne se modifie plus : la demande est livrée.");
        }

        var validated = OrderRules.Validate(dto.Changes.ApplyTo(order.CurrentFields()), Rules, AlgeriaDate.Today(time));
        if (validated.SupplierId != order.SupplierId)
        {
            await EnsureSupplierAsync(validated.SupplierId, cancellationToken);
        }

        var (general, commercial) = order.ApplyEdit(validated, request.Ordered);
        if (general.Count == 0 && commercial.Count == 0)
        {
            return await DetailAsync(request, cancellationToken);
        }

        await EnsureSiteWritableAsync(siteId, cancellationToken);

        if (general.Count > 0)
        {
            events.Add(request, MaterialEventType.OrderEdited, RequestActionContext.Api, changes: general);
        }

        if (commercial.Count > 0)
        {
            events.Add(request, MaterialEventType.OrderCommercialEdited, RequestActionContext.Api, changes: commercial);
        }

        await db.SaveChangesAsync(cancellationToken);

        // Un nouveau prix change le montant de chaque livraison (cache) : un seul ecrivain, le recalcul.
        if (commercial.Any(change => change.Field == OrderFieldNames.UnitPrice))
        {
            await recalculator.RecomputeAsync(request, RecalculationTriggers.DeliveryEdited, null, RequestActionContext.Api, cancellationToken);
            await db.SaveChangesAsync(cancellationToken);
        }

        return await DetailAsync(request, cancellationToken);
    }

    public async Task<MaterialRequestDetailResponse> CancelAsync(Guid siteId, Guid requestId, string? reasonCode, string? reasonNote, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.OrdersCancel, cancellationToken);
        var note = ReasonRules.Validate(ReasonKind.OrderCancellation, reasonCode, reasonNote, Rules);
        return await LockedAsync(requestId, () => CancelLockedAsync(siteId, requestId, reasonCode!, note, cancellationToken), cancellationToken);
    }

    private async Task<MaterialRequestDetailResponse> CancelLockedAsync(Guid siteId, Guid requestId, string reasonCode, string? note, CancellationToken cancellationToken)
    {
        var request = await LoadRequestAsync(siteId, requestId, cancellationToken);
        var order = await ActiveOrderAsync(requestId, cancellationToken);

        if (order is null)
        {
            // Deux appuis : la commande deja annulee (la demande est redevenue validee) rend l'etat courant sans rien ecrire.
            if (request.Status == RequestStatus.Validated && await db.MaterialOrders.AnyAsync(candidate => candidate.RequestId == requestId, cancellationToken))
            {
                return await DetailAsync(request, cancellationToken);
            }

            throw new NotFoundException();
        }

        if (request.Status != RequestStatus.Ordered
            || await db.Deliveries.AnyAsync(delivery => delivery.RequestId == requestId && delivery.Status == DeliveryStatus.Recorded, cancellationToken))
        {
            throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Une livraison est enregistrée : la commande ne s'annule plus.");
        }

        await EnsureSiteWritableAsync(siteId, cancellationToken);

        order.Cancel(reasonCode, note, currentUser.Id ?? throw new NotFoundException(), time.GetUtcNow());
        var from = request.Status;
        request.CancelOrder();
        events.Add(request, MaterialEventType.OrderCancelled, RequestActionContext.Api, from, request.Status, reasonCode, note);
        await db.SaveChangesAsync(cancellationToken);

        return await DetailAsync(request, cancellationToken);
    }

    // --- Outils ---

    /// <summary>Transaction, verrou de la demande, puis le corps rejoue si une ligne a change entre sa lecture et son ecriture.</summary>
    private async Task<T> LockedAsync<T>(Guid requestId, Func<Task<T>> body, CancellationToken cancellationToken)
        => await DbTransactions.RunAsync(db, async () =>
        {
            await AppLocks.AcquireAsync(db, MaterialLocks.Request(requestId), cancellationToken);
            return await MaterialLocks.RetryAsync(db, body);
        }, cancellationToken);

    private async Task<MaterialRequest> LoadRequestAsync(Guid siteId, Guid requestId, CancellationToken cancellationToken)
        => await requests.FirstOrDefaultAsync(new RequestBySiteAndIdSpecification(siteId, requestId), cancellationToken) ?? throw new NotFoundException();

    private Task<MaterialOrder?> ActiveOrderAsync(Guid requestId, CancellationToken cancellationToken)
        => db.MaterialOrders.FirstOrDefaultAsync(order => order.RequestId == requestId && order.CancelledAt == null, cancellationToken);

    private async Task EnsureSupplierAsync(Guid supplierId, CancellationToken cancellationToken)
    {
        var supplier = await suppliers.GetByIdAsync(supplierId, cancellationToken)
            ?? throw new Core.Exceptions.ValidationException("supplierId", "Ce fournisseur n'existe pas.");
        if (!supplier.IsActive)
        {
            throw new DomainRuleException(ErrorCodes.FournisseurInactif, "Ce fournisseur est désactivé : il ne peut plus recevoir de commande.");
        }
    }

    private async Task EnsureSiteWritableAsync(Guid siteId, CancellationToken cancellationToken)
    {
        var site = await sites.GetByIdAsync(siteId, cancellationToken) ?? throw new NotFoundException();
        site.EnsureWritable();
    }

    private async Task RequireAsync(string permission, CancellationToken cancellationToken)
    {
        if (!await permissions.HasAsync(permission, cancellationToken))
        {
            throw new ForbiddenException();
        }
    }

    private async Task<MaterialRequestDetailResponse> DetailAsync(MaterialRequest request, CancellationToken cancellationToken)
        => await projector.ToDetailAsync(
            request,
            includeSiteCode: true,
            includeCommercial: await permissions.HasAsync(Permissions.PricesView, cancellationToken),
            cancellationToken);
}
