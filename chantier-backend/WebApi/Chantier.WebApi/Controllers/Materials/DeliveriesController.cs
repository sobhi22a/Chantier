using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Paging;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Filters;
using Chantier.WebApi.Models.Materials;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Materials;

/// <summary>
/// Livraisons d'un chantier (LIV-001...). Une livraison est un fait de chantier : sa création n'est jamais refusée à cause du statut de la demande (elle est alors enregistrée non
/// rattachée, avec son motif). Le statut de la demande se recalcule dans les deux sens à chaque création, correction, annulation et rattachement. Un chantier non affecté est introuvable.
/// </summary>
[ApiController]
[SiteScoped]
[Route("api/v1/sites/{siteId:guid}/deliveries")]
[Produces("application/json")]
public sealed class DeliveriesController(IDeliveryService deliveries) : ControllerBase
{
    /// <summary>Livraisons du chantier, avec filtres, recherche, tri et pagination avec total.</summary>
    /// <param name="requestId">Livraisons d'une demande.</param>
    /// <param name="unattached"><c>true</c> : seulement les livraisons non rattachées (à traiter).</param>
    /// <param name="withReserve"><c>true</c> : seulement les livraisons reçues avec réserve.</param>
    /// <param name="missingNote"><c>true</c> : seulement les livraisons sans n° de BL ni photo (« à compléter »).</param>
    /// <param name="status"><c>Recorded</c> ou <c>Cancelled</c>.</param>
    /// <param name="supplierId">Limiter à un fournisseur du catalogue.</param>
    /// <param name="productId">Limiter à un produit du catalogue.</param>
    /// <param name="q">Recherche dans le numéro (<c>LIV-006</c>), le n° de BL, le produit et le fournisseur.</param>
    /// <param name="from">Date de livraison à partir de (incluse).</param>
    /// <param name="to">Date de livraison jusqu'à (incluse).</param>
    /// <param name="sort"><c>deliveryDate</c>, <c>-deliveryDate</c>, <c>number</c>, <c>-number</c> ; par défaut les plus récentes d'abord.</param>
    /// <param name="page">Numéro de page, à partir de 1.</param>
    /// <param name="pageSize">Taille de page (1 à 200).</param>
    [HttpGet]
    [HasPermission(PermissionResources.Deliveries, PermissionActions.View)]
    [ProducesResponseType<PagedResult<DeliveryResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<PagedResult<DeliveryResponse>>> List(
        Guid siteId,
        [FromQuery] Guid? requestId,
        [FromQuery] bool? unattached,
        [FromQuery] bool? withReserve,
        [FromQuery] bool? missingNote,
        [FromQuery] DeliveryStatus? status,
        [FromQuery] Guid? supplierId,
        [FromQuery] Guid? productId,
        [FromQuery] string? q,
        [FromQuery] DateOnly? from,
        [FromQuery] DateOnly? to,
        [FromQuery] string? sort = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = PagingRules.DefaultPageSize,
        CancellationToken cancellationToken = default)
        => Ok(await deliveries.ListAsync(
            new DeliveryListQuery(siteId, requestId, unattached, withReserve, missingNote, status, supplierId, productId, q, from, to, sort, page, pageSize),
            cancellationToken));

    /// <summary>Une livraison avec son historique (qui, quand, ancienne et nouvelle valeur, motif).</summary>
    [HttpGet("{deliveryId:guid}")]
    [HasPermission(PermissionResources.Deliveries, PermissionActions.View)]
    [ProducesResponseType<DeliveryDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<DeliveryDetailResponse>> Get(Guid siteId, Guid deliveryId, CancellationToken cancellationToken)
        => Ok(await deliveries.GetAsync(siteId, deliveryId, cancellationToken));

    /// <summary>
    /// Enregistrer une livraison. Le numéro <c>LIV-nnn</c> est donné par le serveur. Un même <c>clientId</c> renvoyé donne 200 et la même livraison.
    /// 422 : <c>UNITES_INCOMPATIBLES</c> (sable en m³ livré en T), <c>PRODUIT_DIFFERENT</c>, <c>UNITE_OBLIGATOIRE</c>, <c>QUANTITE_INVALIDE</c>. 400 <c>DATE_INVALIDE</c> : date dans le futur.
    /// </summary>
    [HttpPost]
    [HasPermission(PermissionResources.Deliveries, PermissionActions.Create)]
    [ProducesResponseType<DeliveryDetailResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<DeliveryDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<DeliveryDetailResponse>> Create(Guid siteId, [FromBody] CreateDeliveryRequest request, CancellationToken cancellationToken)
    {
        var result = await deliveries.CreateAsync(siteId, request.ToDto(), cancellationToken: cancellationToken);
        return result.Created
            ? CreatedAtAction(nameof(Get), new { siteId, deliveryId = result.Delivery.Id }, result.Delivery)
            : Ok(result.Delivery);
    }

    /// <summary>Corriger quantité, unité, date, n° de BL ou conformité tant que la demande n'est pas réceptionnée (422 <c>DEMANDE_NON_OUVERTE</c> sinon). Le numéro ne change jamais. 409 si la version est périmée.</summary>
    [HttpPut("{deliveryId:guid}")]
    [HasPermission(PermissionResources.Deliveries, PermissionActions.Update)]
    [ProducesResponseType<DeliveryDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<DeliveryDetailResponse>> Update(Guid siteId, Guid deliveryId, [FromBody] UpdateDeliveryRequest request, CancellationToken cancellationToken)
        => Ok(await deliveries.UpdateAsync(siteId, deliveryId, request.ToDto(), cancellationToken: cancellationToken));

    /// <summary>Annuler une livraison avec un motif : elle reste visible mais n'entre plus dans aucun total, le statut de la demande est recalculé. Déjà annulée : 200, le premier motif est conservé.</summary>
    [HttpPost("{deliveryId:guid}/cancel")]
    [HasPermission(PermissionResources.Deliveries, PermissionActions.Update)]
    [ProducesResponseType<DeliveryDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<DeliveryDetailResponse>> Cancel(Guid siteId, Guid deliveryId, [FromBody] ReasonBody body, CancellationToken cancellationToken)
        => Ok((await deliveries.CancelAsync(siteId, deliveryId, body.ReasonCode, body.ReasonNote, cancellationToken: cancellationToken)).Delivery);

    /// <summary>
    /// Rattacher une livraison non rattachée à une demande validée, commandée ou livrée partiellement du même chantier et du même produit. 422 : <c>PRODUIT_DIFFERENT</c>,
    /// <c>UNITES_INCOMPATIBLES</c>, <c>DEMANDE_NON_OUVERTE</c>, <c>LIVRAISON_DEJA_RATTACHEE</c>. Réseau exigé (jamais en synchronisation). Pas de détachement : annuler puis ressaisir.
    /// </summary>
    [HttpPost("{deliveryId:guid}/attach")]
    [HasPermission(PermissionResources.Deliveries, PermissionActions.Attach)]
    [ProducesResponseType<DeliveryDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<DeliveryDetailResponse>> Attach(Guid siteId, Guid deliveryId, [FromBody] AttachBody body, CancellationToken cancellationToken)
        => Ok(await deliveries.AttachAsync(siteId, deliveryId, body.RequestId!.Value, cancellationToken));
}
