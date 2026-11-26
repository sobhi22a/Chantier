using Chantier.Core.Validation;

namespace Chantier.Core.Materials;

/// <summary>Champs saisissables d'une commande, tels que recus du client : tous nullables, la validation donne un 400 par champ (jamais de statut, de montant ni d'auteur).</summary>
public sealed record OrderFields(
    Guid? SupplierId,
    DateOnly? OrderDate,
    DateOnly? ExpectedDeliveryDate,
    decimal? UnitPrice,
    string? PurchaseOrderNumber,
    string? Note);

/// <summary>Champs d'une commande apres validation.</summary>
public sealed record ValidatedOrderFields(
    Guid SupplierId,
    DateOnly OrderDate,
    DateOnly? ExpectedDeliveryDate,
    decimal? UnitPrice,
    string? PurchaseOrderNumber,
    string? Note);

/// <summary>Noms des champs de l'historique d'une commande (camelCase du contrat). Le prix et le n° de bon de commande sont <b>commerciaux</b>.</summary>
public static class OrderFieldNames
{
    public const string SupplierId = "supplierId";
    public const string ExpectedDeliveryDate = "expectedDeliveryDate";
    public const string Note = "note";
    public const string UnitPrice = "unitPrice";
    public const string PurchaseOrderNumber = "purchaseOrderNumber";
}

/// <summary>Modification d'une commande : seuls les champs presents changent (la date de commande, la quantite et l'unite ne se modifient pas).</summary>
public sealed record OrderChanges(
    Guid? SupplierId,
    DateOnly? ExpectedDeliveryDate,
    decimal? UnitPrice,
    string? PurchaseOrderNumber,
    string? Note)
{
    public OrderFields ApplyTo(OrderFields current) => new(
        SupplierId ?? current.SupplierId,
        current.OrderDate,
        ExpectedDeliveryDate ?? current.ExpectedDeliveryDate,
        UnitPrice ?? current.UnitPrice,
        PurchaseOrderNumber ?? current.PurchaseOrderNumber,
        Note ?? current.Note);
}

public static class OrderRules
{
    /// <summary>Prix unitaire maximal : garde le montant (quantite maximale x prix) sous la capacite d'une colonne (18,2).</summary>
    public const decimal UnitPriceMax = 9_999_999.99m;

    /// <summary>
    /// Valide une commande complete : fournisseur obligatoire, date de commande complete et pas dans le futur (heure d'Algerie), livraison prevue complete et pas avant
    /// la commande (<c>DATE_INVALIDE</c>), prix facultatif mais superieur a 0 avec 2 decimales au plus. Le fournisseur existant et actif est controle par le service.
    /// </summary>
    public static ValidatedOrderFields Validate(OrderFields fields, MaterialsOptions options, DateOnly today)
    {
        var errors = new ErrorCollector();

        if (fields.SupplierId is null || fields.SupplierId == Guid.Empty)
        {
            errors.Add("supplierId", "Le fournisseur est obligatoire.");
        }

        if (fields.OrderDate is not { } orderDate)
        {
            errors.AddInvalidDate("orderDate", "La date de commande est obligatoire et doit être une date complète.");
        }
        else if (orderDate > today)
        {
            errors.AddInvalidDate("orderDate", "La date de commande ne peut pas être dans le futur.");
        }

        if (fields.ExpectedDeliveryDate is { } expected && fields.OrderDate is { } start && expected < start)
        {
            errors.AddInvalidDate("expectedDeliveryDate", "La livraison prévue ne peut pas précéder la date de commande.");
        }

        if (fields.UnitPrice is { } price
            && (price <= 0m || price > UnitPriceMax || Math.Round(price, Money.Decimals, MidpointRounding.AwayFromZero) != price))
        {
            errors.Add("unitPrice", "Le prix unitaire doit être supérieur à 0, avec 2 décimales au plus.");
        }

        var purchaseOrder = Clean(fields.PurchaseOrderNumber);
        if (purchaseOrder is { Length: > Entities.Materials.MaterialOrder.PurchaseOrderNumberMaxLength })
        {
            errors.Add("purchaseOrderNumber", $"Trop long ({Entities.Materials.MaterialOrder.PurchaseOrderNumberMaxLength} caractères au maximum).");
        }

        var note = Clean(fields.Note);
        if (note is { } text && text.Length > options.NoteMaxLength)
        {
            errors.Add("note", $"Trop long ({options.NoteMaxLength} caractères au maximum).");
        }

        errors.ThrowIfAny();

        return new ValidatedOrderFields(fields.SupplierId!.Value, fields.OrderDate!.Value, fields.ExpectedDeliveryDate, fields.UnitPrice, purchaseOrder, note);
    }

    /// <summary>Jours entre la date de besoin et la livraison prevue quand elle la depasse, sinon 0 : sert a l'avertissement « Livraison prevue N j apres le besoin » (jamais bloquant).</summary>
    public static int PlannedAfterNeedDays(DateOnly neededBy, DateOnly? expectedDeliveryDate)
        => expectedDeliveryDate is { } expected ? Math.Max(0, expected.DayNumber - neededBy.DayNumber) : 0;

    private static string? Clean(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
