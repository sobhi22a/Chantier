namespace Chantier.Core.Entities.Identity;

/// <summary>
/// Jeton de rafraichissement persistant. La valeur brute n'est jamais stockee : seulement son empreinte SHA-256.
/// La rotation renseigne <see cref="RevokedAt"/> et <see cref="ReplacedByTokenHash"/> ; la reutilisation d'un jeton
/// deja revoque est traitee comme un vol et revoque toute la chaine (ADR 0005).
/// </summary>
public class RefreshToken
{
    public Guid Id { get; set; } = Guid.CreateVersion7();

    public Guid UserId { get; set; }

    /// <summary>SHA-256 (base64) du jeton brut.</summary>
    public string TokenHash { get; set; } = string.Empty;

    public DateTimeOffset CreatedAt { get; set; }

    public string? CreatedByIp { get; set; }

    public DateTimeOffset ExpiresAt { get; set; }

    public DateTimeOffset? RevokedAt { get; set; }

    public string? RevokedByIp { get; set; }

    /// <summary>Empreinte du jeton qui a remplace celui-ci a la rotation.</summary>
    public string? ReplacedByTokenHash { get; set; }

    public bool IsActiveAt(DateTimeOffset now) => RevokedAt is null && now < ExpiresAt;
}
