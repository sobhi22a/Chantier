using System.ComponentModel.DataAnnotations;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;

namespace Chantier.WebApi.Models.Materials;

/// <summary>Saisie d'un produit du catalogue. Ni état actif, ni numéro, ni champ d'audit : le client ne les fixe jamais (la désactivation a ses routes).</summary>
public abstract class ProductRequestBase
{
    /// <summary>Nom en français (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus).</summary>
    /// <example>Ciment CPJ 42,5</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(Product.NameMaxLength, ErrorMessage = "Trop long (150 caractères au maximum).")]
    public string? NameFr { get; set; }

    /// <summary>Nom en arabe (facultatif : le nom français est affiché à défaut).</summary>
    /// <example>إسمنت CPJ 42,5</example>
    [StringLength(Product.NameMaxLength, ErrorMessage = "Trop long (150 caractères au maximum).")]
    public string? NameAr { get; set; }

    /// <summary>Catégorie du catalogue.</summary>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public ProductCategory? Category { get; set; }

    /// <summary>Unités autorisées (au moins une), parmi le référentiel : jamais de texte libre.</summary>
    /// <example>["sac", "t", "kg"]</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public List<MeasureUnit>? AllowedUnits { get; set; }

    /// <summary>Unité proposée par défaut ; doit faire partie des unités autorisées (422 <c>UNITE_NON_AUTORISEE</c> sinon).</summary>
    /// <example>sac</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    public MeasureUnit? DefaultUnit { get; set; }

    /// <summary>Masse d'un sac en kg ; obligatoire si l'unité <c>sac</c> est autorisée (422 <c>MASSE_SAC_OBLIGATOIRE</c>).</summary>
    /// <example>50</example>
    public decimal? BagMassKg { get; set; }

    protected ProductInput ToInput() => new(NameFr, NameAr, Category, AllowedUnits, DefaultUnit, BagMassKg);
}

public sealed class CreateProductRequest : ProductRequestBase
{
    public ProductInput ToDto() => ToInput();
}

public sealed class UpdateProductRequest : ProductRequestBase
{
    /// <summary>Version lue avec le produit ; une version périmée donne 409 <c>CONFLIT_VERSION</c>.</summary>
    /// <example>47000</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "La version est invalide.")]
    public string? Version { get; set; }

    public UpdateProductDto ToDto() => new(Version!, ToInput());
}

/// <summary>Saisie d'un fournisseur. Le téléphone est une donnée réservée : jamais renvoyé sans <c>SupplierPhone.View</c>.</summary>
public abstract class SupplierRequestBase
{
    /// <summary>Nom du fournisseur (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus).</summary>
    /// <example>Cimenterie Sigma (fictive)</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(Supplier.NameMaxLength, ErrorMessage = "Trop long (150 caractères au maximum).")]
    public string? Name { get; set; }

    /// <summary>Téléphone au format algérien (05, 06 ou 07 suivi de 8 chiffres, espaces facultatifs).</summary>
    /// <example>0550 00 00 21</example>
    [StringLength(30, ErrorMessage = "Trop long (30 caractères au maximum).")]
    public string? Phone { get; set; }

    /// <summary>Produits fournis (identifiants du catalogue), liste indicative.</summary>
    public List<Guid>? ProductIds { get; set; }

    protected SupplierInput ToInput() => new(Name, Phone, ProductIds);
}

public sealed class CreateSupplierRequest : SupplierRequestBase
{
    public SupplierInput ToDto() => ToInput();
}

public sealed class UpdateSupplierRequest : SupplierRequestBase
{
    /// <summary>Version lue avec le fournisseur ; une version périmée donne 409 <c>CONFLIT_VERSION</c>.</summary>
    /// <example>47001</example>
    [Required(ErrorMessage = "Le champ est obligatoire.")]
    [StringLength(30, ErrorMessage = "La version est invalide.")]
    public string? Version { get; set; }

    public UpdateSupplierDto ToDto() => new(Version!, ToInput());
}
