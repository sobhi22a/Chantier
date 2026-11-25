using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.SeedData.Demo;

/// <summary>
/// Donnees de demonstration « Ecole UV18 » (US-SOCLE-018) : 2 chantiers, 7 comptes, 29 zones, les affectations du tableau.
/// <b>Developpement seulement</b> : actif si <c>Seed:Demo = true</c> <b>et</b> environnement Development (<see cref="IsEnabled"/>).
/// <b>Relancable</b> : ne cree que ce qui manque (compte, chantier, zone, affectation), ne modifie ni ne supprime jamais l'existant
/// (un mot de passe change reste change). Le mot de passe des comptes vient de <c>Seed:DemoPassword</c> (configuration locale) ;
/// il n'est ni dans ce code, ni journalise. Les ecritures sont faites hors requete : auteur = <c>SystemActor</c> (« amorcage »).
/// </summary>
public sealed class DemoDataSeeder(
    ApplicationDbContext db,
    UserManager<AppUser> users,
    IOptions<ZoneOptions> zoneOptions,
    IConfiguration configuration,
    ILogger<DemoDataSeeder> logger)
{
    public const string EnabledKey = "Seed:Demo";
    public const string PasswordKey = "Seed:DemoPassword";

    /// <summary>Deux conditions, jamais une seule : le reglage ET l'environnement de developpement.</summary>
    public static bool IsEnabled(IConfiguration configuration, IHostEnvironment environment)
        => environment.IsDevelopment() && configuration.GetValue<bool>(EnabledKey);

    public async Task SeedAsync(CancellationToken cancellationToken = default)
    {
        var password = configuration[PasswordKey];
        if (string.IsNullOrWhiteSpace(password))
        {
            throw new InvalidOperationException(
                $"{PasswordKey} est absente : renseignez le mot de passe de développement des comptes de démonstration (appsettings.Development.json ou user-secrets).");
        }

        var created = 0;
        var accountIds = new Dictionary<string, Guid>(StringComparer.Ordinal);
        foreach (var account in DemoData.Accounts)
        {
            var (id, isNew) = await EnsureAccountAsync(account, password);
            accountIds[account.UserName] = id;
            created += isNew ? 1 : 0;
        }

        var sitesCreated = 0;
        var zonesCreated = 0;
        var membersCreated = 0;
        var siteIds = new Dictionary<string, Guid>(StringComparer.Ordinal);
        foreach (var demoSite in DemoData.Sites)
        {
            var (siteId, isNew) = await EnsureSiteAsync(demoSite, cancellationToken);
            siteIds[demoSite.Code] = siteId;
            sitesCreated += isNew ? 1 : 0;
            zonesCreated += await EnsureZonesAsync(siteId, demoSite.Zones, cancellationToken);
        }

        foreach (var account in DemoData.Accounts)
        {
            foreach (var siteCode in account.SiteCodes)
            {
                membersCreated += await EnsureMemberAsync(siteIds[siteCode], accountIds[account.UserName], cancellationToken);
            }
        }

        // Comptes seulement par nombre : jamais d'identifiant ni de mot de passe dans les journaux.
        logger.LogInformation(
            "Données de démonstration : {Accounts} comptes, {Sites} chantiers, {Zones} zones, {Members} affectations ajoutés (le reste existait déjà)",
            created, sitesCreated, zonesCreated, membersCreated);
    }

    private async Task<(Guid Id, bool IsNew)> EnsureAccountAsync(DemoData.DemoAccount account, string password)
    {
        if (await users.FindByNameAsync(account.UserName) is { } existing)
        {
            return (existing.Id, false);
        }

        // Mot de passe de demonstration : pas de changement obligatoire (il bloquerait tout autre appel et la demo hors ligne).
        var user = AppUser.Create(account.UserName, account.FullName, phoneNumber: account.Phone, mustChangePassword: false);
        var result = await users.CreateAsync(user, password);
        if (!result.Succeeded)
        {
            // Codes seulement (ex. PasswordTooShort) : ni l'identifiant ni le mot de passe.
            throw new InvalidOperationException(
                $"Création d'un compte de démonstration refusée ({string.Join(", ", result.Errors.Select(error => error.Code))}) : vérifiez {PasswordKey} (8 caractères dont un chiffre).");
        }

        var role = await users.AddToRoleAsync(user, account.Role);
        if (!role.Succeeded)
        {
            throw new InvalidOperationException($"Affectation du rôle {account.Role} refusée ({string.Join(", ", role.Errors.Select(error => error.Code))}).");
        }

        return (user.Id, true);
    }

    private async Task<(Guid Id, bool IsNew)> EnsureSiteAsync(DemoData.DemoSite demoSite, CancellationToken cancellationToken)
    {
        var existing = await db.Sites.Where(site => site.Code == demoSite.Code).Select(site => (Guid?)site.Id).FirstOrDefaultAsync(cancellationToken);
        if (existing is { } id)
        {
            return (id, false);
        }

        var site = Site.Create(demoSite.Code, demoSite.Input);
        db.Sites.Add(site);
        await db.SaveChangesAsync(cancellationToken);
        return (site.Id, true);
    }

    private async Task<int> EnsureZonesAsync(Guid siteId, IReadOnlyList<ZoneInput> zones, CancellationToken cancellationToken)
    {
        // Les zones archivees comptent aussi : une zone de demonstration archivee a la main n'est pas recreee en double.
        var known = (await db.Zones.Where(zone => zone.SiteId == siteId)
                .Select(zone => new { zone.Block, zone.Elevation, zone.RoomType, zone.RoomNumber, zone.RoomLabel })
                .ToListAsync(cancellationToken))
            .Select(zone => new ZoneInput(zone.Block, zone.Elevation, zone.RoomType, zone.RoomNumber, zone.RoomLabel))
            .ToHashSet();

        var added = 0;
        foreach (var input in zones.Where(zone => !known.Contains(zone)))
        {
            db.Zones.Add(Zone.Create(siteId, new CreateZoneDto(null, null, input), zoneOptions.Value));
            added++;
        }

        await db.SaveChangesAsync(cancellationToken);
        return added;
    }

    private async Task<int> EnsureMemberAsync(Guid siteId, Guid userId, CancellationToken cancellationToken)
    {
        if (await db.SiteMembers.AnyAsync(member => member.SiteId == siteId && member.UserId == userId, cancellationToken))
        {
            return 0;
        }

        db.SiteMembers.Add(SiteMember.Create(siteId, userId));
        await db.SaveChangesAsync(cancellationToken);
        return 1;
    }
}
