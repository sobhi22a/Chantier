using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Materials;

/// <summary>Suivi d'un chantier : compteurs des cinq vues, totaux à commander par produit et par unité, montants. Un chantier non affecté est introuvable (404).</summary>
[ApiController]
[SiteScoped]
[Route("api/v1/sites/{siteId:guid}/follow-up")]
[Produces("application/json")]
public sealed class FollowUpController(IFollowUpService followUp) : ControllerBase
{
    /// <summary>
    /// Compteurs (à valider, à commander, attendues, en retard, à réceptionner), totaux « à commander » (400 sacs = 20 T ; 24 m³ et 10 T de sable restent deux lignes) et, avec
    /// le droit <c>Prices.View</c> seulement, les montants du chantier en DZD hors taxes (<c>commercial</c>). Les listes détaillées sont celles des demandes (<c>view</c>).
    /// </summary>
    [HttpGet]
    [HasPermission(PermissionResources.Requests, PermissionActions.View)]
    [ProducesResponseType<FollowUpResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<FollowUpResponse>> Get(Guid siteId, CancellationToken cancellationToken)
        => Ok(await followUp.GetAsync(siteId, cancellationToken));
}
