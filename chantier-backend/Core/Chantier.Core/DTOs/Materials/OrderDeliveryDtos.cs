using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;

namespace Chantier.Core.DTOs.Materials;

/// <summary>Creation d'une commande : <c>clientId</c> rend l'envoi idempotent (meme commande renvoyee : 200, aucun effet).</summary>
public sealed record CreateOrderDto(Guid? ClientId, OrderFields Fields);

/// <summary>Modification d'une commande avec la version lue : une version perimee donne 409 <c>CONFLIT_VERSION</c>.</summary>
public sealed record UpdateOrderDto(string Version, OrderChanges Changes);

/// <summary>
/// Creation d'une livraison (REST ou synchronisation). <paramref name="RequestId"/> absent = « non rattachee ». <paramref name="Reason"/> permet a la
/// synchronisation d'imposer <c>RequestMissing</c> (demande designee par un <c>clientId</c> introuvable) ; sinon le serveur decide d'apres le statut de la demande.
/// </summary>
public sealed record CreateDeliveryDto(Guid? ClientId, DateTimeOffset? ClientCreatedAt, Guid? RequestId, DeliveryFields Fields, UnattachedReason? Reason = null);

/// <summary>Correction d'une livraison avec la version lue : une version perimee donne 409 <c>CONFLIT_VERSION</c>.</summary>
public sealed record UpdateDeliveryDto(string Version, DeliveryChanges Changes);

/// <summary>Metadonnees d'une photo de bon (creables hors ligne) ; le fichier suit par un envoi separe.</summary>
public sealed record CreatePhotoDto(Guid? ClientId, DateTimeOffset? ClientCreatedAt, DateTimeOffset? TakenAt, string? ContentType, long? SizeBytes, string? Sha256);

/// <summary>Filtres de la liste des livraisons d'un chantier.</summary>
/// <param name="Unattached"><c>true</c> : seulement les livraisons non rattachees (a traiter).</param>
/// <param name="WithReserve"><c>true</c> : seulement les livraisons recues avec reserve.</param>
/// <param name="MissingNote"><c>true</c> : seulement les livraisons sans n° de BL ni photo (« a completer »).</param>
public sealed record DeliveryListQuery(
    Guid SiteId,
    Guid? RequestId,
    bool? Unattached,
    bool? WithReserve,
    bool? MissingNote,
    DeliveryStatus? Status,
    Guid? SupplierId,
    Guid? ProductId,
    string? Search,
    DateOnly? From,
    DateOnly? To,
    string? Sort,
    int Page,
    int PageSize);
