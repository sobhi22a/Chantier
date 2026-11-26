using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Core.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// Construit les reponses des livraisons (liste, detail, synchronisation) avec des lectures groupees : une demande, un produit, un fournisseur, une photo ou un
/// utilisateur n'est jamais relu par ligne (pas de N+1). <c>includeCommercial</c> : l'appelant a <c>Prices.View</c> (sinon aucun montant) ; <c>includePhotos</c> :
/// l'appelant a <c>DeliveryPhotos.View</c> (sinon la liste des photos est absente). La synchronisation ne demande ni l'un ni l'autre.
/// </summary>
public sealed class DeliveryProjector(ApplicationDbContext db, IUserDirectory directory)
{
    public async Task<IReadOnlyList<DeliveryResponse>> ToResponsesAsync(
        IReadOnlyCollection<Delivery> deliveries,
        bool includeCommercial,
        bool includePhotos,
        CancellationToken cancellationToken = default)
    {
        var lookups = await LoadAsync(deliveries, includePhotos, cancellationToken);
        return deliveries.Select(delivery => Map(delivery, lookups, includeCommercial, includePhotos)).ToList();
    }

    public async Task<IReadOnlyList<DeliveryDetailResponse>> ToDetailsAsync(
        IReadOnlyCollection<Delivery> deliveries,
        bool includeCommercial,
        bool includePhotos,
        CancellationToken cancellationToken = default,
        bool includeHistory = true)
    {
        if (deliveries.Count == 0)
        {
            return [];
        }

        // Synchronisation : aucun historique (R2-02), donc aucune lecture des evenements.
        var ids = deliveries.Select(delivery => delivery.Id).ToList();
        var events = !includeHistory
            ? []
            : await db.MaterialEvents.AsNoTracking()
                .Where(materialEvent => materialEvent.SubjectType == MaterialSubjectType.Delivery && ids.Contains(materialEvent.SubjectId))
                .OrderBy(materialEvent => materialEvent.CreatedAt).ThenBy(materialEvent => materialEvent.RowVersion)
                .ToListAsync(cancellationToken);

        var lookups = await LoadAsync(deliveries, includePhotos, cancellationToken, events.Select(materialEvent => materialEvent.CreatedBy));
        var byDelivery = events.ToLookup(materialEvent => materialEvent.SubjectId);

        return deliveries
            .Select(delivery => new DeliveryDetailResponse(Map(delivery, lookups, includeCommercial, includePhotos))
            {
                History = byDelivery[delivery.Id].Select(materialEvent => RequestProjector.ToHistoryItem(materialEvent, lookups.Names)).ToList(),
            })
            .ToList();
    }

    public async Task<DeliveryDetailResponse> ToDetailAsync(Delivery delivery, bool includeCommercial, bool includePhotos, CancellationToken cancellationToken = default)
        => (await ToDetailsAsync([delivery], includeCommercial, includePhotos, cancellationToken))[0];

    private static DeliveryResponse Map(Delivery delivery, Lookups lookups, bool includeCommercial, bool includePhotos)
    {
        lookups.Products.TryGetValue(delivery.ProductId ?? Guid.Empty, out var product);
        lookups.Requests.TryGetValue(delivery.RequestId ?? Guid.Empty, out var request);
        lookups.DuplicateNumbers.TryGetValue(delivery.PossibleDuplicateOfId ?? Guid.Empty, out var duplicateNumber);

        return new DeliveryResponse
        {
            Id = delivery.Id,
            SiteId = delivery.SiteId,
            ClientId = delivery.ClientId,
            ClientCreatedAt = delivery.ClientCreatedAt,
            Number = delivery.Number,
            RequestId = delivery.RequestId,
            RequestNumber = request?.Number,
            UnattachedReason = delivery.UnattachedReason,
            SupplierId = delivery.SupplierId,
            SupplierName = delivery.SupplierId is { } supplierId ? lookups.SupplierNames.GetValueOrDefault(supplierId) : null,
            FreeSupplierName = delivery.FreeSupplierName,
            Product = new ProductRefResponse(delivery.ProductId, product?.NameFr, product?.NameAr, delivery.FreeProductName),
            Quantity = Quantity.Of(delivery.QuantityValue, delivery.Unit),
            QuantityInRequestUnit = delivery.QuantityInRequestUnit is { } converted && request is not null && !delivery.IsCancelled
                ? Quantity.Of(converted, request.Unit)
                : null,
            DeliveryDate = delivery.DeliveryDate,
            DeliveryNoteNumber = delivery.DeliveryNoteNumber,
            MissingNote = delivery.IsNoteMissing,
            Conformity = delivery.Conformity,
            Reserve = delivery.ReserveReasonCode is { } code ? new ReserveResponse(code, delivery.ReserveNote) : null,
            Status = delivery.Status,
            CancelReason = delivery.CancelReasonCode is { } cancelCode ? new StatusReasonResponse(cancelCode, delivery.CancelReasonNote) : null,
            PossibleDuplicateOf = delivery.PossibleDuplicateOfId is { } duplicateId && duplicateNumber is not null ? new DuplicateRefResponse(duplicateId, duplicateNumber) : null,
            PhotoCount = delivery.PhotoCount,
            Photos = includePhotos ? lookups.PhotosByDelivery[delivery.Id].Select(photo => new DeliveryPhotoItem(photo.Id, photo.ContentStatus, photo.SizeBytes, photo.TakenAt)).ToList() : null,

            // Un montant d'une livraison annulee ne signifie plus rien (cache non recalcule) : jamais rendu.
            Commercial = delivery.IsCancelled ? null : CommercialProjection.ForDelivery(delivery, includeCommercial),
            Version = delivery.Version,
            CreatedAt = delivery.CreatedAt,
            CreatedByName = lookups.Names.GetValueOrDefault(delivery.CreatedBy),
            UpdatedAt = delivery.UpdatedAt,
            UpdatedByName = delivery.UpdatedBy is { } updatedBy ? lookups.Names.GetValueOrDefault(updatedBy) : null,
        };
    }

