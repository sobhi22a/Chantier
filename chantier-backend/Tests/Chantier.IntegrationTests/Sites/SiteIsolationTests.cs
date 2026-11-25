using System.Net;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.SitesTestKit;

namespace Chantier.IntegrationTests.Sites;

/// <summary>
/// CT-3 : un utilisateur non affecte recoit un 404 INTROUVABLE strictement identique a celui d'un chantier inexistant, sur
/// /sites/{id} et tous ses sous-chemins ; il ne le voit ni dans la liste ni dans la recherche. Admin voit tout, Direction
/// seulement ses affectations. Reproduit les cas (a) a (d) de CA-018.4 avec deux chantiers et plusieurs roles.
/// </summary>
[TestFixture]
public class SiteIsolationTests
{
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public void SetUp() => _factory = new ChantierWebApplicationFactory();

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    /// <summary>Deux chantiers (A, B) ; le chef et la direction ne sont affectes qu'a A ; le conducteur aux deux ; le dernier a aucun.</summary>
    private sealed record World(
        string Marker, SeededSite A, SeededSite B, Guid ZoneOfB,
        ApiSession Admin, ApiSession Direction, ApiSession Conducteur, ApiSession Chef, ApiSession NotAssigned);

    private async Task<World> CreateWorldAsync()
    {
        var marker = Guid.NewGuid().ToString("N")[..8].ToUpperInvariant();
        var admin = await _factory.SignInAsync(RoleNames.Admin);
        var direction = await _factory.SignInAsync(RoleNames.Direction);
        var conducteur = await _factory.SignInAsync(RoleNames.ConducteurTravaux);
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var notAssigned = await _factory.SignInAsync(RoleNames.ChefChantier);

        var a = await _factory.SeedSiteAsync($"{marker}-A", name: $"Chantier A {marker}", members: [direction.Account.Id, conducteur.Account.Id, chef.Account.Id]);
        var b = await _factory.SeedSiteAsync($"{marker}-B", name: $"Chantier B {marker}", members: [conducteur.Account.Id]);
        var zoneOfB = await _factory.SeedZoneAsync(b.Id, "Bloc 01");
        await _factory.SeedZoneAsync(a.Id, "Bloc 01");
        return new World(marker, a, b, zoneOfB, admin, direction, conducteur, chef, notAssigned);
    }

    private static async Task<List<string>> ListedCodesAsync(ApiSession session, string marker, string extraQuery = "")
    {
        var response = await session.GetAsync($"{SiteBase}?q={marker}{extraQuery}");
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        return (await response.JsonAsync()).GetProperty("items").Strings("code").OrderBy(code => code).ToList();
    }

