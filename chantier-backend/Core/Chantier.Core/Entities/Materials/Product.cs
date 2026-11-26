using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Common;
using Chantier.Core.Exceptions;
using Chantier.Core.Materials;
using Chantier.Core.Validation;

namespace Chantier.Core.Entities.Materials;

/// <summary>
/// Produit du catalogue, <b>commun a tous les chantiers</b> (H-MAT-17, entite globale : pas de chantier). Jamais supprime : il est desactive et
/// reste affiche dans l'historique. Les unites autorisees viennent du referentiel ; la masse du sac est obligatoire si <c>sac</c> est autorise.
/// </summary>
public class Product : BasicEntity
{
    public const int NameMaxLength = 150;

    public const decimal BagMassMax = 9_999.999m;

    // EF Core
    private Product()
    {
    }

    public string NameFr { get; private set; } = string.Empty;

    public string? NameAr { get; private set; }

    /// <summary>Forme de comparaison du nom (minuscules, sans accents ni espaces superflus) : unicite et recherche.</summary>
    public string NormalizedNameFr { get; private set; } = string.Empty;

    public ProductCategory Category { get; private set; }

    public IReadOnlyList<MeasureUnit> AllowedUnits { get; private set; } = [];

    public MeasureUnit DefaultUnit { get; private set; }

    /// <summary>Masse d'un sac en kg (50 pour le ciment, 25 pour le monocouche) ; sert aux conversions sac, kg, T.</summary>
    public decimal? BagMassKg { get; private set; }

    public bool IsActive { get; private set; } = true;

    public DateTimeOffset? DeactivatedAt { get; private set; }

    public static Product Create(ProductInput input)
    {
        var product = new Product();
        product.Apply(input);
        return product;
    }

    public void Update(ProductInput input) => Apply(input);

    public void Deactivate(DateTimeOffset at)
    {
        if (IsActive)
        {
            IsActive = false;
            DeactivatedAt = at;
        }
    }

    public void Activate()
    {
        IsActive = true;
        DeactivatedAt = null;
    }

    public bool Allows(MeasureUnit unit) => AllowedUnits.Contains(unit);

    private void Apply(ProductInput input)
    {
        var errors = new ErrorCollector();

        var nameFr = string.IsNullOrWhiteSpace(input.NameFr) ? null : input.NameFr.Trim();
        if (nameFr is null)
        {
            errors.Add("nameFr", "Le nom est obligatoire.");
        }
        else if (nameFr.Length > NameMaxLength)
        {
            errors.Add("nameFr", $"Trop long ({NameMaxLength} caractères au maximum).");
        }

        var nameAr = string.IsNullOrWhiteSpace(input.NameAr) ? null : input.NameAr.Trim();
        if (nameAr is { Length: > NameMaxLength })
        {
            errors.Add("nameAr", $"Trop long ({NameMaxLength} caractères au maximum).");
        }

        if (input.Category is not { } category || !Enum.IsDefined(category))
        {
            errors.Add("category", "La catégorie est obligatoire.");
        }

        var allowed = (input.AllowedUnits ?? []).Distinct().ToList();
        if (allowed.Count == 0)
        {
            errors.Add("allowedUnits", "Choisissez au moins une unité.");
        }
        else if (allowed.Any(unit => !Enum.IsDefined(unit)))
        {
            errors.Add("allowedUnits", "Une unité est inconnue.");
        }

        if (input.DefaultUnit is not { } defaultUnit || !Enum.IsDefined(defaultUnit))
        {
            errors.Add("defaultUnit", "L'unité par défaut est obligatoire.");
        }

        if (input.BagMassKg is { } mass && (mass <= 0m || mass > BagMassMax || decimal.Round(mass, 3, MidpointRounding.AwayFromZero) != mass))
        {
            errors.Add("bagMassKg", "La masse du sac doit être supérieure à 0, avec 3 décimales au plus.");
        }

        errors.ThrowIfAny();

        // Regles metier (422), apres la validation des champs.
        if (!allowed.Contains(input.DefaultUnit!.Value))
        {
            throw new DomainRuleException(ErrorCodes.UniteNonAutorisee, "L'unité par défaut doit faire partie des unités autorisées.");
        }

        var bagAllowed = allowed.Contains(MeasureUnit.Bag);
        if (bagAllowed && input.BagMassKg is null)
        {
            throw new DomainRuleException(ErrorCodes.MasseSacObligatoire, "La masse d'un sac est obligatoire quand l'unité « sac » est autorisée.");
        }

        NameFr = nameFr!;
        NameAr = nameAr;
        NormalizedNameFr = NameNormalizer.Normalize(nameFr);
        Category = input.Category!.Value;
        AllowedUnits = allowed;
        DefaultUnit = input.DefaultUnit!.Value;

        // Sans unite « sac », une masse n'a aucun usage (aucune conversion) : on ne la garde pas.
        BagMassKg = bagAllowed ? input.BagMassKg : null;
    }
}
