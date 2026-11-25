using System.Security.Claims;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Identity;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Support;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>B2 : migration sur base vide, relecture de la migration, amorcage idempotent (roles, permissions, referentiel, premier Admin).</summary>
[TestFixture]
public class SeedAndMigrationTests
{
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public void SetUp()
    {
        _factory = new ChantierWebApplicationFactory();
        _ = _factory.Server; // demarre l'hote : migration + amorcage
    }

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    [Test]
    public async Task Migration_is_applied_at_startup_on_an_empty_database()
    {
        await using var scope = _factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        Assert.Multiple(async () =>
        {
            Assert.That(await db.Database.GetPendingMigrationsAsync(), Is.Empty);
            Assert.That(await db.Database.GetAppliedMigrationsAsync(), Has.Some.EndsWith("_InitialCreate"));
        });
    }

    [Test]
    public void The_migration_up_method_never_drops_anything()
    {
        // Relecture automatisee : une migration qui supprime des tables ou colonnes exige une decision humaine (ADR 0003).
        foreach (var path in Directory.EnumerateFiles(MigrationsDirectory(), "*.cs").Where(p => !p.EndsWith(".Designer.cs", StringComparison.Ordinal) && !p.EndsWith("Snapshot.cs", StringComparison.Ordinal)))
        {
            var source = File.ReadAllText(path);
            var up = source[source.IndexOf("void Up(", StringComparison.Ordinal)..source.IndexOf("void Down(", StringComparison.Ordinal)];
            Assert.Multiple(() =>
            {
                Assert.That(up, Does.Not.Contain("DropTable"), Path.GetFileName(path));
                Assert.That(up, Does.Not.Contain("DropColumn"), Path.GetFileName(path));
                Assert.That(up, Does.Not.Contain("DropIndex"), Path.GetFileName(path));
                Assert.That(up, Does.Not.Contain("DeleteData"), Path.GetFileName(path));
            });
        }
    }

    [Test]
    public async Task The_six_roles_exist_with_exactly_the_permissions_of_the_matrix()
    {
        await using var scope = _factory.Services.CreateAsyncScope();
        var roles = scope.ServiceProvider.GetRequiredService<RoleManager<AppRole>>();

        foreach (var name in RoleNames.All)
        {
            var role = await roles.FindByNameAsync(name);
            Assert.That(role, Is.Not.Null, name);
            var claims = (await roles.GetClaimsAsync(role!)).Where(c => c.Type == Permissions.ClaimType).Select(c => c.Value).ToList();
            Assert.That(claims, Is.EquivalentTo(RolePermissionMatrix.For(name)), name);
        }
    }

    [Test]
    public void Matrix_follows_the_rights_table_of_the_adr()
    {
        Assert.Multiple(() =>
        {
            Assert.That(RolePermissionMatrix.For(RoleNames.Admin), Does.Contain(Permissions.AllSitesView));
            Assert.That(RolePermissionMatrix.For(RoleNames.Direction), Does.Not.Contain(Permissions.AllSitesView), "H-02 : la Direction ne voit que ses affectations.");
            foreach (var role in new[] { RoleNames.Direction, RoleNames.ConducteurTravaux, RoleNames.Achats, RoleNames.ChefChantier, RoleNames.ChefEquipe })
            {
                Assert.That(RolePermissionMatrix.For(role), Does.Not.Contain(Permissions.SitesCreate), role);
                Assert.That(RolePermissionMatrix.For(role), Does.Not.Contain(Permissions.SitesUpdate), role);
                Assert.That(RolePermissionMatrix.For(role), Does.Not.Contain(Permissions.SiteMembersUpdate), role);
                Assert.That(RolePermissionMatrix.For(role), Does.Contain(Permissions.SitesView), role);
            }

            Assert.That(RolePermissionMatrix.For(RoleNames.Direction).Where(p => p.EndsWith(".Create") || p.EndsWith(".Update") || p.EndsWith(".Delete")), Is.Empty, "CA-003.4 : Direction en lecture seule.");
        });
    }

