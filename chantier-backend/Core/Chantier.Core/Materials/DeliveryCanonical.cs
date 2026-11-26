using System.Globalization;
using Chantier.Core.Entities.Materials;

namespace Chantier.Core.Materials;

/// <summary>
/// Formes canoniques (chaines) des champs corrigeables d'une livraison, pour la comparaison a trois valeurs d'une correction hors ligne (ADR 0011) :
/// « 10 t », « 2026-11-25 », « Conform », un texte rogne ou <c>null</c>. Deux saisies equivalentes (10 et 10,0) ont la meme forme.
/// </summary>
public static class DeliveryCanonical
{
    /// <summary>Etat actuel complet de la livraison.</summary>
    public static IReadOnlyDictionary<string, string?> Of(Delivery delivery) => new Dictionary<string, string?>(StringComparer.Ordinal)
    {
        [DeliveryFieldNames.Quantity] = QuantityText(delivery.QuantityValue, delivery.Unit),
        [DeliveryFieldNames.DeliveryDate] = Date(delivery.DeliveryDate),
        [DeliveryFieldNames.DeliveryNoteNumber] = Text(delivery.DeliveryNoteNumber),
        [DeliveryFieldNames.Conformity] = delivery.Conformity.ToString(),
        [DeliveryFieldNames.ReserveReasonCode] = Text(delivery.ReserveReasonCode),
        [DeliveryFieldNames.ReserveNote] = Text(delivery.ReserveNote),
    };

    /// <summary>Seulement les champs presents dans la saisie (valeurs proposees, ou valeurs de depart du telephone).</summary>
    public static IReadOnlyDictionary<string, string?> Of(DeliveryChanges changes)
    {
        var values = new Dictionary<string, string?>(StringComparer.Ordinal);

        if (changes.Quantity is { } quantity)
        {
            values[DeliveryFieldNames.Quantity] = QuantityText(quantity.Value, quantity.Unit);
        }

        if (changes.DeliveryDate is { } date)
        {
            values[DeliveryFieldNames.DeliveryDate] = Date(date);
        }

        if (changes.DeliveryNoteNumber is { } note)
        {
            // Le serveur met le n° de BL en majuscules : on compare la meme forme.
            values[DeliveryFieldNames.DeliveryNoteNumber] = Text(note)?.ToUpperInvariant();
        }

        if (changes.Conformity is { } conformity)
        {
            values[DeliveryFieldNames.Conformity] = conformity.ToString();
        }

        if (changes.ReserveReasonCode is { } code)
        {
            values[DeliveryFieldNames.ReserveReasonCode] = Text(code);
        }

        if (changes.ReserveNote is { } reserveNote)
        {
            values[DeliveryFieldNames.ReserveNote] = Text(reserveNote);
        }

        return values;
    }

    private static string QuantityText(decimal? value, MeasureUnit? unit)
        => $"{(value is { } number ? DecimalScale.Normalize(number).ToString(CultureInfo.InvariantCulture) : "?")} {(unit is { } known ? MeasureUnits.Code(known) : "?")}";

    private static string Date(DateOnly date) => date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    private static string? Text(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
