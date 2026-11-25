namespace Chantier.WebApi.Options;

/// <summary>
/// Chiffrement des cles de protection des donnees (section <c>DataProtection</c>, R1-06). Ces cles signent et chiffrent les cookies de session :
/// ecrites en clair, elles permettraient de forger un cookie d'Admin. Hors developpement, un certificat (PKCS#12) est obligatoire.
/// </summary>
public sealed class DataProtectionSettings
{
    public const string SectionName = "DataProtection";

    /// <summary>Fichier PKCS#12 (.pfx) du certificat qui chiffre les cles ; hors du depot et du dossier de deploiement.</summary>
    public string? CertificatePath { get; set; }

    /// <summary>Mot de passe du .pfx : variable d'environnement ou secret, jamais dans un fichier versionne.</summary>
    public string? CertificatePassword { get; set; }

    /// <summary>Derogation explicite et volontaire (recette sans certificat). Jamais pour la production.</summary>
    public bool AllowUnencryptedKeys { get; set; }

    public bool IsAcceptableIn(bool isDevelopment)
        => isDevelopment || AllowUnencryptedKeys || !string.IsNullOrWhiteSpace(CertificatePath);
}
