namespace Chantier.Core.Identity;

/// <summary>
/// Reglages des jetons (section <c>JwtSettings</c>). La cle vient de user-secrets ou de la variable
/// d'environnement <c>JwtSettings__Key</c> : jamais d'un fichier versionne (CT-15).
/// </summary>
public sealed class JwtSettings
{
    public const string SectionName = "JwtSettings";
    public const int MinimumKeyBytes = 32;

    public string Key { get; set; } = string.Empty;
    public string Issuer { get; set; } = "chantier-api";
    public string Audience { get; set; } = "chantier-clients";

    /// <summary>Jeton d'acces court (CT-1).</summary>
    public int AccessTokenDurationInMinutes { get; set; } = 15;

    /// <summary>Jeton de rafraichissement : 14 jours, alignes sur la duree de session hors ligne (H-05).</summary>
    public int RefreshTokenDurationInDays { get; set; } = 14;

    /// <summary>Message d'erreur si la cle est absente ou trop courte ; ne contient jamais la cle.</summary>
    public string? ValidateKey()
    {
        if (string.IsNullOrWhiteSpace(Key) || System.Text.Encoding.UTF8.GetByteCount(Key) < MinimumKeyBytes)
        {
            return $"{SectionName}:Key est absente ou plus courte que {MinimumKeyBytes} octets. "
                + "Renseignez-la avec user-secrets (développement) ou la variable d'environnement JwtSettings__Key.";
        }

        return null;
    }
}
