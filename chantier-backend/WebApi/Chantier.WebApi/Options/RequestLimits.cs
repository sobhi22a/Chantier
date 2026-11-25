namespace Chantier.WebApi.Options;

/// <summary>Limites de requete communes (R1-08).</summary>
public static class RequestLimits
{
    /// <summary>Taille maximale d'un corps de requete, sauf route qui declare sa propre limite : 64 Ko (une connexion en pese moins de 1 Ko).</summary>
    public const long DefaultMaxBodyBytes = 64 * 1024;
}
