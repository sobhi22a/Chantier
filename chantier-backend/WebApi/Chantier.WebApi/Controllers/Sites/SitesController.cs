using Chantier.Core.Entities.Sites;
using Chantier.Core.Identity;
using Chantier.Core.Paging;
using Chantier.Core.Sites;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Filters;
using Chantier.WebApi.Models.Sites;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Sites;

/// <summary>Chantiers (« Mes chantiers »). Un chantier non affecté est introuvable, exactement comme un chantier inexistant.</summary>
[ApiController]
[Route("api/v1/sites")]
[Produces("application/json")]
public sealed class SitesController(ISiteService sites) : ControllerBase
{
    /// <summary>Mes chantiers (l'Admin voit tous les chantiers).</summary>
    /// <remarks>Les chantiers archivés ne sont listés qu'avec <c>includeArchived=true</c>. <c>sort</c> : <c>name</c>, <c>-name</c>, <c>code</c>, <c>-code</c>, <c>createdAt</c>, <c>-createdAt</c>.</remarks>
    /// <param name="q">Recherche dans le code et les noms.</param>
    /// <param name="type">Type d'ouvrage.</param>
    /// <param name="wilaya">Nom de la wilaya.</param>
    /// <param name="includeArchived">Inclure les chantiers archivés.</param>
    /// <param name="sort">Tri : <c>name</c> (défaut), <c>-name</c>, <c>code</c>, <c>-code</c>, <c>createdAt</c>, <c>-createdAt</c>.</param>
    /// <param name="page">Numéro de page, à partir de 1.</param>
    /// <param name="pageSize">Taille de page (1 à 200).</param>
    [HttpGet]
    [HasPermission(PermissionResources.Sites, PermissionActions.View)]
    [ProducesResponseType<PagedResult<SiteResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    public async Task<ActionResult<PagedResult<SiteResponse>>> List(
        [FromQuery] string? q,
        [FromQuery] SiteType? type,
        [FromQuery] string? wilaya,
        [FromQuery] bool includeArchived = false,
        [FromQuery] string? sort = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = PagingRules.DefaultPageSize,
        CancellationToken cancellationToken = default)
        => Ok(await sites.ListAsync(new SiteListQuery(q, type, wilaya, includeArchived, sort, page, pageSize), cancellationToken));

    /// <summary>Proposer un code de chantier libre (modifiable avant la création).</summary>
    /// <param name="type">Type d'ouvrage.</param>
    /// <param name="name">Nom du chantier, dont on tire le code.</param>
    [HttpGet("code-suggestion")]
    [HasPermission(PermissionResources.Sites, PermissionActions.Create)]
    [ProducesResponseType<SiteCodeSuggestion>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    public async Task<ActionResult<SiteCodeSuggestion>> SuggestCode([FromQuery] SiteType type, [FromQuery] string? name, CancellationToken cancellationToken)
        => Ok(await sites.SuggestCodeAsync(type, name ?? string.Empty, cancellationToken));

    /// <summary>Fiche d'un chantier.</summary>
    [HttpGet("{siteId:guid}")]
    [SiteScoped]
    [HasPermission(PermissionResources.Sites, PermissionActions.View)]
    [ProducesResponseType<SiteResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<SiteResponse>> Get(Guid siteId, CancellationToken cancellationToken)
        => Ok(await sites.GetAsync(siteId, cancellationToken));

    /// <summary>Créer un chantier (Admin).</summary>
    [HttpPost]
    [HasPermission(PermissionResources.Sites, PermissionActions.Create)]
    [ProducesResponseType<SiteResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<SiteResponse>> Create([FromBody] CreateSiteRequest request, CancellationToken cancellationToken)
    {
        var created = await sites.CreateAsync(request.ToDto(), cancellationToken);
        return CreatedAtAction(nameof(Get), new { siteId = created.Id }, created);
    }

    /// <summary>Modifier un chantier (Admin). Le code est immuable ; <c>version</c> détecte une modification concurrente.</summary>
    [HttpPut("{siteId:guid}")]
    [SiteScoped]
    [HasPermission(PermissionResources.Sites, PermissionActions.Update)]
    [ProducesResponseType<SiteResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<SiteResponse>> Update(Guid siteId, [FromBody] UpdateSiteRequest request, CancellationToken cancellationToken)
        => Ok(await sites.UpdateAsync(siteId, request.ToDto(), cancellationToken));

    /// <summary>Archiver un chantier : lecture seule, restaurable, jamais supprimé.</summary>
    [HttpPost("{siteId:guid}/archive")]
    [SiteScoped]
    [HasPermission(PermissionResources.Sites, PermissionActions.Delete)]
    [ProducesResponseType<SiteResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<SiteResponse>> Archive(Guid siteId, CancellationToken cancellationToken)
        => Ok(await sites.ArchiveAsync(siteId, cancellationToken));

    /// <summary>Restaurer un chantier archivé.</summary>
    [HttpPost("{siteId:guid}/restore")]
    [SiteScoped]
    [HasPermission(PermissionResources.Sites, PermissionActions.Delete)]
    [ProducesResponseType<SiteResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<SiteResponse>> Restore(Guid siteId, CancellationToken cancellationToken)
        => Ok(await sites.RestoreAsync(siteId, cancellationToken));
}
