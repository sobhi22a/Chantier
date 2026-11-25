using Chantier.Core.Identity;
using Chantier.WebApi.Extensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Options;

namespace Chantier.WebApi.Authorization;

/// <summary>Exige la permission <c>Ressource.Action</c> (par exemple <c>Zones.Create</c>) : le role decide de l'action, l'affectation du perimetre.</summary>
public sealed class PermissionRequirement(string resource, string action) : IAuthorizationRequirement
{
    public const string PolicyPrefix = "Permission.";

    public string Permission { get; } = Core.Identity.Permissions.Of(resource, action);

    public static string PolicyName(string resource, string action) => PolicyPrefix + Core.Identity.Permissions.Of(resource, action);
}

/// <summary><c>[HasPermission("Zones", "Create")]</c> : politique creee a la demande par <see cref="PermissionPolicyProvider"/>.</summary>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
public sealed class HasPermissionAttribute : AuthorizeAttribute
{
    public HasPermissionAttribute(string resource, string action)
    {
        Resource = resource;
        Action = action;
        Policy = PermissionRequirement.PolicyName(resource, action);
    }

    public string Resource { get; }

    public string Action { get; }
}

/// <summary>Cree les politiques <c>Permission.Ressource.Action</c> a la demande, sur les deux schemas (cookie et jeton).</summary>
public sealed class PermissionPolicyProvider(IOptions<AuthorizationOptions> options) : IAuthorizationPolicyProvider
{
    private readonly DefaultAuthorizationPolicyProvider _fallback = new(options);

    public Task<AuthorizationPolicy> GetDefaultPolicyAsync() => _fallback.GetDefaultPolicyAsync();

    public Task<AuthorizationPolicy?> GetFallbackPolicyAsync() => _fallback.GetFallbackPolicyAsync();

    public Task<AuthorizationPolicy?> GetPolicyAsync(string policyName)
    {
        if (policyName.StartsWith(PermissionRequirement.PolicyPrefix, StringComparison.Ordinal))
        {
            var parts = policyName[PermissionRequirement.PolicyPrefix.Length..].Split('.', 2);
            if (parts.Length == 2)
            {
                var policy = new AuthorizationPolicyBuilder(AuthenticationSchemes.All)
                    .RequireAuthenticatedUser()
                    .AddRequirements(new PermissionRequirement(parts[0], parts[1]))
                    .Build();
                return Task.FromResult<AuthorizationPolicy?>(policy);
            }
        }

        return _fallback.GetPolicyAsync(policyName);
    }
}

/// <summary>Satisfait l'exigence si le role de l'utilisateur porte la permission (cache de 5 minutes, ADR 0005).</summary>
public sealed class PermissionAuthorizationHandler(IPermissionService permissions) : AuthorizationHandler<PermissionRequirement>
{
    protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
    {
        if (context.User.Identity is not { IsAuthenticated: true } || context.User.GetRole() is not { } role)
        {
            return;
        }

        if ((await permissions.GetForRoleAsync(role)).Contains(requirement.Permission))
        {
            context.Succeed(requirement);
        }
    }
}

public static class AuthenticationSchemes
{
    /// <summary>Cookie (web) et jeton porteur (mobile) : toute l'API accepte les deux.</summary>
    public static readonly string[] All =
    [
        Microsoft.AspNetCore.Identity.IdentityConstants.ApplicationScheme,
        Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme,
    ];
}
