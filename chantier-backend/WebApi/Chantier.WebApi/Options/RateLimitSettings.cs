namespace Chantier.WebApi.Options;

/// <summary>Limitation de debit (section <c>RateLimiting</c>, ADR 0005).</summary>
public sealed class RateLimitSettings
{
    public const string SectionName = "RateLimiting";

    /// <summary>Politique <c>auth</c> (connexion, rafraichissement) : par couple (adresse IP, identifiant hache).</summary>
    public AuthLimit Auth { get; set; } = new();

    /// <summary>Limiteur global : par utilisateur authentifie, par adresse IP sinon.</summary>
    public GlobalLimit Global { get; set; } = new();

    public sealed class AuthLimit
    {
        public int PermitLimit { get; set; } = 10;
        public int WindowMinutes { get; set; } = 5;
    }

    public sealed class GlobalLimit
    {
        public int PermitLimit { get; set; } = 300;
        public int WindowMinutes { get; set; } = 1;
    }
}
