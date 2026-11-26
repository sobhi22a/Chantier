using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;

namespace Chantier.Core.DTOs.Materials;

/// <summary>Saisie d'un produit du catalogue : champs nullables, la validation donne un 400 par champ (jamais une erreur de liaison).</summary>
public sealed record ProductInput(
    string? NameFr,
    string? NameAr,
    ProductCategory? Category,
    IReadOnlyList<MeasureUnit>? AllowedUnits,
    MeasureUnit? DefaultUnit,
    decimal? BagMassKg);

public sealed record UpdateProductDto(string Version, ProductInput Data);

public sealed record SupplierInput(string? Name, string? Phone, IReadOnlyList<Guid>? ProductIds);

public sealed record UpdateSupplierDto(string Version, SupplierInput Data);

/// <summary>Filtres de la liste du catalogue (back-office : pagination par page avec total).</summary>
public sealed record ProductListQuery(string? Search, ProductCategory? Category, bool? IsActive, string? Sort, int Page, int PageSize);

public sealed record SupplierListQuery(string? Search, bool? IsActive, string? Sort, int Page, int PageSize);
