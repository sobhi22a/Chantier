using System.Security.Claims;

namespace Chantier.WebApi.Extensions;

public static class ClaimsPrincipalExtensions
{
    /// <summary>Identifiant de l'utilisateur lu dans le jeton (<c>sub</c>) ou le cookie, jamais dans la requete.</summary>
    public static Guid? GetUserId(this ClaimsPrincipal? user)
    {
        var value = user?.FindFirstValue(ClaimTypes.NameIdentifier) ?? user?.FindFirstValue("sub");
        return Guid.TryParse(value, out var id) ? id : null;
    }

    /// <summary>Role lu dans le cookie (<c>ClaimTypes.Role</c>) ou le jeton (<c>role</c>).</summary>
    public static string? GetRole(this ClaimsPrincipal? user)
        => user?.FindFirstValue(ClaimTypes.Role) ?? user?.FindFirstValue("role");
}
