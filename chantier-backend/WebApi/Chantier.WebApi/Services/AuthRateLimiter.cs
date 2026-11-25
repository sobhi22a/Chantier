using System.Security.Cryptography;
using System.Text;
using System.Threading.RateLimiting;
using Chantier.Core.Exceptions;
using Chantier.WebApi.Options;
using Microsoft.Extensions.Options;

namespace Chantier.WebApi.Services;

/// <summary>
/// Politique « auth » (connexion, rafraichissement) : 10 requetes / 5 min par couple (adresse IP, identifiant hache).
/// Kardinal limitait a 5 / 5 min par IP seule : les adresses des operateurs mobiles sont partagees par de nombreux telephones,
/// toute une equipe de chantier aurait ete bloquee (reference-kardinal.md, B-12). L'identifiant est lu dans le corps de la
/// requete, donc le controle est fait par l'action et non par le middleware de limitation, qui s'execute avant la lecture du corps.
/// </summary>
public sealed class AuthRateLimiter : IDisposable
{
    private readonly PartitionedRateLimiter<string> _limiter;

    public AuthRateLimiter(IOptions<RateLimitSettings> options)
    {
        var settings = options.Value.Auth;
        _limiter = PartitionedRateLimiter.Create<string, string>(key =>
            RateLimitPartition.GetFixedWindowLimiter(key, _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = Math.Max(1, settings.PermitLimit),
                Window = TimeSpan.FromMinutes(Math.Max(1, settings.WindowMinutes)),
                QueueLimit = 0,
            }));
    }

    /// <summary>Leve <see cref="RateLimitedException"/> (429) si le couple (adresse, identifiant) depasse sa limite.</summary>
    public void Enforce(string? ipAddress, string identifier)
    {
        var hash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(identifier.Trim().ToUpperInvariant())))[..16];
        using var lease = _limiter.AttemptAcquire($"{ipAddress ?? "unknown"}|{hash}");
        if (!lease.IsAcquired)
        {
            lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter);
            throw new RateLimitedException(retryAfter == default ? TimeSpan.FromMinutes(1) : retryAfter);
        }
    }

    public void Dispose() => _limiter.Dispose();
}