    private async Task<Lookups> LoadAsync(
        IReadOnlyCollection<Delivery> deliveries,
        bool includePhotos,
        CancellationToken cancellationToken,
        IEnumerable<Guid>? extraUsers = null)
    {
        var productIds = deliveries.Where(delivery => delivery.ProductId is not null).Select(delivery => delivery.ProductId!.Value).Distinct().ToList();
        var supplierIds = deliveries.Where(delivery => delivery.SupplierId is not null).Select(delivery => delivery.SupplierId!.Value).Distinct().ToList();
        var requestIds = deliveries.Where(delivery => delivery.RequestId is not null).Select(delivery => delivery.RequestId!.Value).Distinct().ToList();
        var duplicateIds = deliveries.Where(delivery => delivery.PossibleDuplicateOfId is not null).Select(delivery => delivery.PossibleDuplicateOfId!.Value).Distinct().ToList();
        var deliveryIds = deliveries.Select(delivery => delivery.Id).ToList();

        var products = productIds.Count == 0
            ? new Dictionary<Guid, Product>()
            : await db.Products.AsNoTracking().Where(product => productIds.Contains(product.Id)).ToDictionaryAsync(product => product.Id, cancellationToken);

        var supplierNames = supplierIds.Count == 0
            ? new Dictionary<Guid, string>()
            : await db.Suppliers.AsNoTracking().Where(supplier => supplierIds.Contains(supplier.Id)).ToDictionaryAsync(supplier => supplier.Id, supplier => supplier.Name, cancellationToken);

        var requests = requestIds.Count == 0
            ? new Dictionary<Guid, RequestRef>()
            : await db.MaterialRequests.AsNoTracking().Where(request => requestIds.Contains(request.Id))
                .ToDictionaryAsync(request => request.Id, request => new RequestRef(request.Number, request.Unit), cancellationToken);

        var duplicateNumbers = duplicateIds.Count == 0
            ? new Dictionary<Guid, string>()
            : await db.Deliveries.AsNoTracking().Where(delivery => duplicateIds.Contains(delivery.Id))
                .ToDictionaryAsync(delivery => delivery.Id, delivery => delivery.Number, cancellationToken);

        var photos = !includePhotos
            ? Enumerable.Empty<Photo>().ToLookup(photo => Guid.Empty)
            : (await db.Photos.AsNoTracking().Where(photo => deliveryIds.Contains(photo.DeliveryId))
                .OrderBy(photo => photo.CreatedAt).ThenBy(photo => photo.RowVersion)
                .ToListAsync(cancellationToken))
                .ToLookup(photo => photo.DeliveryId);

        var userIds = deliveries
            .SelectMany(delivery => new[] { delivery.CreatedBy, delivery.UpdatedBy }.OfType<Guid>())
            .Concat(extraUsers ?? []);
        var names = await directory.GetNamesAsync(userIds, cancellationToken);

        return new Lookups(products, supplierNames, requests, duplicateNumbers, photos, names);
    }

    private sealed record RequestRef(string Number, MeasureUnit Unit);

    private sealed record Lookups(
        Dictionary<Guid, Product> Products,
        Dictionary<Guid, string> SupplierNames,
        Dictionary<Guid, RequestRef> Requests,
        Dictionary<Guid, string> DuplicateNumbers,
        ILookup<Guid, Photo> PhotosByDelivery,
        IReadOnlyDictionary<Guid, string> Names);
}
