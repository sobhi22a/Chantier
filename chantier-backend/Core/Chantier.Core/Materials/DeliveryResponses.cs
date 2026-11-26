using System.Diagnostics.CodeAnalysis;
using System.Text.Json.Serialization;
using Chantier.Core.Entities.Materials;

namespace Chantier.Core.Materials;

/// <summary>Reserve a la reception : un motif de la liste (<c>QuantityMissing</c>, <c>DamagedProduct</c>...) et une remarque.</summary>
public sealed record ReserveResponse(string Code, string? Note);

/// <summary>Photo du bon dans une livraison : ni chemin de stockage, ni empreinte.</summary>
public sealed record DeliveryPhotoItem(Guid Id, PhotoContentStatus ContentStatus, long SizeBytes, DateTimeOffset TakenAt);

/// <summary>
/// Livraison telle que renvoyee par l'API (liste, detail, actions). Les cles absentes ne sont pas ecrites. Le montant (<c>commercial</c>) n'est rendu
/// qu'avec <c>Prices.View</c> ; la livraison n'a pas de prix propre : prix de la commande x quantite convertie.
/// </summary>
public record DeliveryResponse
{
    public required Guid Id { get; init; }

    public required Guid SiteId { get; init; }

    public Guid? ClientId { get; init; }

    public DateTimeOffset? ClientCreatedAt { get; init; }

    /// <summary>Numero <c>LIV-nnn</c>, donne par le serveur ; jamais reutilise, meme apres une annulation.</summary>
    public required string Number { get; init; }

    /// <summary>Demande liee ; <c>null</c> = non rattachee (voir <c>unattachedReason</c>).</summary>
    public Guid? RequestId { get; init; }

    public string? RequestNumber { get; init; }

    public UnattachedReason? UnattachedReason { get; init; }

    public Guid? SupplierId { get; init; }

    public string? SupplierName { get; init; }

    public string? FreeSupplierName { get; init; }

    public required ProductRefResponse Product { get; init; }

    /// <summary>Quantite recue, dans l'unite saisie.</summary>
    public required Quantity Quantity { get; init; }

    /// <summary>Quantite convertie dans l'unite de la demande ; seulement si la livraison est rattachee.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public Quantity? QuantityInRequestUnit { get; init; }

    public required DateOnly DeliveryDate { get; init; }

    public string? DeliveryNoteNumber { get; init; }

    /// <summary>Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite <c>photo</c>).</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public bool? MissingNote { get; init; }

    public required Conformity Conformity { get; init; }

    public ReserveResponse? Reserve { get; init; }

    public required DeliveryStatus Status { get; init; }

    /// <summary>Motif de l'annulation.</summary>
    public StatusReasonResponse? CancelReason { get; init; }

    /// <summary>Livraison du meme fournisseur, du meme produit et du meme n° de BL deja enregistree (avertissement, jamais un blocage).</summary>
    public DuplicateRefResponse? PossibleDuplicateOf { get; init; }

    /// <summary>Nombre de photos du bon.</summary>
    public required int PhotoCount { get; init; }

    /// <summary>Photos du bon ; absentes sans <c>DeliveryPhotos.View</c> et de la synchronisation.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public IReadOnlyList<DeliveryPhotoItem>? Photos { get; init; }

    /// <summary>Montant de la livraison ; absent sans <c>Prices.View</c> ou sans prix de commande, et de la synchronisation.</summary>
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public DeliveryCommercialResponse? Commercial { get; init; }

    /// <summary>Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.</summary>
    public required string Version { get; init; }

    public required DateTimeOffset CreatedAt { get; init; }

    public string? CreatedByName { get; init; }

    public DateTimeOffset? UpdatedAt { get; init; }

    public string? UpdatedByName { get; init; }
}

/// <summary>Livraison et son historique.</summary>
public record DeliveryDetailResponse : DeliveryResponse
{
    [SetsRequiredMembers]
    public DeliveryDetailResponse(DeliveryResponse original) : base(original)
    {
    }

    public IReadOnlyList<RequestHistoryItem> History { get; init; } = [];
}

/// <summary>Ligne de la synchronisation <c>delivery</c> : le detail sans montant, sans photos et sans « BL manquant » (deduits de l'entite <c>photo</c>).</summary>
public sealed record DeliverySyncData : DeliveryDetailResponse
{
    [SetsRequiredMembers]
    public DeliverySyncData(DeliveryDetailResponse original) : base(original)
    {
    }

    public static DeliverySyncData From(DeliveryDetailResponse detail) => new(detail with
    {
        Commercial = null,
        Photos = null,
        MissingNote = null,

        // Aucun historique en synchronisation (R2-02) : il se lit a la demande par GET .../deliveries/{id}.
        History = [],
    });
}

/// <summary>Photo d'un bon : metadonnees seulement (le fichier se lit par <c>GET .../photos/{id}/content</c>) ; ni chemin de stockage ni empreinte.</summary>
public sealed record PhotoResponse(
    Guid Id,
    Guid SiteId,
    Guid DeliveryId,
    Guid? ClientId,
    DateTimeOffset TakenAt,
    string ContentType,
    long SizeBytes,
    PhotoContentStatus ContentStatus,
    DateTimeOffset? UploadedAt,
    string Version,
    DateTimeOffset CreatedAt)
{
    public static PhotoResponse From(Photo photo) => new(
        photo.Id,
        photo.SiteId,
        photo.DeliveryId,
        photo.ClientId,
        photo.TakenAt,
        photo.ContentType,
        photo.SizeBytes,
        photo.ContentStatus,
        photo.UploadedAt,
        photo.Version,
        photo.CreatedAt);
}

/// <summary>Resultat d'une action sur une livraison : <c>Applied = false</c> si l'etat vise etait deja atteint (deux appuis = une annulation).</summary>
public sealed record DeliveryActionResult(DeliveryDetailResponse Delivery, bool Applied);

/// <summary>Resultat d'une creation idempotente : <c>Created = false</c> si le meme <c>clientId</c> avait deja ete recu.</summary>
public sealed record DeliveryCreationResult(DeliveryDetailResponse Delivery, bool Created);

/// <summary>Resultat de la creation d'une photo : <c>Created = false</c> si le meme <c>clientId</c> avait deja ete recu.</summary>
public sealed record PhotoCreationResult(PhotoResponse Photo, bool Created);
