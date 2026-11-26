using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Exceptions;
using Chantier.Core.Validation;

namespace Chantier.Core.Materials;

/// <summary>
/// Champs saisissables d'une livraison, tels que recus du client (REST ou synchronisation) : tous nullables, la validation donne un 400 par champ
/// ou un 422 avec le code metier. Jamais de statut, de numero, de rattachement decide par le client, de montant ni d'auteur.
/// </summary>
public sealed record DeliveryFields(
    Guid? SupplierId,
    string? FreeSupplierName,
    Guid? ProductId,
    string? FreeProductName,
    decimal? QuantityValue,
    MeasureUnit? Unit,
    DateOnly? DeliveryDate,
    string? DeliveryNoteNumber,
    Conformity? Conformity,
    string? ReserveReasonCode,
    string? ReserveNote);

/// <summary>Champs d'une livraison apres validation : un fournisseur et un produit (catalogue ou nom libre), une quantite avec son unite, une date.</summary>
public sealed record ValidatedDeliveryFields(
    Guid? SupplierId,
    string? FreeSupplierName,
    Guid? ProductId,
    string? FreeProductName,
    Quantity Quantity,
    DateOnly DeliveryDate,
    string? DeliveryNoteNumber,
    Conformity Conformity,
    string? ReserveReasonCode,
    string? ReserveNote);

/// <summary>Noms des champs de l'historique d'une livraison (camelCase du contrat). Jamais un prix.</summary>
public static class DeliveryFieldNames
{
    public const string Quantity = "quantity";
    public const string DeliveryDate = "deliveryDate";
    public const string DeliveryNoteNumber = "deliveryNoteNumber";
    public const string Conformity = "conformity";
    public const string ReserveReasonCode = "reserveReasonCode";
    public const string ReserveNote = "reserveNote";
    public const string RequestId = "requestId";
}

/// <summary>
/// Correction d'une livraison : seuls les champs presents changent (quantite avec unite, date, n° de BL, conformite et reserve). Un n° de BL ou une remarque
/// vide l'efface ; le fournisseur, le produit et la demande ne se modifient pas (rattacher : action dediee).
/// </summary>
public sealed record DeliveryChanges(
    QuantityInput? Quantity,
    DateOnly? DeliveryDate,
    string? DeliveryNoteNumber,
    Conformity? Conformity,
    string? ReserveReasonCode,
    string? ReserveNote)
{
    public DeliveryFields ApplyTo(DeliveryFields current)
    {
        var conformity = Conformity ?? current.Conformity;

        // Passer a « Conforme » efface la reserve ; une reserve donnee avec « Conforme » est une erreur de saisie que la validation signale.
        var keepReserve = Conformity != Entities.Materials.Conformity.Conform;
        return current with
        {
            QuantityValue = Quantity is null ? current.QuantityValue : Quantity.Value,
            Unit = Quantity is null ? current.Unit : Quantity.Unit,
            DeliveryDate = DeliveryDate ?? current.DeliveryDate,
            DeliveryNoteNumber = DeliveryNoteNumber ?? current.DeliveryNoteNumber,
            Conformity = conformity,
            ReserveReasonCode = ReserveReasonCode ?? (keepReserve ? current.ReserveReasonCode : null),
            ReserveNote = ReserveNote ?? (keepReserve ? current.ReserveNote : null),
        };
    }
}

public static class DeliveryRules
{
    public const int FreeSupplierNameMinLength = 3;
    public const int FreeSupplierNameMaxLength = 100;

