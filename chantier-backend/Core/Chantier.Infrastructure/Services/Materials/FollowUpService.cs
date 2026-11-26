using Chantier.Core.Abstractions;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// Suivi d'un chantier : compteurs des cinq vues, totaux « a commander » par produit et famille d'unites (<see cref="QuantityAggregator"/> : 400 sacs = 20 T, jamais
/// m3 + T) et montants (<c>commercial</c>, seulement avec <c>Prices.View</c>). Toutes les lectures sont des agregats SQL sur des index (<c>SiteId, Status, ...</c>) :
/// aucune demande n'est chargee en entier, seules les demandes « a commander » (colonnes de quantite) servent aux totaux.
/// </summary>
public sealed class FollowUpService(ApplicationDbContext db, IUserPermissions permissions, TimeProvider time) : IFollowUpService
{
    public async Task<FollowUpResponse> GetAsync(Guid siteId, CancellationToken cancellationToken = default)
    {
        if (!await permissions.HasAsync(Permissions.RequestsView, cancellationToken))
        {
            throw new ForbiddenException();
        }

        var today = AlgeriaDate.Today(time);
        var open = db.MaterialRequests.AsNoTracking().Where(request => request.SiteId == siteId && request.ArchivedAt == null);

        var byStatus = await open
            .GroupBy(request => request.Status)
            .Select(group => new { Status = group.Key, Count = group.Count() })
            .ToListAsync(cancellationToken);
        int CountOf(params RequestStatus[] statuses) => byStatus.Where(row => statuses.Contains(row.Status)).Sum(row => row.Count);

        // En retard : date de besoin depassee, ou commande attendue dont la livraison prevue est depassee (meme definition que la vue « late »).
        var lateOrderIds = db.MaterialOrders.AsNoTracking()
            .Where(order => order.SiteId == siteId && order.CancelledAt == null && order.ExpectedDeliveryDate < today)
            .Select(order => order.RequestId);
        var late = await open.CountAsync(
            request => (request.Status == RequestStatus.Requested || request.Status == RequestStatus.Validated
                    || request.Status == RequestStatus.Ordered || request.Status == RequestStatus.PartiallyDelivered)
                && (request.NeededBy < today
                    || ((request.Status == RequestStatus.Ordered || request.Status == RequestStatus.PartiallyDelivered) && lateOrderIds.Contains(request.Id))),
            cancellationToken);

        var counters = new FollowUpCounters(
            CountOf(RequestStatus.Requested),
            CountOf(RequestStatus.Validated),
            CountOf(RequestStatus.Ordered, RequestStatus.PartiallyDelivered),
            late,
            CountOf(RequestStatus.Delivered));

        var totals = await ToOrderTotalsAsync(open, cancellationToken);

        FollowUpCommercialResponse? commercial = null;
        var canViewPrices = await permissions.HasAsync(Permissions.PricesView, cancellationToken);
        if (canViewPrices)
        {
            var orderedAmount = await db.MaterialOrders.AsNoTracking()
                .Where(order => order.SiteId == siteId && order.CancelledAt == null && order.Amount != null)
                .SumAsync(order => order.Amount!.Value, cancellationToken);
            var receivedValue = await db.Deliveries.AsNoTracking()
                .Where(delivery => delivery.SiteId == siteId && delivery.Status == DeliveryStatus.Recorded && delivery.RequestId != null && delivery.Amount != null)
                .SumAsync(delivery => delivery.Amount!.Value, cancellationToken);
            commercial = CommercialProjection.ForFollowUp(orderedAmount, receivedValue, canViewPrices);
        }

        return new FollowUpResponse(counters, totals) { Commercial = commercial };
    }

    private async Task<IReadOnlyList<ToOrderTotalLine>> ToOrderTotalsAsync(IQueryable<MaterialRequest> open, CancellationToken cancellationToken)
    {
        var toOrder = await open
            .Where(request => request.Status == RequestStatus.Validated)
            .Select(request => new { request.ProductId, request.FreeProductName, request.QuantityValue, request.Unit })
            .ToListAsync(cancellationToken);
        if (toOrder.Count == 0)
        {
            return [];
        }

        var productIds = toOrder.Where(row => row.ProductId is not null).Select(row => row.ProductId!.Value).Distinct().ToList();
        var catalogue = await db.Products.AsNoTracking().Where(product => productIds.Contains(product.Id)).ToDictionaryAsync(product => product.Id, cancellationToken);

        var lines = new List<ToOrderTotalLine>();

        foreach (var group in toOrder.Where(row => row.ProductId is not null).GroupBy(row => row.ProductId!.Value))
        {
            var product = catalogue[group.Key];
            var requests = group.ToList();
            var sums = QuantityAggregator.Aggregate(requests.Select(row => new Quantity(row.QuantityValue, row.Unit)), product.DefaultUnit, product.BagMassKg);

            // Nombre de demandes par ligne : celles dont l'unite se convertit dans l'unite de la ligne.
            foreach (var sum in sums)
            {
                var count = requests.Count(row => UnitConverter.CanConvert(row.Unit, sum.Total.Unit, product.BagMassKg));
                lines.Add(new ToOrderTotalLine(product.Id, product.NameFr, sum.Total, sum.MassEquivalent, count));
            }
        }

        // Nom libre : un produit different par nom (sans accents ni casse), sans conversion possible entre unites.
        foreach (var group in toOrder.Where(row => row.ProductId is null).GroupBy(row => NameNormalizer.Normalize(row.FreeProductName ?? string.Empty)))
        {
            var requests = group.ToList();
            var name = requests[0].FreeProductName ?? string.Empty;
            var sums = QuantityAggregator.Aggregate(requests.Select(row => new Quantity(row.QuantityValue, row.Unit)), requests[0].Unit, null);
            foreach (var sum in sums)
            {
                lines.Add(new ToOrderTotalLine(null, name, sum.Total, sum.MassEquivalent, requests.Count(row => row.Unit == sum.Total.Unit)));
            }
        }

        return lines.OrderBy(line => line.Name, StringComparer.CurrentCultureIgnoreCase).ThenBy(line => line.Total.Unit).ToList();
    }
}
