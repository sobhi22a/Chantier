using System.Security.Claims;
using Chantier.Core.Abstractions;
using Chantier.WebApi.Extensions;

namespace Chantier.WebApi.Services;

/// <summary>Utilisateur de la requete HTTP en cours, lu dans le jeton ou le cookie (jamais dans le corps de la requete).</summary>
public sealed class HttpContextCurrentUser(IHttpContextAccessor accessor) : ICurrentUser
{
    private ClaimsPrincipal? Principal => accessor.HttpContext?.User;

    public Guid? Id => Principal.GetUserId();

    public string? Role => Principal.GetRole();

    public bool IsAuthenticated => Principal?.Identity?.IsAuthenticated == true;
}
