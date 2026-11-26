namespace Chantier.WebApi.Options;

/// <summary>Limites de requete communes (R1-08).</summary>
public static class RequestLimits
{
    /// <summary>Taille maximale d'un corps de requete, sauf route qui declare sa propre limite : 64 Ko (une connexion en pese moins de 1 Ko).</summary>
    public const long DefaultMaxBodyBytes = 64 * 1024;

    /// <summary>Corps de l'envoi d'une photo de bon (ADR 0013) : 6 Mo, un peu plus que la limite du fichier (<c>Storage:MaxPhotoBytes</c>, 5 Mo) ; le proxy ne releve sa limite que sur cette route.</summary>
    public const long PhotoMaxBodyBytes = 6 * 1024 * 1024;
}
