using System.Globalization;
using System.Net;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Sites;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.SitesTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Sync;

/// <summary>CT-4, CT-8, CT-20 : pull par curseur serveur, pierres tombales, affectation retiree ou ajoutee, montant du marche.</summary>
[TestFixture]
public class SyncPullTests
{
    private ChantierWebApplicationFactory _factory = null!;
    private ApiSession _admin = null!;

    [OneTimeSetUp]
    public async Task SetUp()
    {
        _factory = new ChantierWebApplicationFactory();
        _admin = await _factory.SignInAsync(RoleNames.Admin);
    }

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    private async Task<(ApiSession Chef, SeededSite Site)> ChefWithSiteAsync(int zones = 0)
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(members: chef.Account.Id);
        for (var index = 1; index <= zones; index++)
        {
            await _factory.SeedZoneAsync(site.Id, $"Bloc {index:D2}");
        }

        return (chef, site);
    }

    [Test]
    public async Task First_pull_returns_only_the_assigned_site_with_its_zones_and_members()
    {
        var (chef, site) = await ChefWithSiteAsync(zones: 2);
        var other = await _factory.SeedSiteAsync();
        await _factory.SeedZoneAsync(other.Id);

        var (changes, deleted, cursor) = await chef.PullAllAsync();

        Assert.Multiple(() =>
        {
            Assert.That(changes.Of("site").Select(row => row.GetProperty("id").GetGuid()), Is.EqualTo(new[] { site.Id }));
            Assert.That(changes.Of("zone"), Has.Exactly(2).Items);
            Assert.That(changes.Of("member"), Has.Exactly(1).Items);
            Assert.That(changes.Select(row => row.GetProperty("siteId").GetGuid()), Is.All.EqualTo(site.Id), "Aucune ligne d'un chantier non affecté.");
            Assert.That(deleted, Is.Empty);
            Assert.That(ulong.TryParse(cursor, NumberStyles.None, CultureInfo.InvariantCulture, out var number) && number > 0, Is.True);
        });
    }

    [Test]
    public async Task Row_data_is_the_same_json_as_the_rest_resource_and_versions_are_decimal_strings()
    {
        var (chef, site) = await ChefWithSiteAsync(zones: 1);
        var rest = await (await chef.GetAsync($"{SiteBase}/{site.Id}")).JsonAsync();

        var (changes, _, _) = await chef.PullAllAsync();
        var row = changes.Of("site").Single();

        Assert.Multiple(() =>
        {
            Assert.That(row.GetProperty("data").GetProperty("code").GetString(), Is.EqualTo(rest.GetProperty("code").GetString()));
            Assert.That(row.GetProperty("data").GetProperty("version").GetString(), Is.EqualTo(rest.GetProperty("version").GetString()));
            Assert.That(row.GetProperty("version").GetString(), Is.EqualTo(rest.GetProperty("version").GetString()));
            Assert.That(row.GetProperty("data").GetProperty("contractualEndDate").GetString(), Is.EqualTo("2027-08-24"));
        });
    }

    [Test]
    public async Task Member_rows_carry_name_and_role_but_never_a_phone_number()
    {
        var (chef, _) = await ChefWithSiteAsync();

        var page = await chef.PullAsync();
        var member = page.GetProperty("changes").EnumerateArray().Of("member").Single().GetProperty("data");

        Assert.Multiple(() =>
        {
            Assert.That(member.GetProperty("fullName").GetString(), Is.EqualTo(chef.Account.FullName));
            Assert.That(member.GetProperty("role").GetString(), Is.EqualTo(RoleNames.ChefChantier));
            Assert.That(member.GetRawText(), Does.Not.Contain(chef.Account.Phone).And.Not.Contain(chef.Account.UserName));
            Assert.That(member.EnumerateObject().Select(p => p.Name), Is.EquivalentTo(new[] { "id", "siteId", "userId", "fullName", "role", "assignedAt" }));
        });
    }

    [Test]
    public async Task Pages_follow_limit_and_cursor_without_gap_or_duplicate()
    {
        var (chef, _) = await ChefWithSiteAsync(zones: 7); // 1 chantier + 1 affectation + 7 zones = 9 lignes

        var ids = new List<Guid>();
        var hasMoreFlags = new List<bool>();
        string? cursor = null;
        while (true)
        {
            var page = await chef.PullAsync(cursor, limit: 3);
            ids.AddRange(page.GetProperty("changes").EnumerateArray().Select(row => row.GetProperty("id").GetGuid()));
            hasMoreFlags.Add(page.GetProperty("hasMore").GetBoolean());
            cursor = page.GetProperty("cursor").GetString();
            if (!page.GetProperty("hasMore").GetBoolean())
            {
                break;
            }
        }

        Assert.Multiple(() =>
        {
            Assert.That(ids, Has.Count.EqualTo(9));
            Assert.That(ids, Is.Unique);
            Assert.That(hasMoreFlags, Is.EqualTo(new[] { true, true, false }));
        });
    }

    [Test]
    public async Task Pull_with_the_last_cursor_returns_only_what_changed_since()
    {
        var (chef, site) = await ChefWithSiteAsync(zones: 2);
        var (_, _, cursor) = await chef.PullAllAsync();

        var nothing = await chef.PullAsync(cursor);

        var created = await chef.PostAsync($"{SiteBase}/{site.Id}/zones", ZoneBody("Bloc 77"));
        var zoneId = (await created.JsonAsync()).GetProperty("id").GetGuid();
        var (changes, deleted, _) = await chef.PullAllAsync(cursor);

        Assert.Multiple(() =>
        {
            Assert.That(nothing.GetProperty("changes").GetArrayLength(), Is.Zero);
            Assert.That(nothing.GetProperty("hasMore").GetBoolean(), Is.False);
            Assert.That(changes.Select(row => row.GetProperty("id").GetGuid()), Is.EqualTo(new[] { zoneId }));
            Assert.That(deleted, Is.Empty);
        });
    }

    [Test]
    public async Task A_modified_zone_comes_back_with_a_higher_version()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var created = await (await chef.PostAsync($"{SiteBase}/{site.Id}/zones", ZoneBody("Bloc 05"))).JsonAsync();
        var (_, _, cursor) = await chef.PullAllAsync();

        var update = await chef.PutAsync($"{SiteBase}/{site.Id}/zones/{created.GetProperty("id").GetGuid()}", ZoneBody("Bloc 06", body => body["version"] = created.GetProperty("version").GetString()));
        Assert.That(update.StatusCode, Is.EqualTo(HttpStatusCode.OK));

        var (changes, _, _) = await chef.PullAllAsync(cursor);
        var row = changes.Single();

        Assert.Multiple(() =>
        {
            Assert.That(row.GetProperty("data").GetProperty("block").GetString(), Is.EqualTo("Bloc 06"));
            Assert.That(ulong.Parse(row.GetProperty("version").GetString()!), Is.GreaterThan(ulong.Parse(created.GetProperty("version").GetString()!)));
        });
    }

    [Test]
    public async Task Archiving_is_a_change_not_a_tombstone()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var zoneId = await _factory.SeedZoneAsync(site.Id, "Bloc 08");
        var (_, _, cursor) = await chef.PullAllAsync();

        await _admin.PostAsync($"{SiteBase}/{site.Id}/zones/{zoneId}/archive");
        var (changes, deleted, _) = await chef.PullAllAsync(cursor);

        Assert.Multiple(() =>
        {
            Assert.That(deleted, Is.Empty);
            Assert.That(changes.Single().GetProperty("data").GetProperty("archivedAt").ValueKind, Is.EqualTo(System.Text.Json.JsonValueKind.String));
        });
    }

    [Test]
    public async Task A_deleted_zone_becomes_a_tombstone()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var zoneId = await _factory.SeedZoneAsync(site.Id, "Bloc 09");
        var (_, _, cursor) = await chef.PullAllAsync();

        await _factory.DeleteZoneAsync(zoneId);
        var (changes, deleted, _) = await chef.PullAllAsync(cursor);

        Assert.Multiple(() =>
        {
            Assert.That(changes, Is.Empty);
            Assert.That(deleted, Has.Exactly(1).Items);
            Assert.That(deleted[0].GetProperty("entity").GetString(), Is.EqualTo("zone"));
            Assert.That(deleted[0].GetProperty("id").GetGuid(), Is.EqualTo(zoneId));
            Assert.That(deleted[0].GetProperty("siteId").GetGuid(), Is.EqualTo(site.Id));
        });
    }

    [Test]
    public async Task Removing_a_colleague_gives_a_member_tombstone()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var colleague = await _factory.SignInAsync(RoleNames.ChefEquipe);
        await _factory.AssignDirectlyAsync(site.Id, colleague.Account.Id);
        var (changes, _, cursor) = await chef.PullAllAsync();
        var colleagueRow = changes.Of("member").Single(row => row.GetProperty("data").GetProperty("userId").GetGuid() == colleague.Account.Id);

        await _admin.DeleteAsync($"{SiteBase}/{site.Id}/members/{colleague.Account.Id}");
        var (_, deleted, _) = await chef.PullAllAsync(cursor);

        Assert.Multiple(() =>
        {
            Assert.That(deleted, Has.Exactly(1).Items);
            Assert.That(deleted[0].GetProperty("entity").GetString(), Is.EqualTo("member"));
            Assert.That(deleted[0].GetProperty("id").GetGuid(), Is.EqualTo(colleagueRow.GetProperty("id").GetGuid()));
        });
    }

    [Test]
    public async Task Removed_assignment_cuts_access_at_once_and_the_next_pull_deletes_the_site()
    {
        var (chef, site) = await ChefWithSiteAsync(zones: 3);
        var (_, _, cursor) = await chef.PullAllAsync();

        var removal = await _admin.DeleteAsync($"{SiteBase}/{site.Id}/members/{chef.Account.Id}");
        var direct = await chef.GetAsync($"{SiteBase}/{site.Id}");
        var (changes, deleted, _) = await chef.PullAllAsync(cursor);

        Assert.Multiple(() =>
        {
            Assert.That(removal.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(direct.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "Accès coupé immédiatement.");
            Assert.That(changes, Is.Empty, "Plus aucune ligne de ce chantier.");
            Assert.That(deleted, Has.Exactly(1).Items);
            Assert.That(deleted[0].GetProperty("entity").GetString(), Is.EqualTo("site"));
            Assert.That(deleted[0].GetProperty("id").GetGuid(), Is.EqualTo(site.Id));
        });
    }

    [Test]
    public async Task A_removed_then_reassigned_user_gets_the_site_back_without_a_site_tombstone()
    {
        var (chef, site) = await ChefWithSiteAsync(zones: 2);
        var (_, _, cursor) = await chef.PullAllAsync();

        await _admin.DeleteAsync($"{SiteBase}/{site.Id}/members/{chef.Account.Id}");
        await _admin.PutAsync($"{SiteBase}/{site.Id}/members/{chef.Account.Id}");
        var (changes, deleted, _) = await chef.PullAllAsync(cursor);

        Assert.Multiple(() =>
        {
            Assert.That(deleted.Of("site"), Is.Empty, "Le chantier n'est pas supprimé : l'utilisateur est de nouveau affecté.");
            Assert.That(changes.Of("site"), Has.Exactly(1).Items);
            Assert.That(changes.Of("zone"), Has.Exactly(2).Items);
        });
    }

    [Test]
    public async Task A_new_assignment_on_an_old_site_sends_the_site_its_zones_and_its_members()
    {
        // Le chantier et ses zones existent depuis longtemps (versions basses) : sans « toucher », le nouvel affecte ne les recevrait jamais.
        var lead = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(members: lead.Account.Id);
        await _factory.SeedZoneAsync(site.Id, "Bloc 01");
        await _factory.SeedZoneAsync(site.Id, "Bloc 02");

        var newcomer = await _factory.SignInAsync(RoleNames.ChefEquipe);
        var (before, _, cursor) = await newcomer.PullAllAsync();

        // Des changements sans rapport font avancer les versions du serveur, bien au-dela de celles du chantier.
        await _factory.SeedSiteAsync();
        await _factory.SeedSiteAsync();

        var assigned = await _admin.PutAsync($"{SiteBase}/{site.Id}/members/{newcomer.Account.Id}");
        var (changes, _, _) = await newcomer.PullAllAsync(cursor);

        Assert.Multiple(() =>
        {
            Assert.That(assigned.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(before, Is.Empty);
            Assert.That(changes.Of("site").Select(row => row.GetProperty("id").GetGuid()), Is.EqualTo(new[] { site.Id }));
            Assert.That(changes.Of("zone"), Has.Exactly(2).Items);
            Assert.That(changes.Of("member"), Has.Exactly(2).Items, "Le référent et le nouvel affecté.");
        });
    }

    [Test]
    public async Task Touching_does_not_change_audit_fields_or_data()
    {
        var lead = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(members: lead.Account.Id);
        var zoneId = await _factory.SeedZoneAsync(site.Id, "Bloc 01");
        var before = await (await _admin.GetAsync($"{SiteBase}/{site.Id}/zones/{zoneId}")).JsonAsync();

        var newcomer = await _factory.SignInAsync(RoleNames.ChefEquipe);
        await _admin.PutAsync($"{SiteBase}/{site.Id}/members/{newcomer.Account.Id}");
        var after = await (await _admin.GetAsync($"{SiteBase}/{site.Id}/zones/{zoneId}")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(ulong.Parse(after.GetProperty("version").GetString()!), Is.GreaterThan(ulong.Parse(before.GetProperty("version").GetString()!)), "La version avance.");
            Assert.That(after.GetProperty("updatedAt").ValueKind, Is.EqualTo(before.GetProperty("updatedAt").ValueKind), "Pas de modification d'audit.");
            Assert.That(after.GetProperty("block").GetString(), Is.EqualTo(before.GetProperty("block").GetString()));
        });
    }

    [Test]
    public async Task Contract_amount_is_absent_from_synchronised_data_without_the_permission()
    {
        var site = await _factory.SeedSiteAsync(amount: 185_000_000.00m);
        var withoutRight = new[] { RoleNames.ChefChantier, RoleNames.ChefEquipe, RoleNames.Achats };
        var withRight = new[] { RoleNames.ConducteurTravaux, RoleNames.Direction };

        foreach (var role in withoutRight.Concat(withRight))
        {
            var session = await _factory.SignInAsync(role);
            await _factory.AssignDirectlyAsync(site.Id, session.Account.Id);
            var (changes, _, _) = await session.PullAllAsync();
            var data = changes.Of("site").Single().GetProperty("data");

            Assert.That(
                data.TryGetProperty("contractAmount", out _),
                Is.EqualTo(withRight.Contains(role)),
                $"contractAmount pour {role}");
        }
    }

    [Test]
    public async Task Site_filter_restricts_the_pull_to_that_site()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var first = await _factory.SeedSiteAsync(members: chef.Account.Id);
        var second = await _factory.SeedSiteAsync(members: chef.Account.Id);
        await _factory.SeedZoneAsync(first.Id);
        await _factory.SeedZoneAsync(second.Id);

        var (changes, _, _) = await chef.PullAllAsync(siteId: second.Id);

        Assert.That(changes.Select(row => row.GetProperty("siteId").GetGuid()), Is.All.EqualTo(second.Id));
        Assert.That(changes.Of("zone"), Has.Exactly(1).Items);
    }

    [Test]
    public async Task Site_filter_on_an_unassigned_or_unknown_site_gives_the_same_404()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var foreign = await _factory.SeedSiteAsync();

        var unassigned = await chef.PullRawAsync(siteId: foreign.Id);
        var unknown = await chef.PullRawAsync(siteId: Guid.NewGuid());

        Assert.Multiple(async () =>
        {
            Assert.That(unassigned.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(unknown.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(WithoutTraceId(await unassigned.JsonAsync()), Is.EqualTo(WithoutTraceId(await unknown.JsonAsync())));
        });
    }

    [TestCase("abc")]
    [TestCase("-5")]
    [TestCase("1.5")]
    [TestCase("99999999999999999999999")]
    public async Task An_unreadable_cursor_is_400_CURSEUR_INVALIDE(string since)
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);

        var response = await chef.PullRawAsync(since);
        var problem = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("CURSEUR_INVALIDE"));
            Assert.That(problem.GetProperty("errors").GetProperty("since")[0].GetString(), Does.Not.Contain(since), "Pas d'écho de la valeur reçue.");
        });
    }

    [TestCase(0)]
    [TestCase(501)]
    [TestCase(-1)]
    public async Task A_limit_out_of_range_is_400_VALIDATION(int limit)
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);

        var response = await chef.PullRawAsync(limit: limit);

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        Assert.That((await response.JsonAsync()).GetProperty("code").GetString(), Is.EqualTo("VALIDATION"));
    }

    [Test]
    public async Task Cursor_zero_and_a_missing_cursor_both_mean_first_synchronisation()
    {
        var (chef, _) = await ChefWithSiteAsync(zones: 1);

        var missing = await chef.PullAsync();
        var zero = await chef.PullAsync("0");

        Assert.That(zero.GetProperty("changes").GetArrayLength(), Is.EqualTo(missing.GetProperty("changes").GetArrayLength()).And.EqualTo(3));
    }

    [Test]
    public async Task Repeating_a_pull_with_the_same_cursor_gives_the_same_page()
    {
        var (chef, _) = await ChefWithSiteAsync(zones: 4);

        var first = await chef.PullAsync(null, limit: 3);
        var again = await chef.PullAsync(null, limit: 3);

        Assert.That(again.GetRawText(), Is.EqualTo(first.GetRawText()), "Reprise après coupure : même page, même curseur.");
    }

    [Test]
    public async Task Admin_without_a_site_filter_reads_every_site_even_unassigned()
    {
        var site = await _factory.SeedSiteAsync();

        var (changes, _, _) = await _admin.PullAllAsync();

        Assert.That(changes.Of("site").Select(row => row.GetProperty("id").GetGuid()), Does.Contain(site.Id));
    }

    [Test]
    public async Task Pull_requires_authentication()
    {
        var response = await _factory.CreateClient().GetAsync(ChangesUrl);

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
    }
}
