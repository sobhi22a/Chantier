using Ardalis.Specification;
using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Common;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Paging;
using Chantier.Core.Sites;
using Chantier.Core.Specifications.Materials;
using Chantier.Core.Validation;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>Controles communs des listes du back-office : page, taille de page et tri connu (400 <c>VALIDATION</c> sinon).</summary>
internal static class ListRules
{
    public static string Check(int page, int pageSize, string? sort, string[] allowedSorts)
    {
        var errors = new ErrorCollector();
        if (page < 1)
        {
            errors.Add("page", "La page doit être supérieure ou égale à 1.");
        }

        if (pageSize is < 1 or > PagingRules.MaxPageSize)
        {
            errors.Add("pageSize", $"La taille de page doit être comprise entre 1 et {PagingRules.MaxPageSize}.");
        }

        var resolved = string.IsNullOrWhiteSpace(sort) ? allowedSorts[0] : sort;
        if (!allowedSorts.Contains(resolved))
        {
            errors.Add("sort", "Tri inconnu.");
        }

        errors.ThrowIfAny();
        return resolved;
    }

    public static async Task EnsureVersionAsync(BasicEntity entity, string version, Func<Task<object>> current)
    {
        if (!BasicEntity.TryParseVersion(version, out var parsed))
        {
            throw new Core.Exceptions.ValidationException("version", "La version est invalide.");
        }

        if (parsed != entity.RowVersion)
        {
            throw new ConflictException(await current());
        }
    }
}

/// <summary>
/// Catalogue des produits (global, tenu par Achats et Admin sur le web). Jamais de suppression : desactivation. L'unicite du nom ignore la casse,
/// les accents et les espaces superflus ; l'index unique tranche les creations simultanees.
/// </summary>
public sealed class ProductService(
    IRepositoryBase<Product> products,
    ApplicationDbContext db,
    IUserDirectory directory,
    TimeProvider time) : IProductService
{
    public async Task<PagedResult<ProductResponse>> ListAsync(ProductListQuery query, CancellationToken cancellationToken = default)
    {
        var sort = ListRules.Check(query.Page, query.PageSize, query.Sort, ProductsSearchSpecification.SortValues);
        var specification = new ProductsSearchSpecification(query.Search, query.Category, query.IsActive, sort, query.Page, query.PageSize);

        var total = await products.CountAsync(specification, cancellationToken);
        var rows = await products.ListAsync(specification, cancellationToken);
        return new PagedResult<ProductResponse>(await ToResponsesAsync(rows, cancellationToken), query.Page, query.PageSize, total);
    }

    public async Task<ProductResponse> GetAsync(Guid productId, CancellationToken cancellationToken = default)
        => await ToResponseAsync(await LoadAsync(productId, cancellationToken), cancellationToken);

    public async Task<ProductResponse> CreateAsync(ProductInput input, CancellationToken cancellationToken = default)
    {
        var product = Product.Create(input);
        await EnsureNameFreeAsync(product.NormalizedNameFr, null, cancellationToken);

        try
        {
            await products.AddAsync(product, cancellationToken);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            throw NameTaken();
        }

        return await ToResponseAsync(product, cancellationToken);
    }

    public async Task<ProductResponse> UpdateAsync(Guid productId, UpdateProductDto dto, CancellationToken cancellationToken = default)
    {
        var product = await LoadAsync(productId, cancellationToken);
        await ListRules.EnsureVersionAsync(product, dto.Version, async () => await ToResponseAsync(product, cancellationToken));

        product.Update(dto.Data);
        await EnsureNameFreeAsync(product.NormalizedNameFr, product.Id, cancellationToken);

        try
        {
            await products.UpdateAsync(product, cancellationToken);
        }
        catch (DbUpdateConcurrencyException)
        {
            await db.Entry(product).ReloadAsync(cancellationToken);
            throw new ConflictException(await ToResponseAsync(product, cancellationToken));
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            throw NameTaken();
        }

        return await ToResponseAsync(product, cancellationToken);
    }

    public async Task<ProductResponse> SetActiveAsync(Guid productId, bool active, CancellationToken cancellationToken = default)
    {
        var product = await LoadAsync(productId, cancellationToken);
        if (product.IsActive != active)
        {
            if (active)
            {
                product.Activate();
            }
            else
            {
                product.Deactivate(time.GetUtcNow());
            }

            await products.UpdateAsync(product, cancellationToken);
        }

        return await ToResponseAsync(product, cancellationToken);
    }

    private async Task<Product> LoadAsync(Guid productId, CancellationToken cancellationToken)
        => await products.GetByIdAsync(productId, cancellationToken) ?? throw new NotFoundException();

    private async Task EnsureNameFreeAsync(string normalizedName, Guid? exceptId, CancellationToken cancellationToken)
    {
        if (await products.AnyAsync(new ProductByNormalizedNameSpecification(normalizedName, exceptId), cancellationToken))
        {
            throw NameTaken();
        }
    }

    private static DomainRuleException NameTaken()
        => new(ErrorCodes.ProduitExistant, "Un produit de même nom existe déjà.");

    private async Task<ProductResponse> ToResponseAsync(Product product, CancellationToken cancellationToken)
        => (await ToResponsesAsync([product], cancellationToken))[0];

    private async Task<List<ProductResponse>> ToResponsesAsync(IReadOnlyCollection<Product> rows, CancellationToken cancellationToken)
    {
        var names = await directory.GetNamesAsync(rows.SelectMany(ProductResponse.AuditUsers), cancellationToken);
        return rows.Select(product => ProductResponse.From(product, names)).ToList();
    }
}

