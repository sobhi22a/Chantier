using Ardalis.Specification;
using Chantier.Core.Entities.Materials;

namespace Chantier.Core.Specifications.Materials;

/// <summary>Une livraison lue par (chantier, identifiant) : jamais par identifiant seul (OWASP API1).</summary>
public sealed class DeliveryBySiteAndIdSpecification : Specification<Delivery>, ISingleResultSpecification<Delivery>
{
    public DeliveryBySiteAndIdSpecification(Guid siteId, Guid deliveryId)
    {
        Query.Where(delivery => delivery.SiteId == siteId && delivery.Id == deliveryId);
    }
}

/// <summary>Idempotence de la creation hors ligne : livraison deja recue pour ce (chantier, <c>clientId</c>).</summary>
public sealed class DeliveryByClientIdSpecification : Specification<Delivery>, ISingleResultSpecification<Delivery>
{
    public DeliveryByClientIdSpecification(Guid siteId, Guid clientId)
    {
        Query.Where(delivery => delivery.SiteId == siteId && delivery.ClientId == clientId);
    }
}

/// <summary>
/// Doublon de bon de livraison : meme chantier, meme fournisseur, meme produit et meme n° de BL qu'une livraison non annulee (la plus ancienne). Avertissement,
/// jamais un blocage. Le fournisseur et le produit se comparent par identifiant du catalogue, ou par nom libre.
/// </summary>
public sealed class DeliveryDuplicateSpecification : Specification<Delivery>, ISingleResultSpecification<Delivery>
{
    public DeliveryDuplicateSpecification(Guid siteId, Guid? supplierId, string? freeSupplierName, Guid? productId, string? freeProductName, string deliveryNoteNumber, Guid? exceptId = null)
    {
        Query.Where(delivery => delivery.SiteId == siteId
            && delivery.Status == DeliveryStatus.Recorded
            && delivery.DeliveryNoteNumber == deliveryNoteNumber
            && delivery.SupplierId == supplierId
            && delivery.FreeSupplierName == freeSupplierName
            && delivery.ProductId == productId
            && delivery.FreeProductName == freeProductName
            && (exceptId == null || delivery.Id != exceptId))
            .OrderBy(delivery => delivery.CreatedAt)
            .ThenBy(delivery => delivery.RowVersion)
            .Take(1);
    }
}

/// <summary>
/// Liste des livraisons d'un chantier : filtres (demande, non rattachees, avec reserve, BL manquant, statut, fournisseur, produit, periode), recherche
/// (numero <c>LIV-006</c>, n° de BL, produit, fournisseur) et tri. Tri et pagination ne servent que pour <c>ListAsync</c> : <c>CountAsync</c> n'evalue que les criteres.
/// </summary>
public sealed class DeliveriesListSpecification : Specification<Delivery>
{
    public static readonly string[] SortValues = ["default", "deliveryDate", "-deliveryDate", "number", "-number"];

    public DeliveriesListSpecification(
        Guid siteId,
        Guid? requestId,
        bool? unattached,
        bool? withReserve,
        bool? missingNote,
        DeliveryStatus? status,
        Guid? supplierId,
        Guid? productId,
        string? search,
        IReadOnlyCollection<Guid>? matchingProductIds,
        IReadOnlyCollection<Guid>? matchingSupplierIds,
        DateOnly? from,
        DateOnly? to,
        string sort = "default",
        int page = 1,
        int pageSize = 50)
    {
        Query.Where(delivery => delivery.SiteId == siteId);

        if (requestId is { } request)
        {
            Query.Where(delivery => delivery.RequestId == request);
        }

        if (unattached == true)
        {
            // « A traiter » : une livraison annulee n'a plus rien a rattacher.
            Query.Where(delivery => delivery.RequestId == null && delivery.Status == DeliveryStatus.Recorded);
        }

        if (withReserve == true)
        {
            Query.Where(delivery => delivery.Conformity == Conformity.WithReserve && delivery.Status == DeliveryStatus.Recorded);
        }

        if (missingNote == true)
        {
            Query.Where(delivery => delivery.DeliveryNoteNumber == null && delivery.PhotoCount == 0 && delivery.Status == DeliveryStatus.Recorded);
        }

        if (status is { } wantedStatus)
        {
            Query.Where(delivery => delivery.Status == wantedStatus);
        }

        if (supplierId is { } supplier)
        {
            Query.Where(delivery => delivery.SupplierId == supplier);
        }

        if (productId is { } product)
        {
            Query.Where(delivery => delivery.ProductId == product);
        }

        if (from is { } start)
        {
            Query.Where(delivery => delivery.DeliveryDate >= start);
        }

        if (to is { } end)
        {
            Query.Where(delivery => delivery.DeliveryDate <= end);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var text = search.Trim();
            var upper = text.ToUpperInvariant();
            var productIds = matchingProductIds ?? [];
            var supplierIds = matchingSupplierIds ?? [];
            Query.Where(delivery => delivery.Number.Contains(upper)
                || (delivery.DeliveryNoteNumber != null && delivery.DeliveryNoteNumber.Contains(upper))
                || (delivery.ProductId != null && productIds.Contains(delivery.ProductId.Value))
                || (delivery.SupplierId != null && supplierIds.Contains(delivery.SupplierId.Value))
                || (delivery.FreeProductName != null && delivery.FreeProductName.Contains(text))
                || (delivery.FreeSupplierName != null && delivery.FreeSupplierName.Contains(text)));
        }

        switch (sort)
        {
            case "deliveryDate":
                Query.OrderBy(delivery => delivery.DeliveryDate).ThenBy(delivery => delivery.Number).ThenBy(delivery => delivery.Id);
                break;
            case "number":
                Query.OrderBy(delivery => delivery.Number);
                break;
            case "-number":
                Query.OrderByDescending(delivery => delivery.Number);
                break;
            default:
                // Les plus recentes d'abord (date de livraison, puis ordre de creation).
                Query.OrderByDescending(delivery => delivery.DeliveryDate).ThenByDescending(delivery => delivery.CreatedAt).ThenBy(delivery => delivery.Id);
                break;
        }

        Query.Skip((page - 1) * pageSize).Take(pageSize);
    }
}

/// <summary>Une photo lue par (chantier, identifiant) : jamais par identifiant seul (OWASP API1).</summary>
public sealed class PhotoBySiteAndIdSpecification : Specification<Photo>, ISingleResultSpecification<Photo>
{
    public PhotoBySiteAndIdSpecification(Guid siteId, Guid photoId)
    {
        Query.Where(photo => photo.SiteId == siteId && photo.Id == photoId);
    }
}

/// <summary>Idempotence des metadonnees : photo deja recue pour ce (chantier, <c>clientId</c>).</summary>
public sealed class PhotoByClientIdSpecification : Specification<Photo>, ISingleResultSpecification<Photo>
{
    public PhotoByClientIdSpecification(Guid siteId, Guid clientId)
    {
        Query.Where(photo => photo.SiteId == siteId && photo.ClientId == clientId);
    }
}
