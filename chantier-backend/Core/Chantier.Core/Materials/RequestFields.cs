using Chantier.Core.Entities.Materials;
using Chantier.Core.Exceptions;
using Chantier.Core.Validation;

namespace Chantier.Core.Materials;

/// <summary>
/// Champs saisissables d'une demande, tels que recus du client (REST ou synchronisation) : tous nullables, la validation donne un 400 par champ
/// ou un 422 avec le code metier. Jamais de statut, de numero, d'auteur ni de date d'audit (affectation de masse).
/// </summary>
public sealed record RequestFields(
    Guid? ProductId,
    string? FreeProductName,
    decimal? QuantityValue,
    MeasureUnit? Unit,
    Guid? ZoneId,
    DateOnly? NeededBy,
    Priority? Priority,
    string? Note);

/// <summary>Champs d'une demande apres validation : un produit du catalogue <b>ou</b> un nom libre, une quantite avec son unite.</summary>
public sealed record ValidatedRequestFields(
    Guid? ProductId,
    string? FreeProductName,
    Quantity Quantity,
    Guid? ZoneId,
    DateOnly NeededBy,
    Priority Priority,
    string? Note);

/// <summary>Noms des champs de l'historique et des conflits de synchronisation (camelCase du contrat).</summary>
public static class RequestFieldNames
{
    public const string ProductId = "productId";
    public const string FreeProductName = "freeProductName";
    public const string Quantity = "quantity";
    public const string ZoneId = "zoneId";
    public const string NeededBy = "neededBy";
    public const string Priority = "priority";
    public const string Note = "note";

    /// <summary>Verrouilles des la validation (H-MAT-09) : produit, quantite, unite et zone.</summary>
    public static readonly IReadOnlySet<string> Locked = new HashSet<string>(StringComparer.Ordinal) { ProductId, FreeProductName, Quantity, ZoneId };

    public static readonly IReadOnlyList<string> All = [ProductId, FreeProductName, Quantity, ZoneId, NeededBy, Priority, Note];
}

public static class RequestRules
{
    /// <summary>
    /// Valide une saisie complete (creation, ou etat courant modifie). Ordre : champs invalides (400 <c>VALIDATION</c> ou <c>DATE_INVALIDE</c>),
    /// puis regles metier (422) : <c>UNITE_OBLIGATOIRE</c>, <c>QUANTITE_INVALIDE</c>, <c>QUANTITE_ENTIERE_REQUISE</c>, <c>PRODUIT_INACTIF</c>, <c>UNITE_NON_AUTORISEE</c>.
    /// </summary>
    /// <param name="product">Produit du catalogue designe par <c>ProductId</c> (le service le charge) ; <c>null</c> pour un nom libre.</param>
    /// <param name="checkProduct"><c>false</c> pour une modification qui ne touche ni au produit ni a l'unite : un produit desactive ou dont les unites ont change depuis ne bloque pas une correction de date.</param>
    public static ValidatedRequestFields Validate(RequestFields fields, Product? product, MaterialsOptions options, bool checkProduct = true)
    {
        var errors = new ErrorCollector();

        var freeName = string.IsNullOrWhiteSpace(fields.FreeProductName) ? null : fields.FreeProductName.Trim();
        if (fields.ProductId is null && freeName is null)
        {
            errors.Add("productId", "Choisissez un produit ou saisissez le nom du matériau.");
        }
        else if (fields.ProductId is not null && freeName is not null)
        {
            errors.Add("freeProductName", "Un produit du catalogue ou un nom libre, pas les deux.");
        }
        else if (freeName is not null && (freeName.Length < options.FreeNameMinLength || freeName.Length > options.FreeNameMaxLength))
        {
            errors.Add("freeProductName", $"Le nom doit comporter de {options.FreeNameMinLength} à {options.FreeNameMaxLength} caractères.");
        }

        if (fields.QuantityValue is null && fields.Unit is null)
        {
            errors.Add("quantity", "Le champ est obligatoire.");
        }

        if (fields.NeededBy is null)
        {
            errors.AddInvalidDate("neededBy", "La date de besoin est obligatoire et doit être une date complète.");
        }

        var priority = fields.Priority ?? Entities.Materials.Priority.Normal;
        if (!Enum.IsDefined(priority))
        {
            errors.Add("priority", "L'urgence est inconnue.");
        }

        var note = string.IsNullOrWhiteSpace(fields.Note) ? null : fields.Note.Trim();
        if (note is { } text && text.Length > options.NoteMaxLength)
        {
            errors.Add("note", $"Trop long ({options.NoteMaxLength} caractères au maximum).");
        }

        errors.ThrowIfAny();

        if (fields.Unit is not { } unit || !Enum.IsDefined(unit))
        {
            throw new DomainRuleException(ErrorCodes.UniteObligatoire, "Une quantité doit toujours avoir une unité.");
        }

        var value = fields.QuantityValue ?? 0m;
        QuantityRules.Validate(value, unit);

        if (product is not null && checkProduct)
        {
            if (!product.IsActive)
            {
                throw new DomainRuleException(ErrorCodes.ProduitInactif, "Ce produit est désactivé : il ne peut plus être demandé ni livré.");
            }

            if (!product.Allows(unit))
            {
                throw new DomainRuleException(ErrorCodes.UniteNonAutorisee, "Cette unité n'est pas autorisée pour ce produit.");
            }
        }

        return new ValidatedRequestFields(fields.ProductId, freeName, new Quantity(value, unit), fields.ZoneId, fields.NeededBy!.Value, priority, note);
    }
}
