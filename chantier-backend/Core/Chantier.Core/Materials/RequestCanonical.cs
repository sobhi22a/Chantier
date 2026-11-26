using System.Globalization;
using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Materials;

namespace Chantier.Core.Materials;

/// <summary>
/// Formes canoniques (chaines) des champs d'une demande, pour la comparaison a trois valeurs d'une modification hors ligne : « 300 sac », « 2026-11-28 »,
/// « Normal », un identifiant en minuscules, un texte rogne ou <c>null</c>. Deux saisies equivalentes (300 et 300,0) ont la meme forme.
/// </summary>
public static class RequestCanonical
{
    /// <summary>Etat actuel complet de la demande.</summary>
    public static IReadOnlyDictionary<string, string?> Of(MaterialRequest request) => new Dictionary<string, string?>(StringComparer.Ordinal)
    {
        [RequestFieldNames.ProductId] = request.ProductId?.ToString(),
        [RequestFieldNames.FreeProductName] = Text(request.FreeProductName),
        [RequestFieldNames.Quantity] = QuantityText(request.QuantityValue, request.Unit),
        [RequestFieldNames.ZoneId] = request.ZoneId?.ToString(),
        [RequestFieldNames.NeededBy] = Date(request.NeededBy),
        [RequestFieldNames.Priority] = request.Priority.ToString(),
        [RequestFieldNames.Note] = Text(request.Note),
    };

    /// <summary>Seulement les champs presents dans la saisie (valeurs proposees, ou valeurs de depart du telephone).</summary>
    public static IReadOnlyDictionary<string, string?> Of(RequestChanges changes)
    {
        var values = new Dictionary<string, string?>(StringComparer.Ordinal);

        if (changes.ProductId is { } productId)
        {
            values[RequestFieldNames.ProductId] = productId.ToString();
        }

        if (changes.FreeProductName is { } name)
        {
            values[RequestFieldNames.FreeProductName] = Text(name);
        }

        if (changes.Quantity is { } quantity)
        {
            values[RequestFieldNames.Quantity] = QuantityText(quantity.Value, quantity.Unit);
        }

        if (changes.ClearZone || changes.ZoneId is not null)
        {
            values[RequestFieldNames.ZoneId] = changes.ClearZone ? null : changes.ZoneId?.ToString();
        }

        if (changes.NeededBy is { } neededBy)
        {
            values[RequestFieldNames.NeededBy] = Date(neededBy);
        }

        if (changes.Priority is { } priority)
        {
            values[RequestFieldNames.Priority] = priority.ToString();
        }

        if (changes.Note is { } note)
        {
            values[RequestFieldNames.Note] = Text(note);
        }

        return values;
    }

    private static string QuantityText(decimal? value, MeasureUnit? unit)
        => $"{(value is { } number ? DecimalScale.Normalize(number).ToString(CultureInfo.InvariantCulture) : "?")} {(unit is { } known ? MeasureUnits.Code(known) : "?")}";

    private static string Date(DateOnly date) => date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    private static string? Text(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
