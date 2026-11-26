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
/// Demandes de matériaux d'un chantier (DEM-001...). Un chantier non affecté est introuvable, exactement comme un chantier inexistant.
/// Les enchaînements métier sont des actions explicites (<c>approve</c>, <c>reject</c>...), jamais un changement de statut libre. Chaque action est
/// idempotente : rejouer une action déjà faite rend 200 et la demande, sans nouvel historique.
/// </summary>
[ApiController]
[SiteScoped]
[Route("api/v1/sites/{siteId:guid}/requests")]
[Produces("application/json")]
public sealed class RequestsController(IRequestService requests) : ControllerBase
{
    /// <summary>Demandes du chantier (vue « à suivre » par défaut), avec filtres, recherche, tri et pagination avec total.</summary>
    /// <param name="view"><c>toFollow</c> (défaut), <c>toApprove</c>, <c>toOrder</c>, <c>expected</c>, <c>late</c> (date de besoin ou livraison prévue dépassée), <c>toReceive</c>, <c>received</c>, <c>closed</c> ou <c>archived</c>. Les demandes archivées ne figurent que dans <c>archived</c>.</param>
    /// <param name="mine">Seulement mes demandes.</param>
    /// <param name="status">Limiter à un statut.</param>
    /// <param name="priority">Limiter à une urgence.</param>
    /// <param name="zoneId">Limiter à une zone.</param>
    /// <param name="productId">Limiter à un produit du catalogue.</param>
    /// <param name="supplierId">Limiter aux demandes dont la commande active est chez ce fournisseur.</param>
    /// <param name="from">Date de besoin à partir de (incluse).</param>
    /// <param name="to">Date de besoin jusqu'à (incluse).</param>
    /// <param name="q">Recherche dans le numéro (<c>DEM-014</c>), le produit et la remarque.</param>
    /// <param name="sort"><c>neededBy</c>, <c>-neededBy</c>, <c>number</c>, <c>-number</c>, <c>createdAt</c>, <c>-createdAt</c>, <c>priority</c> ; par défaut les plus urgentes d'abord (vue à suivre) ou par date de besoin.</param>
    /// <param name="page">Numéro de page, à partir de 1.</param>
    /// <param name="pageSize">Taille de page (1 à 200).</param>
    [HttpGet]
    [HasPermission(PermissionResources.Requests, PermissionActions.View)]
    [ProducesResponseType<PagedResult<MaterialRequestResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<PagedResult<MaterialRequestResponse>>> List(
        Guid siteId,
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
        => Ok(await requests.ListAsync(
            new RequestListQuery(siteId, view, mine, status, priority, zoneId, productId, from, to, q, sort, page, pageSize, supplierId),
            cancellationToken));

    /// <summary>Une demande avec son historique (qui, quand, ancien et nouveau statut, motif).</summary>
    [HttpGet("{requestId:guid}")]
    [HasPermission(PermissionResources.Requests, PermissionActions.View)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Get(Guid siteId, Guid requestId, CancellationToken cancellationToken)
        => Ok(await requests.GetAsync(siteId, requestId, cancellationToken));

    /// <summary>
    /// Signaler un besoin. Le numéro <c>DEM-nnn</c> est donné par le serveur. Un même <c>clientId</c> renvoyé donne 200 et la même demande, sans doublon ni nouveau numéro.
    /// </summary>
    [HttpPost]
    [HasPermission(PermissionResources.Requests, PermissionActions.Create)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Create(Guid siteId, [FromBody] CreateRequestRequest request, CancellationToken cancellationToken)
    {
        var result = await requests.CreateAsync(siteId, request.ToDto(), cancellationToken: cancellationToken);
        return result.Created
            ? CreatedAtAction(nameof(Get), new { siteId, requestId = result.Request.Id }, result.Request)
            : Ok(result.Request);
    }

    /// <summary>
    /// Modifier une demande. Jusqu'à la validation tous les champs ; après, seulement date, urgence et remarque (droit <c>Requests.UpdateAny</c>) :
    /// 422 <c>DEMANDE_VERROUILLEE</c> pour produit, quantité, unité ou zone. 409 <c>CONFLIT_VERSION</c> (avec l'état courant) si la version est périmée.
    /// </summary>
    [HttpPut("{requestId:guid}")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Update)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Update(Guid siteId, Guid requestId, [FromBody] UpdateRequestRequest request, CancellationToken cancellationToken)
        => Ok(await requests.UpdateAsync(siteId, requestId, request.ToDto(), cancellationToken));

    /// <summary>Valider (conducteur), avec une quantité ajustée facultative. Déjà validée : 200 sans effet ; autre statut : 422 <c>TRANSITION_INTERDITE</c>.</summary>
    [HttpPost("{requestId:guid}/approve")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Approve)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Approve(
        Guid siteId, Guid requestId, [FromBody(EmptyBodyBehavior = Microsoft.AspNetCore.Mvc.ModelBinding.EmptyBodyBehavior.Allow)] ApproveBody? body, CancellationToken cancellationToken)
        => Ok((await requests.ApproveAsync(siteId, requestId, body?.Quantity?.ToInput(), cancellationToken: cancellationToken)).Request);

    /// <summary>Refuser (conducteur), avec un motif de la liste. Déjà refusée : 200 sans effet.</summary>
    [HttpPost("{requestId:guid}/reject")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Approve)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Reject(Guid siteId, Guid requestId, [FromBody] ReasonBody body, CancellationToken cancellationToken)
        => Ok((await requests.RejectAsync(siteId, requestId, body.ReasonCode, body.ReasonNote, cancellationToken: cancellationToken)).Request);

    /// <summary>
    /// Annuler une demande demandée ou validée, avec un motif. L'auteur annule la sienne (droit <c>Requests.Cancel</c>), le conducteur toutes
    /// (<c>Requests.CancelAny</c>). Déjà annulée : 200, le premier motif est conservé. Commandée ou au-delà : 422 <c>TRANSITION_INTERDITE</c> (contacter les Achats).
    /// </summary>
    [HttpPost("{requestId:guid}/cancel")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Cancel)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Cancel(Guid siteId, Guid requestId, [FromBody] ReasonBody body, CancellationToken cancellationToken)
        => Ok((await requests.CancelAsync(siteId, requestId, body.ReasonCode, body.ReasonNote, cancellationToken: cancellationToken)).Request);

    /// <summary>Réceptionner une demande livrée (chef de chantier). Déjà réceptionnée : 200 sans effet ; autre statut : 422 <c>TRANSITION_INTERDITE</c>.</summary>
    [HttpPost("{requestId:guid}/receive")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Receive)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Receive(
        Guid siteId, Guid requestId, [FromBody(EmptyBodyBehavior = Microsoft.AspNetCore.Mvc.ModelBinding.EmptyBodyBehavior.Allow)] ReceiveBody? body, CancellationToken cancellationToken)
        => Ok((await requests.ReceiveAsync(siteId, requestId, body?.Note, cancellationToken: cancellationToken)).Request);

    /// <summary>Solder un manque définitif (Achats, conducteur) : livrée partiellement vers livrée, avec un motif. Réseau exigé (jamais en synchronisation).</summary>
    [HttpPost("{requestId:guid}/settle")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Settle)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Settle(Guid siteId, Guid requestId, [FromBody] ReasonBody body, CancellationToken cancellationToken)
        => Ok((await requests.SettleAsync(siteId, requestId, body.ReasonCode, body.ReasonNote, cancellationToken)).Request);

    /// <summary>Rattacher un produit du catalogue à une demande en nom libre (Achats) ; le nom libre est conservé, quantité et unité sont revérifiées.</summary>
    [HttpPost("{requestId:guid}/link-product")]
    [HasPermission(PermissionResources.Requests, PermissionActions.LinkProduct)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> LinkProduct(Guid siteId, Guid requestId, [FromBody] LinkProductBody body, CancellationToken cancellationToken)
        => Ok((await requests.LinkProductAsync(siteId, requestId, body.ProductId!.Value, cancellationToken)).Request);

    /// <summary>Archiver une demande refusée, annulée ou réceptionnée (conducteur) : jamais d'effacement. Une demande ouverte : 422 <c>TRANSITION_INTERDITE</c>.</summary>
    [HttpPost("{requestId:guid}/archive")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Archive)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Archive(Guid siteId, Guid requestId, CancellationToken cancellationToken)
        => Ok((await requests.ArchiveAsync(siteId, requestId, cancellationToken)).Request);

    /// <summary>Restaurer une demande archivée : elle reprend son statut.</summary>
    [HttpPost("{requestId:guid}/restore")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Archive)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Restore(Guid siteId, Guid requestId, CancellationToken cancellationToken)
        => Ok((await requests.RestoreAsync(siteId, requestId, cancellationToken)).Request);

    /// <summary>Valider jusqu'à 50 demandes d'un coup : un résultat par demande (<c>applied</c>, <c>duplicate</c>, <c>rejected</c> avec <c>code</c>), chacune dans sa propre transaction.</summary>
    [HttpPost("batch/approve")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Approve)]
    [ProducesResponseType<BatchResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<BatchResponse>> ApproveBatch(Guid siteId, [FromBody] RequestIdsBody body, CancellationToken cancellationToken)
        => Ok(await requests.ApproveBatchAsync(siteId, body.RequestIds!, cancellationToken));

    /// <summary>Archiver jusqu'à 100 demandes d'un coup : un résultat par demande.</summary>
    [HttpPost("batch/archive")]
    [HasPermission(PermissionResources.Requests, PermissionActions.Archive)]
    [ProducesResponseType<BatchResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<BatchResponse>> ArchiveBatch(Guid siteId, [FromBody] RequestIdsBody body, CancellationToken cancellationToken)
        => Ok(await requests.ArchiveBatchAsync(siteId, body.RequestIds!, cancellationToken));
}
