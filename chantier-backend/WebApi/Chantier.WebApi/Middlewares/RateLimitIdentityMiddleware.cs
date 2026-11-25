using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authorization.Policy;

namespace Chantier.WebApi.Middlewares;

/// <summary>
/// Place entre l'authentification et le limiteur global, <b>avant</b> l'autorisation : identifie l'appelant (cookie ou jeton porteur) pour que le
/// limiteur choisisse son seau, sans attendre l'autorisation. Utilisateur reconnu : seau par utilisateur (R1-01, plusieurs telephones derriere
/// une meme adresse). Appelant anonyme ou jeton invalide : seau par adresse IP. Sans cette etape le limiteur devait suivre l'autorisation,
/// et les requetes refusees (401, 403) ne le traversaient jamais : un anonyme pouvait marteler l'API sans limite (D-7 de la QA).
/// <para>
/// Meme evaluation que l'intergiciel d'autorisation (politique par defaut : cookie et jeton porteur) ; les gestionnaires d'authentification
/// memorisent leur resultat pour la requete, le jeton n'est donc pas valide deux fois.
/// </para>
/// </summary>
public sealed class RateLimitIdentityMiddleware(RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context, IPolicyEvaluator evaluator, IAuthorizationPolicyProvider policies)
    {
        var policy = await policies.GetDefaultPolicyAsync();
        var result = await evaluator.AuthenticateAsync(policy, context);
        if (result.Succeeded && result.Principal is not null)
        {
            context.User = result.Principal;
        }

        await next(context);
    }
}
