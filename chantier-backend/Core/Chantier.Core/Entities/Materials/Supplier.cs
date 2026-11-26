using System.Text.RegularExpressions;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Common;
using Chantier.Core.Materials;
using Chantier.Core.Validation;

namespace Chantier.Core.Entities.Materials;

/// <summary>
/// Fournisseur, <b>commun a tous les chantiers</b> (H-MAT-17). Le telephone est une donnee reservee (<c>SupplierPhone.View</c>) :
/// jamais synchronise, jamais journalise. Jamais supprime : desactive.
/// </summary>
public partial class Supplier : BasicEntity
{
    public const int NameMaxLength = 150;

    // EF Core
    private Supplier()
    {
    }

    public string Name { get; private set; } = string.Empty;

    public string NormalizedName { get; private set; } = string.Empty;

    /// <summary>Format algerien <c>0[5-7]x xx xx xx</c>, enregistre avec ses espaces d'affichage ; donnee sensible.</summary>
    public string? Phone { get; private set; }

    /// <summary>Produits fournis (identifiants du catalogue) ; liste indicative, colonne JSON.</summary>
    public List<Guid> ProductIds { get; private set; } = [];

    public bool IsActive { get; private set; } = true;

    public DateTimeOffset? DeactivatedAt { get; private set; }

    [GeneratedRegex(@"^0[5-7]\d{8}$")]
    private static partial Regex PhonePattern();

    public static Supplier Create(SupplierInput input)
    {
        var supplier = new Supplier();
        supplier.Apply(input);
        return supplier;
    }

    public void Update(SupplierInput input) => Apply(input);

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

    /// <summary>Normalise un telephone saisi (« 0550 00 00 21 », « 0550000021 ») ; <c>null</c> s'il n'est pas au format algerien.</summary>
    public static string? NormalizePhone(string? value)
    {
        var digits = new string((value ?? string.Empty).Where(character => !char.IsWhiteSpace(character)).ToArray());
        return PhonePattern().IsMatch(digits)
            ? $"{digits[..4]} {digits[4..6]} {digits[6..8]} {digits[8..10]}"
            : null;
    }

    private void Apply(SupplierInput input)
    {
        var errors = new ErrorCollector();

        var name = string.IsNullOrWhiteSpace(input.Name) ? null : input.Name.Trim();
        if (name is null)
        {
            errors.Add("name", "Le nom est obligatoire.");
        }
        else if (name.Length > NameMaxLength)
        {
            errors.Add("name", $"Trop long ({NameMaxLength} caractères au maximum).");
        }

        string? phone = null;
        if (!string.IsNullOrWhiteSpace(input.Phone))
        {
            phone = NormalizePhone(input.Phone);
            if (phone is null)
            {
                // Aucune valeur saisie dans le message : un telephone ne doit jamais s'echapper vers une reponse d'erreur ou un journal.
                errors.Add("phone", "Le téléphone doit être un numéro algérien (05, 06 ou 07 suivi de 8 chiffres).");
            }
        }

        errors.ThrowIfAny();

        Name = name!;
        NormalizedName = NameNormalizer.Normalize(name);
        Phone = phone;
        ProductIds = (input.ProductIds ?? []).Distinct().ToList();
    }
}
