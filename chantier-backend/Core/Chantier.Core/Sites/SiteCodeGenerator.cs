using System.Globalization;
using System.Text;
using Chantier.Core.Entities.Sites;

namespace Chantier.Core.Sites;

/// <summary>
/// Propose un code de chantier a partir du type d'ouvrage et du nom : « Ecole UV18 » donne <c>CH-ECO-UV18</c>,
/// « 40 logements Les Oliviers » donne <c>CH-LOG-OL40</c>. Modifiable avant la creation, jamais ensuite (CA-008.2).
/// Les mots generiques sont ignores ; un mot sans chiffre est abrege a 2 lettres ; les nombres passent apres les lettres.
/// </summary>
public static class SiteCodeGenerator
{
    private const int MaxLength = 30;
    private const int MaxSuffixLength = 8;

    private static readonly HashSet<string> GenericWords = new(StringComparer.Ordinal)
    {
        "ECOLE", "ECOLES", "LOGEMENT", "LOGEMENTS", "LOG", "LES", "LE", "LA", "L", "DE", "DU", "DES", "D", "ET", "AU", "AUX", "EN", "UN", "UNE",
        "CHANTIER", "PROJET", "CONSTRUCTION", "REALISATION", "TRAVAUX", "ETUDE", "EQUIPEMENT", "EQUIPEMENTS", "PUBLIC", "PUBLICS",
        "GROUPE", "SCOLAIRE", "CEM", "CEP", "LYCEE", "COLLEGE",
    };

    public static string Prefix(SiteType type) => type switch
    {
        SiteType.School => "CH-ECO",
        SiteType.Housing => "CH-LOG",
        SiteType.PublicFacility => "CH-EQP",
        _ => "CH-DIV",
    };

    /// <summary>Code de base (sans suffixe d'unicite).</summary>
    public static string Build(SiteType type, string name)
    {
        var words = Tokens(name).Where(token => !GenericWords.Contains(token)).ToList();

        var letters = words.Where(token => token.All(char.IsLetter)).Select(token => token.Length > 2 ? token[..2] : token);
        var withDigits = words.Where(token => token.Any(char.IsDigit) && token.Any(char.IsLetter));
        var numbers = words.Where(token => token.All(char.IsDigit));

        var suffix = string.Concat(letters.Concat(withDigits).Concat(numbers));
        if (suffix.Length > MaxSuffixLength)
        {
            suffix = suffix[..MaxSuffixLength];
        }

        var prefix = Prefix(type);
        return suffix.Length == 0 ? $"{prefix}-NEW" : $"{prefix}-{suffix}";
    }

    /// <summary>Ajoute <c>-2</c>, <c>-3</c>... tant que le code est pris.</summary>
    public static string MakeUnique(string baseCode, Func<string, bool> isTaken)
    {
        if (!isTaken(baseCode))
        {
            return baseCode;
        }

        for (var attempt = 2; attempt < 1000; attempt++)
        {
            var candidate = $"{baseCode}-{attempt.ToString(CultureInfo.InvariantCulture)}";
            if (candidate.Length <= MaxLength && !isTaken(candidate))
            {
                return candidate;
            }
        }

        throw new InvalidOperationException("Aucun code de chantier disponible.");
    }

    private static IEnumerable<string> Tokens(string? name)
    {
        var normalized = RemoveAccents(name ?? string.Empty).ToUpperInvariant();
        var builder = new StringBuilder();
        foreach (var character in normalized)
        {
            if (character is >= 'A' and <= 'Z' or >= '0' and <= '9')
            {
                builder.Append(character);
            }
            else if (builder.Length > 0)
            {
                yield return builder.ToString();
                builder.Clear();
            }
        }

        if (builder.Length > 0)
        {
            yield return builder.ToString();
        }
    }

    private static string RemoveAccents(string text)
    {
        var decomposed = text.Normalize(NormalizationForm.FormD);
        var builder = new StringBuilder(decomposed.Length);
        foreach (var character in decomposed.Where(character => CharUnicodeInfo.GetUnicodeCategory(character) != UnicodeCategory.NonSpacingMark))
        {
            builder.Append(character);
        }

        return builder.ToString().Normalize(NormalizationForm.FormC);
    }
}