    [Test]
    public void Contract_amount_is_reserved_to_admin_direction_and_conducteur()
    {
        var holders = RoleNames.All.Where(role => RolePermissionMatrix.For(role).Contains(Permissions.ContractAmountView)).ToList();

        Assert.That(holders, Is.EquivalentTo(new[] { RoleNames.Admin, RoleNames.Direction, RoleNames.ConducteurTravaux }));
    }

    [Test]
    public void Zones_create_is_for_admin_conducteur_and_chef_chantier_only()
    {
        var holders = RoleNames.All.Where(role => RolePermissionMatrix.For(role).Contains(Permissions.ZonesCreate)).ToList();
        var archivers = RoleNames.All.Where(role => RolePermissionMatrix.For(role).Contains(Permissions.ZonesDelete)).ToList();

        Assert.Multiple(() =>
        {
            Assert.That(holders, Is.EquivalentTo(new[] { RoleNames.Admin, RoleNames.ConducteurTravaux, RoleNames.ChefChantier }));
            Assert.That(archivers, Is.EquivalentTo(new[] { RoleNames.Admin, RoleNames.ConducteurTravaux }));
        });
    }

    [Test]
    public async Task Seeding_twice_changes_nothing_and_keeps_manual_additions()
    {
        await using var scope = _factory.Services.CreateAsyncScope();
        var roles = scope.ServiceProvider.GetRequiredService<RoleManager<AppRole>>();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var role = (await roles.FindByNameAsync(RoleNames.Achats))!;
        await roles.AddClaimAsync(role, new Claim(Permissions.ClaimType, "Reports.View"));

        var wilayasBefore = await db.Wilayas.CountAsync();
        var communesBefore = await db.Communes.CountAsync();
        var claimsBefore = await db.RoleClaims.CountAsync();

        await scope.ServiceProvider.GetRequiredService<IdentityDbInitializer>().InitializeAsync();
        await scope.ServiceProvider.GetRequiredService<ReferenceDataSeeder>().SeedAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(await db.Wilayas.CountAsync(), Is.EqualTo(wilayasBefore));
            Assert.That(await db.Communes.CountAsync(), Is.EqualTo(communesBefore));
            Assert.That(await db.RoleClaims.CountAsync(), Is.EqualTo(claimsBefore), "Aucun doublon, aucun retrait.");
            Assert.That((await roles.GetClaimsAsync(role)).Any(c => c.Value == "Reports.View"), Is.True, "Un ajout manuel n'est jamais retiré.");
        });

        await roles.RemoveClaimAsync(role, new Claim(Permissions.ClaimType, "Reports.View"));
    }

    [Test]
    public async Task Reference_data_is_loaded_from_the_json_files()
    {
        await using var scope = _factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var blida = await db.Wilayas.SingleAsync(w => w.Code == "09");
        Assert.Multiple(async () =>
        {
            Assert.That(await db.Wilayas.CountAsync(), Is.EqualTo(58));
            Assert.That(blida.NameFr, Is.EqualTo("Blida"));
            Assert.That(blida.NameAr, Is.EqualTo("البليدة"));
            Assert.That(await db.Communes.AnyAsync(c => c.WilayaCode == "09" && c.NameFr == "Boufarik"), Is.True);
        });
    }

    [Test]
    public async Task Reference_lists_are_data_files_not_code()
    {
        // Ajouter une ligne au fichier suffit : le demarrage l'ajoute sans toucher a l'existant.
        var directory = Path.Combine(Path.GetTempPath(), "chantier-ref-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(directory);
        try
        {
            File.WriteAllText(Path.Combine(directory, "wilayas.json"), """[ { "code": "09", "nameFr": "Blida (modifié)", "nameAr": "x" }, { "code": "59", "nameFr": "Nouvelle", "nameAr": "جديدة" } ]""");
            File.WriteAllText(Path.Combine(directory, "communes.json"), """[ { "wilayaCode": "59", "nameFr": "Centre", "nameAr": "وسط" } ]""");

            await using var scope = _factory.Services.CreateAsyncScope();
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            await scope.ServiceProvider.GetRequiredService<ReferenceDataSeeder>().SeedAsync(directory);

            Assert.Multiple(async () =>
            {
                Assert.That(await db.Wilayas.AnyAsync(w => w.Code == "59"), Is.True);
                Assert.That((await db.Wilayas.SingleAsync(w => w.Code == "09")).NameFr, Is.EqualTo("Blida"), "L'existant n'est pas modifié.");
                Assert.That(await db.Communes.AnyAsync(c => c.WilayaCode == "59"), Is.True);
            });

            db.Communes.RemoveRange(db.Communes.Where(c => c.WilayaCode == "59"));
            db.Wilayas.RemoveRange(db.Wilayas.Where(w => w.Code == "59"));
            await db.SaveChangesAsync();
        }
        finally
        {
            Directory.Delete(directory, recursive: true);
        }
    }

    [Test]
    public async Task Bootstrap_admin_is_created_only_when_no_admin_exists_and_must_change_its_password()
    {
        // Base vierge dediee : le test ne depend d'aucun autre.
        var connection = await SqlServerFixture.CreateDatabaseAsync("boot");
        try
        {
            var firstName = "boot" + Guid.NewGuid().ToString("N")[..8];
            using (var first = new ChantierWebApplicationFactory())
            {
                first.Settings["ConnectionStrings:ChantierDb"] = connection;
                first.Settings["Bootstrap:AdminUserName"] = firstName;
                first.Settings["Bootstrap:AdminPassword"] = "Initial2026x";
                _ = first.Server;
            }

            using (var second = new ChantierWebApplicationFactory())
            {
                second.Settings["ConnectionStrings:ChantierDb"] = connection;
                second.Settings["Bootstrap:AdminUserName"] = "autre" + Guid.NewGuid().ToString("N")[..8];
                second.Settings["Bootstrap:AdminPassword"] = "Initial2026x";
                _ = second.Server;

                await using var scope = second.Services.CreateAsyncScope();
                var users = scope.ServiceProvider.GetRequiredService<UserManager<AppUser>>();
                var admins = await users.GetUsersInRoleAsync(RoleNames.Admin);

                Assert.That(admins, Has.Count.EqualTo(1), "Le deuxième démarrage ne crée pas d'Admin supplémentaire.");
                Assert.Multiple(async () =>
                {
                    Assert.That(admins[0].UserName, Is.EqualTo(firstName));
                    Assert.That(admins[0].MustChangePassword, Is.True);
                    Assert.That(admins[0].IsActive, Is.True);
                    Assert.That(await users.CheckPasswordAsync(admins[0], "Initial2026x"), Is.True);
                });
            }
        }
        finally
        {
            await SqlServerFixture.DropDatabaseAsync(connection);
        }
    }

    [Test]
    public void Weak_bootstrap_password_stops_the_startup_without_leaking_it()
    {
        // Verifie sur une base vierge : la politique de mot de passe s'applique au premier Admin.
        var connection = SqlServerFixture.CreateDatabaseAsync("bootweak").GetAwaiter().GetResult();
        try
        {
            using var factory = new ChantierWebApplicationFactory();
            factory.Settings["ConnectionStrings:ChantierDb"] = connection;
            factory.Settings["Bootstrap:AdminUserName"] = "adminfaible";
            factory.Settings["Bootstrap:AdminPassword"] = "court";

            var exception = Assert.Throws<InvalidOperationException>(() => _ = factory.Server);

            Assert.Multiple(() =>
            {
                Assert.That(exception!.Message, Does.Not.Contain("court"));
                Assert.That(exception.Message, Does.Not.Contain("adminfaible"));
            });
        }
        finally
        {
            SqlServerFixture.DropDatabaseAsync(connection).GetAwaiter().GetResult();
        }
    }

    private static string MigrationsDirectory()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null)
        {
            var candidate = Path.Combine(directory.FullName, "Core", "Chantier.Infrastructure", "Persistence", "Migrations");
            if (Directory.Exists(candidate))
            {
                return candidate;
            }

            directory = directory.Parent;
        }

        throw new DirectoryNotFoundException("Dossier des migrations introuvable.");
    }
}
