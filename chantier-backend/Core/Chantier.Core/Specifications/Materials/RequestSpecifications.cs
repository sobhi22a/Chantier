using Ardalis.Specification;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;

namespace Chantier.Core.Specifications.Materials;

/// <summary>Une demande lue par (chantier, identifiant) : jamais par identifiant seul (OWASP API1).</summary>
public sealed class RequestBySiteAndIdSpecification : Specification<MaterialRequest>, ISingleResultSpecification<MaterialRequest>
{
    public RequestBySiteAndIdSpecification(Guid siteId, Guid requestId)
    {
        Query.Where(request => request.SiteId == siteId && request.Id == requestId);
    }
}

/// <summary>Idempotence de la creation hors ligne : demande deja recue pour ce (chantier, <c>clientId</c>).</summary>
public sealed class RequestByClientIdSpecification : Specification<MaterialRequest>, ISingleResultSpecification<MaterialRequest>
{
    public RequestByClientIdSpecification(Guid siteId, Guid clientId)
    {
        Query.Where(request => request.SiteId == siteId && request.ClientId == clientId);
    }
}

/// <summary>
/// Doublon possible (H-MAT-21) : demande encore ouverte (<c>Requested</c> ou <c>Validated</c>) du meme chantier, meme produit du catalogue,
/// meme zone (ou aucune zone). La plus recente d'abord ; avertissement, jamais un blocage.
/// </summary>
public sealed class OpenRequestsForDuplicateSpecification : Specification<MaterialRequest>
{
    public OpenRequestsForDuplicateSpecification(Guid siteId, Guid productId, Guid? zoneId)
    {
        Query.Where(request => request.SiteId == siteId
            && request.ProductId == productId
            && request.ZoneId == zoneId
            && request.ArchivedAt == null
            && (request.Status == RequestStatus.Requested || request.Status == RequestStatus.Validated))
            .OrderByDescending(request => request.CreatedAt)
            .ThenByDescending(request => request.Id)
            .Take(1);
    }
}

/// <summary>Demandes d'un lot (au plus 100) lues par (chantier, identifiants).</summary>
public sealed class RequestsBySiteAndIdsSpecification : Specification<MaterialRequest>
{
    public RequestsBySiteAndIdsSpecification(Guid siteId, IReadOnlyCollection<Guid> ids)
    {
        Query.Where(request => request.SiteId == siteId && ids.Contains(request.Id));
    }
}

/// <summary>
/// Liste des demandes d'un chantier ou de plusieurs (<c>visibleSiteIds</c> : chantiers visibles de l'utilisateur, <c>null</c> = tous pour l'Admin) :
/// une vue du suivi, des filtres et un tri. Tri et pagination ne servent que pour <c>ListAsync</c> ; <c>CountAsync</c> n'evalue que les criteres.
/// </summary>
public sealed class RequestsListSpecification : Specification<MaterialRequest>
{
    private static readonly RequestStatus[] ToFollowStatuses =
        [RequestStatus.Requested, RequestStatus.Validated, RequestStatus.Ordered, RequestStatus.PartiallyDelivered, RequestStatus.Delivered];

    public RequestsListSpecification(
        Guid? siteId,
        IReadOnlyCollection<Guid>? visibleSiteIds,
        string? view,
        Guid? mineUserId,
        RequestStatus? status,
        Priority? priority,
        Guid? zoneId,
        Guid? productId,
        DateOnly? from,
        DateOnly? to,
        string? search,
        IReadOnlyCollection<Guid>? matchingProductIds,
        string sort = "default",
        int page = 1,
        int pageSize = 50,
        DateOnly today = default,
        IReadOnlyCollection<Guid>? supplierRequestIds = null,
        IReadOnlyCollection<Guid>? lateOrderRequestIds = null)
    {
        if (siteId is { } site)
        {
            Query.Where(request => request.SiteId == site);
        }
        else if (visibleSiteIds is { } visible)
        {
            Query.Where(request => visible.Contains(request.SiteId));
        }

        ApplyView(view, status, today, lateOrderRequestIds ?? []);

        if (supplierRequestIds is { } bySupplier)
        {
            // Fournisseur de la commande active : les demandes sont retrouvees par la commande (une lecture a part, jamais une jointure dans la specification).
            Query.Where(request => bySupplier.Contains(request.Id));
        }

        if (mineUserId is { } mine)
        {
            Query.Where(request => request.CreatedBy == mine);
        }

        if (status is { } wantedStatus)
        {
            Query.Where(request => request.Status == wantedStatus);
        }

        if (priority is { } wantedPriority)
        {
            Query.Where(request => request.Priority == wantedPriority);
        }

        if (zoneId is { } zone)
        {
            Query.Where(request => request.ZoneId == zone);
        }

        if (productId is { } product)
        {
            Query.Where(request => request.ProductId == product);
        }

        if (from is { } start)
        {
            Query.Where(request => request.NeededBy >= start);
        }

        if (to is { } end)
        {
            Query.Where(request => request.NeededBy <= end);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var text = search.Trim();
            var number = text.ToUpperInvariant();
            var productIds = matchingProductIds ?? [];
            Query.Where(request => request.Number.Contains(number)
                || (request.ProductId != null && productIds.Contains(request.ProductId.Value))
                || (request.FreeProductName != null && request.FreeProductName.Contains(text))
                || (request.Note != null && request.Note.Contains(text)));
        }

        ApplySort(sort, view);
        Query.Skip((page - 1) * pageSize).Take(pageSize);
    }

