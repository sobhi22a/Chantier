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

/// <summary>
/// Catalogue des produits : <b>commun à tous les chantiers</b> (pas de chantier dans la route). Un produit n'est jamais supprimé : il est désactivé
/// et reste affiché dans l'historique.
/// </summary>
[ApiController]
[Route("api/v1/products")]
[Produces("application/json")]
public sealed class ProductsController(IProductService products) : ControllerBase
{
    /// <summary>Produits du catalogue, avec recherche insensible aux accents et pagination avec total.</summary>
    /// <param name="q">Recherche dans le nom (français ou arabe).</param>
    /// <param name="category">Limiter à une catégorie.</param>
    /// <param name="isActive">Limiter aux produits actifs (<c>true</c>) ou désactivés (<c>false</c>).</param>
    /// <param name="sort"><c>name</c> (défaut), <c>-name</c>, <c>category</c>, <c>-category</c>, <c>createdAt</c>, <c>-createdAt</c>.</param>
    /// <param name="page">Numéro de page, à partir de 1.</param>
    /// <param name="pageSize">Taille de page (1 à 200).</param>
    [HttpGet]
    [HasPermission(PermissionResources.Products, PermissionActions.View)]
    [ProducesResponseType<PagedResult<ProductResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    public async Task<ActionResult<PagedResult<ProductResponse>>> List(
        [FromQuery] string? q,
        [FromQuery] ProductCategory? category,
        [FromQuery] bool? isActive,
        [FromQuery] string? sort = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = PagingRules.DefaultPageSize,
        CancellationToken cancellationToken = default)
        => Ok(await products.ListAsync(new ProductListQuery(q, category, isActive, sort, page, pageSize), cancellationToken));

    /// <summary>Un produit du catalogue.</summary>
    [HttpGet("{productId:guid}")]
    [HasPermission(PermissionResources.Products, PermissionActions.View)]
    [ProducesResponseType<ProductResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<ProductResponse>> Get(Guid productId, CancellationToken cancellationToken)
        => Ok(await products.GetAsync(productId, cancellationToken));

    /// <summary>Créer un produit (Achats, Admin). 422 <c>PRODUIT_EXISTANT</c>, <c>MASSE_SAC_OBLIGATOIRE</c>, <c>UNITE_NON_AUTORISEE</c>.</summary>
    [HttpPost]
    [HasPermission(PermissionResources.Products, PermissionActions.Create)]
    [ProducesResponseType<ProductResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<ProductResponse>> Create([FromBody] CreateProductRequest request, CancellationToken cancellationToken)
    {
        var created = await products.CreateAsync(request.ToDto(), cancellationToken);
        return CreatedAtAction(nameof(Get), new { productId = created.Id }, created);
    }

    /// <summary>Modifier un produit (Achats, Admin). <c>version</c> détecte une modification concurrente (409 <c>CONFLIT_VERSION</c>).</summary>
    [HttpPut("{productId:guid}")]
    [HasPermission(PermissionResources.Products, PermissionActions.Update)]
    [ProducesResponseType<ProductResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status409Conflict, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<ActionResult<ProductResponse>> Update(Guid productId, [FromBody] UpdateProductRequest request, CancellationToken cancellationToken)
        => Ok(await products.UpdateAsync(productId, request.ToDto(), cancellationToken));

    /// <summary>Désactiver un produit : il reste dans l'historique mais ne peut plus être demandé ni livré. Idempotent.</summary>
    [HttpPost("{productId:guid}/deactivate")]
    [HasPermission(PermissionResources.Products, PermissionActions.Update)]
    [ProducesResponseType<ProductResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<ProductResponse>> Deactivate(Guid productId, CancellationToken cancellationToken)
        => Ok(await products.SetActiveAsync(productId, active: false, cancellationToken));

    /// <summary>Réactiver un produit désactivé. Idempotent.</summary>
    [HttpPost("{productId:guid}/activate")]
    [HasPermission(PermissionResources.Products, PermissionActions.Update)]
    [ProducesResponseType<ProductResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json")]
    public async Task<ActionResult<ProductResponse>> Activate(Guid productId, CancellationToken cancellationToken)
        => Ok(await products.SetActiveAsync(productId, active: true, cancellationToken));
}
