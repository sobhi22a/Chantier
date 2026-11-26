using Chantier.Core.Entities.Materials;

namespace Chantier.Core.Materials;

/// <summary>Resultat du calcul du statut d'une demande commandee, dans l'unite de la demande.</summary>
/// <param name="Received">Quantite recue cumulee Qr.</param>
/// <param name="Remaining">Reste a livrer, jamais negatif.</param>
/// <param name="Variance">Ecart Qr - Qc : negatif = manque, positif = surplus.</param>
/// <param name="VariancePercent">Ecart en pourcentage de la quantite commandee, 2 decimales.</param>
/// <param name="Status"><c>Ordered</c>, <c>PartiallyDelivered</c> ou <c>Delivered</c>.</param>
/// <param name="IsSettled">Le solde ne compte que s'il reste au moins une livraison : sans livraison, la demande redevient <c>Ordered</c> et perd son solde.</param>
public sealed record StatusComputation(decimal Received, decimal Remaining, decimal Variance, decimal VariancePercent, RequestStatus Status, bool IsSettled);

/// <summary>
/// Seule fonction qui decide du statut d'une demande commandee (H-MAT-10) : somme des livraisons non annulees, converties dans l'unite de
/// la demande. Pure : aucune dependance a la base ni a HTTP. Les clients n'ont qu'un miroir d'affichage, teste par les memes vecteurs (ADR 0014).
/// </summary>
public static class RequestStatusCalculator
{
    /// <param name="ordered">Quantite et unite de la demande (Qc).</param>
    /// <param name="bagMassKg">Masse du sac du produit, si le produit en a une.</param>
    /// <param name="deliveries">Livraisons <b>non annulees</b>, chacune dans son unite.</param>
    /// <param name="tolerancePercent">Tolerance de « livraison complete » (defaut 0 %).</param>
    /// <param name="isSettled">Demande soldee par Achats ou le conducteur : un manque definitif.</param>
    public static StatusComputation Compute(
        Quantity ordered,
        decimal? bagMassKg,
        IEnumerable<Quantity> deliveries,
        decimal tolerancePercent,
        bool isSettled)
    {
        // Chaque livraison est convertie (et arrondie a 3 decimales) avant d'etre additionnee : UNITES_INCOMPATIBLES si elle ne l'est pas.
        var received = deliveries.Sum(delivery => UnitConverter.Convert(delivery, ordered.Unit, bagMassKg).Value);

        var remaining = Math.Max(0m, ordered.Value - received);
        var variance = received - ordered.Value;
        var variancePercent = ordered.Value > 0m
            ? Math.Round(variance / ordered.Value * 100m, 2, MidpointRounding.AwayFromZero)
            : 0m;

        var status = received <= 0m
            ? RequestStatus.Ordered
            : IsComplete(ordered.Value, received, tolerancePercent, isSettled) ? RequestStatus.Delivered : RequestStatus.PartiallyDelivered;

        return new StatusComputation(received, remaining, variance, variancePercent, status, isSettled && received > 0m);
    }

    private static bool IsComplete(decimal ordered, decimal received, decimal tolerancePercent, bool isSettled)
    {
        if (received >= ordered || isSettled)
        {
            return true;
        }

        // Manque dans la tolerance : comparaison sur la valeur exacte (pas sur le pourcentage arrondi).
        return ordered > 0m && (ordered - received) / ordered * 100m <= tolerancePercent;
    }
}
