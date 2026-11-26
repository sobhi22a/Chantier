using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Core.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// Construit les reponses des demandes (liste, detail, synchronisation) avec des lectures groupees : un chantier, un produit, un doublon
/// ou un utilisateur n'est jamais relu par ligne (pas de N+1). Un seul endroit pour les calculs d'affichage (recu, reste, ecart, retard).
/// <c>includeCommercial</c> : l'appelant a <c>Prices.View</c> ; sans lui, aucun prix ni montant, aucun evenement sensible. La synchronisation ne le demande jamais.
/// </summary>
public sealed class RequestProjector(ApplicationDbContext db, IUserDirectory directory, TimeProvider time)
{
    public async Task<IReadOnlyList<MaterialRequestResponse>> ToResponsesAsync(
        IReadOnlyCollection<MaterialRequest> requests,
        bool includeSiteCode,
        bool includeCommercial,
        CancellationToken cancellationToken = default)
    {
        var lookups = await LoadAsync(requests, includeSiteCode, includeCommercial, includeDeliveries: false, cancellationToken);
        return requests.Select(request => Map(request, lookups)).ToList();
    }

    /// <summary>
    /// Detail avec historique et livraisons. <paramref name="includeCommercial"/> : prix, montants et evenements reserves aux roles qui voient les prix (jamais en synchronisation).
    /// <paramref name="includeDeliveries"/> : faux pour la synchronisation (l'entite <c>delivery</c> porte les livraisons).
    /// </summary>
    public async Task<IReadOnlyList<MaterialRequestDetailResponse>> ToDetailsAsync(
        IReadOnlyCollection<MaterialRequest> requests,
        bool includeSiteCode,
        bool includeCommercial,
        bool includeDeliveries = true,
        CancellationToken cancellationToken = default,
        bool includeHistory = true)
    {
        if (requests.Count == 0)
        {
            return [];
        }

        // Synchronisation : aucun historique (R2-02), donc aucune lecture des evenements ; il se lit a la demande par le detail.
        var ids = requests.Select(request => request.Id).ToList();
        var events = !includeHistory
            ? []
            : await db.MaterialEvents.AsNoTracking()
                .Where(materialEvent => materialEvent.SubjectType == MaterialSubjectType.Request && ids.Contains(materialEvent.SubjectId))
                .OrderBy(materialEvent => materialEvent.CreatedAt).ThenBy(materialEvent => materialEvent.RowVersion)
                .ToListAsync(cancellationToken);

        if (!includeCommercial)
        {
            events = events.Where(materialEvent => !materialEvent.IsSensitive).ToList();
        }

        var lookups = await LoadAsync(requests, includeSiteCode, includeCommercial, includeDeliveries, cancellationToken, events.Select(materialEvent => materialEvent.CreatedBy));
        var byRequest = events.ToLookup(materialEvent => materialEvent.SubjectId);

        return requests
            .Select(request => new MaterialRequestDetailResponse(Map(request, lookups))
            {
                History = byRequest[request.Id].Select(materialEvent => ToHistoryItem(materialEvent, lookups.Names)).ToList(),
                Deliveries = includeDeliveries ? lookups.DeliveriesByRequest[request.Id].Select(delivery => ToDeliveryItem(delivery, request.Unit)).ToList() : null,
            })
            .ToList();
    }

    public async Task<MaterialRequestDetailResponse> ToDetailAsync(
        MaterialRequest request,
        bool includeSiteCode,
        bool includeCommercial,
        CancellationToken cancellationToken = default)
        => (await ToDetailsAsync([request], includeSiteCode, includeCommercial, includeDeliveries: true, cancellationToken))[0];

    private static RequestDeliveryItem ToDeliveryItem(Delivery delivery, MeasureUnit requestUnit) => new(
        delivery.Id,
        delivery.Number,
        delivery.DeliveryDate,
        Quantity.Of(delivery.QuantityValue, delivery.Unit),
        delivery.QuantityInRequestUnit is { } converted && !delivery.IsCancelled ? Quantity.Of(converted, requestUnit) : null,
        delivery.Status,
        delivery.DeliveryNoteNumber,
        delivery.Conformity,
        delivery.PhotoCount);

    internal static RequestHistoryItem ToHistoryItem(MaterialEvent materialEvent, IReadOnlyDictionary<Guid, string> names) => new(
        materialEvent.Id,
        materialEvent.Type,
        materialEvent.FromStatus,
        materialEvent.ToStatus,
        materialEvent.ReasonCode,
        materialEvent.ReasonNote,
        materialEvent.Changes,
        names.TryGetValue(materialEvent.CreatedBy, out var name) ? name : null,
        materialEvent.CreatedAt,
        materialEvent.DeviceAt,
        materialEvent.Source);

