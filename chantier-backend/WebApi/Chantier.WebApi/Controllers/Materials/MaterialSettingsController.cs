using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Paging;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Models.Materials;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace Chantier.WebApi.Controllers.Materials;

/// <summary>Réglages des demandes de matériaux (date de besoin par défaut, tolérance, motifs...) : lus par le mobile à chaque synchronisation.</summary>
[ApiController]
[Route("api/v1/settings/materials")]
[Produces("application/json")]
public sealed class MaterialSettingsController(IOptions<MaterialsOptions> options, IOptions<PhotoStorageOptions> storage) : ControllerBase
{
    /// <summary>Réglages et listes de motifs. Réservé aux utilisateurs connectés ; aucune donnée personnelle ni prix.</summary>
    [HttpGet]
    [ProducesResponseType<MaterialSettingsResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    public ActionResult<MaterialSettingsResponse> Get()
        => Ok(MaterialSettingsResponse.From(options.Value, storage.Value.MaxPhotoBytes));
}
