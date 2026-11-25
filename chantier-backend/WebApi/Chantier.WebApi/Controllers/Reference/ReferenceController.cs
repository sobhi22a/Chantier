using Chantier.Core.Sites;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Reference;

/// <summary>Référentiel géographique (wilayas et communes), lu en base et mis en cache (H-14). Réservé aux utilisateurs connectés.</summary>
[ApiController]
[Route("api/v1/reference")]
[Produces("application/json")]
public sealed class ReferenceController(IReferenceService reference) : ControllerBase
{
    /// <summary>Liste des wilayas (code, nom français, nom arabe).</summary>
    [HttpGet("wilayas")]
    [ProducesResponseType<IReadOnlyList<WilayaResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    public async Task<ActionResult<IReadOnlyList<WilayaResponse>>> Wilayas(CancellationToken cancellationToken)
        => Ok(await reference.GetWilayasAsync(cancellationToken));

    /// <summary>Communes d'une wilaya (404 si le code est inconnu).</summary>
    [HttpGet("wilayas/{code}/communes")]
    [ProducesResponseType<IReadOnlyList<CommuneResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<IReadOnlyList<CommuneResponse>>> Communes(string code, CancellationToken cancellationToken)
        => Ok(await reference.GetCommunesAsync(code, cancellationToken));
}
