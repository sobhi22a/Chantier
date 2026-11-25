namespace Chantier.Core.Sites;

/// <summary>Bornes de la cote d'une zone, en metres (H-15, section <c>Zones</c>) : parametrables.</summary>
public sealed class ZoneOptions
{
    public const string SectionName = "Zones";

    public decimal ElevationMin { get; set; } = -20.00m;

    public decimal ElevationMax { get; set; } = 60.00m;
}
