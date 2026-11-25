using System.Net;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Sites;
using Chantier.Infrastructure.Persistence;
using Chantier.Infrastructure.SeedData.Demo;
using Chantier.IntegrationTests.Support;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.SitesTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>CT-3, CT-16, US-SOCLE-018 : donnees de demonstration « Ecole UV18 », relancables, jamais hors developpement. Une base par test : les comptes sont exacts.</summary>
[TestFixture]
public class DemoDataTests
{
    private readonly List<string> _databases = [];

    [OneTimeTearDown]
    public async Task DropDatabases()
    {
        foreach (var database in _databases)
        {
            await SqlServerFixture.DropDatabaseAsync(database);
        }
    }

    private async Task<ChantierWebApplicationFactory> StartAsync(bool demo = true, string environment = "Development", Action<Dictionary<string, string?>>? settings = null)
    {
        var connection = await SqlServerFixture.CreateDatabaseAsync("demo");
        _databases.Add(connection);

        var factory = new ChantierWebApplicationFactory { EnvironmentName = environment };
        factory.Settings["ConnectionStrings:ChantierDb"] = connection;
        if (demo)
        {
            factory.Settings[DemoDataSeeder.EnabledKey] = "true";
        }

        settings?.Invoke(factory.Settings);
        _ = factory.Server; // migration + amorcage + donnees de demonstration
        return factory;
    }

    private static string DemoPassword(ChantierWebApplicationFactory factory)
        => factory.Services.GetRequiredService<IConfiguration>()[DemoDataSeeder.PasswordKey]!;

