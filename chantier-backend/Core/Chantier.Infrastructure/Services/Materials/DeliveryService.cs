using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Common;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Paging;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Materials;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// Livraisons : creation idempotente (numero <c>LIV-nnn</c> attribue dans la transaction apres le controle du <c>clientId</c>), correction avec la version lue,
/// annulation motivee, rattachement. <b>Une livraison est un fait de chantier</b> : sa creation n'est jamais refusee a cause du statut de la demande (elle est alors
/// enregistree non rattachee, avec son motif). Le statut, le recu et les montants de la demande ne sont jamais ecrits ici mais par <see cref="IRequestRecalculator"/>,
/// dans la meme transaction, apres chaque ecriture. Droits, produit, unites et dates : une seule source de regles pour l'API REST et la synchronisation.
/// Verrous : livraison puis demande, toujours avant la premiere ecriture (<see cref="MaterialLocks"/>).
/// </summary>
public sealed class DeliveryService(
    ApplicationDbContext db,
    IRepositoryBase<Delivery> deliveries,
    IRepositoryBase<MaterialRequest> requests,
    IRepositoryBase<Site> sites,
    IRepositoryBase<Supplier> suppliers,
    IRepositoryBase<Product> products,
    ISiteNumbering numbering,
    IRequestRecalculator recalculator,
    IRequestEventWriter events,
    DeliveryProjector projector,
    ICurrentUser currentUser,
    IUserPermissions permissions,
    IOptions<MaterialsOptions> options,
    TimeProvider time) : IDeliveryService
{
    /// <summary>Statuts d'une demande qui recoit une livraison a la creation : validee (livraison « retenue »), commandee, livree partiellement, livree (surplus).</summary>
    private static readonly RequestStatus[] ReceivesDelivery =
        [RequestStatus.Validated, RequestStatus.Ordered, RequestStatus.PartiallyDelivered, RequestStatus.Delivered];

    /// <summary>Statuts d'une demande ou l'on peut rattacher apres coup une livraison (CA-MAT-011.2).</summary>
    private static readonly RequestStatus[] AcceptsAttachment = [RequestStatus.Validated, RequestStatus.Ordered, RequestStatus.PartiallyDelivered];

    private MaterialsOptions Rules => options.Value;

    // --- Lecture ---

    public async Task<PagedResult<DeliveryResponse>> ListAsync(DeliveryListQuery query, CancellationToken cancellationToken = default)
    {
        var sort = ListRules.Check(query.Page, query.PageSize, query.Sort, DeliveriesListSpecification.SortValues);

        IReadOnlyCollection<Guid>? matchingProducts = null;
        IReadOnlyCollection<Guid>? matchingSuppliers = null;
        if (!string.IsNullOrWhiteSpace(query.Search))
        {
            var normalized = NameNormalizer.Normalize(query.Search);
            var text = query.Search.Trim();
            matchingProducts = await db.Products.AsNoTracking()
                .Where(product => product.NormalizedNameFr.Contains(normalized) || (product.NameAr != null && product.NameAr.Contains(text)))
                .Select(product => product.Id)
                .ToListAsync(cancellationToken);
            matchingSuppliers = await db.Suppliers.AsNoTracking()
                .Where(supplier => supplier.NormalizedName.Contains(normalized))
                .Select(supplier => supplier.Id)
                .ToListAsync(cancellationToken);
        }

        var specification = new DeliveriesListSpecification(
            query.SiteId, query.RequestId, query.Unattached, query.WithReserve, query.MissingNote, query.Status, query.SupplierId, query.ProductId,
            query.Search, matchingProducts, matchingSuppliers, query.From, query.To, sort, query.Page, query.PageSize);

        var total = await deliveries.CountAsync(specification, cancellationToken);
        var rows = await deliveries.ListAsync(specification, cancellationToken);
        var items = await projector.ToResponsesAsync(rows, await permissions.HasAsync(Permissions.PricesView, cancellationToken), includePhotos: false, cancellationToken);
        return new PagedResult<DeliveryResponse>(items, query.Page, query.PageSize, total);
    }

    public async Task<DeliveryDetailResponse> GetAsync(Guid siteId, Guid deliveryId, CancellationToken cancellationToken = default)
        => await DetailAsync(await LoadAsync(siteId, deliveryId, cancellationToken), cancellationToken);

    // --- Creation ---

    public async Task<DeliveryCreationResult> CreateAsync(Guid siteId, CreateDeliveryDto dto, RequestActionContext? context = null, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.DeliveriesCreate, cancellationToken);
        var action = (context ?? RequestActionContext.Api) with { };

        if (dto.ClientId == Guid.Empty)
        {
            throw new Core.Exceptions.ValidationException("clientId", "L'identifiant client est invalide.");
        }

        // Renvoi du meme clientId : meme livraison, meme numero, aucun effet (meme si le chantier a ete archive depuis).
        if (await FindByClientIdAsync(siteId, dto.ClientId, cancellationToken) is { } existing)
        {
            return new DeliveryCreationResult(await DetailAsync(existing, cancellationToken), Created: false);
        }

        await EnsureSiteWritableAsync(siteId, cancellationToken);

        try
        {
            var (delivery, created) = await DbTransactions.RunAsync(db, async () =>
            {
                if (dto.RequestId is { } requestId)
                {
                    await AppLocks.AcquireAsync(db, MaterialLocks.Request(requestId), cancellationToken);
                }

                return await MaterialLocks.RetryAsync(db, () => CreateLockedAsync(siteId, dto, action, cancellationToken));
            }, cancellationToken);

            return new DeliveryCreationResult(await DetailAsync(delivery, cancellationToken), created);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            // Deux envois du meme clientId en parallele : l'index unique tranche, le second recoit la livraison du premier.
            db.ChangeTracker.Clear();
            if (await FindByClientIdAsync(siteId, dto.ClientId, cancellationToken) is { } winner)
            {
                return new DeliveryCreationResult(await DetailAsync(winner, cancellationToken), Created: false);
            }

            throw;
        }
    }

    private async Task<(Delivery Delivery, bool Created)> CreateLockedAsync(Guid siteId, CreateDeliveryDto dto, RequestActionContext action, CancellationToken cancellationToken)
    {
        // Course entre deux renvois : le premier a peut-etre ecrit pendant que le second attendait le verrou.
        if (await FindByClientIdAsync(siteId, dto.ClientId, cancellationToken) is { } known)
        {
            return (known, false);
        }

        var request = dto.RequestId is { } requestId ? await LoadRequestAsync(siteId, requestId, cancellationToken) : null;

        // Fait de chantier : la livraison est toujours enregistree ; seule une demande qui peut la recevoir la rattache.
        var attach = request is not null && ReceivesDelivery.Contains(request.Status);
        var reason = request is not null
            ? (attach ? (UnattachedReason?)null : UnattachedReason.RequestNotOpen)
            : dto.Reason ?? UnattachedReason.NoRequestChosen;

        var fields = dto.Fields;
        if (request is not null)
        {
            fields = ResolveProduct(fields, request);
        }

        MaterialOrder? order = null;
        if (attach)
        {
            order = await db.MaterialOrders.AsNoTracking().FirstOrDefaultAsync(candidate => candidate.RequestId == request!.Id && candidate.CancelledAt == null, cancellationToken);
            if (fields.SupplierId is null && string.IsNullOrWhiteSpace(fields.FreeSupplierName) && order is not null)
            {
                fields = fields with { SupplierId = order.SupplierId };
            }
        }

        var validated = DeliveryRules.Validate(fields, Rules, AlgeriaDate.Today(time));
        var unit = validated.Quantity.Unit;

        var product = validated.ProductId is { } productId
            ? await products.GetByIdAsync(productId, cancellationToken) ?? throw new Core.Exceptions.ValidationException("productId", "Ce produit n'existe pas dans le catalogue.")
            : null;
        if (product is not null)
        {
            // Un produit saisi explicitement doit etre actif ; celui d'une demande existante reste valable (le camion est arrive).
            if (request is null && !product.IsActive)
            {
                throw new DomainRuleException(ErrorCodes.ProduitInactif, "Ce produit est désactivé : il ne peut plus être demandé ni livré.");
            }

            if (!attach && !product.Allows(unit))
            {
                throw new DomainRuleException(ErrorCodes.UniteNonAutorisee, "Cette unité n'est pas autorisée pour ce produit.");
            }
        }

        if (validated.SupplierId is { } supplierId && supplierId != order?.SupplierId)
        {
            await EnsureSupplierAsync(supplierId, cancellationToken);
        }

        decimal? converted = null;
        decimal? amount = null;
        if (attach)
        {
            converted = UnitConverter.Convert(validated.Quantity, request!.Unit, product?.BagMassKg).Value;
            amount = order?.UnitPrice is { } price ? Money.Amount(converted.Value, price) : null;
            Money.EnsureStorable(converted.Value, amount);
        }

        Guid? duplicateOf = null;
        if (validated.DeliveryNoteNumber is { } noteNumber)
        {
            duplicateOf = (await deliveries.FirstOrDefaultAsync(
                new DeliveryDuplicateSpecification(siteId, validated.SupplierId, validated.FreeSupplierName, validated.ProductId, validated.FreeProductName, noteNumber),
                cancellationToken))?.Id;
        }

        // Le numero est demande dans la transaction qui ecrit la livraison : une annulation le libere (aucun trou), apres le controle du clientId.
        var number = await numbering.NextAsync(siteId, NumberPrefixes.Delivery, cancellationToken);
        var delivery = Delivery.Create(siteId, number, dto.ClientId, dto.ClientCreatedAt, validated, attach ? request!.Id : null, reason, duplicateOf);
        delivery.ApplyComputed(converted, amount);
        db.Deliveries.Add(delivery);

        var context = action with { DeviceAt = action.DeviceAt ?? dto.ClientCreatedAt };
        events.Add(delivery, MaterialEventType.DeliveryRegistered, context, reason?.ToString(), request?.Number);
        if (attach)
        {
            events.Add(request!, MaterialEventType.DeliveryRegistered, context, note: number);
        }

        await db.SaveChangesAsync(cancellationToken);

        if (attach)
        {
            await recalculator.RecomputeAsync(request!, RecalculationTriggers.DeliveryRegistered, number, context, cancellationToken);
            await db.SaveChangesAsync(cancellationToken);
        }

        return (delivery, true);
    }

    // --- Correction ---

    public async Task<DeliveryDetailResponse> UpdateAsync(Guid siteId, Guid deliveryId, UpdateDeliveryDto dto, RequestActionContext? context = null, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.DeliveriesUpdate, cancellationToken);
        return await LockedAsync(siteId, deliveryId, () => UpdateLockedAsync(siteId, deliveryId, dto, context ?? RequestActionContext.Api, cancellationToken), cancellationToken);
    }

    private async Task<DeliveryDetailResponse> UpdateLockedAsync(Guid siteId, Guid deliveryId, UpdateDeliveryDto dto, RequestActionContext action, CancellationToken cancellationToken)
    {
        var delivery = await LoadAsync(siteId, deliveryId, cancellationToken);

        if (!BasicEntity.TryParseVersion(dto.Version, out var version))
        {
            throw new Core.Exceptions.ValidationException("version", "La version est invalide.");
        }

        if (version != delivery.RowVersion)
        {
            throw new ConflictException(await DetailAsync(delivery, cancellationToken));
        }

        if (delivery.IsCancelled)
        {
            throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Une livraison annulée ne se corrige pas.");
        }

        var request = await LoadAttachedRequestAsync(siteId, delivery, cancellationToken);
        EnsureRequestOpen(request);

        var validated = DeliveryRules.Validate(dto.Changes.ApplyTo(delivery.CurrentFields()), Rules, AlgeriaDate.Today(time));
        var product = delivery.ProductId is { } productId ? await products.GetByIdAsync(productId, cancellationToken) : null;

        if (request is not null)
        {
            // Unites : celle de la demande ou convertible (UNITES_INCOMPATIBLES sinon) ; sans demande, une unite du produit du catalogue.
            _ = UnitConverter.Convert(validated.Quantity, request.Unit, product?.BagMassKg);
        }
        else if (product is not null && validated.Quantity.Unit != delivery.Unit && !product.Allows(validated.Quantity.Unit))
        {
            throw new DomainRuleException(ErrorCodes.UniteNonAutorisee, "Cette unité n'est pas autorisée pour ce produit.");
        }

        if (delivery.ChangedFields(validated).Count == 0)
        {
            return await DetailAsync(delivery, cancellationToken);
        }

        await EnsureSiteWritableAsync(siteId, cancellationToken);

        var changes = delivery.ApplyEdit(validated);
        events.Add(delivery, MaterialEventType.DeliveryEdited, action, changes: changes);
        if (request is not null)
        {
            events.Add(request, MaterialEventType.DeliveryEdited, action, note: delivery.Number);
        }

        await db.SaveChangesAsync(cancellationToken);

        if (request is not null)
        {
            await recalculator.RecomputeAsync(request, RecalculationTriggers.DeliveryEdited, delivery.Number, action, cancellationToken);
            await db.SaveChangesAsync(cancellationToken);
        }

        return await DetailAsync(delivery, cancellationToken);
    }

    // --- Annulation ---

    public async Task<DeliveryActionResult> CancelAsync(Guid siteId, Guid deliveryId, string? reasonCode, string? reasonNote, RequestActionContext? context = null, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.DeliveriesUpdate, cancellationToken);
        var note = ReasonRules.Validate(ReasonKind.DeliveryCancellation, reasonCode, reasonNote, Rules);
        var action = context ?? RequestActionContext.Api;

        return await LockedAsync(siteId, deliveryId, async () =>
        {
            var delivery = await LoadAsync(siteId, deliveryId, cancellationToken);

            // Deux appuis : une seule annulation, le premier motif est conserve.
            if (delivery.IsCancelled)
            {
                return new DeliveryActionResult(await DetailAsync(delivery, cancellationToken), Applied: false);
            }

            var request = await LoadAttachedRequestAsync(siteId, delivery, cancellationToken);
            EnsureRequestOpen(request);
            await EnsureSiteWritableAsync(siteId, cancellationToken);

            delivery.Cancel(reasonCode!, note, currentUser.Id ?? throw new NotFoundException(), time.GetUtcNow());
            events.Add(delivery, MaterialEventType.DeliveryCancelled, action, reasonCode, note);
            if (request is not null)
            {
                events.Add(request, MaterialEventType.DeliveryCancelled, action, note: delivery.Number);
            }

            await db.SaveChangesAsync(cancellationToken);

            if (request is not null)
            {
                await recalculator.RecomputeAsync(request, RecalculationTriggers.DeliveryCancelled, delivery.Number, action, cancellationToken);
                await db.SaveChangesAsync(cancellationToken);
            }

            return new DeliveryActionResult(await DetailAsync(delivery, cancellationToken), Applied: true);
        }, cancellationToken);
    }

    // --- Rattachement ---

    public async Task<DeliveryDetailResponse> AttachAsync(Guid siteId, Guid deliveryId, Guid requestId, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.DeliveriesAttach, cancellationToken);

        return await DbTransactions.RunAsync(db, async () =>
        {
            await AppLocks.AcquireAsync(db, MaterialLocks.Delivery(deliveryId), cancellationToken);
            await AppLocks.AcquireAsync(db, MaterialLocks.Request(requestId), cancellationToken);

            return await MaterialLocks.RetryAsync(db, async () =>
            {
                var delivery = await LoadAsync(siteId, deliveryId, cancellationToken);

                if (delivery.IsCancelled)
                {
                    throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Une livraison annulée ne se rattache pas.");
                }

                if (delivery.IsAttached)
                {
                    throw new DomainRuleException(ErrorCodes.LivraisonDejaRattachee, "Cette livraison est déjà rattachée à une demande.");
                }

                // Une demande d'un autre chantier est introuvable (jamais revelee).
                var request = await LoadRequestAsync(siteId, requestId, cancellationToken);
                if (!AcceptsAttachment.Contains(request.Status))
                {
                    throw new DomainRuleException(ErrorCodes.DemandeNonOuverte, "Cette demande n'accepte plus de livraison.");
                }

                if (!SameProduct(delivery, request))
                {
                    throw new DomainRuleException(ErrorCodes.ProduitDifferent, "Le produit de la livraison n'est pas celui de la demande.");
                }

                var product = request.ProductId is { } productId ? await products.GetByIdAsync(productId, cancellationToken) : null;
                _ = UnitConverter.Convert(delivery.Delivered, request.Unit, product?.BagMassKg);
                await EnsureSiteWritableAsync(siteId, cancellationToken);

                delivery.Attach(request.Id);
                events.Add(delivery, MaterialEventType.DeliveryAttached, RequestActionContext.Api, note: request.Number);
                events.Add(request, MaterialEventType.DeliveryAttached, RequestActionContext.Api, note: delivery.Number);
                await db.SaveChangesAsync(cancellationToken);

                await recalculator.RecomputeAsync(request, RecalculationTriggers.DeliveryAttached, delivery.Number, RequestActionContext.Api, cancellationToken);
                await db.SaveChangesAsync(cancellationToken);

                return await DetailAsync(delivery, cancellationToken);
            });
        }, cancellationToken);
    }

    // --- Outils ---

    /// <summary>Transaction, verrou de la livraison puis de sa demande (avant toute ecriture), puis le corps rejoue si une ligne a change entre sa lecture et son ecriture.</summary>
    private async Task<T> LockedAsync<T>(Guid siteId, Guid deliveryId, Func<Task<T>> body, CancellationToken cancellationToken)
        => await DbTransactions.RunAsync(db, async () =>
        {
            await AppLocks.AcquireAsync(db, MaterialLocks.Delivery(deliveryId), cancellationToken);

            var head = await db.Deliveries.AsNoTracking()
                .Where(delivery => delivery.SiteId == siteId && delivery.Id == deliveryId)
                .Select(delivery => new { delivery.RequestId })
                .FirstOrDefaultAsync(cancellationToken) ?? throw new NotFoundException();
            if (head.RequestId is { } requestId)
            {
                await AppLocks.AcquireAsync(db, MaterialLocks.Request(requestId), cancellationToken);
            }

            return await MaterialLocks.RetryAsync(db, body);
        }, cancellationToken);

    /// <summary>
    /// Impose le produit de la demande a la livraison : l'envoi d'un autre produit est refuse (<c>PRODUIT_DIFFERENT</c>) ; un produit non precise est celui de la demande.
    /// </summary>
    private static DeliveryFields ResolveProduct(DeliveryFields fields, MaterialRequest request)
    {
        var givenFree = string.IsNullOrWhiteSpace(fields.FreeProductName) ? null : fields.FreeProductName;
        if ((fields.ProductId is not null || givenFree is not null) && !SameProduct(fields.ProductId, givenFree, request))
        {
            throw new DomainRuleException(ErrorCodes.ProduitDifferent, "Le produit de la livraison n'est pas celui de la demande.");
        }

        return request.ProductId is { } productId
            ? fields with { ProductId = productId, FreeProductName = null }
            : fields with { ProductId = null, FreeProductName = request.FreeProductName };
    }

    private static bool SameProduct(Delivery delivery, MaterialRequest request) => SameProduct(delivery.ProductId, delivery.FreeProductName, request);

    /// <summary>Meme produit du catalogue, ou meme nom libre (compare sans tenir compte de la casse, des accents ni des espaces superflus).</summary>
    private static bool SameProduct(Guid? productId, string? freeName, MaterialRequest request)
    {
        if (request.ProductId is { } requestProduct && productId == requestProduct)
        {
            return true;
        }

        return productId is null
            && freeName is not null
            && request.FreeProductName is { } requestFree
            && NameNormalizer.Normalize(freeName) == NameNormalizer.Normalize(requestFree);
    }

    private async Task<Delivery> LoadAsync(Guid siteId, Guid deliveryId, CancellationToken cancellationToken)
        => await deliveries.FirstOrDefaultAsync(new DeliveryBySiteAndIdSpecification(siteId, deliveryId), cancellationToken) ?? throw new NotFoundException();

    private async Task<Delivery?> FindByClientIdAsync(Guid siteId, Guid? clientId, CancellationToken cancellationToken)
        => clientId is { } id && id != Guid.Empty
            ? await deliveries.FirstOrDefaultAsync(new DeliveryByClientIdSpecification(siteId, id), cancellationToken)
            : null;

    private async Task<MaterialRequest> LoadRequestAsync(Guid siteId, Guid requestId, CancellationToken cancellationToken)
        => await requests.FirstOrDefaultAsync(new RequestBySiteAndIdSpecification(siteId, requestId), cancellationToken) ?? throw new NotFoundException();

    private async Task<MaterialRequest?> LoadAttachedRequestAsync(Guid siteId, Delivery delivery, CancellationToken cancellationToken)
        => delivery.RequestId is { } requestId ? await LoadRequestAsync(siteId, requestId, cancellationToken) : null;

    /// <summary>Une demande receptionnee ne se recalcule plus : correction et annulation de ses livraisons sont refusees (<c>DEMANDE_NON_OUVERTE</c>).</summary>
    private static void EnsureRequestOpen(MaterialRequest? request)
    {
        if (request?.Status == RequestStatus.Received)
        {
            throw new DomainRuleException(ErrorCodes.DemandeNonOuverte, "Cette demande est réceptionnée : ses livraisons ne se modifient plus.");
        }
    }

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

    private async Task<DeliveryDetailResponse> DetailAsync(Delivery delivery, CancellationToken cancellationToken)
        => await projector.ToDetailAsync(
            delivery,
            includeCommercial: await permissions.HasAsync(Permissions.PricesView, cancellationToken),
            includePhotos: await permissions.HasAsync(Permissions.DeliveryPhotosView, cancellationToken),
            cancellationToken);
}
