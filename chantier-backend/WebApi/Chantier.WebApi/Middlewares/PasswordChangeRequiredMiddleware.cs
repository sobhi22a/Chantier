using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.WebApi.Extensions;
using Microsoft.AspNetCore.Authorization;

namespace Chantier.WebApi.Middlewares;

/// <summary>
/// Mot de passe provisoire : tout est refuse (403 <c>MOT_DE_PASSE_A_CHANGER</c>) tant que l'utilisateur n'a pas choisi
/// le sien (CA-001.7), sauf lire son profil, changer sa langue, changer son mot de passe et se deconnecter.
/// S'execute apres l'autorisation, quand l'utilisateur est connu ; ignore les routes anonymes.
/// </summary>
public sealed class PasswordChangeRequiredMiddleware(RequestDelegate next)
{
    private static readonly string[] AllowedPaths =
    [
        "/api/v1/auth/me",
        "/api/v1/auth/me/language",
        "/api/v1/auth/change-password",
        "/api/v1/auth/logout",
    ];

    public async Task InvokeAsync(HttpContext context, IUserStatusProvider statusProvider)
    {
        var isAnonymousRoute = context.GetEndpoint()?.Metadata.GetMetadata<IAllowAnonymous>() is not null;
        if (!isAnonymousRoute
            && context.User.Identity is { IsAuthenticated: true }
            && context.User.GetUserId() is { } userId
            && !AllowedPaths.Contains(context.Request.Path.Value?.TrimEnd('/'), StringComparer.OrdinalIgnoreCase)
            && await statusProvider.GetAsync(userId, context.RequestAborted) is { MustChangePassword: true })
        {
            throw new PasswordChangeRequiredException();
        }

        await next(context);
    }
}