    /// <summary>
    /// Valide une saisie complete. Ordre : champs invalides (400 <c>VALIDATION</c> ou <c>DATE_INVALIDE</c>), puis regles metier (422) :
    /// <c>UNITE_OBLIGATOIRE</c>, <c>QUANTITE_INVALIDE</c>, <c>QUANTITE_ENTIERE_REQUISE</c>. La date de livraison n'est jamais dans le futur (heure d'Algerie, sans marge,
    /// H-ARCH-14) ; antérieure à la demande, elle est acceptée. Le n° de BL est mis en majuscules. « Avec reserve » exige un motif de la liste.
    /// La coherence avec la demande (produit, unite convertible) et l'existence du fournisseur sont controlees par le service.
    /// </summary>
    public static ValidatedDeliveryFields Validate(DeliveryFields fields, MaterialsOptions options, DateOnly today)
    {
        var errors = new ErrorCollector();

        var freeSupplier = Clean(fields.FreeSupplierName);
        if (fields.SupplierId is null && freeSupplier is null)
        {
            errors.Add("supplierId", "Choisissez un fournisseur ou saisissez son nom.");
        }
        else if (fields.SupplierId is not null && freeSupplier is not null)
        {
            errors.Add("freeSupplierName", "Un fournisseur du catalogue ou un nom libre, pas les deux.");
        }
        else if (freeSupplier is not null && (freeSupplier.Length < FreeSupplierNameMinLength || freeSupplier.Length > FreeSupplierNameMaxLength))
        {
            errors.Add("freeSupplierName", $"Le nom doit comporter de {FreeSupplierNameMinLength} à {FreeSupplierNameMaxLength} caractères.");
        }

        var freeProduct = Clean(fields.FreeProductName);
        if (fields.ProductId is null && freeProduct is null)
        {
            errors.Add("productId", "Choisissez un produit ou saisissez le nom du matériau.");
        }
        else if (fields.ProductId is not null && freeProduct is not null)
        {
            errors.Add("freeProductName", "Un produit du catalogue ou un nom libre, pas les deux.");
        }
        else if (freeProduct is not null && (freeProduct.Length < options.FreeNameMinLength || freeProduct.Length > options.FreeNameMaxLength))
        {
            errors.Add("freeProductName", $"Le nom doit comporter de {options.FreeNameMinLength} à {options.FreeNameMaxLength} caractères.");
        }

        if (fields.QuantityValue is null && fields.Unit is null)
        {
            errors.Add("quantity", "Le champ est obligatoire.");
        }

        if (fields.DeliveryDate is not { } date)
        {
            errors.AddInvalidDate("deliveryDate", "La date de livraison est obligatoire et doit être une date complète.");
        }
        else if (date > today)
        {
            errors.AddInvalidDate("deliveryDate", "La date de livraison ne peut pas être dans le futur.");
        }

        var note = Clean(fields.DeliveryNoteNumber)?.ToUpperInvariant();
        if (note is { } number && number.Length > options.DeliveryNoteMaxLength)
        {
            errors.Add("deliveryNoteNumber", $"Trop long ({options.DeliveryNoteMaxLength} caractères au maximum).");
        }

        var conformity = fields.Conformity ?? Conformity.Conform;
        if (!Enum.IsDefined(conformity))
        {
            errors.Add("conformity", "La conformité est inconnue.");
        }

        if (conformity == Conformity.Conform && (!string.IsNullOrWhiteSpace(fields.ReserveReasonCode) || !string.IsNullOrWhiteSpace(fields.ReserveNote)))
        {
            errors.Add("reserveReasonCode", "Une réserve n'a de sens qu'avec la conformité « Avec réserve ».");
        }

        errors.ThrowIfAny();

        string? reserveCode = null;
        string? reserveNote = null;
        if (conformity == Conformity.WithReserve)
        {
            reserveNote = ReasonRules.Validate(ReasonKind.Reserve, fields.ReserveReasonCode, fields.ReserveNote, options);
            reserveCode = fields.ReserveReasonCode;
        }

        if (fields.Unit is not { } unit || !Enum.IsDefined(unit))
        {
            throw new DomainRuleException(ErrorCodes.UniteObligatoire, "Une quantité doit toujours avoir une unité.");
        }

        var value = fields.QuantityValue ?? 0m;
        QuantityRules.Validate(value, unit);

        return new ValidatedDeliveryFields(
            fields.SupplierId, freeSupplier, fields.ProductId, freeProduct, new Quantity(value, unit), fields.DeliveryDate!.Value,
            note, conformity, reserveCode, reserveNote);
    }

    private static string? Clean(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
