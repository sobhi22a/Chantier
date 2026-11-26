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
using Chantier.Core.Specifications.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// Demandes de materiaux : creation idempotente (numero <c>DEM-nnn</c> attribue dans la transaction apres le controle du <c>clientId</c>), modification
/// verrouillee par le statut, transitions (valider, refuser, annuler, receptionner, solder), rattachement d'un produit, archivage, lots.
/// <b>Le meme code sert l'API REST et la synchronisation</b> : droits, verrous, validations et historique ne sont ecrits qu'ici.
/// Le role decide de l'action (verifie ici et par <c>[HasPermission]</c>), l'affectation du chantier est verifiee par l'appelant ; deux regles de ressource
/// s'ajoutent : « la sienne seulement » pour <c>Requests.Update</c> et <c>Requests.Cancel</c>.
/// </summary>
public sealed class RequestService(
    ApplicationDbContext db,
    IRepositoryBase<MaterialRequest> requests,
    IRepositoryBase<Site> sites,
    IRepositoryBase<Product> products,
    IRepositoryBase<Zone> zones,
    ISiteNumbering numbering,
    ICurrentUser currentUser,
    IUserPermissions permissions,
    IOptions<MaterialsOptions> options,
    RequestProjector projector,
    IRequestEventWriter events,
    TimeProvider time) : IRequestService
{
    private const int MaxAttempts = 3;

    private MaterialsOptions Rules => options.Value;

    // --- Lecture ---

    public async Task<PagedResult<MaterialRequestResponse>> ListAsync(RequestListQuery query, CancellationToken cancellationToken = default)
    {
        var errors = new Core.Validation.ErrorCollector();
        if (query.Page < 1)
        {
            errors.Add("page", "La page doit être supérieure ou égale à 1.");
        }

        if (query.PageSize is < 1 or > PagingRules.MaxPageSize)
        {
            errors.Add("pageSize", $"La taille de page doit être comprise entre 1 et {PagingRules.MaxPageSize}.");
        }

        var sort = string.IsNullOrWhiteSpace(query.Sort) ? "default" : query.Sort;
        if (!RequestViews.SortValues.Contains(sort))
        {
            errors.Add("sort", "Tri inconnu.");
        }

        if (query.View is not null && !RequestViews.Available.Contains(query.View))
        {
            errors.Add("view", "Vue inconnue.");
        }

        errors.ThrowIfAny();

        var userId = currentUser.Id ?? throw new NotFoundException();
        IReadOnlyCollection<Guid>? visible = null;
        if (query.SiteId is null && !await permissions.HasAsync(Permissions.AllSitesView, cancellationToken))
        {
            // Chantiers affectes seulement (affectations actives : le filtre de suppression logique est actif).
            visible = await db.SiteMembers.AsNoTracking().Where(member => member.UserId == userId).Select(member => member.SiteId).ToListAsync(cancellationToken);
        }

        IReadOnlyCollection<Guid>? matchingProducts = null;
        if (!string.IsNullOrWhiteSpace(query.Search))
        {
            var normalized = NameNormalizer.Normalize(query.Search);
            var text = query.Search.Trim();
            matchingProducts = await db.Products.AsNoTracking()
                .Where(product => product.NormalizedNameFr.Contains(normalized) || (product.NameAr != null && product.NameAr.Contains(text)))
                .Select(product => product.Id)
                .ToListAsync(cancellationToken);
        }

        // Fournisseur et retard de livraison dependent de la commande active : retrouves par la commande, dans le meme perimetre de chantiers.
        var orders = db.MaterialOrders.AsNoTracking().Where(order => order.CancelledAt == null);
        if (query.SiteId is { } onlySite)
        {
            orders = orders.Where(order => order.SiteId == onlySite);
        }
        else if (visible is not null)
        {
            orders = orders.Where(order => visible.Contains(order.SiteId));
        }

        IReadOnlyCollection<Guid>? supplierRequestIds = null;
        if (query.SupplierId is { } supplierId)
        {
            supplierRequestIds = await orders.Where(order => order.SupplierId == supplierId).Select(order => order.RequestId).ToListAsync(cancellationToken);
        }

        var today = AlgeriaDate.Today(time);
        IReadOnlyCollection<Guid>? lateOrderRequestIds = null;
        if (query.View == RequestViews.Late)
        {
            lateOrderRequestIds = await orders.Where(order => order.ExpectedDeliveryDate < today).Select(order => order.RequestId).ToListAsync(cancellationToken);
        }

        var specification = new RequestsListSpecification(
            query.SiteId, visible, query.View, query.Mine ? userId : null, query.Status, query.Priority, query.ZoneId, query.ProductId,
            query.From, query.To, query.Search, matchingProducts, sort, query.Page, query.PageSize, today, supplierRequestIds, lateOrderRequestIds);

        var total = await requests.CountAsync(specification, cancellationToken);
        var rows = await requests.ListAsync(specification, cancellationToken);
        var items = await projector.ToResponsesAsync(rows, includeSiteCode: true, await permissions.HasAsync(Permissions.PricesView, cancellationToken), cancellationToken);
        return new PagedResult<MaterialRequestResponse>(items, query.Page, query.PageSize, total);
    }

    public async Task<MaterialRequestDetailResponse> GetAsync(Guid siteId, Guid requestId, CancellationToken cancellationToken = default)
        => await DetailAsync(await LoadAsync(siteId, requestId, cancellationToken), cancellationToken);

    // --- Creation ---

    public async Task<RequestCreationResult> CreateAsync(Guid siteId, CreateRequestDto dto, RequestActionContext? context = null, CancellationToken cancellationToken = default)
    {
        await RequireAsync(Permissions.RequestsCreate, cancellationToken);
        var action = context ?? RequestActionContext.Api;

        if (dto.ClientId == Guid.Empty)
        {
            throw new Core.Exceptions.ValidationException("clientId", "L'identifiant client est invalide.");
        }

        // Renvoi du meme clientId : meme demande, meme numero, aucun effet (meme si le chantier a ete archive depuis).
        if (await FindByClientIdAsync(siteId, dto.ClientId, cancellationToken) is { } existing)
        {
            return new RequestCreationResult(await DetailAsync(existing, cancellationToken), Created: false);
        }

        await EnsureSiteWritableAsync(siteId, cancellationToken);

        var product = await LoadProductAsync(dto.Fields.ProductId, cancellationToken);
        var validated = RequestRules.Validate(dto.Fields, product, Rules);
        await EnsureZoneAsync(siteId, validated.ZoneId, cancellationToken);

        Guid? duplicateOf = null;
        if (validated.ProductId is { } productId)
        {
            duplicateOf = (await requests.FirstOrDefaultAsync(new OpenRequestsForDuplicateSpecification(siteId, productId, validated.ZoneId), cancellationToken))?.Id;
        }

        try
        {
            var created = await DbTransactions.RunAsync(db, async () =>
            {
                // Le numero est demande dans la transaction qui ecrit la demande : une annulation le libere (aucun trou).
                var number = await numbering.NextAsync(siteId, NumberPrefixes.Request, cancellationToken);
                var request = MaterialRequest.Create(siteId, number, dto.ClientId, dto.ClientCreatedAt, validated, duplicateOf);
                db.MaterialRequests.Add(request);
                events.Add(request, MaterialEventType.Created, action with { DeviceAt = action.DeviceAt ?? dto.ClientCreatedAt }, toStatus: RequestStatus.Requested);
                await db.SaveChangesAsync(cancellationToken);
                return request;
            }, cancellationToken);

            return new RequestCreationResult(await DetailAsync(created, cancellationToken), Created: true);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            // Deux envois du meme clientId en parallele : l'index unique tranche, le second recoit la demande du premier.
            db.ChangeTracker.Clear();
            if (await FindByClientIdAsync(siteId, dto.ClientId, cancellationToken) is { } winner)
            {
                return new RequestCreationResult(await DetailAsync(winner, cancellationToken), Created: false);
            }

            throw;
        }
    }

    // --- Modification ---

    public async Task<MaterialRequestDetailResponse> UpdateAsync(Guid siteId, Guid requestId, UpdateRequestDto dto, CancellationToken cancellationToken = default)
        => (await EditAsync(siteId, requestId, dto.Changes, dto.Version, RequestActionContext.Api, cancellationToken)).Request;

    public Task<RequestActionResult> ApplyChangesAsync(Guid siteId, Guid requestId, RequestChanges changes, RequestChanges? baseValues, RequestActionContext context, CancellationToken cancellationToken = default)
        => EditAsync(siteId, requestId, changes, expectedVersion: null, context, cancellationToken, baseValues);

    private async Task<RequestActionResult> EditAsync(
        Guid siteId,
        Guid requestId,
        RequestChanges changes,
        string? expectedVersion,
        RequestActionContext context,
        CancellationToken cancellationToken,
        RequestChanges? baseValues = null)
        => await DbTransactions.RunAsync(db, async () =>
        {
            await AppLocks.AcquireAsync(db, LockName(requestId), cancellationToken);
            return await EditLockedAsync(siteId, requestId, changes, expectedVersion, context, baseValues, cancellationToken);
        }, cancellationToken);

    private async Task<RequestActionResult> EditLockedAsync(
        Guid siteId,
        Guid requestId,
        RequestChanges changes,
        string? expectedVersion,
        RequestActionContext context,
        RequestChanges? baseValues,
        CancellationToken cancellationToken)
    {
        for (var attempt = 1; ; attempt++)
        {
            var request = await LoadAsync(siteId, requestId, cancellationToken);

            if (expectedVersion is not null)
            {
                if (!BasicEntity.TryParseVersion(expectedVersion, out var version))
                {
                    throw new Core.Exceptions.ValidationException("version", "La version est invalide.");
                }

                if (version != request.RowVersion)
                {
                    throw new ConflictException(await DetailAsync(request, cancellationToken));
                }
            }

            // Le role decide : UpdateAny (toutes les demandes du chantier) ou Update sur la sienne seulement.
            var canUpdateAny = await permissions.HasAsync(Permissions.RequestsUpdateAny, cancellationToken);
            var canUpdateOwn = request.CreatedBy == currentUser.Id && await permissions.HasAsync(Permissions.RequestsUpdate, cancellationToken);
            if (!canUpdateAny && !canUpdateOwn)
            {
                throw new ForbiddenException();
            }

            var wanted = changes.ApplyTo(request.CurrentFields());

            // Le statut decide d'abord (verrouillee, livree, close : conflit en synchronisation), avant toute validation de contenu.
            request.EnsureEditable(request.ChangedFields(wanted));

            if (baseValues is not null)
            {
                await EnsureNoConcurrentChangeAsync(request, changes, baseValues, cancellationToken);
            }

            var product = await LoadProductAsync(wanted.ProductId, cancellationToken);

            // Un produit desactive ou une unite retiree du catalogue depuis la creation ne bloque pas une simple correction de date.
            var checkProduct = wanted.ProductId != request.ProductId || wanted.Unit != request.Unit;
            var next = RequestRules.Validate(wanted, product, Rules, checkProduct);
            var changed = request.ChangedFields(next);

            // Apres la validation, seule la modification « toutes les demandes » (UpdateAny) peut encore changer date, urgence et remarque.
            if (request.Status != RequestStatus.Requested && !canUpdateAny)
            {
                throw new ForbiddenException();
            }

            if (changed.Count == 0)
            {
                return new RequestActionResult(await DetailAsync(request, cancellationToken), Applied: false);
            }

            await EnsureSiteWritableAsync(siteId, cancellationToken);
            if (changed.Contains(RequestFieldNames.ZoneId))
            {
                await EnsureZoneAsync(siteId, next.ZoneId, cancellationToken);
            }

            var diff = request.ApplyEdit(next);
            events.Add(request, MaterialEventType.Edited, context, changes: diff);

            try
            {
                await db.SaveChangesAsync(cancellationToken);
                return new RequestActionResult(await DetailAsync(request, cancellationToken), Applied: true);
            }
            catch (DbUpdateConcurrencyException)
            {
                db.ChangeTracker.Clear();
                if (expectedVersion is not null)
                {
                    // Modifiee par quelqu'un d'autre entre la lecture et l'ecriture : on renvoie l'etat courant pour proposer de recharger.
                    throw new ConflictException(await DetailAsync(await LoadAsync(siteId, requestId, cancellationToken), cancellationToken));
                }

                if (attempt >= MaxAttempts)
                {
                    throw;
                }
            }
        }
    }

    /// <summary>
    /// Comparaison a trois valeurs d'une modification hors ligne : un champ que quelqu'un d'autre a deja change vers une autre valeur est un conflit
    /// (la premiere arrivee est retenue). Tout ou rien : le moindre conflit refuse toute l'operation.
    /// </summary>
    private async Task EnsureNoConcurrentChangeAsync(MaterialRequest request, RequestChanges changes, RequestChanges baseValues, CancellationToken cancellationToken)
    {
        var proposed = RequestCanonical.Of(changes);
        var start = RequestCanonical.Of(baseValues);

        var errors = new Core.Validation.ErrorCollector();
        foreach (var field in proposed.Keys.Where(field => !start.ContainsKey(field)))
        {
            errors.Add($"base.{field}", "La valeur de départ est obligatoire pour chaque champ modifié.");
        }

        errors.ThrowIfAny();

        var merge = FieldMergeEvaluator.Evaluate(RequestCanonical.Of(request), start, proposed);
        if (merge.HasConflict)
        {
            throw new ConflictException(await DetailAsync(request, cancellationToken), ErrorCodes.ConflitVersion) { Fields = merge.Conflicts };
        }
    }

    // --- Transitions ---

    public Task<RequestActionResult> ApproveAsync(Guid siteId, Guid requestId, QuantityInput? quantity, RequestActionContext? context = null, CancellationToken cancellationToken = default)
        => TransitionAsync(siteId, requestId, async request =>
        {
            await RequireAsync(Permissions.RequestsApprove, cancellationToken);

            Quantity? adjusted = null;
            if (quantity is not null)
            {
                if (quantity.Unit is not { } unit)
                {
                    throw new DomainRuleException(ErrorCodes.UniteObligatoire, "Une quantité doit toujours avoir une unité.");
                }

                adjusted = new Quantity(quantity.Value ?? 0m, unit);
            }

            var from = request.Status;
            if (request.Approve(adjusted, out var adjustment) == TransitionOutcome.AlreadyDone)
            {
                return false;
            }

            var action = context ?? RequestActionContext.Api;
            if (adjustment is not null)
            {
                events.Add(request, MaterialEventType.QuantityAdjusted, action, changes: [adjustment]);
            }

            events.Add(request, MaterialEventType.Approved, action, from, request.Status);
            return true;
        }, cancellationToken);

    public Task<RequestActionResult> RejectAsync(Guid siteId, Guid requestId, string? reasonCode, string? reasonNote, RequestActionContext? context = null, CancellationToken cancellationToken = default)
        => TransitionAsync(siteId, requestId, async request =>
        {
            await RequireAsync(Permissions.RequestsApprove, cancellationToken);
            var note = ReasonRules.Validate(ReasonKind.Rejection, reasonCode, reasonNote, Rules);

            var from = request.Status;
            if (request.Reject(reasonCode!, note) == TransitionOutcome.AlreadyDone)
            {
                return false;
            }

            events.Add(request, MaterialEventType.Rejected, context ?? RequestActionContext.Api, from, request.Status, reasonCode, note);
            return true;
        }, cancellationToken);

    public Task<RequestActionResult> CancelAsync(Guid siteId, Guid requestId, string? reasonCode, string? reasonNote, RequestActionContext? context = null, CancellationToken cancellationToken = default)
        => TransitionAsync(siteId, requestId, async request =>
        {
            // CancelAny : toutes les demandes (conducteur, Admin) ; Cancel : la sienne seulement (Q-MAT-01 c : le ChefChantier n'annule pas celles de son equipe).
            var canCancelAny = await permissions.HasAsync(Permissions.RequestsCancelAny, cancellationToken);
            var canCancelOwn = request.CreatedBy == currentUser.Id && await permissions.HasAsync(Permissions.RequestsCancel, cancellationToken);
            if (!canCancelAny && !canCancelOwn)
            {
                throw new ForbiddenException();
            }

            var note = ReasonRules.Validate(ReasonKind.RequestCancellation, reasonCode, reasonNote, Rules);

            // Une livraison deja retenue (recue avant la commande) est un fait de chantier : la demande ne s'annule plus, il faut d'abord annuler la livraison.
            if (request.Status == RequestStatus.Validated && await HasLiveDeliveryAsync(request.Id, cancellationToken))
            {
                throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Une livraison est déjà rattachée à cette demande : annulez-la d'abord.");
            }

            var from = request.Status;
            if (request.Cancel(reasonCode!, note) == TransitionOutcome.AlreadyDone)
            {
                return false;
            }

            events.Add(request, MaterialEventType.Cancelled, context ?? RequestActionContext.Api, from, request.Status, reasonCode, note);
            return true;
        }, cancellationToken);

    public Task<RequestActionResult> ReceiveAsync(Guid siteId, Guid requestId, string? note, RequestActionContext? context = null, CancellationToken cancellationToken = default)
        => TransitionAsync(siteId, requestId, async request =>
        {
            await RequireAsync(Permissions.RequestsReceive, cancellationToken);

            var text = string.IsNullOrWhiteSpace(note) ? null : note.Trim();
            if (text is { } value && value.Length > Rules.NoteMaxLength)
            {
                throw new Core.Exceptions.ValidationException("note", $"Trop long ({Rules.NoteMaxLength} caractères au maximum).");
            }

            var from = request.Status;
            if (request.Receive() == TransitionOutcome.AlreadyDone)
            {
                return false;
            }

            events.Add(request, MaterialEventType.Received, context ?? RequestActionContext.Api, from, request.Status, note: text);
            return true;
        }, cancellationToken);

    public Task<RequestActionResult> SettleAsync(Guid siteId, Guid requestId, string? reasonCode, string? reasonNote, CancellationToken cancellationToken = default)
        => TransitionAsync(siteId, requestId, async request =>
        {
            await RequireAsync(Permissions.RequestsSettle, cancellationToken);
            var note = ReasonRules.Validate(ReasonKind.Settle, reasonCode, reasonNote, Rules);

            var from = request.Status;
            if (request.Status == RequestStatus.PartiallyDelivered && !await HasLiveDeliveryAsync(request.Id, cancellationToken))
            {
                // Sans aucune livraison non annulee il n'y a rien a solder : annuler la commande.
                throw new DomainRuleException(ErrorCodes.TransitionInterdite, "Aucune livraison à solder : annulez la commande.");
            }

            if (request.Settle() == TransitionOutcome.AlreadyDone)
            {
                return false;
            }

            events.Add(request, MaterialEventType.Settled, RequestActionContext.Api, from, request.Status, reasonCode, note);
            return true;
        }, cancellationToken);

    public Task<RequestActionResult> LinkProductAsync(Guid siteId, Guid requestId, Guid productId, CancellationToken cancellationToken = default)
        => TransitionAsync(siteId, requestId, async request =>
        {
            await RequireAsync(Permissions.RequestsLinkProduct, cancellationToken);

            var product = await LoadProductAsync(productId, cancellationToken) ?? throw new Core.Exceptions.ValidationException("productId", "Le produit est obligatoire.");
            if (!product.IsActive)
            {
                throw new DomainRuleException(ErrorCodes.ProduitInactif, "Ce produit est désactivé : il ne peut plus être demandé ni livré.");
            }

            if (!product.Allows(request.Unit))
            {
                throw new DomainRuleException(ErrorCodes.UniteNonAutorisee, "Cette unité n'est pas autorisée pour ce produit.");
            }

            if (request.LinkProduct(productId) == TransitionOutcome.AlreadyDone)
            {
                return false;
            }

            events.Add(request, MaterialEventType.ProductLinked, RequestActionContext.Api, changes: [new FieldChange(RequestFieldNames.ProductId, null, productId.ToString())]);
            return true;
        }, cancellationToken);

    public Task<RequestActionResult> ArchiveAsync(Guid siteId, Guid requestId, CancellationToken cancellationToken = default)
        => TransitionAsync(siteId, requestId, async request =>
        {
            await RequireAsync(Permissions.RequestsArchive, cancellationToken);

            if (request.Archive(currentUser.Id ?? throw new NotFoundException(), time.GetUtcNow()) == TransitionOutcome.AlreadyDone)
            {
                return false;
            }

            events.Add(request, MaterialEventType.Archived, RequestActionContext.Api);
            return true;
        }, cancellationToken);

    public Task<RequestActionResult> RestoreAsync(Guid siteId, Guid requestId, CancellationToken cancellationToken = default)
        => TransitionAsync(siteId, requestId, async request =>
        {
            await RequireAsync(Permissions.RequestsArchive, cancellationToken);

            if (request.Restore() == TransitionOutcome.AlreadyDone)
            {
                return false;
            }

            events.Add(request, MaterialEventType.Restored, RequestActionContext.Api);
            return true;
        }, cancellationToken);

    // --- Lots ---

    public Task<BatchResponse> ApproveBatchAsync(Guid siteId, IReadOnlyList<Guid> requestIds, CancellationToken cancellationToken = default)
        => BatchAsync(requestIds, RequestBatchLimits.Approve, id => ApproveAsync(siteId, id, null, null, cancellationToken));

    public Task<BatchResponse> ArchiveBatchAsync(Guid siteId, IReadOnlyList<Guid> requestIds, CancellationToken cancellationToken = default)
        => BatchAsync(requestIds, RequestBatchLimits.Archive, id => ArchiveAsync(siteId, id, cancellationToken));

    /// <summary>Chaque demande est traitee dans sa propre ecriture : un refus ou un conflit n'annule jamais les autres ; un resultat par demande.</summary>
    private async Task<BatchResponse> BatchAsync(IReadOnlyList<Guid> requestIds, int maximum, Func<Guid, Task<RequestActionResult>> action)
    {
        var ids = requestIds.Distinct().ToList();
        if (ids.Count == 0 || ids.Count > maximum)
        {
            throw new Core.Exceptions.ValidationException("requestIds", $"Envoyez entre 1 et {maximum} demandes.");
        }

        var results = new List<BatchItemResult>(ids.Count);
        foreach (var id in ids)
        {
            try
            {
                var result = await action(id);
                results.Add(new BatchItemResult(id, result.Applied ? BatchOutcomes.Applied : BatchOutcomes.Duplicate, null));
            }
            catch (DomainException exception)
            {
                results.Add(new BatchItemResult(id, BatchOutcomes.Rejected, exception.Code));
            }
            catch (DbUpdateConcurrencyException)
            {
                results.Add(new BatchItemResult(id, BatchOutcomes.Rejected, ErrorCodes.ConflitVersion));
            }
            finally
            {
                db.ChangeTracker.Clear();
            }
        }

        return new BatchResponse(results);
    }

    /// <summary>
    /// Charge la demande, applique l'action (qui ajoute ses evenements), puis ecrit. Une validation simultanee de deux conducteurs : le second
    /// perd l'ecriture (<c>rowversion</c>), relit la demande deja validee et rend « deja validee » (jamais deux evenements).
    /// </summary>
    private async Task<RequestActionResult> TransitionAsync(
        Guid siteId,
        Guid requestId,
        Func<MaterialRequest, Task<bool>> action,
        CancellationToken cancellationToken)
        => await DbTransactions.RunAsync(db, async () =>
        {
            await AppLocks.AcquireAsync(db, LockName(requestId), cancellationToken);
            return await TransitionLockedAsync(siteId, requestId, action, cancellationToken);
        }, cancellationToken);

    private static string LockName(Guid requestId) => MaterialLocks.Request(requestId);

    private async Task<RequestActionResult> TransitionLockedAsync(
        Guid siteId,
        Guid requestId,
        Func<MaterialRequest, Task<bool>> action,
        CancellationToken cancellationToken)
    {
        for (var attempt = 1; ; attempt++)
        {
            var request = await LoadAsync(siteId, requestId, cancellationToken);

            if (!await action(request))
            {
                return new RequestActionResult(await DetailAsync(request, cancellationToken), Applied: false);
            }

            // Chantier archive : lecture seule, y compris pour receptionner (H-ARCH-12). Les evenements ajoutes ne sont jamais ecrits.
            await EnsureSiteWritableAsync(siteId, cancellationToken);

            try
            {
                await db.SaveChangesAsync(cancellationToken);
                return new RequestActionResult(await DetailAsync(request, cancellationToken), Applied: true);
            }
            catch (DbUpdateConcurrencyException) when (attempt < MaxAttempts)
            {
                db.ChangeTracker.Clear();
            }
        }
    }

    // --- Outils ---

    private async Task<MaterialRequest> LoadAsync(Guid siteId, Guid requestId, CancellationToken cancellationToken)
        => await requests.FirstOrDefaultAsync(new RequestBySiteAndIdSpecification(siteId, requestId), cancellationToken) ?? throw new NotFoundException();

    private async Task<MaterialRequest?> FindByClientIdAsync(Guid siteId, Guid? clientId, CancellationToken cancellationToken)
        => clientId is { } id && id != Guid.Empty
            ? await requests.FirstOrDefaultAsync(new RequestByClientIdSpecification(siteId, id), cancellationToken)
            : null;

    private async Task<Product?> LoadProductAsync(Guid? productId, CancellationToken cancellationToken)
    {
        if (productId is not { } id)
        {
            return null;
        }

        return await products.GetByIdAsync(id, cancellationToken)
            ?? throw new Core.Exceptions.ValidationException("productId", "Ce produit n'existe pas dans le catalogue.");
    }

    private async Task EnsureZoneAsync(Guid siteId, Guid? zoneId, CancellationToken cancellationToken)
    {
        if (zoneId is { } id && !await zones.AnyAsync(new ZoneBySiteAndIdSpecification(siteId, id), cancellationToken))
        {
            throw new DomainRuleException(ErrorCodes.ZoneHorsChantier, "Cette zone n'appartient pas à ce chantier.");
        }
    }

    /// <summary>Au moins une livraison non annulee rattachee a la demande (le recalcul suit exactement ces livraisons).</summary>
    private Task<bool> HasLiveDeliveryAsync(Guid requestId, CancellationToken cancellationToken)
        => db.Deliveries.AnyAsync(delivery => delivery.RequestId == requestId && delivery.Status == DeliveryStatus.Recorded, cancellationToken);

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
