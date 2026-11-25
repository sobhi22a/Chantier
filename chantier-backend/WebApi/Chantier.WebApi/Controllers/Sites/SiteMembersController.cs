using Chantier.Core.Identity;
using Chantier.Core.Paging;
using Chantier.Core.Sites;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Sites;

/// <summary>Affectation des personnes à un chantier (Admin). Jamais de téléphone ni d'identifiant de connexion dans les réponses.</summary>
[ApiController]
[SiteScoped]
[Route("api/v1/sites/{siteId:guid}/members")]
[Produces("application/json")]
public sealed class SiteMembersController(ISiteMemberService members) : ControllerBase
{
    /// <summary>Personnes affectées au chantier (nom et rôle).</summary>
    [HttpGet]
    [HasPermission(PermissionResources.SiteMembers, PermissionActions.View)]
    [ProducesResponseType<ItemsResponse<SiteMemberResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<ItemsResponse<SiteMemberResponse>>> List(Guid siteId, CancellationToken cancellationToken)
        => Ok(new ItemsResponse<SiteMemberResponse>(await members.ListAsync(siteId, cancellationToken)));

    /// <summary>Affecter une personne : immédiat. 201 si créée, 200 si elle était déjà affectée.</summary>
    [HttpPut("{userId:guid}")]
    [HasPermission(PermissionResources.SiteMembers, PermissionActions.Update)]
    [ProducesResponseType<SiteMemberResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<SiteMemberResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<SiteMemberResponse>> Assign(Guid siteId, Guid userId, CancellationToken cancellationToken)
    {
        var result = await members.AssignAsync(siteId, userId, cancellationToken);
        return result.Created
            ? Created($"/api/v1/sites/{siteId}/members/{userId}", result.Member)
            : Ok(result.Member);
    }

    /// <summary>Retirer une personne : l'accès est coupé tout de suite. Idempotent.</summary>
    [HttpDelete("{userId:guid}")]
    [HasPermission(PermissionResources.SiteMembers, PermissionActions.Update)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<IActionResult> Remove(Guid siteId, Guid userId, CancellationToken cancellationToken)
    {
        await members.RemoveAsync(siteId, userId, cancellationToken);
        return NoContent();
    }
}
