using Chantier.Core.DTOs.Materials;
using Chantier.Core.Paging;

namespace Chantier.Core.Materials;

/// <summary>
/// Commandes (une par demande, sans numero propre). <b>Toutes les regles vivent ici</b> : droits, statut de la demande, fournisseur actif, prix, montant,
/// historique. Le chantier est fourni par l'appelant apres son controle d'affectation. Les reponses sont la demande et sa commande (<c>order</c>).
/// </summary>
public interface IOrderService
{
    /// <summary>
    /// Enregistre la commande d'une demande <c>Validated</c> : la demande devient <c>Ordered</c> puis son statut est recalcule d'apres les livraisons deja retenues
    /// (deux evenements si besoin). Idempotent par <c>clientId</c> ; une autre commande active : 422 <c>COMMANDE_EXISTANTE</c>.
    /// </summary>
    Task<RequestCreationResult> CreateAsync(Guid siteId, Guid requestId, CreateOrderDto dto, CancellationToken cancellationToken = default);

    /// <summary>Modifie fournisseur, livraison prevue, prix, n° de bon de commande, remarque. Un changement de prix recalcule le montant de la commande et de chaque livraison.</summary>
    Task<MaterialRequestDetailResponse> UpdateAsync(Guid siteId, Guid requestId, UpdateOrderDto dto, CancellationToken cancellationToken = default);

    /// <summary>Annule la commande d'une demande sans livraison non annulee : la demande redevient <c>Validated</c>. Avec une livraison : 422 <c>TRANSITION_INTERDITE</c>.</summary>
    Task<MaterialRequestDetailResponse> CancelAsync(Guid siteId, Guid requestId, string? reasonCode, string? reasonNote, CancellationToken cancellationToken = default);
}

/// <summary>
/// Livraisons. Une livraison est un <b>fait de chantier</b> : sa creation n'est jamais refusee a cause du statut de la demande. Toutes les regles (droits, produit,
/// unites, dates, recalcul du statut dans les deux sens, historique) vivent ici : l'API REST et la synchronisation appellent ce service.
/// </summary>
public interface IDeliveryService
{
    Task<PagedResult<DeliveryResponse>> ListAsync(DeliveryListQuery query, CancellationToken cancellationToken = default);

    Task<DeliveryDetailResponse> GetAsync(Guid siteId, Guid deliveryId, CancellationToken cancellationToken = default);

    /// <summary>Creation idempotente par (chantier, <c>clientId</c>) : un renvoi rend la meme livraison et le meme numero.</summary>
    Task<DeliveryCreationResult> CreateAsync(Guid siteId, CreateDeliveryDto dto, RequestActionContext? context = null, CancellationToken cancellationToken = default);

    /// <summary>Corrige quantite, date, n° de BL, conformite avec la version lue (409 si perimee) ; recalcule la demande.</summary>
    Task<DeliveryDetailResponse> UpdateAsync(Guid siteId, Guid deliveryId, UpdateDeliveryDto dto, RequestActionContext? context = null, CancellationToken cancellationToken = default);

    /// <summary>Annule avec un motif ; deja annulee : <c>Applied = false</c>, le premier motif est conserve. Recalcule la demande.</summary>
    Task<DeliveryActionResult> CancelAsync(Guid siteId, Guid deliveryId, string? reasonCode, string? reasonNote, RequestActionContext? context = null, CancellationToken cancellationToken = default);

    /// <summary>Rattache une livraison non rattachee a une demande validee, commandee ou livree partiellement du meme chantier et du meme produit ; recalcule.</summary>
    Task<DeliveryDetailResponse> AttachAsync(Guid siteId, Guid deliveryId, Guid requestId, CancellationToken cancellationToken = default);
}

/// <summary>Photos des bons de livraison (ADR 0013) : metadonnees idempotentes, puis un fichier JPEG a la fois.</summary>
public interface IPhotoService
{
    /// <summary>Cree les metadonnees (201) ou rend celles du meme <c>clientId</c> (200). 5 photos au plus par livraison : 422 <c>PHOTOS_TROP_NOMBREUSES</c>.</summary>
    Task<PhotoCreationResult> CreateAsync(Guid siteId, Guid deliveryId, CreatePhotoDto dto, RequestActionContext? context = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// Envoie le fichier : JPEG verifie par ses octets magiques, taille limitee, metadonnees EXIF retirees sans reencodage, empreinte comparee a celle declaree.
    /// Meme contenu renvoye : <c>Stored = false</c> (200 sans effet) ; contenu different sur une photo deja envoyee : 409 <c>PHOTO_DEJA_ENVOYEE</c>.
    /// </summary>
    Task<PhotoUploadResult> UploadAsync(Guid siteId, Guid photoId, Stream content, string? contentType, long? declaredLength, CancellationToken cancellationToken = default);

    /// <summary>Ouvre le fichier pour la lecture. Photo d'un autre chantier, non envoyee ou sans <c>DeliveryPhotos.View</c> : 404, indiscernable.</summary>
    Task<PhotoContent> OpenAsync(Guid siteId, Guid photoId, CancellationToken cancellationToken = default);
}

/// <summary>Resultat d'un envoi de fichier : <c>Stored = false</c> si la photo avait deja exactement ce contenu.</summary>
public sealed record PhotoUploadResult(PhotoResponse Photo, bool Stored);

/// <summary>Fichier d'une photo a servir : le flux est a liberer par l'appelant.</summary>
public sealed record PhotoContent(Stream Content, string ContentType, long Length);
