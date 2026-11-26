using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Paging;
using Chantier.Core.Sites;
using Chantier.WebApi.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Materials;

/// <summary>
/// Demandes de <b>tous mes chantiers</b> (files « À valider » et « À commander » du back-office). Seuls les chantiers affectés à l'utilisateur
/// sont lus (l'Admin les voit tous) ; un <c>siteId</c> non affecté donne 404, comme partout ailleurs.
/// </summary>
[ApiController]
[Route("api/v1/requests")]
[Produces("application/json")]
public sealed class CrossSiteRequestsController(IRequestService requests, ISiteAccess siteAccess) : ControllerBase
{
    /// <summary>Demandes de mes chantiers (mêmes filtres que la liste d'un chantier, avec le code du chantier).</summary>
    /// <param name="siteId">Limiter à un chantier (404 s'il n'est pas affecté).</param>
    /// <param name="view"><c>toFollow</c> (défaut), <c>toApprove</c>, <c>toOrder</c>, <c>expected</c>, <c>late</c> (date de besoin ou livraison prévue dépassée), <c>toReceive</c>, <c>received</c>, <c>closed</c> ou <c>archived</c>.</param>
    /// <param name="mine">Seulement mes demandes.</param>
    /// <param name="status">Limiter à un statut.</param>
    /// <param name="priority">Limiter à une urgence.</param>
    /// <param name="zoneId">Limiter à une zone.</param>
    /// <param name="productId">Limiter à un produit du catalogue.</param>
    /// <param name="supplierId">Limiter aux demandes dont la commande active est chez ce fournisseur.</param>
    /// <param name="from">Date de besoin à partir de (incluse).</param>
    /// <param name="to">Date de besoin jusqu'à (incluse).</param>
    /// <param name="q">Recherche dans le numéro, le produit et la remarque.</param>
    /// <param name="sort"><c>neededBy</c>, <c>-neededBy</c>, <c>number</c>, <c>-number</c>, <c>createdAt</c>, <c>-createdAt</c>, <c>priority</c>.</param>
    /// <param name="page">Numéro de page, à partir de 1.</param>
    /// <param name="pageSize">Taille de page (1 à 200).</param>
    [HttpGet]
    [HasPermission(PermissionResources.Requests, PermissionActions.View)]
    [ProducesResponseType<PagedResult<MaterialRequestResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<PagedResult<MaterialRequestResponse>>> List(
        [FromQuery] Guid? siteId,
        [FromQuery] string? view,
        [FromQuery] bool mine,
        [FromQuery] RequestStatus? status,
        [FromQuery] Priority? priority,
        [FromQuery] Guid? zoneId,
        [FromQuery] Guid? productId,
        [FromQuery] Guid? supplierId,
        [FromQuery] DateOnly? from,
        [FromQuery] DateOnly? to,
        [FromQuery] string? q,
        [FromQuery] string? sort = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = PagingRules.DefaultPageSize,
        CancellationToken cancellationToken = default)
    {
        if (siteId is { } requested)
        {
            // Chantier non affecte ou inexistant : meme 404 que sur la route d'un chantier.
            await siteAccess.EnsureAsync(requested, cancellationToken);
        }

        return Ok(await requests.ListAsync(
            new RequestListQuery(siteId, view, mine, status, priority, zoneId, productId, from, to, q, sort, page, pageSize, supplierId),
            cancellationToken));
    }
}
