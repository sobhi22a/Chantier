using Chantier.Core.DTOs.Materials;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Filters;
using Chantier.WebApi.Models.Materials;
using Chantier.WebApi.Options;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Materials;

/// <summary>
/// Photos des bons de livraison (ADR 0013), en deux temps : les métadonnées (idempotentes, créables hors ligne), puis le fichier JPEG par un <c>PUT</c> direct, un fichier à la fois.
/// Jamais de chemin de stockage ni d'URL publique : la lecture est authentifiée, par chantier. Un chantier non affecté est introuvable (404).
/// </summary>
[ApiController]
[SiteScoped]
[Route("api/v1/sites/{siteId:guid}")]
[Produces("application/json")]
public sealed class PhotosController(IPhotoService photos) : ControllerBase
{
    /// <summary>Créer les métadonnées d'une photo du bon (5 au plus par livraison : 422 <c>PHOTOS_TROP_NOMBREUSES</c>). Un même <c>clientId</c> renvoyé donne 200 et les mêmes métadonnées.</summary>
    [HttpPost("deliveries/{deliveryId:guid}/photos")]
    [HasPermission(PermissionResources.DeliveryPhotos, PermissionActions.Create)]
    [ProducesResponseType<PhotoResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<PhotoResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status413PayloadTooLarge, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status415UnsupportedMediaType, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<PhotoResponse>> Create(Guid siteId, Guid deliveryId, [FromBody] CreatePhotoRequest request, CancellationToken cancellationToken)
    {
        var result = await photos.CreateAsync(siteId, deliveryId, request.ToDto(), cancellationToken: cancellationToken);
        return result.Created
            ? CreatedAtAction(nameof(Download), new { siteId, photoId = result.Photo.Id }, result.Photo)
            : Ok(result.Photo);
    }

    /// <summary>
    /// Envoyer le fichier : le corps est l'image JPEG elle-même (<c>Content-Type: image/jpeg</c>, 5 Mo au plus, cible 2 Mo). Vérifié par ses octets magiques ; l'empreinte
    /// SHA-256 doit être celle déclarée ; les métadonnées EXIF (GPS, appareil) sont retirées sans réencodage. Même contenu renvoyé : 200 sans effet ; autre contenu sur une photo
    /// déjà envoyée : 409 <c>PHOTO_DEJA_ENVOYEE</c> ; 413 <c>FICHIER_TROP_GROS</c> ; 415 <c>TYPE_FICHIER_REFUSE</c>.
    /// </summary>
    [HttpPut("photos/{photoId:guid}/content")]
    [HasPermission(PermissionResources.DeliveryPhotos, PermissionActions.Create)]
    [RequestSizeLimit(RequestLimits.PhotoMaxBodyBytes)]
    [ProducesResponseType<PhotoResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status413PayloadTooLarge, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status415UnsupportedMediaType, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<PhotoResponse>> Upload(Guid siteId, Guid photoId, CancellationToken cancellationToken)
    {
        var result = await photos.UploadAsync(siteId, photoId, Request.Body, Request.ContentType, Request.ContentLength, cancellationToken);
        return Ok(result.Photo);
    }

    /// <summary>
    /// Lire le fichier (<c>image/jpeg</c>, <c>nosniff</c>, <c>Cache-Control: private, no-cache</c> avec un <c>ETag</c> : revalidation à chaque lecture, <c>304</c> si inchangée). Une photo d'un autre chantier, non envoyée, ou sans le droit <c>DeliveryPhotos.View</c> est
    /// introuvable (404 identique) : le droit se vérifie dans le service pour ne pas distinguer « interdit » de « inexistant ».
    /// </summary>
    [HttpGet("photos/{photoId:guid}/content")]
    [Produces("image/jpeg", "application/problem+json")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status304NotModified)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<IActionResult> Download(Guid siteId, Guid photoId, CancellationToken cancellationToken)
    {
        var content = await photos.OpenAsync(siteId, photoId, cancellationToken);
        Response.Headers.XContentTypeOptions = "nosniff";

        // R2-11 : jamais conservee sans revalidation (poste partage, affectation retiree) ; le contenu d'une photo ne change jamais, son identifiant sert d'ETag :
        // une relecture sans changement coute un 304 (apres controle du droit et du chantier), pas un telechargement.
        Response.Headers.CacheControl = "private, no-cache";
        var etag = new Microsoft.Net.Http.Headers.EntityTagHeaderValue($"\"photo-{photoId:N}\"");
        return File(content.Content, content.ContentType, lastModified: null, entityTag: etag);
    }
}
