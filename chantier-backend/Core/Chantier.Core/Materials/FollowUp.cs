using System.Text.Json.Serialization;

namespace Chantier.Core.Materials;

/// <summary>Compteurs des cinq vues du suivi d'un chantier (demandes non archivees).</summary>
/// <param name="ToApprove">A valider : demandees.</param>
/// <param name="ToOrder">A commander : validees.</param>
/// <param name="Expected">Attendues : commandees et livrees partiellement.</param>
/// <param name="Late">En retard : date de besoin depassee, ou commande attendue dont la date prevue est depassee.</param>
/// <param name="ToReceive">A receptionner : livrees.</param>
public sealed record FollowUpCounters(int ToApprove, int ToOrder, int Expected, int Late, int ToReceive);

/// <summary>
/// Total d'une ligne de « A commander » : par produit et par famille d'unites convertibles, jamais d'unites incompatibles additionnees
/// (400 sacs = 20 T ; 24 m3 et 10 T de sable = deux lignes).
/// </summary>
/// <param name="ProductId">Produit du catalogue ; <c>null</c> pour un nom libre.</param>
/// <param name="MassEquivalent">Masse en tonnes d'un total en sacs ; absente sinon.</param>
/// <param name="RequestCount">Nombre de demandes comptees dans cette ligne.</param>
public sealed record ToOrderTotalLine(
    Guid? ProductId,
    string Name,
    Quantity Total,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] Quantity? MassEquivalent,
    int RequestCount);

/// <summary>Montants du chantier en DZD hors taxes : commandes non annulees et valeur recue (somme des montants arrondis des livraisons). Absent sans <c>Prices.View</c>.</summary>
public sealed record FollowUpCommercialResponse(decimal OrderedAmount, decimal ReceivedValue);

public sealed record FollowUpResponse(FollowUpCounters Counters, IReadOnlyList<ToOrderTotalLine> ToOrderTotals)
{
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public FollowUpCommercialResponse? Commercial { get; init; }
}

/// <summary>Suivi d'un chantier : compteurs, totaux a commander et montants. Les vues detaillees sont les listes de demandes (<c>view</c>).</summary>
public interface IFollowUpService
{
    Task<FollowUpResponse> GetAsync(Guid siteId, CancellationToken cancellationToken = default);
}
