using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Filters;
using Chantier.WebApi.Models.Materials;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Materials;

/// <summary>
/// Commande d'une demande (une seule commande active par demande, sans numéro propre). Réservée aux Achats et à l'Admin ; le prix, le montant et le n° de bon de commande
/// n'apparaissent que pour les rôles qui voient les prix (objet <c>order.commercial</c>). Un chantier non affecté est introuvable (404).
/// </summary>
[ApiController]
[SiteScoped]
[Route("api/v1/sites/{siteId:guid}/requests/{requestId:guid}/order")]
[Produces("application/json")]
public sealed class OrdersController(IOrderService orders) : ControllerBase
{
    /// <summary>
    /// Commander une demande validée : elle passe à <c>Ordered</c>, puis son statut est recalculé d'après les livraisons déjà retenues (livraison reçue avant la commande).
    /// Montant = quantité × prix unitaire, arrondi au centime (300 sacs × 780,00 = 234 000,00 DZD). Un même <c>clientId</c> renvoyé donne 200 et la même commande.
    /// </summary>
    [HttpPost]
    [HasPermission(PermissionResources.Orders, PermissionActions.Create)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Create(Guid siteId, Guid requestId, [FromBody] CreateOrderRequest request, CancellationToken cancellationToken)
    {
        var result = await orders.CreateAsync(siteId, requestId, request.ToDto(), cancellationToken);
        return result.Created
            ? Created($"/api/v1/sites/{siteId}/requests/{requestId}", result.Request)
            : Ok(result.Request);
    }

    /// <summary>Modifier la commande (fournisseur, livraison prévue, prix, n° de bon de commande, remarque) tant que la demande n'est pas livrée. 409 <c>CONFLIT_VERSION</c> si la version est périmée.</summary>
    [HttpPut]
    [HasPermission(PermissionResources.Orders, PermissionActions.Update)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Update(Guid siteId, Guid requestId, [FromBody] UpdateOrderRequest request, CancellationToken cancellationToken)
        => Ok(await orders.UpdateAsync(siteId, requestId, request.ToDto(), cancellationToken));

    /// <summary>Annuler la commande d'une demande sans livraison non annulée, avec un motif : la demande redevient <c>Validated</c>. Avec une livraison : 422 <c>TRANSITION_INTERDITE</c>.</summary>
    [HttpPost("cancel")]
    [HasPermission(PermissionResources.Orders, PermissionActions.Cancel)]
    [ProducesResponseType<MaterialRequestDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status403Forbidden, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<MaterialRequestDetailResponse>> Cancel(Guid siteId, Guid requestId, [FromBody] ReasonBody body, CancellationToken cancellationToken)
        => Ok(await orders.CancelAsync(siteId, requestId, body.ReasonCode, body.ReasonNote, cancellationToken));
}
