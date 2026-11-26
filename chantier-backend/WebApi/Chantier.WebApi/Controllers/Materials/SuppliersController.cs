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

/// <summary>Fournisseurs : <b>communs à tous les chantiers</b>. Le téléphone n'est renvoyé qu'avec <c>SupplierPhone.View</c>.</summary>
[ApiController]
[Route("api/v1/suppliers")]
[Produces("application/json")]
public sealed class SuppliersController(ISupplierService suppliers) : ControllerBase
{
    /// <summary>Fournisseurs, avec recherche insensible aux accents et pagination avec total.</summary>
    /// <param name="q">Recherche dans le nom.</param>
    /// <param name="isActive">Limiter aux fournisseurs actifs (<c>true</c>) ou désactivés (<c>false</c>).</param>
    /// <param name="sort"><c>name</c> (défaut), <c>-name</c>, <c>createdAt</c>, <c>-createdAt</c>.</param>
    /// <param name="page">Numéro de page, à partir de 1.</param>
    /// <param name="pageSize">Taille de page (1 à 200).</param>
    [HttpGet]
    [HasPermission(PermissionResources.Suppliers, PermissionActions.View)]
    [ProducesResponseType<PagedResult<SupplierResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    public async Task<ActionResult<PagedResult<SupplierResponse>>> List(
        [FromQuery] string? q,
        [FromQuery] bool? isActive,
        [FromQuery] string? sort = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = PagingRules.DefaultPageSize,
        CancellationToken cancellationToken = default)
        => Ok(await suppliers.ListAsync(new SupplierListQuery(q, isActive, sort, page, pageSize), cancellationToken));

    /// <summary>Un fournisseur (c'est ici qu'un téléphone est lu, en ligne seulement).</summary>
    [HttpGet("{supplierId:guid}")]
    [HasPermission(PermissionResources.Suppliers, PermissionActions.View)]
    [ProducesResponseType<SupplierResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<SupplierResponse>> Get(Guid supplierId, CancellationToken cancellationToken)
        => Ok(await suppliers.GetAsync(supplierId, cancellationToken));

    /// <summary>Créer un fournisseur (Achats, Admin). 422 <c>FOURNISSEUR_EXISTANT</c>.</summary>
    [HttpPost]
    [HasPermission(PermissionResources.Suppliers, PermissionActions.Create)]
    [ProducesResponseType<SupplierResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<SupplierResponse>> Create([FromBody] CreateSupplierRequest request, CancellationToken cancellationToken)
    {
        var created = await suppliers.CreateAsync(request.ToDto(), cancellationToken);
        return CreatedAtAction(nameof(Get), new { supplierId = created.Id }, created);
    }

    /// <summary>Modifier un fournisseur (Achats, Admin). <c>version</c> détecte une modification concurrente (409 <c>CONFLIT_VERSION</c>).</summary>
    [HttpPut("{supplierId:guid}")]
    [HasPermission(PermissionResources.Suppliers, PermissionActions.Update)]
    [ProducesResponseType<SupplierResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<SupplierResponse>> Update(Guid supplierId, [FromBody] UpdateSupplierRequest request, CancellationToken cancellationToken)
        => Ok(await suppliers.UpdateAsync(supplierId, request.ToDto(), cancellationToken));

    /// <summary>Désactiver un fournisseur : il reste dans l'historique mais ne peut plus recevoir de commande. Idempotent.</summary>
    [HttpPost("{supplierId:guid}/deactivate")]
    [HasPermission(PermissionResources.Suppliers, PermissionActions.Update)]
    [ProducesResponseType<SupplierResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<SupplierResponse>> Deactivate(Guid supplierId, CancellationToken cancellationToken)
        => Ok(await suppliers.SetActiveAsync(supplierId, active: false, cancellationToken));

    /// <summary>Réactiver un fournisseur désactivé. Idempotent.</summary>
    [HttpPost("{supplierId:guid}/activate")]
    [HasPermission(PermissionResources.Suppliers, PermissionActions.Update)]
    [ProducesResponseType<SupplierResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<SupplierResponse>> Activate(Guid supplierId, CancellationToken cancellationToken)
        => Ok(await suppliers.SetActiveAsync(supplierId, active: true, cancellationToken));
}
