namespace Chantier.WebApi.Options;

/// <summary>Origines autorisees du back-office (section <c>Cors</c>). Liste blanche exacte, jamais de joker (CT-15).</summary>
public sealed class CorsSettings
{
    public const string SectionName = "Cors";

    public string[] Origins { get; set; } = [];

    public bool HasWildcard => Origins.Any(origin => origin.Contains('*', StringComparison.Ordinal));
}
