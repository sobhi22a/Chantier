using System.Text.Json.Serialization;

namespace Chantier.Core.Materials;

/// <summary>
/// Unites du referentiel (skill <c>metier-chantier</c>), identifiees par leur <b>code stable</b> dans le JSON, la base et les vecteurs de calcul :
/// <c>u ml m2 m3 kg t sac l h j pj ft</c>. Une quantite n'existe jamais sans unite (regle 1).
/// </summary>
public enum MeasureUnit
{
    [JsonStringEnumMemberName("u")]
    Piece,

    [JsonStringEnumMemberName("ml")]
    LinearMeter,

    [JsonStringEnumMemberName("m2")]
    SquareMeter,

    [JsonStringEnumMemberName("m3")]
    CubicMeter,

    [JsonStringEnumMemberName("kg")]
    Kilogram,

    [JsonStringEnumMemberName("t")]
    Tonne,

    [JsonStringEnumMemberName("sac")]
    Bag,

    [JsonStringEnumMemberName("l")]
    Liter,

    [JsonStringEnumMemberName("h")]
    Hour,

    [JsonStringEnumMemberName("j")]
    Day,

    [JsonStringEnumMemberName("pj")]
    ManDay,

    [JsonStringEnumMemberName("ft")]
    LumpSum,
}

public static class MeasureUnits
{
    public static IReadOnlyList<MeasureUnit> All { get; } = Enum.GetValues<MeasureUnit>();

    public static string Code(MeasureUnit unit) => unit switch
    {
        MeasureUnit.Piece => "u",
        MeasureUnit.LinearMeter => "ml",
        MeasureUnit.SquareMeter => "m2",
        MeasureUnit.CubicMeter => "m3",
        MeasureUnit.Kilogram => "kg",
        MeasureUnit.Tonne => "t",
        MeasureUnit.Bag => "sac",
        MeasureUnit.Liter => "l",
        MeasureUnit.Hour => "h",
        MeasureUnit.Day => "j",
        MeasureUnit.ManDay => "pj",
        MeasureUnit.LumpSum => "ft",
        _ => throw new ArgumentOutOfRangeException(nameof(unit), unit, "Unité inconnue."),
    };

    /// <summary>Lit un code du referentiel (sensible a la casse : les codes sont stables). <c>false</c> si le code est absent ou inconnu.</summary>
    public static bool TryParse(string? code, out MeasureUnit unit)
    {
        foreach (var candidate in All)
        {
            if (string.Equals(Code(candidate), code, StringComparison.Ordinal))
            {
                unit = candidate;
                return true;
            }
        }

        unit = default;
        return false;
    }

    /// <summary>Unites qui se comptent en nombres entiers (H-MAT-07) : <c>sac</c> et <c>u</c>.</summary>
    public static bool IsWholeOnly(MeasureUnit unit) => unit is MeasureUnit.Bag or MeasureUnit.Piece;
}
