using Chantier.Core.Sync;
using Chantier.WebApi.Models.Sync;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Sync;

/// <summary>
/// Synchronisation hors ligne (ADR 0009). Reservee aux utilisateurs connectes ; chaque entite verifie ensuite le role et l'affectation
/// au chantier (le pull ne renvoie que les chantiers affectes, le push verifie chaque operation).
/// </summary>
[ApiController]
[Route("api/v1/sync")]
[Produces("application/json")]
public sealed class SyncController(ISyncPullService pull, ISyncPushService push) : ControllerBase
{
    /// <summary>Changements depuis le curseur (lecture).</summary>
    /// <remarks>
    /// <c>since</c> est le curseur renvoyé par le serveur (jamais l'horloge du téléphone) ; absent ou <c>0</c> = première synchronisation.
    /// <c>siteId</c> est facultatif : absent = tous les chantiers visibles. Répéter l'appel tant que <c>hasMore</c> vaut vrai.
    /// Une ligne n'est à appliquer que si sa <c>version</c> est plus grande que celle déjà connue.
    /// </remarks>
    /// <param name="since">Curseur reçu du serveur ; absent ou <c>0</c> = première synchronisation.</param>
    /// <param name="siteId">Limiter à un chantier (404 s'il n'est pas affecté) ; absent = tous les chantiers visibles.</param>
    /// <param name="limit">Nombre de lignes par page (1 à 500, 200 par défaut).</param>
    [HttpGet("changes")]
    [ProducesResponseType<SyncPullResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<SyncPullResponse>> Changes(
        [FromQuery] string? since,
        [FromQuery] Guid? siteId,
        [FromQuery] int limit = SyncLimits.DefaultPullLimit,
        CancellationToken cancellationToken = default)
        => Ok(await pull.PullAsync(since, siteId, limit, cancellationToken));

    /// <summary>Envoyer un lot d'opérations saisies hors ligne.</summary>
    /// <remarks>
    /// Réponse 200 avec un résultat par opération, dans l'ordre : <c>applied</c>, <c>duplicate</c> (déjà reçue, éventuellement
    /// <c>merged</c>), <c>conflict</c> ou <c>rejected</c> (avec <c>code</c>). Un lot peut réussir partiellement : ne rejouer que ce qui doit l'être.
    /// </remarks>
    [HttpPost("push")]
    [RequestSizeLimit(SyncLimits.MaxBodyBytes)]
    [ProducesResponseType<SyncPushResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status413PayloadTooLarge, "application/problem+json")]
    public async Task<ActionResult<SyncPushResponse>> Push([FromBody] SyncPushRequest request, CancellationToken cancellationToken)
        => Ok(await push.PushAsync(request.ToOperations(), cancellationToken));
}
