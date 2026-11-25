using Chantier.Core.Identity;
using Chantier.Core.Paging;
using Chantier.Core.Sites;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Filters;
using Chantier.WebApi.Models.Sites;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Sites;

/// <summary>Zones d'un chantier (bloc, cote, local). Les zones sont toujours lues par (chantier, identifiant).</summary>
[ApiController]
[SiteScoped]
[Route("api/v1/sites/{siteId:guid}/zones")]
[Produces("application/json")]
public sealed class ZonesController(IZoneService zones) : ControllerBase
{
    /// <summary>Zones du chantier, du plus bas au plus haut, avec pagination par curseur.</summary>
    /// <param name="block">Limiter à un bloc.</param>
    /// <param name="q">Recherche dans le bloc et le libellé.</param>
    /// <param name="includeArchived">Inclure les zones archivées.</param>
    /// <param name="pageSize">Taille de page (1 à 200).</param>
    /// <param name="cursor"><c>nextCursor</c> de la page précédente (opaque).</param>
    [HttpGet]
    [HasPermission(PermissionResources.Zones, PermissionActions.View)]
    [ProducesResponseType<CursorPage<ZoneResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<CursorPage<ZoneResponse>>> List(
        Guid siteId,
        [FromQuery] string? block,
        [FromQuery] string? q,
        [FromQuery] bool includeArchived = false,
        [FromQuery] int pageSize = 100,
        [FromQuery] string? cursor = null,
        CancellationToken cancellationToken = default)
        => Ok(await zones.ListAsync(siteId, new ZoneListQuery(block, q, includeArchived, pageSize, cursor), cancellationToken));

    /// <summary>Une zone du chantier.</summary>
    [HttpGet("{zoneId:guid}")]
    [HasPermission(PermissionResources.Zones, PermissionActions.View)]
    [ProducesResponseType<ZoneResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<ZoneResponse>> Get(Guid siteId, Guid zoneId, CancellationToken cancellationToken)
        => Ok(await zones.GetAsync(siteId, zoneId, cancellationToken));

    /// <summary>Ajouter une zone. Un même <c>clientId</c> renvoyé donne 200 et la même zone, sans doublon.</summary>
    [HttpPost]
    [HasPermission(PermissionResources.Zones, PermissionActions.Create)]
    [ProducesResponseType<ZoneResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<ZoneResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<ZoneResponse>> Create(Guid siteId, [FromBody] CreateZoneRequest request, CancellationToken cancellationToken)
    {
        var result = await zones.CreateAsync(siteId, request.ToDto(), cancellationToken);
        return result.Created
            ? CreatedAtAction(nameof(Get), new { siteId, zoneId = result.Zone.Id }, result.Zone)
            : Ok(result.Zone);
    }

    /// <summary>Modifier une zone. <c>version</c> détecte une modification concurrente (409 <c>CONFLIT_VERSION</c>) ; 422 <c>ZONE_EXISTANTE</c> si la position est prise.</summary>
    [HttpPut("{zoneId:guid}")]
    [HasPermission(PermissionResources.Zones, PermissionActions.Update)]
    [ProducesResponseType<ZoneResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<ZoneResponse>> Update(Guid siteId, Guid zoneId, [FromBody] UpdateZoneRequest request, CancellationToken cancellationToken)
        => Ok(await zones.UpdateAsync(siteId, zoneId, request.ToDto(), cancellationToken));

    /// <summary>Archiver une zone (Admin, ConducteurTravaux) : elle disparaît des choix mais pas de l'historique.</summary>
    [HttpPost("{zoneId:guid}/archive")]
    [HasPermission(PermissionResources.Zones, PermissionActions.Delete)]
    [ProducesResponseType<ZoneResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<ZoneResponse>> Archive(Guid siteId, Guid zoneId, CancellationToken cancellationToken)
        => Ok(await zones.ArchiveAsync(siteId, zoneId, cancellationToken));

    /// <summary>Restaurer une zone archivée (422 <c>ZONE_EXISTANTE</c> si une zone identique a été créée depuis).</summary>
    [HttpPost("{zoneId:guid}/restore")]
    [HasPermission(PermissionResources.Zones, PermissionActions.Delete)]
    [ProducesResponseType<ZoneResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<ZoneResponse>> Restore(Guid siteId, Guid zoneId, CancellationToken cancellationToken)
        => Ok(await zones.RestoreAsync(siteId, zoneId, cancellationToken));
}
