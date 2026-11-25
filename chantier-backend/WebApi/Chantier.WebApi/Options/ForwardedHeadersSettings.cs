using System.Net;

namespace Chantier.WebApi.Options;

/// <summary>
/// En-tetes <c>X-Forwarded-For</c> / <c>X-Forwarded-Proto</c> poses par le proxy inverse (section <c>ForwardedHeaders</c>, R1-01).
/// <b>Desactive par defaut</b> : sans proxy, ces en-tetes viendraient du client et permettraient d'usurper son adresse (limites par IP, journaux).
/// Active, il faut declarer les proxys de confiance : l'en-tete n'est lu que s'il vient d'une adresse de <see cref="KnownProxies"/>
/// ou d'un reseau de <see cref="KnownNetworks"/> ; ailleurs, il est ignore.
/// </summary>
public sealed class ForwardedHeadersSettings
{
    public const string SectionName = "ForwardedHeaders";

    public bool Enabled { get; set; }

    /// <summary>Adresses IP des proxys de confiance (ex. <c>10.0.0.2</c>).</summary>
    public string[] KnownProxies { get; set; } = [];

    /// <summary>Reseaux de proxys de confiance en notation CIDR (ex. <c>172.18.0.0/16</c>).</summary>
    public string[] KnownNetworks { get; set; } = [];

    /// <summary>Nombre de proxys successifs a traverser (1 = un seul proxy inverse devant l'API).</summary>
    public int ForwardLimit { get; set; } = 1;

    public bool HasTrustedProxy => KnownProxies.Length > 0 || KnownNetworks.Length > 0;

    public bool IsValid(out string error)
    {
        error = string.Empty;
        if (!Enabled)
        {
            return true;
        }

        if (!HasTrustedProxy)
        {
            error = "ForwardedHeaders:Enabled exige au moins un proxy de confiance (KnownProxies ou KnownNetworks) : on ne fait jamais confiance aveuglément aux en-têtes.";
            return false;
        }

        if (KnownProxies.Any(value => !IPAddress.TryParse(value, out _)) || KnownNetworks.Any(value => !IPNetwork.TryParse(value, out _)))
        {
            error = "ForwardedHeaders : une adresse de KnownProxies ou un réseau de KnownNetworks est illisible.";
            return false;
        }

        if (ForwardLimit < 1)
        {
            error = "ForwardedHeaders:ForwardLimit doit être supérieur ou égal à 1.";
            return false;
        }

        return true;
    }
}