    [Test]
    public async Task Each_role_sees_only_its_own_sites_in_the_list()
    {
        var w = await CreateWorldAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(await ListedCodesAsync(w.Chef, w.Marker), Is.EqualTo(new[] { w.A.Code }), "(a) le chef de chantier voit 1 chantier");
            Assert.That(await ListedCodesAsync(w.Conducteur, w.Marker), Is.EqualTo(new[] { w.A.Code, w.B.Code }.OrderBy(c => c)), "(b) le conducteur en voit 2");
            Assert.That(await ListedCodesAsync(w.NotAssigned, w.Marker), Is.Empty, "(c) le non affecté n'en voit aucun");
            Assert.That(await ListedCodesAsync(w.Direction, w.Marker), Is.EqualTo(new[] { w.A.Code }), "H-02 : la Direction ne voit que ses affectations");
            Assert.That(await ListedCodesAsync(w.Admin, w.Marker), Is.EqualTo(new[] { w.A.Code, w.B.Code }.OrderBy(c => c)), "l'Admin voit tout");
        });
    }

    [Test]
    public async Task An_unassigned_site_never_appears_through_the_search_or_any_filter()
    {
        var w = await CreateWorldAsync();

        // Recherche par code exact, par nom, par morceau de nom, avec archives et filtre de type : jamais le chantier B pour le chef.
        foreach (var query in new[] { w.B.Code, $"Chantier B {w.Marker}", $"B {w.Marker}", w.Marker + "-B" })
        {
            var response = await w.Chef.GetAsync($"{SiteBase}?q={Uri.EscapeDataString(query)}&includeArchived=true&type=School&pageSize=200");
            var text = await response.Content.ReadAsStringAsync();
            var json = System.Text.Json.JsonDocument.Parse(text).RootElement;

            Assert.Multiple(() =>
            {
                Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
                Assert.That(json.GetProperty("items").Strings("code"), Does.Not.Contain(w.B.Code), query);
                Assert.That(text, Does.Not.Contain(w.B.Id.ToString()), query);
            });
        }

        var total = (await (await w.NotAssigned.GetAsync($"{SiteBase}?q={w.Marker}")).JsonAsync()).GetProperty("totalCount").GetInt32();
        Assert.That(total, Is.Zero, "Le total ne révèle rien non plus.");
    }

    [Test]
    public async Task Direct_access_to_an_unassigned_site_is_the_same_404_as_an_unknown_site()
    {
        var w = await CreateWorldAsync();
        var unknown = Guid.NewGuid();

        var notAssigned = await w.Chef.GetAsync($"{SiteBase}/{w.B.Id}");
        var inexistent = await w.Chef.GetAsync($"{SiteBase}/{unknown}");
        var notAssignedBody = await notAssigned.JsonAsync();
        var inexistentBody = await inexistent.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(notAssigned.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "(d) la demande directe répond « introuvable »");
            Assert.That(inexistent.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(notAssignedBody.GetProperty("code").GetString(), Is.EqualTo("INTROUVABLE"));
            Assert.That(WithoutTraceId(notAssignedBody), Is.EqualTo(WithoutTraceId(inexistentBody)), "Même message, même code, mêmes champs.");
            Assert.That(notAssigned.Content.Headers.ContentType, Is.EqualTo(inexistent.Content.Headers.ContentType));
            Assert.That(notAssigned.Headers.Select(h => h.Key).Order(), Is.EqualTo(inexistent.Headers.Select(h => h.Key).Order()), "Mêmes en-têtes.");
            Assert.That(notAssigned.Content.Headers.ContentLength, Is.EqualTo(inexistent.Content.Headers.ContentLength));
        });
    }

    [Test]
    public async Task Every_sub_path_of_an_unassigned_site_gives_the_same_404_as_an_unknown_site()
    {
        var w = await CreateWorldAsync();
        var unknownSite = Guid.NewGuid();
        var unknownZone = Guid.NewGuid();
        var validZone = new { block = "Bloc 09", elevation = 1.0m, roomType = "Classroom", roomNumber = 1 };

        // (verbe, gabarit) : l'utilisateur a la permission (conducteur), donc seul le perimetre decide du 404.
        var calls = new List<(string Name, Func<ApiSession, Guid, Task<HttpResponseMessage>> Send)>
        {
            ("GET site", (s, id) => s.GetAsync($"{SiteBase}/{id}")),
            ("GET zones", (s, id) => s.GetAsync($"{SiteBase}/{id}/zones")),
            ("GET zones?q", (s, id) => s.GetAsync($"{SiteBase}/{id}/zones?q=Bloc&includeArchived=true")),
            ("GET zone", (s, id) => s.GetAsync($"{SiteBase}/{id}/zones/{unknownZone}")),
            ("POST zone", (s, id) => s.PostAsync($"{SiteBase}/{id}/zones", validZone)),
            ("PUT zone", (s, id) => s.PutAsync($"{SiteBase}/{id}/zones/{unknownZone}", new { version = "1", block = "Bloc 01" })),
            ("POST zone archive", (s, id) => s.PostAsync($"{SiteBase}/{id}/zones/{unknownZone}/archive")),
            ("POST zone restore", (s, id) => s.PostAsync($"{SiteBase}/{id}/zones/{unknownZone}/restore")),
            ("GET members", (s, id) => s.GetAsync($"{SiteBase}/{id}/members")),
        };

        // Le chantier B n'est PAS affecte au chef de chantier ; les zones 'Zones.*' sont permises au chef (View/Create/Update), pas Delete.
        foreach (var (name, send) in calls.Where(call => !call.Name.Contains("archive") && !call.Name.Contains("restore")))
        {
            var realB = await send(w.Chef, w.B.Id);
            var fake = await send(w.Chef, unknownSite);

            Assert.Multiple(async () =>
            {
                Assert.That(realB.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), name);
                Assert.That(fake.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), name);
                Assert.That(WithoutTraceId(await realB.JsonAsync()), Is.EqualTo(WithoutTraceId(await fake.JsonAsync())), name);
            });
        }

        // Archiver/restaurer exige Zones.Delete : le conducteur (affecte a A et B) est donc teste sur un chantier ou il n'est pas affecte.
        var onlyA = await _factory.SignInAsync(RoleNames.ConducteurTravaux);
        await _factory.AssignDirectlyAsync(w.A.Id, onlyA.Account.Id);
        foreach (var (name, send) in calls.Where(call => call.Name.Contains("archive") || call.Name.Contains("restore")))
        {
            var realB = await send(onlyA, w.B.Id);
            var fake = await send(onlyA, unknownSite);

            Assert.Multiple(async () =>
            {
                Assert.That(realB.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), name);
                Assert.That(WithoutTraceId(await realB.JsonAsync()), Is.EqualTo(WithoutTraceId(await fake.JsonAsync())), name);
            });
        }
    }

    [Test]
    public async Task A_zone_is_only_readable_through_its_own_site()
    {
        var w = await CreateWorldAsync();

        // Le conducteur est affecte aux deux chantiers : la zone de B lue via A est introuvable (lecture par (chantier, id)).
        var viaWrongSite = await w.Conducteur.GetAsync($"{SiteBase}/{w.A.Id}/zones/{w.ZoneOfB}");
        var viaRightSite = await w.Conducteur.GetAsync($"{SiteBase}/{w.B.Id}/zones/{w.ZoneOfB}");

        Assert.Multiple(async () =>
        {
            Assert.That(viaWrongSite.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That((await viaWrongSite.JsonAsync()).GetProperty("code").GetString(), Is.EqualTo("INTROUVABLE"));
            Assert.That(viaRightSite.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });

        // Modifier ou archiver la zone de B via le chantier A est refuse, et la zone n'a pas change.
        var put = await w.Conducteur.PutAsync($"{SiteBase}/{w.A.Id}/zones/{w.ZoneOfB}", new { version = "1", block = "Piraté" });
        var archive = await w.Conducteur.PostAsync($"{SiteBase}/{w.A.Id}/zones/{w.ZoneOfB}/archive");
        var unchanged = await (await w.Conducteur.GetAsync($"{SiteBase}/{w.B.Id}/zones/{w.ZoneOfB}")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(put.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(archive.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(unchanged.GetProperty("block").GetString(), Is.EqualTo("Bloc 01"));
            Assert.That(unchanged.GetProperty("archivedAt").ValueKind, Is.EqualTo(System.Text.Json.JsonValueKind.Null));
        });
    }

    [Test]
    public async Task A_malformed_body_never_reveals_that_an_unassigned_site_exists()
    {
        var w = await CreateWorldAsync();

        // Corps invalide : pour un chantier affecte c'est un 400, pour un chantier non affecte ce doit etre le meme 404 que l'inexistant.
        var onAssigned = await w.Chef.PostAsync($"{SiteBase}/{w.A.Id}/zones", new { });
        var onUnassigned = await w.Chef.PostAsync($"{SiteBase}/{w.B.Id}/zones", new { });
        var onUnknown = await w.Chef.PostAsync($"{SiteBase}/{Guid.NewGuid()}/zones", new { });

        Assert.Multiple(async () =>
        {
            Assert.That(onAssigned.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(onUnassigned.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(WithoutTraceId(await onUnassigned.JsonAsync()), Is.EqualTo(WithoutTraceId(await onUnknown.JsonAsync())));
        });
    }

    [Test]
    public async Task Role_without_the_permission_gets_403_whatever_the_site()
    {
        var w = await CreateWorldAsync();
        var equipe = await _factory.SignInAsync(RoleNames.ChefEquipe);
        await _factory.AssignDirectlyAsync(w.A.Id, equipe.Account.Id);

        // Le role decide de l'action : un chef d'equipe ne cree pas de zone, sur son chantier comme ailleurs (pas de fuite d'existence).
        var onOwn = await equipe.PostAsync($"{SiteBase}/{w.A.Id}/zones", new { block = "Bloc 05" });
        var onOther = await equipe.PostAsync($"{SiteBase}/{w.B.Id}/zones", new { block = "Bloc 05" });
        var onUnknown = await equipe.PostAsync($"{SiteBase}/{Guid.NewGuid()}/zones", new { block = "Bloc 05" });

        Assert.Multiple(async () =>
        {
            Assert.That(onOwn.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(onOther.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(onUnknown.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That((await onOwn.JsonAsync()).GetProperty("code").GetString(), Is.EqualTo("INTERDIT"));
            Assert.That((await (await equipe.GetAsync($"{SiteBase}/{w.A.Id}/zones")).JsonAsync()).GetProperty("items").GetArrayLength(), Is.EqualTo(1), "Rien n'a été enregistré.");
        });
    }

    [Test]
    public async Task Removing_an_assignment_cuts_the_access_immediately()
    {
        var w = await CreateWorldAsync();
        Assert.That((await w.Chef.GetAsync($"{SiteBase}/{w.A.Id}")).StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var removed = await w.Admin.DeleteAsync($"{SiteBase}/{w.A.Id}/members/{w.Chef.Account.Id}");

        // Aucun delai : meme jeton, meme seconde.
        var afterGet = await w.Chef.GetAsync($"{SiteBase}/{w.A.Id}");
        var afterZones = await w.Chef.GetAsync($"{SiteBase}/{w.A.Id}/zones");
        var afterList = await ListedCodesAsync(w.Chef, w.Marker);

        Assert.Multiple(() =>
        {
            Assert.That(removed.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(afterGet.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(afterZones.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(afterList, Is.Empty);
        });
    }

    [Test]
    public async Task Adding_an_assignment_gives_access_immediately_even_to_an_old_site()
    {
        var w = await CreateWorldAsync();
        Assert.That((await w.NotAssigned.GetAsync($"{SiteBase}/{w.B.Id}")).StatusCode, Is.EqualTo(HttpStatusCode.NotFound));

        var assigned = await w.Admin.PutAsync($"{SiteBase}/{w.B.Id}/members/{w.NotAssigned.Account.Id}");

        Assert.Multiple(async () =>
        {
            Assert.That(assigned.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That((await w.NotAssigned.GetAsync($"{SiteBase}/{w.B.Id}")).StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(await ListedCodesAsync(w.NotAssigned, w.Marker), Is.EqualTo(new[] { w.B.Code }));
        });
    }

    [Test]
    public async Task Admin_can_open_any_site_without_being_assigned()
    {
        var w = await CreateWorldAsync();

        var response = await w.Admin.GetAsync($"{SiteBase}/{w.B.Id}");

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
    }

    [Test]
    public async Task Unauthenticated_calls_are_401_before_any_site_lookup()
    {
        var w = await CreateWorldAsync();
        using var client = _factory.CreateClient();

        var real = await client.GetAsync($"{SiteBase}/{w.A.Id}");
        var unknown = await client.GetAsync($"{SiteBase}/{Guid.NewGuid()}");

        Assert.Multiple(() =>
        {
            Assert.That(real.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(unknown.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task A_deactivated_account_loses_the_access_to_its_sites()
    {
        using var factory = new ChantierWebApplicationFactory();
        var chef = await factory.SignInAsync(RoleNames.ChefChantier);
        var site = await factory.SeedSiteAsync(members: chef.Account.Id);
        Assert.That((await chef.GetAsync($"{SiteBase}/{site.Id}")).StatusCode, Is.EqualTo(HttpStatusCode.OK));

        await factory.SetActiveAsync(chef.Account.Id, false);
        factory.Time.Advance(TimeSpan.FromSeconds(61));
        var refused = await chef.GetAsync($"{SiteBase}/{site.Id}");

        Assert.That(refused.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
    }
}
