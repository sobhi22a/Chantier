using System.Globalization;
using System.Text;

namespace Chantier.Core.Materials;

/// <summary>
/// Forme de comparaison d'un nom (produit, fournisseur) : minuscules, sans accents ni diacritiques (arabes compris), sans tatweel,
/// espaces compactes. Sert a l'unicite (« Ciment  CPJ » = « ciment cpj ») et a la recherche insensible aux accents.
/// </summary>
public static class NameNormalizer
{
    private const char Tatweel = 'ـ';

    public static string Normalize(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return string.Empty;
        }

        var decomposed = value.Trim().Normalize(NormalizationForm.FormD);
        var builder = new StringBuilder(decomposed.Length);
        var lastWasSpace = false;

        foreach (var character in decomposed)
        {
            if (character == Tatweel || CharUnicodeInfo.GetUnicodeCategory(character) == UnicodeCategory.NonSpacingMark)
            {
                continue;
            }

            if (char.IsWhiteSpace(character))
            {
                if (!lastWasSpace)
                {
                    builder.Append(' ');
                }

                lastWasSpace = true;
                continue;
            }

            lastWasSpace = false;
            builder.Append(char.ToLowerInvariant(character));
        }

        return builder.ToString().Normalize(NormalizationForm.FormC);
    }
}
