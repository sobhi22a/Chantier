namespace Chantier.Core.Exceptions;

/// <summary>Limite de debit depassee sur la surface d'authentification (par adresse et identifiant) : 429 avec <c>Retry-After</c>.</summary>
public sealed class RateLimitedException : DomainException
{
    public RateLimitedException(TimeSpan retryAfter)
        : base(ErrorCodes.TropDeRequetes, "Trop de requêtes, réessayez dans un instant.")
    {
        RetryAfter = retryAfter;
    }

    public TimeSpan RetryAfter { get; }
}
