using System.Security.Claims;
using Chantier.Core.Abstractions;
using Chantier.Core.Identity;
using Chantier.WebApi.Models.Auth;
using Chantier.WebApi.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Controllers.Auth;

/// <summary>Connexion web (cookie) et mobile (jetons), profil, langue et mot de passe (ADR 0005).</summary>
[ApiController]
[Route("api/v1/auth")]
[Produces("application/json")]
public sealed class AuthController(IAuthService auth, AuthRateLimiter rateLimiter, ICurrentUser currentUser, TimeProvider time) : ControllerBase
{
    /// <summary>Claims du cookie web : version de session de l'utilisateur et heure de connexion (plafond absolu), R1-02.</summary>
    public const string StampClaim = "session_stamp";
    public const string LoginAtClaim = "login_at";

    private string? Ip => HttpContext.Connection.RemoteIpAddress?.ToString();

    private Guid UserId => currentUser.Id ?? throw new InvalidOperationException("Utilisateur non authentifié.");

    /// <summary>Se connecter.</summary>
    /// <remarks>
    /// Web (<c>isAppMobile = false</c>) : cookie de session HttpOnly. Mobile : jeton d'accès de 15 min et jeton de
    /// rafraîchissement de 14 jours. Identifiant faux, mot de passe faux et compte désactivé donnent la même réponse.
    /// </remarks>
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType<AuthResult>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status429TooManyRequests, "application/problem+json")]
    public async Task<ActionResult<AuthResult>> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        rateLimiter.Enforce(Ip, request.UserName!);
        var result = await auth.LoginAsync(request.UserName!, request.Password!, request.IsAppMobile, Ip, cancellationToken);

        if (!request.IsAppMobile)
        {
            await SignInCookieAsync(result.User, await auth.GetSessionStampAsync(result.User.Id, cancellationToken));
        }

        return Ok(result);
    }

    /// <summary>Renouveler les jetons (mobile). L'ancien jeton de rafraîchissement n'est plus accepté.</summary>
    [HttpPost("refresh")]
    [AllowAnonymous]
    [ProducesResponseType<AuthResult>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status429TooManyRequests, "application/problem+json")]
    public async Task<ActionResult<AuthResult>> Refresh([FromBody] RefreshRequest request, CancellationToken cancellationToken)
    {
        rateLimiter.Enforce(Ip, request.RefreshToken!);
        return Ok(await auth.RefreshAsync(request.RefreshToken!, Ip, cancellationToken));
    }

    /// <summary>Se déconnecter : efface le cookie et révoque le jeton de rafraîchissement fourni.</summary>
    [HttpPost("logout")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    public async Task<IActionResult> Logout([FromBody(EmptyBodyBehavior = Microsoft.AspNetCore.Mvc.ModelBinding.EmptyBodyBehavior.Allow)] LogoutRequest? request, CancellationToken cancellationToken)
    {
        await auth.LogoutAsync(UserId, request?.RefreshToken, Ip, cancellationToken);

        // Un cookie deja emis ne doit plus servir apres « Se deconnecter » (vol de cookie, poste partage) : on change la version de session.
        if (await IsCookieSessionAsync())
        {
            await auth.EndWebSessionsAsync(UserId, cancellationToken);
        }

        await HttpContext.SignOutAsync(IdentityConstants.ApplicationScheme);
        return NoContent();
    }

    /// <summary>Changer son mot de passe (obligatoire après un mot de passe provisoire). Révoque tous les jetons de rafraîchissement.</summary>
    [HttpPost("change-password")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status422UnprocessableEntity, "application/problem+json")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        var wasCookieSession = await IsCookieSessionAsync();
        await auth.ChangePasswordAsync(UserId, request.CurrentPassword!, request.NewPassword!, Ip, cancellationToken);

        // Le changement invalide tous les cookies emis avant (autres navigateurs, cookie vole) ; la session qui l'a demande est reouverte.
        if (wasCookieSession)
        {
            var me = await auth.GetMeAsync(UserId, cancellationToken);
            await SignInCookieAsync(new AuthUserResponse(me.Id, me.UserName, me.FullName, me.Role, me.Language, me.MustChangePassword), await auth.GetSessionStampAsync(UserId, cancellationToken));
        }

        return NoContent();
    }

    /// <summary>Mon profil et mes permissions. Le téléphone n'est renvoyé qu'à son titulaire.</summary>
    [HttpGet("me")]
    [ProducesResponseType<MeResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    public async Task<ActionResult<MeResponse>> Me(CancellationToken cancellationToken)
        => Ok(await auth.GetMeAsync(UserId, cancellationToken));

    /// <summary>Changer ma langue (français ou arabe).</summary>
    [HttpPut("me/language")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status401Unauthorized, "application/problem+json")]
    public async Task<IActionResult> UpdateLanguage([FromBody] UpdateLanguageRequest request, CancellationToken cancellationToken)
    {
        await auth.UpdateLanguageAsync(UserId, request.Language!, cancellationToken);
        return NoContent();
    }

    private async Task<bool> IsCookieSessionAsync()
        => (await HttpContext.AuthenticateAsync(IdentityConstants.ApplicationScheme)).Succeeded;

    private Task SignInCookieAsync(AuthUserResponse user, string sessionStamp)
    {
        // Cookie minimal : identifiant anonyme, role, version de session et heure de connexion. Les permissions restent cote serveur (cache de 5 minutes).
        var identity = new ClaimsIdentity(
            [
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Role, user.Role),
                new Claim(StampClaim, sessionStamp),
                new Claim(LoginAtClaim, time.GetUtcNow().ToUnixTimeSeconds().ToString(System.Globalization.CultureInfo.InvariantCulture)),
            ],
            IdentityConstants.ApplicationScheme);

        return HttpContext.SignInAsync(
            IdentityConstants.ApplicationScheme,
            new ClaimsPrincipal(identity),
            new AuthenticationProperties { IsPersistent = true });
    }
}
