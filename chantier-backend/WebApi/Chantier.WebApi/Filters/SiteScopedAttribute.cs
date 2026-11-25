using Chantier.Core.Sites;
using Microsoft.AspNetCore.Mvc.Filters;

namespace Chantier.WebApi.Filters;

/// <summary>
/// Obligatoire sur toute route portant <c>{siteId}</c> (un test d'architecture le verifie). Verifie l'affectation de l'utilisateur
/// au chantier : sinon <c>404 INTROUVABLE</c>, <b>strictement identique</b> a celui d'un chantier inexistant (CA-006.2).
/// Filtre de <b>ressource</b> : il s'execute avant la liaison du corps, donc un corps invalide ne revele jamais l'existence
/// d'un chantier non affecte (400 pour un chantier existant, 404 pour les autres).
/// </summary>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public sealed class SiteScopedAttribute : Attribute, IAsyncResourceFilter
{
    public const string RouteKey = "siteId";

    public async Task OnResourceExecutionAsync(ResourceExecutingContext context, ResourceExecutionDelegate next)
    {
        if (!context.RouteData.Values.TryGetValue(RouteKey, out var raw) || !Guid.TryParse(raw?.ToString(), out var siteId))
        {
            throw new Core.Exceptions.NotFoundException();
        }

        await context.HttpContext.RequestServices.GetRequiredService<ISiteAccess>().EnsureAsync(siteId, context.HttpContext.RequestAborted);
        await next();
    }
}
