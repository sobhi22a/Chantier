using Chantier.Core.Exceptions;

namespace Chantier.Core.Materials;

/// <summary>
/// Seules conversions autorisees (ADR 0014) : <c>sac</c> &lt;-&gt; <c>kg</c> &lt;-&gt; <c>t</c>, avec la masse du sac du produit.
/// Aucune autre paire (m3 et t, l et kg...) : <c>UNITES_INCOMPATIBLES</c>. Resultat arrondi a 3 decimales, « loin de zero ».
/// </summary>
public static class UnitConverter
{
    public const int Decimals = 3;

    private const decimal KilogramsPerTonne = 1000m;

    public static bool TryConvert(Quantity from, MeasureUnit to, decimal? bagMassKg, out Quantity result)
    {
        if (from.Unit == to)
        {
            result = from;
            return true;
        }

        if (KilogramsPer(from.Unit, bagMassKg) is not { } fromFactor || KilogramsPer(to, bagMassKg) is not { } toFactor)
        {
            result = default;
            return false;
        }

        var kilograms = from.Value * fromFactor;
        result = new Quantity(Math.Round(kilograms / toFactor, Decimals, MidpointRounding.AwayFromZero), to);
        return true;
    }

    /// <summary>Convertit ou leve <c>UNITES_INCOMPATIBLES</c> (422).</summary>
    public static Quantity Convert(Quantity from, MeasureUnit to, decimal? bagMassKg)
        => TryConvert(from, to, bagMassKg, out var result)
            ? result
            : throw new DomainRuleException(ErrorCodes.UnitesIncompatibles, "Ces deux unités ne peuvent pas être additionnées. Saisissez dans l'unité de la commande.");

    public static bool CanConvert(MeasureUnit from, MeasureUnit to, decimal? bagMassKg)
        => TryConvert(new Quantity(1m, from), to, bagMassKg, out _);

    /// <summary>Masse en kilogrammes d'une unite de la famille « masse » ; <c>null</c> hors famille, ou pour un sac sans masse connue.</summary>
    private static decimal? KilogramsPer(MeasureUnit unit, decimal? bagMassKg) => unit switch
    {
        MeasureUnit.Kilogram => 1m,
        MeasureUnit.Tonne => KilogramsPerTonne,
        MeasureUnit.Bag when bagMassKg is > 0m => bagMassKg,
        _ => null,
    };
}
