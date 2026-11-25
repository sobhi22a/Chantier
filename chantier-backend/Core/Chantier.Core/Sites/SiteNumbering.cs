using System.Globalization;

namespace Chantier.Core.Sites;

/// <summary>Prefixes des numeros de document par chantier (regle 5) : DEM-001, LIV-001, T-001, PB-001, SIT-001.</summary>
public static class NumberPrefixes
{
    public const string Request = "DEM";
    public const string Delivery = "LIV";
    public const string Task = "T";
    public const string Issue = "PB";
    public const string Statement = "SIT";

    public const int MaxLength = 10;

    public static readonly IReadOnlyList<string> All = [Request, Delivery, Task, Issue, Statement];

    public static bool IsKnown(string? prefix) => prefix is not null && All.Contains(prefix, StringComparer.Ordinal);
}

/// <summary>Format d'un numero : prefixe, tiret, au moins 3 chiffres ; au-dela de 999 le numero grandit sans troncature (<c>DEM-1000</c>).</summary>
public static class SiteNumber
{
    public const int MinDigits = 3;

    public static string Format(string prefix, int value)
    {
        if (value < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(value), "Un numéro commence à 1.");
        }

        return $"{prefix}-{value.ToString("D" + MinDigits, CultureInfo.InvariantCulture)}";
    }
}

/// <summary>
/// Numerotation par chantier, attribuee <b>par le serveur seulement</b> (jamais par le client). Fondation du socle : aucune entite ne
/// l'utilise encore, le premier consommateur est le lot des demandes de materiaux.
/// </summary>
public interface ISiteNumbering
{
    /// <summary>
    /// Attribue le numero suivant du chantier pour ce prefixe (<c>DEM-001</c>, puis <c>DEM-002</c>...), sans trou ni doublon, y compris
    /// avec des appels paralleles. Le compteur est verrouille jusqu'a la fin de la transaction : <b>l'appeler dans la transaction qui ecrit
    /// l'entite</b> (une annulation libere le numero, il n'y a donc pas de trou). Une transaction est exigee, sinon <see cref="InvalidOperationException"/>.
    /// Ordre a respecter par l'appelant : verifier d'abord l'idempotence (<c>clientId</c> deja recu : renvoyer l'existant), puis demander le numero.
    /// </summary>
    Task<string> NextAsync(Guid siteId, string prefix, CancellationToken cancellationToken = default);
}
