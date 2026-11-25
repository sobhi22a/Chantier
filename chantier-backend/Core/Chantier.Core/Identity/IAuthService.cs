using System.Text.Json.Serialization;

namespace Chantier.Core.Identity;

/// <summary>Utilisateur renvoye apres connexion. Jamais de telephone ici : il n'est visible que par son titulaire via <c>GET /auth/me</c> (H-17).</summary>
public sealed record AuthUserResponse(
    Guid Id,
    string UserName,
    string FullName,
    string Role,
    string Language,
    bool MustChangePassword);

/// <summary>
/// Resultat de connexion ou de rafraichissement. Web (<c>isAppMobile = false</c>) : cookie + <c>user</c>.
/// Mobile : en plus <c>accessToken</c> (15 min), <c>refreshToken</c> (14 jours, rotatif) et <c>expiresIn</c> (secondes).
/// </summary>
public sealed record AuthResult(
    AuthUserResponse User,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? AccessToken,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? RefreshToken,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] int? ExpiresIn);

/// <summary>Profil du titulaire : le seul endroit ou son telephone est renvoye (H-17, CT-14).</summary>
public sealed record MeResponse(
    Guid Id,
    string UserName,
    string FullName,
    string? PhoneNumber,
    string Role,
    string Language,
    IReadOnlyList<string> Permissions,
    string PermissionsVersion,
    bool MustChangePassword);

public interface IAuthService
{
    Task<AuthResult> LoginAsync(string userName, string password, bool isAppMobile, string? ipAddress, CancellationToken cancellationToken = default);

    Task<AuthResult> RefreshAsync(string refreshToken, string? ipAddress, CancellationToken cancellationToken = default);

    /// <summary>Revoque le jeton de rafraichissement fourni s'il appartient a l'utilisateur ; sans effet sinon.</summary>
    Task LogoutAsync(Guid userId, string? refreshToken, string? ipAddress, CancellationToken cancellationToken = default);

    /// <summary>Change le mot de passe, leve l'obligation de changement et revoque tous les jetons de rafraichissement (CT-2).</summary>
    Task ChangePasswordAsync(Guid userId, string currentPassword, string newPassword, string? ipAddress, CancellationToken cancellationToken = default);

    /// <summary>Version de session a inscrire dans le cookie web a la connexion (R1-02).</summary>
    Task<string> GetSessionStampAsync(Guid userId, CancellationToken cancellationToken = default);

    /// <summary>Invalide tous les cookies web deja emis pour cet utilisateur (deconnexion web) ; les jetons mobiles ne sont pas touches (R1-02).</summary>
    Task EndWebSessionsAsync(Guid userId, CancellationToken cancellationToken = default);

    Task<MeResponse> GetMeAsync(Guid userId, CancellationToken cancellationToken = default);

    Task UpdateLanguageAsync(Guid userId, string language, CancellationToken cancellationToken = default);
}
