using Chantier.Core.DTOs.Materials;
using Chantier.Core.Paging;

namespace Chantier.Core.Materials;

public interface IProductService
{
    Task<PagedResult<ProductResponse>> ListAsync(ProductListQuery query, CancellationToken cancellationToken = default);

    Task<ProductResponse> GetAsync(Guid productId, CancellationToken cancellationToken = default);

    /// <summary><c>PRODUIT_EXISTANT</c> si le nom (sans casse, accents ni espaces superflus) est déjà pris.</summary>
    Task<ProductResponse> CreateAsync(ProductInput input, CancellationToken cancellationToken = default);

    Task<ProductResponse> UpdateAsync(Guid productId, UpdateProductDto dto, CancellationToken cancellationToken = default);

    /// <summary>Désactive ou réactive (jamais de suppression) ; idempotent.</summary>
    Task<ProductResponse> SetActiveAsync(Guid productId, bool active, CancellationToken cancellationToken = default);
}

public interface ISupplierService
{
    Task<PagedResult<SupplierResponse>> ListAsync(SupplierListQuery query, CancellationToken cancellationToken = default);

    Task<SupplierResponse> GetAsync(Guid supplierId, CancellationToken cancellationToken = default);

    Task<SupplierResponse> CreateAsync(SupplierInput input, CancellationToken cancellationToken = default);

    Task<SupplierResponse> UpdateAsync(Guid supplierId, UpdateSupplierDto dto, CancellationToken cancellationToken = default);

    Task<SupplierResponse> SetActiveAsync(Guid supplierId, bool active, CancellationToken cancellationToken = default);
}
