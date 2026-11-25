using System.Globalization;
using System.Security.Claims;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.WebApi.Controllers.Auth;
using Chantier.WebApi.Errors;
using Chantier.WebApi.Extensions;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;

namespace Chantier.WebApi.Authorization;

/// <summary>
/// Verifie a chaque requete (cache de 60 s au plus) que le compte est toujours actif : un jeton ou un cookie encore valide
/// d'un compte desactive est refuse en 401 <c>ACCES_RETIRE</c> (CT-19, ADR 0005). Le code est transmis a la reponse via
/// <c>HttpContext.Items</c> : le 401 du framework n'a pas de corps, <c>UseStatusCodePages</c> y met le Problem Details.
/// </summary>
public static class ActiveUserValidator
{
    public static async Task ValidateJwtAsync(TokenValidatedContext context)
    {
        if (!await IsActiveAsync(context.HttpContext, context.Principal))
        {
            context.Fail("Compte inactif.");
        }
    }

    /// <summary>
    /// Cookie web : compte actif, version de session inchangee (deconnexion, changement de mot de passe) et duree absolue non depassee.
    /// Un cookie sans version ni heure de connexion (emis avant R1-02) est refuse : reconnexion.
    /// </summary>
    public static async Task ValidateCookieAsync(CookieValidatePrincipalContext context)
    {
        var http = context.HttpContext;
        if (!await IsActiveAsync(http, context.Principal) || !await IsCurrentSessionAsync(http, context.Principal))
        {
            context.RejectPrincipal();
            await http.SignOutAsync(IdentityConstants.ApplicationScheme);
        }
    }

    private static async Task<bool> IsCurrentSessionAsync(HttpContext http, ClaimsPrincipal? principal)
    {
        var settings = http.RequestServices.GetRequiredService<IOptions<AuthSettings>>().Value;
        var stamp = principal?.FindFirstValue(AuthController.StampClaim);
        var loginAt = long.TryParse(principal?.FindFirstValue(AuthController.LoginAtClaim), NumberStyles.None, CultureInfo.InvariantCulture, out var seconds)
            ? DateTimeOffset.FromUnixTimeSeconds(seconds)
            : (DateTimeOffset?)null;

        var current = principal.GetUserId() is { } id
            ? await http.RequestServices.GetRequiredService<IUserStatusProvider>().GetAsync(id, http.RequestAborted)
            : null;

        var expired = loginAt is null
            || http.RequestServices.GetRequiredService<TimeProvider>().GetUtcNow() - loginAt.Value > TimeSpan.FromHours(Math.Max(1, settings.CookieAbsoluteHours));

        if (stamp is null || current?.SecurityStamp is null || !string.Equals(stamp, current.SecurityStamp, StringComparison.Ordinal) || expired)
        {
            http.Items[ProblemResponses.AuthFailureCodeItem] = ErrorCodes.NonAuthentifie;
            return false;
        }

        return true;
    }

    private static async Task<bool> IsActiveAsync(HttpContext http, ClaimsPrincipal? principal)
    {
        var userId = principal.GetUserId();
        if (userId is { } id
            && await http.RequestServices.GetRequiredService<IUserStatusProvider>().GetAsync(id, http.RequestAborted) is { IsActive: true })
        {
            return true;
        }

        http.Items[ProblemResponses.AuthFailureCodeItem] = ErrorCodes.AccesRetire;
        return false;
    }
}
