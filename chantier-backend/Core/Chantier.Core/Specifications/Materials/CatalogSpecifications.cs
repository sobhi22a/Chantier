using Ardalis.Specification;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;

namespace Chantier.Core.Specifications.Materials;

/// <summary>
/// Produits du catalogue : recherche insensible a la casse et aux accents (sur le nom normalise et le nom arabe), filtres categorie et etat, tri.
/// Tri et pagination ne servent que pour <c>ListAsync</c> : <c>CountAsync</c> n'evalue que les criteres.
/// </summary>
public sealed class ProductsSearchSpecification : Specification<Product>
{
    public static readonly string[] SortValues = ["name", "-name", "category", "-category", "createdAt", "-createdAt"];

    public ProductsSearchSpecification(string? search, ProductCategory? category, bool? isActive, string sort = "name", int page = 1, int pageSize = 50)
    {
        if (!string.IsNullOrWhiteSpace(search))
        {
            var normalized = NameNormalizer.Normalize(search);
            var text = search.Trim();
            Query.Where(product => product.NormalizedNameFr.Contains(normalized) || (product.NameAr != null && product.NameAr.Contains(text)));
        }

        if (category is { } wanted)
        {
            Query.Where(product => product.Category == wanted);
        }

        if (isActive is { } active)
        {
            Query.Where(product => product.IsActive == active);
        }

        switch (sort)
        {
            case "-name":
                Query.OrderByDescending(product => product.NormalizedNameFr).ThenBy(product => product.Id);
                break;
            case "category":
                Query.OrderBy(product => product.Category).ThenBy(product => product.NormalizedNameFr).ThenBy(product => product.Id);
                break;
            case "-category":
                Query.OrderByDescending(product => product.Category).ThenBy(product => product.NormalizedNameFr).ThenBy(product => product.Id);
                break;
            case "createdAt":
                Query.OrderBy(product => product.CreatedAt).ThenBy(product => product.Id);
                break;
            case "-createdAt":
                Query.OrderByDescending(product => product.CreatedAt).ThenBy(product => product.Id);
                break;
            default:
                Query.OrderBy(product => product.NormalizedNameFr).ThenBy(product => product.Id);
                break;
        }

        Query.Skip((page - 1) * pageSize).Take(pageSize);
    }
}

/// <summary>Un produit actif ou non, par nom normalise (unicite) ; <c>exceptId</c> exclut le produit en cours de modification.</summary>
public sealed class ProductByNormalizedNameSpecification : Specification<Product>, ISingleResultSpecification<Product>
{
    public ProductByNormalizedNameSpecification(string normalizedName, Guid? exceptId = null)
    {
        Query.Where(product => product.NormalizedNameFr == normalizedName);
        if (exceptId is { } except)
        {
            Query.Where(product => product.Id != except);
        }
    }
}

public sealed class ProductsByIdsSpecification : Specification<Product>
{
    public ProductsByIdsSpecification(IReadOnlyCollection<Guid> ids)
    {
        Query.Where(product => ids.Contains(product.Id));
    }
}

public sealed class SuppliersSearchSpecification : Specification<Supplier>
{
    public static readonly string[] SortValues = ["name", "-name", "createdAt", "-createdAt"];

    public SuppliersSearchSpecification(string? search, bool? isActive, string sort = "name", int page = 1, int pageSize = 50)
    {
        if (!string.IsNullOrWhiteSpace(search))
        {
            var normalized = NameNormalizer.Normalize(search);
            Query.Where(supplier => supplier.NormalizedName.Contains(normalized));
        }

        if (isActive is { } active)
        {
            Query.Where(supplier => supplier.IsActive == active);
        }

        switch (sort)
        {
            case "-name":
                Query.OrderByDescending(supplier => supplier.NormalizedName).ThenBy(supplier => supplier.Id);
                break;
            case "createdAt":
                Query.OrderBy(supplier => supplier.CreatedAt).ThenBy(supplier => supplier.Id);
                break;
            case "-createdAt":
                Query.OrderByDescending(supplier => supplier.CreatedAt).ThenBy(supplier => supplier.Id);
                break;
            default:
                Query.OrderBy(supplier => supplier.NormalizedName).ThenBy(supplier => supplier.Id);
                break;
        }

        Query.Skip((page - 1) * pageSize).Take(pageSize);
    }
}

public sealed class SupplierByNormalizedNameSpecification : Specification<Supplier>, ISingleResultSpecification<Supplier>
{
    public SupplierByNormalizedNameSpecification(string normalizedName, Guid? exceptId = null)
    {
        Query.Where(supplier => supplier.NormalizedName == normalizedName);
        if (exceptId is { } except)
        {
            Query.Where(supplier => supplier.Id != except);
        }
    }
}
