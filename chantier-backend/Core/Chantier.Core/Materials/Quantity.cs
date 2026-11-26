namespace Chantier.Core.Materials;

/// <summary>Une quantite et son unite : les deux voyagent toujours ensemble (<c>{ "value": 300, "unit": "sac" }</c>).</summary>
/// <param name="Value">Valeur, 3 decimales au plus.</param>
/// <param name="Unit">Code de l'unite : <c>u ml m2 m3 kg t sac l h j pj ft</c>.</param>
public readonly record struct Quantity(decimal Value, MeasureUnit Unit)
{
    /// <summary>Quantite sans zeros inutiles a droite (300 et non 300,000) : meme valeur, JSON plus lisible.</summary>
    public static Quantity Of(decimal value, MeasureUnit unit) => new(DecimalScale.Normalize(value), unit);
}

public static class DecimalScale
{
    /// <summary>Retire les zeros de fin (le <c>decimal</c> garde l'echelle de la colonne : 300,000).</summary>
    public static decimal Normalize(decimal value) => value / 1.0000000000000000000000000000m;
}