    private void ApplyView(string? view, RequestStatus? status, DateOnly today, IReadOnlyCollection<Guid> lateOrderRequestIds)
    {
        switch (view)
        {
            case RequestViews.Late:
                // En retard : date de besoin depassee, ou commande attendue dont la livraison prevue est depassee (les demandes livrees ou closes ne sont jamais en retard).
                Query.Where(request => request.ArchivedAt == null
                    && (request.Status == RequestStatus.Requested || request.Status == RequestStatus.Validated
                        || request.Status == RequestStatus.Ordered || request.Status == RequestStatus.PartiallyDelivered)
                    && (request.NeededBy < today
                        || ((request.Status == RequestStatus.Ordered || request.Status == RequestStatus.PartiallyDelivered) && lateOrderRequestIds.Contains(request.Id))));
                return;

            case RequestViews.Archived:
                Query.Where(request => request.ArchivedAt != null);
                return;

            case RequestViews.ToApprove:
                Query.Where(request => request.ArchivedAt == null && request.Status == RequestStatus.Requested);
                return;

            case RequestViews.ToOrder:
                Query.Where(request => request.ArchivedAt == null && request.Status == RequestStatus.Validated);
                return;

            case RequestViews.Expected:
                Query.Where(request => request.ArchivedAt == null
                    && (request.Status == RequestStatus.Ordered || request.Status == RequestStatus.PartiallyDelivered));
                return;

            case RequestViews.ToReceive:
                Query.Where(request => request.ArchivedAt == null && request.Status == RequestStatus.Delivered);
                return;

            case RequestViews.Received:
                Query.Where(request => request.ArchivedAt == null && request.Status == RequestStatus.Received);
                return;

            case RequestViews.Closed:
                Query.Where(request => request.ArchivedAt == null
                    && (request.Status == RequestStatus.Rejected || request.Status == RequestStatus.Cancelled));
                return;

            default:
                // Vue par defaut « a suivre » ; un statut explicite sans vue n'est pas limite par elle (archivees exclues dans les deux cas).
                Query.Where(request => request.ArchivedAt == null);
                if (status is null)
                {
                    Query.Where(request => ToFollowStatuses.Contains(request.Status));
                }

                return;
        }
    }

    private void ApplySort(string sort, string? view)
    {
        switch (sort)
        {
            case "neededBy":
                Query.OrderBy(request => request.NeededBy).ThenBy(request => request.Number);
                break;
            case "-neededBy":
                Query.OrderByDescending(request => request.NeededBy).ThenBy(request => request.Number);
                break;
            case "number":
                Query.OrderBy(request => request.Number);
                break;
            case "-number":
                Query.OrderByDescending(request => request.Number);
                break;
            case "createdAt":
                Query.OrderBy(request => request.CreatedAt).ThenBy(request => request.Id);
                break;
            case "-createdAt":
                Query.OrderByDescending(request => request.CreatedAt).ThenBy(request => request.Id);
                break;
            case "priority":
                OrderByUrgency();
                break;
            default:
                // « A suivre » : les plus urgentes d'abord ; les autres vues : par date de besoin.
                if (view is null or RequestViews.ToFollow)
                {
                    OrderByUrgency();
                }
                else
                {
                    Query.OrderBy(request => request.NeededBy).ThenBy(request => request.Number).ThenBy(request => request.Id);
                }

                break;
        }
    }

    private void OrderByUrgency()
        => Query.OrderByDescending(request => request.Priority == Priority.Blocking ? 2 : request.Priority == Priority.Urgent ? 1 : 0)
            .ThenBy(request => request.NeededBy)
            .ThenBy(request => request.Number)
            .ThenBy(request => request.Id);
}
