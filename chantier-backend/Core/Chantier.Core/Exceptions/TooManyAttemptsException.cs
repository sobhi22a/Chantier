namespace Chantier.Core.Exceptions;

/// <summary>Trop d'echecs de connexion sur un identifiant (existant ou non) : 429 avec <c>Retry-After</c>.</summary>
public sealed class TooManyAttemptsException : DomainException
{
    public TooManyAttemptsException(TimeSpan retryAfter)
        : base(ErrorCodes.TropDEssais, "Trop d'essais, réessayez plus tard.")
    {
        RetryAfter = retryAfter;
    }

    public TimeSpan RetryAfter { get; }
}