    private MaterialRequestResponse Map(MaterialRequest request, Lookups lookups)
    {
        lookups.Products.TryGetValue(request.ProductId ?? Guid.Empty, out var product);
        lookups.DuplicateNumbers.TryGetValue(request.PossibleDuplicateOfId ?? Guid.Empty, out var duplicateNumber);
        var counted = request.Status is RequestStatus.Ordered or RequestStatus.PartiallyDelivered or RequestStatus.Delivered or RequestStatus.Received;

        // Une demande validee dont une livraison est deja retenue montre son recu (badge « Livraison recue sans commande enregistree »).
        var retained = request.Status == RequestStatus.Validated && request.ReceivedQuantity > 0m;
        var ordered = request.QuantityValue;
        var received = request.ReceivedQuantity;
        var variance = received - ordered;

        return new MaterialRequestResponse
        {
            Id = request.Id,
            SiteId = request.SiteId,
            SiteCode = lookups.SiteCodes.GetValueOrDefault(request.SiteId),
            ClientId = request.ClientId,
            ClientCreatedAt = request.ClientCreatedAt,
            Number = request.Number,
            Product = new ProductRefResponse(request.ProductId, product?.NameFr, product?.NameAr, request.FreeProductName),
            Quantity = Quantity.Of(ordered, request.Unit),
            ZoneId = request.ZoneId,
            NeededBy = request.NeededBy,
            Priority = request.Priority,
            Note = request.Note,
            Status = request.Status,
            StatusReason = request.Status is RequestStatus.Rejected or RequestStatus.Cancelled && request.StatusReasonCode is { } code
                ? new StatusReasonResponse(code, request.StatusReasonNote)
                : null,
            ReceivedQuantity = counted || retained ? Quantity.Of(received, request.Unit) : null,
            RemainingQuantity = counted ? Quantity.Of(Math.Max(0m, ordered - received), request.Unit) : null,
            Variance = counted
                ? new VarianceResponse(
                    DecimalScale.Normalize(variance),
                    request.Unit,
                    ordered > 0m ? Math.Round(variance / ordered * 100m, 2, MidpointRounding.AwayFromZero) : 0m)
                : null,
            IsSettled = request.IsSettled,
            OverdueDays = IsOverdueEligible(request.Status) ? OverdueCalculator.Days(request.NeededBy, lookups.Today) : 0,
            PossibleDuplicateOf = request.PossibleDuplicateOfId is { } duplicateId && duplicateNumber is not null
                ? new DuplicateRefResponse(duplicateId, duplicateNumber)
                : null,
            Order = lookups.Orders.TryGetValue(request.Id, out var order) ? ToOrderResponse(order, request, lookups) : null,
            HasDeliveryWithoutOrder = retained,
            RequestedById = request.CreatedBy,
            RequestedByName = lookups.Names.GetValueOrDefault(request.CreatedBy),
            ArchivedAt = request.ArchivedAt,
            ArchivedByName = request.ArchivedBy is { } archivedBy ? lookups.Names.GetValueOrDefault(archivedBy) : null,
            Version = request.Version,
            CreatedAt = request.CreatedAt,
            CreatedByName = lookups.Names.GetValueOrDefault(request.CreatedBy),
            UpdatedAt = request.UpdatedAt,
            UpdatedByName = request.UpdatedBy is { } updatedBy ? lookups.Names.GetValueOrDefault(updatedBy) : null,
        };
    }

    private static OrderResponse ToOrderResponse(MaterialOrder order, MaterialRequest request, Lookups lookups) => new(
        order.Id,
        order.SupplierId,
        lookups.SupplierNames.GetValueOrDefault(order.SupplierId),
        order.OrderDate,
        order.ExpectedDeliveryDate,
        OrderRules.PlannedAfterNeedDays(request.NeededBy, order.ExpectedDeliveryDate),
        order.Note,
        order.Version)
    {
        Commercial = CommercialProjection.ForOrder(order, lookups.ReceivedValues.GetValueOrDefault(request.Id), lookups.IncludeCommercial),
    };

    /// <summary>Retard : demandee, validee, commandee ou livree partiellement (une demande livree n'est plus en retard).</summary>
    private static bool IsOverdueEligible(RequestStatus status)
        => status is RequestStatus.Requested or RequestStatus.Validated or RequestStatus.Ordered or RequestStatus.PartiallyDelivered;