/// <summary>
/// Fournisseurs (global). Le telephone n'est lu qu'avec <c>SupplierPhone.View</c> ; il n'est jamais journalise : aucun message, aucun
/// parametre de journal ne le contient.
/// </summary>
public sealed class SupplierService(
    IRepositoryBase<Supplier> suppliers,
    IRepositoryBase<Product> products,
    ApplicationDbContext db,
    IUserPermissions permissions,
    IUserDirectory directory,
    TimeProvider time) : ISupplierService
{
    public async Task<PagedResult<SupplierResponse>> ListAsync(SupplierListQuery query, CancellationToken cancellationToken = default)
    {
        var sort = ListRules.Check(query.Page, query.PageSize, query.Sort, SuppliersSearchSpecification.SortValues);
        var specification = new SuppliersSearchSpecification(query.Search, query.IsActive, sort, query.Page, query.PageSize);

        var total = await suppliers.CountAsync(specification, cancellationToken);
        var rows = await suppliers.ListAsync(specification, cancellationToken);
        return new PagedResult<SupplierResponse>(await ToResponsesAsync(rows, cancellationToken), query.Page, query.PageSize, total);
    }

    public async Task<SupplierResponse> GetAsync(Guid supplierId, CancellationToken cancellationToken = default)
        => await ToResponseAsync(await LoadAsync(supplierId, cancellationToken), cancellationToken);

    public async Task<SupplierResponse> CreateAsync(SupplierInput input, CancellationToken cancellationToken = default)
    {
        var supplier = Supplier.Create(input);
        await EnsureProductsExistAsync(supplier.ProductIds, cancellationToken);
        await EnsureNameFreeAsync(supplier.NormalizedName, null, cancellationToken);

        try
        {
            await suppliers.AddAsync(supplier, cancellationToken);
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            throw NameTaken();
        }

        return await ToResponseAsync(supplier, cancellationToken);
    }

    public async Task<SupplierResponse> UpdateAsync(Guid supplierId, UpdateSupplierDto dto, CancellationToken cancellationToken = default)
    {
        var supplier = await LoadAsync(supplierId, cancellationToken);
        await ListRules.EnsureVersionAsync(supplier, dto.Version, async () => await ToResponseAsync(supplier, cancellationToken));

        supplier.Update(dto.Data);
        await EnsureProductsExistAsync(supplier.ProductIds, cancellationToken);
        await EnsureNameFreeAsync(supplier.NormalizedName, supplier.Id, cancellationToken);

        try
        {
            await suppliers.UpdateAsync(supplier, cancellationToken);
        }
        catch (DbUpdateConcurrencyException)
        {
            await db.Entry(supplier).ReloadAsync(cancellationToken);
            throw new ConflictException(await ToResponseAsync(supplier, cancellationToken));
        }
        catch (DbUpdateException exception) when (exception.IsUniqueViolation())
        {
            throw NameTaken();
        }

        return await ToResponseAsync(supplier, cancellationToken);
    }

    public async Task<SupplierResponse> SetActiveAsync(Guid supplierId, bool active, CancellationToken cancellationToken = default)
    {
        var supplier = await LoadAsync(supplierId, cancellationToken);
        if (supplier.IsActive != active)
        {
            if (active)
            {
                supplier.Activate();
            }
            else
            {
                supplier.Deactivate(time.GetUtcNow());
            }

            await suppliers.UpdateAsync(supplier, cancellationToken);
        }

        return await ToResponseAsync(supplier, cancellationToken);
    }

    private async Task<Supplier> LoadAsync(Guid supplierId, CancellationToken cancellationToken)
        => await suppliers.GetByIdAsync(supplierId, cancellationToken) ?? throw new NotFoundException();

    private async Task EnsureNameFreeAsync(string normalizedName, Guid? exceptId, CancellationToken cancellationToken)
    {
        if (await suppliers.AnyAsync(new SupplierByNormalizedNameSpecification(normalizedName, exceptId), cancellationToken))
        {
            throw NameTaken();
        }
    }

    private async Task EnsureProductsExistAsync(IReadOnlyCollection<Guid> productIds, CancellationToken cancellationToken)
    {
        if (productIds.Count == 0)
        {
            return;
        }

        var found = await products.CountAsync(new ProductsByIdsSpecification(productIds), cancellationToken);
        if (found != productIds.Count)
        {
            throw new Core.Exceptions.ValidationException("productIds", "Un produit de la liste n'existe pas dans le catalogue.");
        }
    }

    private static DomainRuleException NameTaken()
        => new(ErrorCodes.FournisseurExistant, "Un fournisseur de même nom existe déjà.");

    private async Task<SupplierResponse> ToResponseAsync(Supplier supplier, CancellationToken cancellationToken)
        => (await ToResponsesAsync([supplier], cancellationToken))[0];

    private async Task<List<SupplierResponse>> ToResponsesAsync(IReadOnlyCollection<Supplier> rows, CancellationToken cancellationToken)
    {
        var names = await directory.GetNamesAsync(rows.SelectMany(SupplierResponse.AuditUsers), cancellationToken);
        var includePhone = await permissions.HasAsync(Permissions.SupplierPhoneView, cancellationToken);
        return rows.Select(supplier => SupplierResponse.From(supplier, includePhone, names)).ToList();
    }
}