    private static async Task<(int Sites, int Zones, int Members, int DemoUsers, int Users)> CountsAsync(ChantierWebApplicationFactory factory)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        return (
            await db.Sites.CountAsync(),
            await db.Zones.CountAsync(),
            await db.SiteMembers.CountAsync(),
            await db.Users.CountAsync(user => user.UserName!.EndsWith(".dev")),
            await db.Users.CountAsync());
    }

    private static async Task<ApiSession> SignInDemoAsync(ChantierWebApplicationFactory factory, string userName)
    {
        var account = DemoData.Accounts.Single(candidate => candidate.UserName == userName);
        return await factory.SignInAsync(new TestAccount(Guid.Empty, userName, DemoPassword(factory), account.FullName, account.Phone, account.Role));
    }

    private static async Task<List<string>> SiteCodesOfAsync(ApiSession session)
    {
        var response = await session.GetAsync($"{SiteBase}?includeArchived=true&pageSize=200");
        return (await response.JsonAsync()).GetProperty("items").Strings("code").Order().ToList();
    }

    [Test]
    public async Task Loading_creates_exactly_2_sites_7_accounts_26_and_3_zones_and_the_assignments_of_the_table()
    {
        using var factory = await StartAsync();

        var counts = await CountsAsync(factory);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var zonesBySite = await db.Zones.GroupBy(zone => zone.SiteId).Select(group => new { group.Key, Count = group.Count() }).ToListAsync();
        var sites = await db.Sites.ToDictionaryAsync(site => site.Code, site => site.Id);
        var memberships = await db.SiteMembers
            .Join(db.Users, member => member.UserId, user => user.Id, (member, user) => new { member.SiteId, user.UserName })
            .ToListAsync();

        Assert.Multiple(() =>
        {
            Assert.That(counts.Sites, Is.EqualTo(2));
            Assert.That(counts.DemoUsers, Is.EqualTo(7));
            Assert.That(counts.Users, Is.EqualTo(7), "Aucun autre compte.");
            Assert.That(counts.Zones, Is.EqualTo(29));
            Assert.That(zonesBySite.Single(group => group.Key == sites["CH-ECO-UV18"]).Count, Is.EqualTo(26));
            Assert.That(zonesBySite.Single(group => group.Key == sites["CH-LOG-OL40"]).Count, Is.EqualTo(3));
            Assert.That(counts.Members, Is.EqualTo(8));
            Assert.That(
                memberships.Where(member => member.SiteId == sites["CH-ECO-UV18"]).Select(member => member.UserName),
                Is.EquivalentTo(new[] { "direction.dev", "conducteur.dev", "achats.dev", "chef.dev", "equipe.dev" }));
            Assert.That(
                memberships.Where(member => member.SiteId == sites["CH-LOG-OL40"]).Select(member => member.UserName),
                Is.EquivalentTo(new[] { "direction.dev", "conducteur.dev", "achats.dev" }));
            Assert.That(memberships.Select(member => member.UserName), Does.Not.Contain("nonaffecte.dev"));
            Assert.That(memberships.Select(member => member.UserName), Does.Not.Contain("admin.dev"), "L'Admin voit tout par sa permission, sans affectation.");
        });
    }

    [Test]
    public async Task The_school_zones_follow_the_table_of_the_user_story()
    {
        using var factory = await StartAsync();
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var zones = await db.Zones.Join(db.Sites.Where(site => site.Code == "CH-ECO-UV18"), zone => zone.SiteId, site => site.Id, (zone, _) => zone).ToListAsync();

        Assert.Multiple(() =>
        {
            Assert.That(zones.Count(zone => zone.Elevation is null && zone.RoomType is null), Is.EqualTo(2), "Bloc 01 et Bloc 02 entiers.");
            Assert.That(zones.Count(zone => zone.Block == "Bloc 01" && zone.Elevation is not null && zone.RoomType is null), Is.EqualTo(5), "Cotes du bloc 01.");
            Assert.That(zones.Where(zone => zone.Block == "Bloc 01" && zone.RoomType is not null).Select(zone => zone.Elevation).Distinct(), Is.EquivalentTo(new decimal?[] { 0.00m, 3.40m }));
            Assert.That(zones.Count(zone => zone.Block == "Bloc 01" && zone.Elevation == 0.00m && zone.RoomType == RoomType.Classroom), Is.EqualTo(6));
            Assert.That(zones.Count(zone => zone.Block == "Bloc 01" && zone.Elevation == 3.40m && zone.RoomType == RoomType.Corridor), Is.EqualTo(1));
            Assert.That(zones.Select(zone => zone.Elevation).Where(elevation => elevation is not null), Does.Contain(-1.90m).And.Contain(10.20m));
            Assert.That(zones.Single(zone => zone.RoomLabel == "Façade cantine").Elevation, Is.Null, "Façade cantine : sans cote.");
            Assert.That(zones.Count(zone => zone.Block == "Bloc 02"), Is.EqualTo(6), "Bloc entier + cote ±0,00 + 4 locaux.");
            Assert.That(zones.Where(zone => zone.Block == "Bloc 02" && zone.RoomType is RoomType.Canteen or RoomType.Refectory or RoomType.Kitchen).Select(zone => zone.RoomType), Is.EquivalentTo(new RoomType?[] { RoomType.Canteen, RoomType.Refectory, RoomType.Kitchen }));
        });
    }

    [Test]
    public async Task Loading_twice_creates_no_duplicate()
    {
        using var factory = await StartAsync();
        var first = await CountsAsync(factory);

        await DatabaseInitializer.InitializeAsync(factory.Services);
        await DatabaseInitializer.InitializeAsync(factory.Services);
        var third = await CountsAsync(factory);

        Assert.That(third, Is.EqualTo(first), "CA-018.2 : trois chargements, mêmes totaux.");
    }

    [Test]
    public async Task A_second_host_on_the_same_database_adds_nothing()
    {
        using var first = await StartAsync();
        var before = await CountsAsync(first);
        var connection = first.Settings["ConnectionStrings:ChantierDb"]!;

        using var second = new ChantierWebApplicationFactory();
        second.Settings["ConnectionStrings:ChantierDb"] = connection;
        second.Settings[DemoDataSeeder.EnabledKey] = "true";
        _ = second.Server;

        Assert.That(await CountsAsync(second), Is.EqualTo(before));
    }

    [Test]
    public async Task Existing_data_is_never_modified_and_an_archived_demo_zone_is_not_created_again()
    {
        using var factory = await StartAsync();
        var chef = await SignInDemoAsync(factory, "chef.dev");
        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var users = scope.ServiceProvider.GetRequiredService<UserManager<AppUser>>();
            var user = await users.FindByNameAsync("chef.dev");
            user!.FullName = "Nom modifié à la main";
            await users.UpdateAsync(user);
            await users.ChangePasswordAsync(user, DemoPassword(factory), "Autre-Mot-De-Passe-9");

            var zone = await db.Zones.FirstAsync(candidate => candidate.Block == "Bloc 01" && candidate.RoomType == RoomType.Classroom);
            zone.Archive(SystemActorId, DateTimeOffset.UtcNow);
            await db.SaveChangesAsync();
        }

        var before = await CountsAsync(factory);
        await DatabaseInitializer.InitializeAsync(factory.Services);

        await using var verification = factory.Services.CreateAsyncScope();
        var manager = verification.ServiceProvider.GetRequiredService<UserManager<AppUser>>();
        var edited = await manager.FindByNameAsync("chef.dev");
        Assert.Multiple(async () =>
        {
            Assert.That(await CountsAsync(factory), Is.EqualTo(before));
            Assert.That(edited!.FullName, Is.EqualTo("Nom modifié à la main"));
            Assert.That(await manager.CheckPasswordAsync(edited, "Autre-Mot-De-Passe-9"), Is.True, "Un mot de passe changé n'est pas réinitialisé.");
            Assert.That(chef.Account.UserName, Is.EqualTo("chef.dev"));
        });
    }

    [Test]
    public async Task The_seven_accounts_have_the_roles_and_the_fictitious_phones_of_the_table()
    {
        using var factory = await StartAsync();
        await using var scope = factory.Services.CreateAsyncScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<AppUser>>();

        var actual = new List<(string UserName, string FullName, string Role, string? Phone, bool Active, bool MustChange)>();
        foreach (var account in DemoData.Accounts)
        {
            var user = await users.FindByNameAsync(account.UserName);
            actual.Add((account.UserName, user!.FullName, (await users.GetRolesAsync(user)).Single(), user.PhoneNumber, user.IsActive, user.MustChangePassword));
        }

        Assert.Multiple(() =>
        {
            Assert.That(actual.Select(account => (account.UserName, account.FullName, account.Role)), Is.EqualTo(new[]
            {
                ("admin.dev", "Farid L.", "Admin"),
                ("direction.dev", "Meriem S.", "Direction"),
                ("conducteur.dev", "Slimane H.", "ConducteurTravaux"),
                ("achats.dev", "Amel R.", "Achats"),
                ("chef.dev", "Mourad B.", "ChefChantier"),
                ("equipe.dev", "Toufik G.", "ChefEquipe"),
                ("nonaffecte.dev", "Nadia Z.", "ChefChantier"),
            }));
            Assert.That(actual.Select(account => account.Phone), Is.EqualTo(Enumerable.Range(11, 7).Select(number => $"0550 00 00 {number}")));
            Assert.That(actual.All(account => account.Active && !account.MustChange), Is.True);
        });
    }

    [Test]
    public async Task CA_018_4_each_demo_account_sees_what_the_table_says()
    {
        using var factory = await StartAsync();

        var chef = await SignInDemoAsync(factory, "chef.dev");
        var conductor = await SignInDemoAsync(factory, "conducteur.dev");
        var unassigned = await SignInDemoAsync(factory, "nonaffecte.dev");
        var crew = await SignInDemoAsync(factory, "equipe.dev");
        var direction = await SignInDemoAsync(factory, "direction.dev");
        var admin = await SignInDemoAsync(factory, "admin.dev");
        var purchasing = await SignInDemoAsync(factory, "achats.dev");

        var conductorSites = (await (await conductor.GetAsync($"{SiteBase}?pageSize=200")).JsonAsync()).GetProperty("items");
        var oliviers = conductorSites.EnumerateArray().Single(site => site.GetProperty("code").GetString() == "CH-LOG-OL40");
        var school = conductorSites.EnumerateArray().Single(site => site.GetProperty("code").GetString() == "CH-ECO-UV18");
        var schoolId = school.GetProperty("id").GetGuid();

        var chefOnOliviers = await chef.GetAsync($"{SiteBase}/{oliviers.GetProperty("id").GetGuid()}");
        var chefOnMissing = await chef.GetAsync($"{SiteBase}/{Guid.NewGuid()}");
        var crewSchool = await (await crew.GetAsync($"{SiteBase}/{schoolId}")).JsonAsync();
        var zones = await (await chef.GetAsync($"{SiteBase}/{schoolId}/zones?pageSize=200")).JsonAsync();
        var (pulled, _, _) = await crew.PullAllAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(await SiteCodesOfAsync(chef), Is.EqualTo(new[] { "CH-ECO-UV18" }), "(a) chef.dev voit 1 chantier.");
            Assert.That(await SiteCodesOfAsync(conductor), Is.EqualTo(new[] { "CH-ECO-UV18", "CH-LOG-OL40" }), "(b) conducteur.dev en voit 2.");
            Assert.That(await SiteCodesOfAsync(unassigned), Is.Empty, "(c) nonaffecte.dev n'en voit aucun.");
            Assert.That(chefOnOliviers.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "(d) CH-LOG-OL40 demandé par chef.dev : introuvable.");
            Assert.That(WithoutTraceId(await chefOnOliviers.JsonAsync()), Is.EqualTo(WithoutTraceId(await chefOnMissing.JsonAsync())), "(d) même réponse qu'un chantier inexistant.");
            Assert.That(school.GetProperty("contractualEndDate").GetString(), Is.EqualTo("2027-08-24"), "(e) fin contractuelle de l'École UV18 : 24/08/2027.");
            Assert.That(oliviers.GetProperty("contractualEndDate").GetString(), Is.EqualTo("2027-08-09"));
            Assert.That(crewSchool.TryGetProperty("contractAmount", out _), Is.False, "(f) equipe.dev ne voit pas le montant du marché.");
            Assert.That(pulled.Of("site").Single().GetProperty("data").TryGetProperty("contractAmount", out _), Is.False, "(f) ni dans la synchronisation.");
            Assert.That(school.GetProperty("contractAmount").GetDecimal(), Is.EqualTo(185_000_000.00m));
            Assert.That(oliviers.GetProperty("contractAmount").GetDecimal(), Is.EqualTo(96_400_000.00m));
            Assert.That(zones.GetProperty("items").GetArrayLength(), Is.EqualTo(26), "26 zones pour l'École UV18.");
            Assert.That((await SiteCodesOfAsync(direction)), Is.EqualTo(new[] { "CH-ECO-UV18", "CH-LOG-OL40" }));
            Assert.That(await SiteCodesOfAsync(purchasing), Is.EqualTo(new[] { "CH-ECO-UV18", "CH-LOG-OL40" }));
            Assert.That(await SiteCodesOfAsync(admin), Is.EqualTo(new[] { "CH-ECO-UV18", "CH-LOG-OL40" }), "Admin : tous les chantiers.");
        });
    }

    [Test]
    public async Task Demo_data_is_off_by_default_even_in_development()
    {
        using var factory = await StartAsync(demo: false);

        var counts = await CountsAsync(factory);

        Assert.That((counts.Sites, counts.Users), Is.EqualTo((0, 0)));
    }

    [Test]
    public async Task Demo_data_is_never_loaded_outside_development_even_when_requested()
    {
        using var factory = await StartAsync(demo: true, environment: "Production");

        var counts = await CountsAsync(factory);

        Assert.Multiple(() =>
        {
            Assert.That((counts.Sites, counts.Zones, counts.DemoUsers, counts.Users), Is.EqualTo((0, 0, 0, 0)), "Aucun compte .dev en production.");
            Assert.That(factory.Logs.AllText.Contains("Seed:Demo est ignoré", StringComparison.Ordinal), Is.True, "L'oubli est signalé dans le journal.");
        });
    }

    [Test]
    public async Task Loading_without_a_password_fails_clearly_and_creates_nothing()
    {
        var connection = await SqlServerFixture.CreateDatabaseAsync("demo");
        _databases.Add(connection);
        var factory = new ChantierWebApplicationFactory();
        factory.Settings["ConnectionStrings:ChantierDb"] = connection;
        factory.Settings[DemoDataSeeder.EnabledKey] = "true";
        factory.Settings[DemoDataSeeder.PasswordKey] = "";

        var failure = Assert.Throws<InvalidOperationException>(() => _ = factory.Server);

        Assert.That(failure!.Message, Does.Contain(DemoDataSeeder.PasswordKey));
        factory.Settings[DemoDataSeeder.EnabledKey] = "false";
        using var clean = new ChantierWebApplicationFactory();
        clean.Settings["ConnectionStrings:ChantierDb"] = connection;
        _ = clean.Server;
        Assert.That((await CountsAsync(clean)).Users, Is.Zero);
        factory.Dispose();
    }

    [Test]
    public async Task A_password_refused_by_the_policy_is_reported_without_echoing_it()
    {
        var connection = await SqlServerFixture.CreateDatabaseAsync("demo");
        _databases.Add(connection);
        using var factory = new ChantierWebApplicationFactory();
        factory.Settings["ConnectionStrings:ChantierDb"] = connection;
        factory.Settings[DemoDataSeeder.EnabledKey] = "true";
        factory.Settings[DemoDataSeeder.PasswordKey] = "abc";

        var failure = Assert.Throws<InvalidOperationException>(() => _ = factory.Server);

        Assert.Multiple(() =>
        {
            Assert.That(failure!.Message, Does.Contain("PasswordTooShort"));
            Assert.That(failure.Message, Does.Not.Contain("abc"));
        });
        await Task.CompletedTask;
    }

    [Test]
    public async Task Demo_loading_writes_no_account_name_nor_password_in_the_logs()
    {
        using var factory = await StartAsync();

        var everything = factory.Logs.AllText;

        Assert.Multiple(() =>
        {
            Assert.That(everything, Does.Contain("Données de démonstration"));
            Assert.That(everything, Does.Not.Contain(DemoPassword(factory)));
            foreach (var account in DemoData.Accounts)
            {
                Assert.That(everything, Does.Not.Contain(account.UserName), account.UserName);
                Assert.That(everything, Does.Not.Contain(account.Phone), account.UserName);
            }
        });
    }

    [Test]
    public void No_demo_password_is_written_in_the_base_configuration_nor_in_the_code()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "Chantier.sln")))
        {
            root = root.Parent;
        }

        Assert.That(root, Is.Not.Null);
        var baseSettings = File.ReadAllText(Path.Combine(root!.FullName, "WebApi", "Chantier.WebApi", "appsettings.json"));
        var seeder = File.ReadAllText(Path.Combine(root.FullName, "Core", "Chantier.Infrastructure", "SeedData", "Demo", "DemoDataSeeder.cs"));
        var data = File.ReadAllText(Path.Combine(root.FullName, "Core", "Chantier.Infrastructure", "SeedData", "Demo", "DemoData.cs"));

        Assert.Multiple(() =>
        {
            Assert.That(baseSettings, Does.Not.Contain("Seed"), "appsettings.json (utilisé partout) ne porte aucune donnée de démonstration.");
            Assert.That(seeder + data, Does.Not.Contain("Demo-Chantier"), "Le mot de passe de développement n'est pas dans le code.");
        });
    }
}