    private async Task<Lookups> LoadAsync(
        IReadOnlyCollection<MaterialRequest> requests,
        bool includeSiteCode,
        bool includeCommercial,
        bool includeDeliveries,
        CancellationToken cancellationToken,
        IEnumerable<Guid>? extraUsers = null)
    {
        var productIds = requests.Where(request => request.ProductId is not null).Select(request => request.ProductId!.Value).Distinct().ToList();
        var duplicateIds = requests.Where(request => request.PossibleDuplicateOfId is not null).Select(request => request.PossibleDuplicateOfId!.Value).Distinct().ToList();
        var siteIds = requests.Select(request => request.SiteId).Distinct().ToList();

        var products = productIds.Count == 0
            ? new Dictionary<Guid, Product>()
            : await db.Products.AsNoTracking().Where(product => productIds.Contains(product.Id)).ToDictionaryAsync(product => product.Id, cancellationToken);

        var duplicateNumbers = duplicateIds.Count == 0
            ? new Dictionary<Guid, string>()
            : await db.MaterialRequests.AsNoTracking().Where(request => duplicateIds.Contains(request.Id))
                .ToDictionaryAsync(request => request.Id, request => request.Number, cancellationToken);

        var siteCodes = !includeSiteCode
            ? new Dictionary<Guid, string>()
            : await db.Sites.AsNoTracking().Where(site => siteIds.Contains(site.Id)).ToDictionaryAsync(site => site.Id, site => site.Code, cancellationToken);

        var userIds = requests
            .SelectMany(request => new[] { request.CreatedBy, request.UpdatedBy, request.ArchivedBy }.OfType<Guid>())
            .Concat(extraUsers ?? []);
        var names = await directory.GetNamesAsync(userIds, cancellationToken);

        // Commandes actives (une par demande) et leurs fournisseurs : une lecture groupee pour toute la page.
        var requestIds = requests.Select(request => request.Id).ToList();
        var orders = await db.MaterialOrders.AsNoTracking()
            .Where(order => requestIds.Contains(order.RequestId) && order.CancelledAt == null)
            .ToDictionaryAsync(order => order.RequestId, cancellationToken);
        var supplierIds = orders.Values.Select(order => order.SupplierId).Distinct().ToList();
        var supplierNames = supplierIds.Count == 0
            ? new Dictionary<Guid, string>()
            : await db.Suppliers.AsNoTracking().Where(supplier => supplierIds.Contains(supplier.Id)).ToDictionaryAsync(supplier => supplier.Id, supplier => supplier.Name, cancellationToken);

        // Valeur recue (somme des montants arrondis des livraisons) : seulement pour qui voit les prix.
        var receivedValues = !includeCommercial || orders.Count == 0
            ? new Dictionary<Guid, decimal>()
            : (await db.Deliveries.AsNoTracking()
                .Where(delivery => delivery.RequestId != null && requestIds.Contains(delivery.RequestId.Value) && delivery.Status == DeliveryStatus.Recorded && delivery.Amount != null)
                .GroupBy(delivery => delivery.RequestId!.Value)
                .Select(group => new { RequestId = group.Key, Value = group.Sum(delivery => delivery.Amount!.Value) })
                .ToListAsync(cancellationToken))
                .ToDictionary(row => row.RequestId, row => row.Value);

        var deliveries = !includeDeliveries
            ? Enumerable.Empty<Delivery>().ToLookup(delivery => Guid.Empty)
            : (await db.Deliveries.AsNoTracking()
                .Where(delivery => delivery.RequestId != null && requestIds.Contains(delivery.RequestId.Value))
                .OrderBy(delivery => delivery.DeliveryDate).ThenBy(delivery => delivery.CreatedAt).ThenBy(delivery => delivery.RowVersion)
                .ToListAsync(cancellationToken))
                .ToLookup(delivery => delivery.RequestId!.Value);

        return new Lookups(products, duplicateNumbers, siteCodes, names, AlgeriaDate.Today(time), orders, supplierNames, receivedValues, deliveries, includeCommercial);
    }

    private sealed record Lookups(
        Dictionary<Guid, Product> Products,
        Dictionary<Guid, string> DuplicateNumbers,
        Dictionary<Guid, string> SiteCodes,
        IReadOnlyDictionary<Guid, string> Names,
        DateOnly Today,
        Dictionary<Guid, MaterialOrder> Orders,
        Dictionary<Guid, string> SupplierNames,
        Dictionary<Guid, decimal> ReceivedValues,
        ILookup<Guid, Delivery> DeliveriesByRequest,
        bool IncludeCommercial);
}
