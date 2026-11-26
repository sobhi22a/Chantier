using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// <b>Seul ecrivain</b> du recu cumule, du statut apres <c>Ordered</c>, du solde d'une demande et des caches de ses livraisons (quantite convertie, montant).
/// Tout part des livraisons non annulees : le recalcul est donc <b>idempotent</b> et va dans les deux sens (annuler une livraison ramene <c>Delivered</c> a
/// <c>PartiallyDelivered</c>, puis a <c>Ordered</c>). Il s'execute dans la transaction de l'appelant, la demande etant chargee et verrouillee par lui.
/// </summary>
public sealed class RequestRecalculator(ApplicationDbContext db, IOptions<MaterialsOptions> options, IRequestEventWriter events) : IRequestRecalculator
{
    private static readonly RequestStatus[] Recomputed =
        [RequestStatus.Validated, RequestStatus.Ordered, RequestStatus.PartiallyDelivered, RequestStatus.Delivered];

    public async Task RecomputeAsync(MaterialRequest request, string trigger, string? reference, RequestActionContext context, CancellationToken cancellationToken = default)
    {
        // Demandee, refusee, annulee : aucune livraison rattachee possible. Receptionnee : ne se recalcule plus (DEMANDE_NON_OUVERTE pour toute correction).
        if (!Recomputed.Contains(request.Status))
        {
            return;
        }

        var bagMassKg = request.ProductId is { } productId
            ? (await db.Products.FindAsync([productId], cancellationToken))?.BagMassKg
            : null;

        var deliveries = await db.Deliveries
            .Where(delivery => delivery.RequestId == request.Id && delivery.Status == DeliveryStatus.Recorded)
            .ToListAsync(cancellationToken);
        var order = await db.MaterialOrders.FirstOrDefaultAsync(candidate => candidate.RequestId == request.Id && candidate.CancelledAt == null, cancellationToken);

        // Une livraison convertie, arrondie a 3 decimales : exactement ce que le calculateur additionne (UNITES_INCOMPATIBLES si la conversion n'existe plus).
        var ordered = request.Ordered;
        foreach (var delivery in deliveries)
        {
            var converted = UnitConverter.Convert(delivery.Delivered, ordered.Unit, bagMassKg).Value;
            var amount = order?.UnitPrice is { } price ? Money.Amount(converted, price) : (decimal?)null;

            // D-1 : 1 milliard de tonnes converties en kg x le prix maximal depassent les colonnes (18,3) et (18,2) : refus clair, jamais un 500 a l'ecriture.
            Money.EnsureStorable(converted, amount);

            delivery.ApplyComputed(converted, amount);
        }

        var computation = RequestStatusCalculator.Compute(
            ordered, bagMassKg, deliveries.Select(delivery => delivery.Delivered), options.Value.DeliveryTolerancePercent, request.IsSettled);
        Money.EnsureStorable(computation.Received, order?.UnitPrice is { } unitPrice ? Money.ReceivedValue(unitPrice, deliveries.Select(delivery => delivery.QuantityInRequestUnit ?? 0m)) : null);

        var from = request.Status;
        if (request.ApplyComputation(computation))
        {
            events.Add(request, MaterialEventType.StatusRecomputed, context, from, request.Status, trigger, reference);
        }
    }

}
