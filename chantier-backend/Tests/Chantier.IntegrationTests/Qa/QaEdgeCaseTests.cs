using System.Diagnostics;
using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Sites;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.SitesTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Qa;

/// <summary>
/// Q1 : cas limites du socle (donnees extremes, texte arabe long, caracteres speciaux, horloge fausse, grande liste, concurrence).
/// Chaque test cree ses propres donnees (chantier et comptes uniques) : aucun ne depend d'un autre.
/// </summary>
[TestFixture]
public class QaEdgeCaseTests
{
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public void CreateFactory() => _factory = new ChantierWebApplicationFactory();

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    private static Task<HttpResponseMessage> RawAsync(ApiSession session, HttpMethod method, string url, string json) => session.SendRawAsync(method, url, json);

    private async Task<(ApiSession Admin, ApiSession Chef, SeededSite Site)> ArrangeAsync()
    {
        var admin = await _factory.SignInAsync(RoleNames.Admin);
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(members: chef.Account.Id);
        return (admin, chef, site);
    }

    private static string Arabic(int length) => new string('\u0639', length); // lettre arabe : une unite UTF-16 par caractere

    // --- Montants et dates extremes -----------------------------------------------------------------

    [Test]
    public async Task The_largest_accepted_contract_amount_is_stored_without_loss()
    {
        var admin = await _factory.SignInAsync(RoleNames.Admin);
        var body = SiteBody(overrides: b => b["contractAmount"] = 999_999_999_999_999.99m);

        var response = await admin.PostAsync(SiteBase, body);
        var json = await response.JsonAsync();
        var reread = await (await admin.GetAsync($"{SiteBase}/{json.GetProperty("id").GetGuid()}")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(reread.GetProperty("contractAmount").GetDecimal(), Is.EqualTo(999_999_999_999_999.99m));
        });
    }

    [TestCase("1000000000000000.00")]
    [TestCase("1e16")]
    [TestCase("79228162514264337593543950335")]
    [TestCase("1e40")]
    [TestCase("-0.01")]
    public async Task An_absurd_contract_amount_is_a_400_never_a_500(string amount)
    {
        var admin = await _factory.SignInAsync(RoleNames.Admin);
        var code = "T-" + Guid.NewGuid().ToString("N")[..10].ToUpperInvariant();
        var json = $$"""{"code":"{{code}}","name":"Ecole","type":"School","wilaya":"Blida","commune":"Boufarik","owner":"MO fictif","contractAmount":{{amount}}}""";

        var response = await RawAsync(admin, HttpMethod.Post, SiteBase, json);

        Assert.That((int)response.StatusCode, Is.EqualTo(400), await response.Content.ReadAsStringAsync());
    }

    [TestCase(int.MaxValue)]
    [TestCase(36501)]
    [TestCase(1_000_000)]
    public async Task An_enormous_delay_is_refused_instead_of_breaking_the_end_date_computation(int delay)
    {
        var admin = await _factory.SignInAsync(RoleNames.Admin);

        var response = await admin.PostAsync(SiteBase, SiteBody(overrides: b => { b["delayDays"] = delay; b["odsDate"] = "2100-12-31"; }));

        Assert.That((int)response.StatusCode, Is.EqualTo(400), await response.Content.ReadAsStringAsync());
    }

    [Test]
    public async Task The_latest_ods_with_the_longest_delay_still_gives_a_computable_end_date()
    {
        var admin = await _factory.SignInAsync(RoleNames.Admin);

        var response = await admin.PostAsync(SiteBase, SiteBody(overrides: b => { b["delayDays"] = 36500; b["odsDate"] = "2100-12-31"; }));
        var json = await response.JsonAsync();
        var list = await admin.GetAsync(SiteBase + "?pageSize=5");

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(json.GetProperty("contractualEndDate").GetString(), Is.EqualTo("2200-12-07"));
            Assert.That(list.StatusCode, Is.EqualTo(HttpStatusCode.OK), "La liste ne doit pas casser a cause d'une date extreme.");
        });
    }

    // --- Texte arabe long, caracteres speciaux, valeurs nulles --------------------------------------

    [Test]
    public async Task Arabic_text_at_the_column_limits_round_trips_unaltered_on_the_site_and_the_zone()
    {
        var (admin, _, _) = await ArrangeAsync();
        var name = Arabic(200);
        var created = await (await admin.PostAsync(SiteBase, SiteBody(overrides: b => { b["name"] = name; b["nameAr"] = name; b["owner"] = Arabic(200); }))).JsonAsync();
        var siteId = created.GetProperty("id").GetGuid();

        var zone = await admin.PostAsync($"{SiteBase}/{siteId}/zones", new { block = Arabic(50), roomType = "Other", roomLabel = Arabic(100) });
        var zoneJson = await zone.JsonAsync();
        var reread = await (await admin.GetAsync($"{SiteBase}/{siteId}")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(reread.GetProperty("name").GetString(), Is.EqualTo(name));
            Assert.That(reread.GetProperty("nameAr").GetString(), Is.EqualTo(name));
            Assert.That(zone.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(zoneJson.GetProperty("block").GetString(), Is.EqualTo(Arabic(50)));
            Assert.That(zoneJson.GetProperty("roomLabel").GetString(), Is.EqualTo(Arabic(100)));
        });
    }

    [Test]
    public async Task One_character_over_the_limit_is_a_400_on_the_rest_zone_endpoint()
    {
        var (admin, _, site) = await ArrangeAsync();

        var block = await admin.PostAsync($"{SiteBase}/{site.Id}/zones", new { block = Arabic(51) });
        var label = await admin.PostAsync($"{SiteBase}/{site.Id}/zones", new { block = "Bloc 01", roomType = "Other", roomLabel = Arabic(101) });

        Assert.Multiple(() =>
        {
            Assert.That((int)block.StatusCode, Is.EqualTo(400));
            Assert.That((int)label.StatusCode, Is.EqualTo(400));
        });
    }

    [Test]
    public async Task A_block_longer_than_50_characters_pushed_offline_is_rejected_and_the_rest_of_the_batch_goes_through()
    {
        var (_, chef, site) = await ArrangeAsync();

        var results = await chef.PushAsync(
            ZoneOperation(Guid.NewGuid(), site.Id, Arabic(51)),
            ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 02"),
            ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 03", body => { body["roomType"] = "Other"; body["roomLabel"] = Arabic(101); }));

        Assert.Multiple(() =>
        {
            Assert.That(results[0].Status(), Is.EqualTo("rejected"));
            Assert.That(results[0].Code(), Is.EqualTo("VALIDATION"));
            Assert.That(results[1].Status(), Is.EqualTo("applied"));
            Assert.That(results[2].Status(), Is.EqualTo("rejected"));
        });
    }

    [Test]
    public async Task Special_characters_are_data_not_code_in_a_block_and_in_a_site_name()
    {
        var (admin, _, site) = await ArrangeAsync();
        const string Block = "Bloc <script>alert(1)</script> ' \" ; DROP TABLE Zones; -- % _ [ ] \\ \U0001F3D7";

        var zone = await admin.PostAsync($"{SiteBase}/{site.Id}/zones", new { block = Block.Length > 50 ? Block[..50] : Block });
        var zoneJson = await zone.JsonAsync();
        var search = await admin.GetAsync($"{SiteBase}?q=" + Uri.EscapeDataString("'; DROP TABLE Sites;--"));
        var items = (await (await admin.GetAsync($"{SiteBase}/{site.Id}/zones")).JsonAsync()).GetProperty("items").GetArrayLength();

        Assert.Multiple(() =>
        {
            Assert.That(zone.StatusCode, Is.EqualTo(HttpStatusCode.Created), zoneJson.ToString());
            Assert.That(zoneJson.GetProperty("block").GetString(), Is.EqualTo(Block.Length > 50 ? Block[..50].Trim() : Block));
            Assert.That(search.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(items, Is.EqualTo(1));
        });
    }

    [Test]
    public async Task A_lone_surrogate_or_a_nul_character_in_a_block_is_refused_or_stored_but_never_a_500()
    {
        var (_, chef, site) = await ArrangeAsync();

        var surrogate = await RawAsync(chef, HttpMethod.Post, $"{SiteBase}/{site.Id}/zones", "{\"block\":\"Bloc \\ud800\"}");
        var nul = await RawAsync(chef, HttpMethod.Post, $"{SiteBase}/{site.Id}/zones", "{\"block\":\"Bloc\\u0000 07\"}");

        Assert.Multiple(() =>
        {
            Assert.That((int)surrogate.StatusCode, Is.LessThan(500), "surrogate isole");
            Assert.That((int)nul.StatusCode, Is.LessThan(500), "caractere NUL");
        });
    }

    [Test]
    public async Task Null_and_missing_optional_values_are_accepted_on_a_zone_and_on_a_site()
    {
        var (admin, _, site) = await ArrangeAsync();

        var zone = await admin.PostAsync($"{SiteBase}/{site.Id}/zones", new Dictionary<string, object?>
        {
            ["block"] = "Bloc 09",
            ["elevation"] = null,
            ["roomType"] = null,
            ["roomNumber"] = null,
            ["roomLabel"] = null,
            ["clientId"] = null,
            ["clientCreatedAt"] = null,
        });
        var created = await admin.PostAsync(SiteBase, SiteBody(overrides: b =>
        {
            b["nameAr"] = null; b["latitude"] = null; b["longitude"] = null; b["contractNumber"] = null; b["contractAmount"] = null; b["delayDays"] = null; b["odsDate"] = null;
        }));
        var json = await created.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(zone.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(created.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(json.GetProperty("contractualEndDate").ValueKind, Is.EqualTo(JsonValueKind.Null));
        });
    }

    [Test]
    public async Task Zone_positions_differing_only_by_case_or_surrounding_spaces_are_the_same_position()
    {
        var (_, chef, site) = await ArrangeAsync();
        await chef.PostAsync($"{SiteBase}/{site.Id}/zones", new { block = "Bloc 01", elevation = 3.40m, roomType = "Classroom", roomNumber = 1 });

        var upper = await chef.PostAsync($"{SiteBase}/{site.Id}/zones", new { block = "BLOC 01", elevation = 3.40m, roomType = "Classroom", roomNumber = 1 });
        var spaces = await chef.PostAsync($"{SiteBase}/{site.Id}/zones", new { block = "  Bloc 01  ", elevation = 3.40m, roomType = "Classroom", roomNumber = 1 });

        Assert.Multiple(async () =>
        {
            Assert.That((int)upper.StatusCode, Is.EqualTo(422), await upper.Content.ReadAsStringAsync());
            Assert.That((int)spaces.StatusCode, Is.EqualTo(422), await spaces.Content.ReadAsStringAsync());
        });
    }

    // --- Horloge du telephone fausse ----------------------------------------------------------------

    [TestCase("1970-01-01T00:00:00Z")]
    [TestCase("2099-12-31T23:59:59Z")]
    [TestCase("0001-01-01T00:00:00Z")]
    [TestCase("9999-12-31T23:59:59Z")]
    [TestCase("2026-11-24T06:58:00+13:00")]
    public async Task A_wrong_phone_clock_is_kept_apart_and_never_changes_the_server_audit_or_breaks_the_pull(string phoneTime)
    {
        var (_, chef, site) = await ArrangeAsync();
        var before = DateTimeOffset.UtcNow.AddMinutes(-1);

        var result = (await chef.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 01", body => body["clientCreatedAt"] = phoneTime)))[0];
        var pulled = await chef.PullAllAsync(siteId: site.Id);

        var zone = result.GetProperty("resource");
        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("applied"), result.ToString());
            Assert.That(zone.GetProperty("createdAt").GetDateTimeOffset(), Is.GreaterThan(before).And.LessThan(DateTimeOffset.UtcNow.AddMinutes(1)), "Heure du serveur.");
            Assert.That(pulled.Changes.Of("zone").Count(), Is.EqualTo(1));
        });
    }

    // --- Grande liste (5 000 zones) -----------------------------------------------------------------

    [Test]
    public async Task A_site_with_5000_zones_is_listed_and_pulled_completely_without_duplicate_or_slowness()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(members: chef.Account.Id);
        await SeedManyZonesAsync(site.Id, 5000);

        var listWatch = Stopwatch.StartNew();
        var ids = new List<Guid>();
        string? cursor = null;
        var pages = 0;
        do
        {
            var url = $"{SiteBase}/{site.Id}/zones?pageSize=200" + (cursor is null ? string.Empty : "&cursor=" + Uri.EscapeDataString(cursor));
            var page = await (await chef.GetAsync(url)).JsonAsync();
            ids.AddRange(page.GetProperty("items").EnumerateArray().Select(item => item.GetProperty("id").GetGuid()));
            cursor = page.TryGetProperty("nextCursor", out var next) && next.ValueKind == JsonValueKind.String ? next.GetString() : null;
            pages++;
        }
        while (cursor is not null && pages < 100);
        listWatch.Stop();

        var pullWatch = Stopwatch.StartNew();
        var pulled = await chef.PullAllAsync(siteId: site.Id);
        pullWatch.Stop();
        TestContext.Out.WriteLine($"5000 zones : liste {pages} pages en {listWatch.ElapsedMilliseconds} ms ; pull {pulled.Changes.Count} lignes en {pullWatch.ElapsedMilliseconds} ms");

        Assert.Multiple(() =>
        {
            Assert.That(ids, Has.Count.EqualTo(5000));
            Assert.That(ids, Is.Unique);
            Assert.That(pages, Is.EqualTo(25));
            Assert.That(pulled.Changes.Of("zone").Count(), Is.EqualTo(5000));
            Assert.That(pulled.Changes.Of("zone").Select(change => change.GetProperty("id").GetGuid()), Is.Unique);
            Assert.That(listWatch.Elapsed, Is.LessThan(TimeSpan.FromSeconds(30)), "liste complete");
            Assert.That(pullWatch.Elapsed, Is.LessThan(TimeSpan.FromSeconds(30)), "pull complet");
        });
    }

    private async Task SeedManyZonesAsync(Guid siteId, int count)
    {
        await using var scope = _factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        db.ChangeTracker.AutoDetectChangesEnabled = false;
        for (var index = 0; index < count; index++)
        {
            var block = $"Bloc {index / 500:D2}";
            var elevation = ((index / 50) % 10) * 3.40m - 1.90m;
            db.Zones.Add(TestDb.NewZone(siteId, TestDb.ZoneInput(block, elevation, RoomType.Classroom, index % 50 + 1)));
        }

        await db.SaveChangesAsync();
    }

    // --- Concurrence -------------------------------------------------------------------------------

    [Test]
    public async Task Two_updates_of_a_zone_on_the_same_version_let_exactly_one_win_and_the_other_gets_409()
    {
        var (admin, chef, site) = await ArrangeAsync();
        await _factory.AssignDirectlyAsync(site.Id, admin.Account.Id);
        var zone = await (await chef.PostAsync($"{SiteBase}/{site.Id}/zones", new { block = "Bloc 01" })).JsonAsync();
        var zoneUrl = $"{SiteBase}/{site.Id}/zones/{zone.GetProperty("id").GetGuid()}";
        var version = zone.GetProperty("version").GetString();

        var attempts = await Task.WhenAll(
            Enumerable.Range(0, 6).Select(index => Task.Run(() => admin.PutAsync(zoneUrl, new { block = $"Bloc {index + 10}", version }))));

        var statuses = attempts.Select(response => (int)response.StatusCode).ToList();
        Assert.Multiple(() =>
        {
            Assert.That(statuses.Count(status => status == 200), Is.EqualTo(1), string.Join(",", statuses));
            Assert.That(statuses.Count(status => status == 409), Is.EqualTo(5), string.Join(",", statuses));
        });
    }

    [Test]
    public async Task Parallel_pushes_of_the_same_client_id_create_one_zone_and_the_others_are_duplicates()
    {
        var (_, chef, site) = await ArrangeAsync();
        var operation = ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 05");

        var batches = await Task.WhenAll(Enumerable.Range(0, 8).Select(_ => Task.Run(() => chef.PushAsync(operation))));

        var statuses = batches.Select(batch => batch[0].Status()).ToList();
        var ids = batches.Select(batch => batch[0].GetProperty("resource").GetProperty("id").GetGuid()).Distinct().ToList();
        Assert.Multiple(() =>
        {
            Assert.That(statuses.Count(status => status == "applied"), Is.EqualTo(1), string.Join(",", statuses));
            Assert.That(statuses.Count(status => status == "duplicate"), Is.EqualTo(7), string.Join(",", statuses));
            Assert.That(ids, Has.Count.EqualTo(1));
        });
    }

    [Test]
    public async Task Parallel_pushes_of_the_same_position_with_different_client_ids_end_with_one_zone_and_no_error()
    {
        var (_, chef, site) = await ArrangeAsync();
        var second = await _factory.SignInAsync(RoleNames.ChefChantier);
        await _factory.AssignDirectlyAsync(site.Id, second.Account.Id);

        var batches = await Task.WhenAll(Enumerable.Range(0, 8).Select(index => Task.Run(() =>
            (index % 2 == 0 ? chef : second).PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 06", body => { body["elevation"] = 3.40m; body["roomType"] = "Classroom"; body["roomNumber"] = 1; })))));

        var statuses = batches.Select(batch => batch[0].Status()).ToList();
        var ids = batches.Select(batch => batch[0].GetProperty("resource").GetProperty("id").GetGuid()).Distinct().ToList();
        Assert.Multiple(() =>
        {
            Assert.That(statuses.Count(status => status == "applied"), Is.EqualTo(1), string.Join(",", statuses));
            Assert.That(statuses.Where(status => status != "applied"), Has.All.EqualTo("duplicate"));
            Assert.That(ids, Has.Count.EqualTo(1), "Toutes les saisies pointent vers la zone retenue.");
        });
    }

    // --- Isolation par chantier (ChefEquipe, Achats, Direction : lecture seule) ---------------------

    [TestCase(RoleNames.ChefEquipe)]
    [TestCase(RoleNames.Achats)]
    [TestCase(RoleNames.Direction)]
    public async Task A_read_only_role_never_creates_a_zone_neither_by_rest_nor_by_push_and_nothing_is_stored(string role)
    {
        var user = await _factory.SignInAsync(role);
        var site = await _factory.SeedSiteAsync(members: user.Account.Id);

        var rest = await user.PostAsync($"{SiteBase}/{site.Id}/zones", new { block = "Bloc 01" });
        var pushed = await user.PostAsync(PushUrl, new { operations = new[] { ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 02") } });
        var admin = await _factory.SignInAsync(RoleNames.Admin);
        var zones = await (await admin.GetAsync($"{SiteBase}/{site.Id}/zones?includeArchived=true")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That((int)rest.StatusCode, Is.EqualTo(403));
            Assert.That(zones.GetProperty("items").GetArrayLength(), Is.Zero);
            Assert.That(pushed.StatusCode, Is.AnyOf(HttpStatusCode.OK, HttpStatusCode.Forbidden));
        });
    }

    [Test]
    public async Task A_user_cannot_push_a_zone_on_a_site_of_another_user_and_cannot_read_it_back_through_the_pull()
    {
        var (_, chef, site) = await ArrangeAsync();
        var outsider = await _factory.SignInAsync(RoleNames.ChefChantier);

        var result = (await outsider.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 66")))[0];
        var unknown = (await outsider.PushAsync(ZoneOperation(Guid.NewGuid(), Guid.NewGuid(), "Bloc 66")))[0];
        var visible = await chef.PullAllAsync(siteId: site.Id);
        var outsiderPull = await outsider.PullAllAsync();

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("rejected"));
            Assert.That(result.Code(), Is.EqualTo("INTROUVABLE"));
            Assert.That(unknown.Code(), Is.EqualTo(result.Code()), "Meme motif qu'un chantier inexistant.");
            Assert.That(visible.Changes.Of("zone"), Is.Empty);
            Assert.That(outsiderPull.Changes, Is.Empty);
            Assert.That(outsiderPull.Deleted, Is.Empty);
        });
    }
}
