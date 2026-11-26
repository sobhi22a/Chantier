using System.Diagnostics.CodeAnalysis;
using System.Text.Json.Serialization;
using Chantier.Core.Entities.Materials;

namespace Chantier.Core.Materials;

/// <summary>Produit d'une demande : du catalogue (<c>productId</c>, <c>name</c>) et/ou le nom libre saisi (<c>freeName</c>, conserve apres un rattachement).</summary>
public sealed record ProductRefResponse(Guid? ProductId, string? Name, string? NameAr, string? FreeName);

/// <summary>Motif d'un refus ou d'une annulation.</summary>
public sealed record StatusReasonResponse(string Code, string? Note);

/// <summary>Demande semblable deja ouverte (avertissement, jamais un blocage).</summary>
public sealed record DuplicateRefResponse(Guid Id, string Number);

/// <summary>Ecart entre le recu et le demande dans l'unite de la demande : negatif = manque, positif = surplus.</summary>
public sealed record VarianceResponse(decimal Value, MeasureUnit Unit, decimal Percent);

/// <summary>Evenement de l'historique : qui, quand (heure du serveur), ancien et nouveau statut, motif, champs modifies.</summary>
/// <param name="DeviceAt">« Saisi le » du telephone pour une saisie hors ligne : information seulement.</param>
public sealed record RequestHistoryItem(
    Guid Id,
    MaterialEventType Type,
    RequestStatus? FromStatus,
    RequestStatus? ToStatus,
    string? ReasonCode,
    string? ReasonNote,
    IReadOnlyList<FieldChange>? Changes,
    string? ActorName,
    DateTimeOffset OccurredAt,
    DateTimeOffset? DeviceAt,
    MaterialEventSource Source);

/// <summary>
/// Demande de materiaux telle que renvoyee par l'API (liste, detail, actions). Les clés absentes ne sont pas ecrites.
/// Le statut, le recu, le reste et l'ecart sont calcules par le serveur : un client ne les envoie jamais.
/// </summary>
public record MaterialRequestResponse
{
    public required Guid Id { get; init; }

    public required Guid SiteId { get; init; }

    /// <summary>Code du chantier (liste transversale et REST) ; absent de la synchronisation.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? SiteCode { get; init; }

    /// <summary>Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon <c>null</c>.</summary>
    public Guid? ClientId { get; init; }

    public DateTimeOffset? ClientCreatedAt { get; init; }

    /// <summary>Numero <c>DEM-nnn</c>, donne par le serveur.</summary>
    public required string Number { get; init; }

    public required ProductRefResponse Product { get; init; }

    /// <summary>Quantite demandee et son unite.</summary>
    public required Quantity Quantity { get; init; }

    public Guid? ZoneId { get; init; }

    /// <summary>Date de besoin (« pour le »), date complete sans fuseau.</summary>
    public required DateOnly NeededBy { get; init; }

    public required Priority Priority { get; init; }

    public string? Note { get; init; }

    public required RequestStatus Status { get; init; }

    /// <summary>Motif du refus ou de l'annulation.</summary>
    public StatusReasonResponse? StatusReason { get; init; }

    /// <summary>Recu cumule dans l'unite de la demande ; absent tant que la demande n'est pas commandee.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public Quantity? ReceivedQuantity { get; init; }

    /// <summary>Reste a livrer, jamais negatif ; absent tant que la demande n'est pas commandee.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public Quantity? RemainingQuantity { get; init; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public VarianceResponse? Variance { get; init; }

    /// <summary>Manque definitif accepte (« solde »).</summary>
    public required bool IsSettled { get; init; }

    /// <summary>Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon.</summary>
    public required int OverdueDays { get; init; }

    public DuplicateRefResponse? PossibleDuplicateOf { get; init; }

    /// <summary>Commande active ; <c>null</c> sans commande. Ses champs commerciaux sont absents sans <c>Prices.View</c> et de la synchronisation.</summary>
    public OrderResponse? Order { get; init; }

    /// <summary>Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »).</summary>
    public bool HasDeliveryWithoutOrder { get; init; }

    public required Guid RequestedById { get; init; }

    public string? RequestedByName { get; init; }

    public DateTimeOffset? ArchivedAt { get; init; }

    public string? ArchivedByName { get; init; }

    /// <summary>Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification.</summary>
    public required string Version { get; init; }

    public required DateTimeOffset CreatedAt { get; init; }

    public string? CreatedByName { get; init; }

    public DateTimeOffset? UpdatedAt { get; init; }

    public string? UpdatedByName { get; init; }
}

/// <summary>Demande et son historique (le detail d'une demande).</summary>
public record MaterialRequestDetailResponse : MaterialRequestResponse
{
    [SetsRequiredMembers]
    public MaterialRequestDetailResponse(MaterialRequestResponse original) : base(original)
    {
    }

    public IReadOnlyList<RequestHistoryItem> History { get; init; } = [];

    /// <summary>Livraisons de la demande, annulees comprises ; absentes de la synchronisation (l'entite <c>delivery</c> les porte).</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public IReadOnlyList<RequestDeliveryItem>? Deliveries { get; init; }
}

/// <summary>Ligne de la synchronisation <c>request</c> : le detail sans le code du chantier ni aucun champ commercial (ADR 0012).</summary>
public sealed record RequestSyncData : MaterialRequestDetailResponse
{
    [SetsRequiredMembers]
    public RequestSyncData(MaterialRequestDetailResponse original) : base(original)
    {
    }

    /// <summary>
    /// Forme de synchronisation d'un detail : sans code de chantier, sans aucun champ commercial et <b>sans historique</b> (<c>history</c> toujours vide : 34 % du volume de la
    /// premiere synchronisation, R2-02 ; il se lit a la demande, en ligne, par <c>GET .../requests/{id}</c>). Le statut, le motif et la derniere modification restent dans la ligne.
    /// </summary>
    public static RequestSyncData From(MaterialRequestDetailResponse detail) => new(detail with
    {
        SiteCode = null,
        Order = detail.Order is { } order ? order with { Commercial = null } : null,
        Deliveries = null,
        History = [],
    });
}

/// <summary>Resultat d'une action : <c>Applied = false</c> si l'etat vise etait deja atteint (« deja validee »), sans rien ecrire.</summary>
public sealed record RequestActionResult(MaterialRequestDetailResponse Request, bool Applied);

/// <summary>Resultat d'une creation idempotente : <c>Created = false</c> si le meme <c>clientId</c> avait deja ete recu.</summary>
public sealed record RequestCreationResult(MaterialRequestDetailResponse Request, bool Created);

/// <summary>Issue d'une demande d'un lot : <c>applied</c>, <c>duplicate</c> (deja dans l'etat vise) ou <c>rejected</c> (avec <c>code</c>).</summary>
public sealed record BatchItemResult(
    Guid RequestId,
    string Outcome,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? Code);

public sealed record BatchResponse(IReadOnlyList<BatchItemResult> Results);

public static class BatchOutcomes
{
    public const string Applied = "applied";
    public const string Duplicate = "duplicate";
    public const string Rejected = "rejected";
}
