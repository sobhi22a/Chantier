using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Ardalis.Specification;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Specifications.Identity;
using Chantier.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;

namespace Chantier.Infrastructure.Services;

/// <summary>
/// Connexion, rotation des jetons de rafraichissement et changement de mot de passe (ADR 0005), calque sur le service
/// d'authentification de Kardinal avec les corrections de reference-kardinal.md : suivi des echecs par identifiant
/// (existant ou non), reponse unique pour un identifiant faux, un mot de passe faux et un compte desactive,
/// rotation atomique et revocation de la chaine apres reutilisation.
/// Les journaux ne contiennent que l'identifiant GUID anonyme : jamais de nom, d'identifiant de connexion, de telephone,
/// de mot de passe ni de jeton (CT-14).
/// </summary>
public sealed class AuthService(
    UserManager<AppUser> users,
    IRepositoryBase<RefreshToken> refreshTokens,
    ApplicationDbContext db,
    ILoginAttemptTracker attempts,
    IUserStatusProvider status,
    IPermissionService permissions,
    IOptions<JwtSettings> jwtOptions,
    IOptions<AuthSettings> authOptions,
    TimeProvider time,
    ILogger<AuthService> logger) : IAuthService
{
    private static readonly AppUser DummyUser = new();

    private JwtSettings Jwt => jwtOptions.Value;

    public async Task<AuthResult> LoginAsync(string userName, string password, bool isAppMobile, string? ipAddress, CancellationToken cancellationToken = default)
    {
        var identifier = Normalize(userName);
        if (attempts.GetRetryAfter(identifier) is { } wait)
        {
            logger.LogWarning("Connexion refusée : trop d'échecs");
            throw new TooManyAttemptsException(wait < TimeSpan.Zero ? TimeSpan.Zero : wait);
        }

        var user = await users.FindByNameAsync(userName.Trim());
        var passwordOk = user is null
            ? BurnPasswordHashTime(password)
            : await users.CheckPasswordAsync(user, password);

        // Identifiant inconnu, mot de passe faux et compte desactive : meme reponse, meme comptage (CA-001.3).
        if (user is null || !passwordOk || !user.IsActive)
        {
            attempts.RegisterFailure(identifier);
            logger.LogInformation("Échec de connexion");
            throw new InvalidCredentialsException();
        }

        var role = await GetRoleAsync(user);
        if (role is null)
        {
            attempts.RegisterFailure(identifier);
            logger.LogWarning("Connexion refusée : compte sans rôle {UserId}", user.Id);
            throw new InvalidCredentialsException();
        }

        attempts.Reset(identifier);
        logger.LogInformation("Connexion réussie {UserId} mobile={IsMobile}", user.Id, isAppMobile);
        return await BuildResultAsync(user, role, isAppMobile, ipAddress, cancellationToken);
    }

    public async Task<AuthResult> RefreshAsync(string refreshToken, string? ipAddress, CancellationToken cancellationToken = default)
    {
        var now = time.GetUtcNow();
        var stored = await refreshTokens.FirstOrDefaultAsync(new RefreshTokenByHashSpecification(HashToken(refreshToken)), cancellationToken);
        if (stored is null)
        {
            throw new InvalidCredentialsException(ErrorCodes.RefreshInvalide);
        }

        var user = await users.FindByIdAsync(stored.UserId.ToString());
        if (user is null)
        {
            throw new InvalidCredentialsException(ErrorCodes.RefreshInvalide);
        }

        if (!user.IsActive)
        {
            // Compte desactive : acces retire (le mobile efface les donnees chantier) et plus aucun jeton ne marche (CT-19).
            await RevokeAllAsync(user.Id, ipAddress, cancellationToken);
            logger.LogWarning("Rafraîchissement refusé : accès retiré {UserId}", user.Id);
            throw new AccessRevokedException();
        }

        if (stored.IsActiveAt(now) is false)
        {
            if (await TryRetryLostRotationAsync(stored, user, ipAddress, now, cancellationToken) is { } retried)
            {
                return retried;
            }

            if (stored.RevokedAt is not null)
            {
                // Jeton deja revoque presente a nouveau : vol presume, on brule toute la chaine (CT-2).
                await RevokeAllAsync(user.Id, ipAddress, cancellationToken);
                logger.LogWarning("Réutilisation d'un jeton de rafraîchissement détectée {UserId}", user.Id);
            }

            throw new InvalidCredentialsException(ErrorCodes.RefreshInvalide);
        }

        var role = await GetRoleAsync(user) ?? throw new InvalidCredentialsException(ErrorCodes.RefreshInvalide);
        var (raw, entity) = NewRefreshToken(user.Id, ipAddress, now);

        // Revocation atomique : si deux appels presentent le meme jeton en parallele, un seul gagne ; l'autre est une reutilisation.
        var claimed = await db.RefreshTokens
            .Where(token => token.Id == stored.Id && token.RevokedAt == null)
            .ExecuteUpdateAsync(
                update => update
                    .SetProperty(token => token.RevokedAt, now)
                    .SetProperty(token => token.RevokedByIp, ipAddress)
                    .SetProperty(token => token.ReplacedByTokenHash, entity.TokenHash),
                cancellationToken);

        if (claimed == 0)
        {
            await RevokeAllAsync(user.Id, ipAddress, cancellationToken);
            logger.LogWarning("Réutilisation d'un jeton de rafraîchissement détectée {UserId}", user.Id);
            throw new InvalidCredentialsException(ErrorCodes.RefreshInvalide);
        }

        await refreshTokens.AddAsync(entity, cancellationToken);
        logger.LogInformation("Jeton de rafraîchissement renouvelé {UserId}", user.Id);
        return BuildMobileResult(user, role, raw);
    }

    /// <summary>
    /// Fenetre de grace (R1-05) : l'ancien jeton a ete remplace il y a peu et son successeur n'a pas servi. La reponse du renouvellement s'est donc
    /// probablement perdue en route : on emet un nouveau successeur (l'ancien successeur, jamais livre, est revoque) et la chaine reste intacte.
    /// <c>null</c> = pas un cas de grace, l'appelant traite la reutilisation.
    /// </summary>
    private async Task<AuthResult?> TryRetryLostRotationAsync(RefreshToken stored, AppUser user, string? ipAddress, DateTimeOffset now, CancellationToken cancellationToken)
    {
        var grace = TimeSpan.FromSeconds(Math.Max(0, authOptions.Value.RefreshGraceSeconds));
        if (stored.RevokedAt is not { } revokedAt || stored.ReplacedByTokenHash is not { } successorHash || now - revokedAt > grace || now >= stored.ExpiresAt)
        {
            return null;
        }

        var role = await GetRoleAsync(user);
        if (role is null)
        {
            return null;
        }

        var (raw, entity) = NewRefreshToken(user.Id, ipAddress, now);
        var claimed = await db.RefreshTokens
            .Where(token => token.TokenHash == successorHash && token.UserId == user.Id && token.RevokedAt == null && token.ExpiresAt > now)
            .ExecuteUpdateAsync(
                update => update
                    .SetProperty(token => token.RevokedAt, now)
                    .SetProperty(token => token.RevokedByIp, ipAddress)
                    .SetProperty(token => token.ReplacedByTokenHash, entity.TokenHash),
                cancellationToken);

        if (claimed == 0)
        {
            // Le successeur a deja servi (ou un autre renvoi a gagne) : pas une perte de reponse, le cas general s'applique.
            return null;
        }

        await refreshTokens.AddAsync(entity, cancellationToken);
        logger.LogInformation("Renouvellement rejoué dans la fenêtre de grâce {UserId}", user.Id);
        return BuildMobileResult(user, role, raw);
    }

    public async Task LogoutAsync(Guid userId, string? refreshToken, string? ipAddress, CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrWhiteSpace(refreshToken))
        {
            var hash = HashToken(refreshToken);
            var now = time.GetUtcNow();
            await db.RefreshTokens
                .Where(token => token.TokenHash == hash && token.UserId == userId && token.RevokedAt == null)
                .ExecuteUpdateAsync(
                    update => update.SetProperty(token => token.RevokedAt, now).SetProperty(token => token.RevokedByIp, ipAddress),
                    cancellationToken);
        }

        logger.LogInformation("Déconnexion {UserId}", userId);
    }

    public async Task ChangePasswordAsync(Guid userId, string currentPassword, string newPassword, string? ipAddress, CancellationToken cancellationToken = default)
    {
        var user = await users.FindByIdAsync(userId.ToString()) ?? throw new InvalidCredentialsException(ErrorCodes.NonAuthentifie);
        var identifier = Normalize(user.UserName ?? string.Empty);

        // Un jeton vole ne doit pas permettre de deviner le mot de passe actuel : meme blocage que la connexion.
        if (attempts.GetRetryAfter(identifier) is { } wait)
        {
            throw new TooManyAttemptsException(wait < TimeSpan.Zero ? TimeSpan.Zero : wait);
        }

        if (!await users.CheckPasswordAsync(user, currentPassword))
        {
            attempts.RegisterFailure(identifier);
            logger.LogInformation("Changement de mot de passe refusé : mot de passe actuel incorrect {UserId}", userId);
            throw new InvalidCredentialsException();
        }

        if (string.Equals(currentPassword, newPassword, StringComparison.Ordinal))
        {
            throw new DomainRuleException(ErrorCodes.MotDePasseFaible, "Le nouveau mot de passe doit être différent de l'actuel.");
        }

        var result = await users.ChangePasswordAsync(user, currentPassword, newPassword);
        if (!result.Succeeded)
        {
            throw new DomainRuleException(ErrorCodes.MotDePasseFaible, "Le mot de passe doit contenir au moins 8 caractères dont un chiffre.");
        }

        user.MustChangePassword = false;
        await users.UpdateAsync(user);
        attempts.Reset(identifier);
        await RevokeAllAsync(userId, ipAddress, cancellationToken);
        status.Invalidate(userId);
        logger.LogInformation("Mot de passe changé {UserId}", userId);
    }

    public async Task<string> GetSessionStampAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await users.FindByIdAsync(userId.ToString()) ?? throw new NotFoundException();
        return await users.GetSecurityStampAsync(user) ?? string.Empty;
    }

    public async Task EndWebSessionsAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await users.FindByIdAsync(userId.ToString()) ?? throw new NotFoundException();
        var result = await users.UpdateSecurityStampAsync(user);
        if (!result.Succeeded)
        {
            throw new InvalidOperationException("Invalidation des sessions web refusée.");
        }

        status.Invalidate(userId);
        logger.LogInformation("Sessions web invalidées {UserId}", userId);
    }

    public async Task<MeResponse> GetMeAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await users.FindByIdAsync(userId.ToString()) ?? throw new NotFoundException();
        var role = await GetRoleAsync(user) ?? throw new NotFoundException();
        var granted = (await permissions.GetForRoleAsync(role, cancellationToken)).Order(StringComparer.Ordinal).ToList();

        // Le telephone n'est renvoye qu'a son titulaire : cette methode ne sert que « GET /auth/me » (H-17).
        return new MeResponse(
            user.Id, user.UserName ?? string.Empty, user.FullName, user.PhoneNumber, role, user.Language,
            granted, PermissionVersion.Compute(granted), user.MustChangePassword);
    }

    public async Task UpdateLanguageAsync(Guid userId, string language, CancellationToken cancellationToken = default)
    {
        if (!AppUser.IsSupportedLanguage(language))
        {
            throw new Core.Exceptions.ValidationException("language", "La langue doit être « fr » ou « ar ».");
        }

        var user = await users.FindByIdAsync(userId.ToString()) ?? throw new NotFoundException();
        user.Language = language;
        var result = await users.UpdateAsync(user);
        if (!result.Succeeded)
        {
            throw new InvalidOperationException("Mise à jour de la langue refusée.");
        }
    }

    private async Task<AuthResult> BuildResultAsync(AppUser user, string role, bool isAppMobile, string? ipAddress, CancellationToken cancellationToken)
    {
        if (!isAppMobile)
        {
            return new AuthResult(ToResponse(user, role), null, null, null);
        }

        var (raw, entity) = NewRefreshToken(user.Id, ipAddress, time.GetUtcNow());
        await refreshTokens.AddAsync(entity, cancellationToken);
        return BuildMobileResult(user, role, raw);
    }

    private AuthResult BuildMobileResult(AppUser user, string role, string rawRefreshToken)
    {
        var minutes = Math.Max(1, Jwt.AccessTokenDurationInMinutes);
        return new AuthResult(ToResponse(user, role), CreateAccessToken(user, role, minutes), rawRefreshToken, minutes * 60);
    }

    private string CreateAccessToken(AppUser user, string role, int minutes)
    {
        var now = time.GetUtcNow().UtcDateTime;
        var descriptor = new SecurityTokenDescriptor
        {
            // Pas de nom ni de telephone dans le jeton : seulement l'identifiant anonyme et le role.
            Subject = new ClaimsIdentity(
            [
                new Claim("sub", user.Id.ToString()),
                new Claim("jti", Guid.NewGuid().ToString()),
                new Claim("role", role),
            ]),
            IssuedAt = now,
            NotBefore = now,
            Expires = now.AddMinutes(minutes),
            Issuer = Jwt.Issuer,
            Audience = Jwt.Audience,
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Jwt.Key)), SecurityAlgorithms.HmacSha256),
        };

        return new JsonWebTokenHandler().CreateToken(descriptor);
    }

    private (string Raw, RefreshToken Entity) NewRefreshToken(Guid userId, string? ipAddress, DateTimeOffset now)
    {
        var raw = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32));
        var days = Jwt.RefreshTokenDurationInDays <= 0 ? 14 : Jwt.RefreshTokenDurationInDays;
        return (raw, new RefreshToken
        {
            UserId = userId,
            TokenHash = HashToken(raw),
            CreatedAt = now,
            CreatedByIp = ipAddress,
            ExpiresAt = now.AddDays(days),
        });
    }

    private async Task RevokeAllAsync(Guid userId, string? ipAddress, CancellationToken cancellationToken)
    {
        var now = time.GetUtcNow();
        await db.RefreshTokens
            .Where(token => token.UserId == userId && token.RevokedAt == null)
            .ExecuteUpdateAsync(
                update => update.SetProperty(token => token.RevokedAt, now).SetProperty(token => token.RevokedByIp, ipAddress),
                cancellationToken);
    }

    private async Task<string?> GetRoleAsync(AppUser user) => (await users.GetRolesAsync(user)).FirstOrDefault();

    private static AuthUserResponse ToResponse(AppUser user, string role)
        => new(user.Id, user.UserName ?? string.Empty, user.FullName, role, user.Language, user.MustChangePassword);

    private static string Normalize(string userName) => userName.Trim().ToUpperInvariant();

    /// <summary>Identifiant inconnu : on depense le meme temps de hachage qu'une verification, pour ne pas reveler l'existence par la latence.</summary>
    private bool BurnPasswordHashTime(string password)
    {
        _ = users.PasswordHasher.HashPassword(DummyUser, password);
        return false;
    }

    public static string HashToken(string raw) => Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(raw)));
}
