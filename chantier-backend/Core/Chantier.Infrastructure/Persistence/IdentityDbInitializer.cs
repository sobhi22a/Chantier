using System.Security.Claims;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Chantier.Infrastructure.Persistence;

/// <summary>
/// Amorcage idempotent : les six roles, les permissions de <see cref="RolePermissionMatrix"/> (ajoutees si absentes,
/// jamais retirees), et le premier Admin depuis <c>Bootstrap:AdminUserName</c> / <c>Bootstrap:AdminPassword</c>
/// <b>seulement s'il n'existe aucun Admin</b>. Aucun mot de passe dans le depot (ADR 0005).
/// </summary>
public sealed class IdentityDbInitializer(
    RoleManager<AppRole> roleManager,
    UserManager<AppUser> userManager,
    IConfiguration configuration,
    ILogger<IdentityDbInitializer> logger)
{
    public const string BootstrapAdminUserName = "Bootstrap:AdminUserName";
    public const string BootstrapAdminPassword = "Bootstrap:AdminPassword";

    public async Task InitializeAsync()
    {
        foreach (var roleName in RoleNames.All)
        {
            var role = await roleManager.FindByNameAsync(roleName);
            if (role is null)
            {
                var created = await roleManager.CreateAsync(new AppRole(roleName));
                EnsureSucceeded(created, $"création du rôle {roleName}");
                role = await roleManager.FindByNameAsync(roleName)
                    ?? throw new InvalidOperationException($"Le rôle {roleName} est introuvable après sa création.");
            }

            var existing = (await roleManager.GetClaimsAsync(role))
                .Where(claim => claim.Type == Permissions.ClaimType)
                .Select(claim => claim.Value)
                .ToHashSet(StringComparer.Ordinal);

            foreach (var permission in RolePermissionMatrix.For(roleName).Where(permission => !existing.Contains(permission)))
            {
                var added = await roleManager.AddClaimAsync(role, new Claim(Permissions.ClaimType, permission));
                EnsureSucceeded(added, $"ajout de la permission {permission} au rôle {roleName}");
            }
        }

        await EnsureBootstrapAdminAsync();
    }

    private async Task EnsureBootstrapAdminAsync()
    {
        var userName = configuration[BootstrapAdminUserName];
        var password = configuration[BootstrapAdminPassword];
        if (string.IsNullOrWhiteSpace(userName) || string.IsNullOrWhiteSpace(password))
        {
            return;
        }

        if ((await userManager.GetUsersInRoleAsync(RoleNames.Admin)).Count > 0)
        {
            return;
        }

        var admin = AppUser.Create(userName.Trim(), "Administrateur", mustChangePassword: true);
        var created = await userManager.CreateAsync(admin, password);
        if (!created.Succeeded)
        {
            // Ni l'identifiant ni le mot de passe dans le message.
            throw new InvalidOperationException(
                "Création de l'administrateur initial refusée : vérifiez Bootstrap:AdminUserName et la politique de mot de passe (8 caractères dont un chiffre).");
        }

        EnsureSucceeded(await userManager.AddToRoleAsync(admin, RoleNames.Admin), "affectation du rôle Admin");
        logger.LogInformation("Administrateur initial créé {UserId}", admin.Id);
    }

    private static void EnsureSucceeded(IdentityResult result, string action)
    {
        if (!result.Succeeded)
        {
            throw new InvalidOperationException($"Amorçage des identités : échec de {action} ({string.Join(", ", result.Errors.Select(error => error.Code))}).");
        }
    }
}
