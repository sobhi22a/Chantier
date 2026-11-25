using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.SitesTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Sync;

/// <summary>CT-9, CT-21 : push par lot, un resultat par operation, idempotence, fusion, droits, chantier archive, limites.</summary>
[TestFixture]
public class SyncPushTests
{
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public void SetUp() => _factory = new ChantierWebApplicationFactory();

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    private async Task<(ApiSession Chef, SeededSite Site)> ChefWithSiteAsync(bool archived = false)
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(archived: archived, members: chef.Account.Id);
        return (chef, site);
    }

    private static async Task<int> CountZonesAsync(ApiSession session, Guid siteId)
        => (await (await session.GetAsync($"{SiteBase}/{siteId}/zones?includeArchived=true")).JsonAsync()).GetProperty("items").GetArrayLength();

    [Test]
    public async Task An_empty_batch_is_200_with_no_result()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);

        var results = await chef.PushAsync();

        Assert.That(results.GetArrayLength(), Is.Zero);
    }

    [Test]
    public async Task A_zone_is_created_and_returned_with_the_clientCreatedAt_kept_apart_from_the_server_time()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var clientId = Guid.NewGuid();
        var phoneTime = new DateTimeOffset(2026, 11, 24, 6, 58, 0, TimeSpan.Zero);

        var results = await chef.PushAsync(ZoneOperation(clientId, site.Id, "Bloc 01", body =>
        {
            body["clientCreatedAt"] = phoneTime;
            body["elevation"] = 3.40m;
            body["roomType"] = "Classroom";
            body["roomNumber"] = 7;
        }));

        var result = results[0];
        var zone = result.GetProperty("resource");
        Assert.Multiple(() =>
        {
            Assert.That(result.GetProperty("clientId").GetGuid(), Is.EqualTo(clientId));
            Assert.That(result.Status(), Is.EqualTo("applied"));
            Assert.That(zone.GetProperty("block").GetString(), Is.EqualTo("Bloc 01"));
            Assert.That(zone.GetProperty("elevation").GetDecimal(), Is.EqualTo(3.40m));
            Assert.That(zone.GetProperty("roomType").GetString(), Is.EqualTo("Classroom"));
            Assert.That(zone.GetProperty("roomNumber").GetInt32(), Is.EqualTo(7));
            Assert.That(zone.GetProperty("clientId").GetGuid(), Is.EqualTo(clientId));
            Assert.That(zone.GetProperty("clientCreatedAt").GetDateTimeOffset(), Is.EqualTo(phoneTime), "« Saisi le » du téléphone conservé.");
            Assert.That(zone.GetProperty("createdAt").GetDateTimeOffset(), Is.Not.EqualTo(phoneTime), "L'audit vient de l'horloge du serveur.");
            Assert.That(zone.GetProperty("createdByName").GetString(), Is.EqualTo(chef.Account.FullName));
            Assert.That(result.TryGetProperty("code", out _), Is.False);
        });
    }

    [Test]
    public async Task Sending_the_same_operation_again_is_a_duplicate_without_a_second_zone()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var operation = ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 03");

        var first = (await chef.PushAsync(operation))[0];
        var again = (await chef.PushAsync(operation))[0];

        Assert.Multiple(async () =>
        {
            Assert.That(first.Status(), Is.EqualTo("applied"));
            Assert.That(again.Status(), Is.EqualTo("duplicate"));
            Assert.That(again.GetProperty("resource").GetProperty("id").GetGuid(), Is.EqualTo(first.GetProperty("resource").GetProperty("id").GetGuid()));
            Assert.That(again.TryGetProperty("merged", out _), Is.False, "Un simple renvoi n'est pas une fusion.");
            Assert.That(await CountZonesAsync(chef, site.Id), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task The_same_clientId_twice_in_one_batch_creates_one_zone()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var operation = ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 04");

        var results = await chef.PushAsync(operation, operation);

        Assert.Multiple(async () =>
        {
            Assert.That(results[0].Status(), Is.EqualTo("applied"));
            Assert.That(results[1].Status(), Is.EqualTo("duplicate"));
            Assert.That(await CountZonesAsync(chef, site.Id), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task A_replay_after_the_site_was_archived_still_returns_the_same_zone()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var operation = ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 05");
        var first = (await chef.PushAsync(operation))[0];
        var admin = await _factory.SignInAsync(RoleNames.Admin);
        await admin.PostAsync($"{SiteBase}/{site.Id}/archive");

        var again = (await chef.PushAsync(operation))[0];

        Assert.Multiple(() =>
        {
            Assert.That(again.Status(), Is.EqualTo("duplicate"));
            Assert.That(again.GetProperty("resource").GetProperty("id").GetGuid(), Is.EqualTo(first.GetProperty("resource").GetProperty("id").GetGuid()));
        });
    }

    [Test]
    public async Task Two_phones_creating_the_same_zone_end_with_one_zone_and_the_second_is_merged_without_error()
    {
        var (first, site) = await ChefWithSiteAsync();
        var second = await _factory.SignInAsync(RoleNames.ChefChantier);
        await _factory.AssignDirectlyAsync(site.Id, second.Account.Id);
        Action<Dictionary<string, object?>> classroom = body =>
        {
            body["elevation"] = 3.40m;
            body["roomType"] = "Classroom";
            body["roomNumber"] = 2;
        };

        var created = (await first.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 01", classroom)))[0];
        var merged = (await second.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 01", classroom)))[0];
        var replay = (await second.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 01", classroom)))[0];

        Assert.Multiple(async () =>
        {
            Assert.That(created.Status(), Is.EqualTo("applied"));
            Assert.That(merged.Status(), Is.EqualTo("duplicate"));
            Assert.That(merged.GetProperty("merged").GetBoolean(), Is.True);
            Assert.That(merged.GetProperty("resource").GetProperty("id").GetGuid(), Is.EqualTo(created.GetProperty("resource").GetProperty("id").GetGuid()), "La zone retenue est celle du premier.");
            Assert.That(merged.Code(), Is.Null, "Aucune erreur affichée.");
            Assert.That(replay.Status(), Is.EqualTo("duplicate"));
            Assert.That(await CountZonesAsync(first, site.Id), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task Merging_ignores_an_archived_identical_zone_and_creates_a_new_one()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var admin = await _factory.SignInAsync(RoleNames.Admin);
        var archivedId = await _factory.SeedZoneAsync(site.Id, "Bloc 01");
        await admin.PostAsync($"{SiteBase}/{site.Id}/zones/{archivedId}/archive");

        var result = (await chef.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 01")))[0];

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("applied"));
            Assert.That(result.GetProperty("resource").GetProperty("id").GetGuid(), Is.Not.EqualTo(archivedId));
        });
    }

    [Test]
    public async Task A_site_the_user_is_not_assigned_to_gives_the_same_rejection_as_a_missing_site()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var foreign = await _factory.SeedSiteAsync();
        var clientId = Guid.NewGuid();

        var unassigned = (await chef.PushAsync(ZoneOperation(clientId, foreign.Id)))[0];
        var unknown = (await chef.PushAsync(ZoneOperation(clientId, Guid.NewGuid())))[0];

        Assert.Multiple(async () =>
        {
            Assert.That(unassigned.Status(), Is.EqualTo("rejected"));
            Assert.That(unassigned.Code(), Is.EqualTo("INTROUVABLE"));
            Assert.That(unassigned.GetRawText(), Is.EqualTo(unknown.GetRawText()), "Indiscernable d'un chantier inexistant.");
            var admin = await _factory.SignInAsync(RoleNames.Admin);
            Assert.That(await CountZonesAsync(admin, foreign.Id), Is.Zero, "Rien n'a été écrit.");
        });
    }

    [Test]
    public async Task An_archived_site_rejects_with_CHANTIER_ARCHIVE_and_the_rest_of_the_batch_goes_through()
    {
        var (chef, archived) = await ChefWithSiteAsync(archived: true);
        var open = await _factory.SeedSiteAsync(members: chef.Account.Id);

        var results = await chef.PushAsync(
            ZoneOperation(Guid.NewGuid(), archived.Id, "Bloc 01"),
            ZoneOperation(Guid.NewGuid(), open.Id, "Bloc 01"));

        Assert.Multiple(() =>
        {
            Assert.That(results[0].Status(), Is.EqualTo("rejected"));
            Assert.That(results[0].Code(), Is.EqualTo("CHANTIER_ARCHIVE"));
            Assert.That(results[1].Status(), Is.EqualTo("applied"), "Un lot peut réussir partiellement.");
        });
    }

    [Test]
    public async Task A_role_without_zone_creation_is_rejected_with_INTERDIT()
    {
        var crew = await _factory.SignInAsync(RoleNames.ChefEquipe);
        var site = await _factory.SeedSiteAsync(members: crew.Account.Id);

        var result = (await crew.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id)))[0];

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("rejected"));
            Assert.That(result.Code(), Is.EqualTo("INTERDIT"));
        });
    }

    [Test]
    public async Task An_unknown_entity_is_rejected_ENTITE_NON_SYNCHRONISABLE_and_does_not_stop_the_batch()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var stranger = ZoneOperation(Guid.NewGuid(), site.Id, entity: "delivery");

        var results = await chef.PushAsync(stranger, ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 06"));

        Assert.Multiple(() =>
        {
            Assert.That(results[0].Status(), Is.EqualTo("rejected"));
            Assert.That(results[0].Code(), Is.EqualTo("ENTITE_NON_SYNCHRONISABLE"));
            Assert.That(results[1].Status(), Is.EqualTo("applied"));
        });
    }

    [Test]
    public async Task Results_come_back_in_the_order_of_the_operations()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var ids = Enumerable.Range(1, 6).Select(_ => Guid.NewGuid()).ToArray();

        var results = await chef.PushAsync(ids.Select((id, index) => ZoneOperation(id, site.Id, $"Bloc {index + 1:D2}")).ToArray());

        Assert.That(results.EnumerateArray().Select(result => result.GetProperty("clientId").GetGuid()), Is.EqualTo(ids));
    }

    [Test]
    public async Task Updating_a_zone_offline_is_not_supported_at_the_socle()
    {
        var (chef, site) = await ChefWithSiteAsync();

        var result = (await chef.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, operation: "update")))[0];

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("rejected"));
            Assert.That(result.Code(), Is.EqualTo("ENTITE_NON_SYNCHRONISABLE"));
        });
    }

    [Test]
    public async Task An_unknown_operation_a_missing_clientId_or_a_missing_site_are_rejected_as_VALIDATION()
    {
        var (chef, site) = await ChefWithSiteAsync();

        var results = await chef.PushAsync(
            ZoneOperation(Guid.NewGuid(), site.Id, operation: "delete"),
            ZoneOperation(Guid.Empty, site.Id),
            ZoneOperation(Guid.NewGuid(), null));

        Assert.Multiple(() =>
        {
            Assert.That(results.EnumerateArray().Select(result => result.Code()), Is.All.EqualTo("VALIDATION"));
            Assert.That(results[0].GetProperty("errors").TryGetProperty("operation", out _), Is.True);
            Assert.That(results[1].GetProperty("errors").TryGetProperty("clientId", out _), Is.True);
            Assert.That(results[2].GetProperty("errors").TryGetProperty("siteId", out _), Is.True);
        });
    }

    [Test]
    public async Task Zone_validations_are_the_same_as_the_rest_endpoint_with_the_error_per_field()
    {
        var (chef, site) = await ChefWithSiteAsync();

        var results = await chef.PushAsync(
            ZoneOperation(Guid.NewGuid(), site.Id, block: " "),
            ZoneOperation(Guid.NewGuid(), site.Id, payload: body => body["elevation"] = 99.00m),
            ZoneOperation(Guid.NewGuid(), site.Id, payload: body => body["roomLabel"] = "Local libre"),
            ZoneOperation(Guid.NewGuid(), site.Id, payload: body => body["roomType"] = "Nope"));

        Assert.Multiple(() =>
        {
            Assert.That(results.EnumerateArray().Select(result => result.Status()), Is.All.EqualTo("rejected"));
            Assert.That(results.EnumerateArray().Select(result => result.Code()), Is.All.EqualTo("VALIDATION"));
            Assert.That(results[0].GetProperty("errors").TryGetProperty("block", out _), Is.True);
            Assert.That(results[1].GetProperty("errors").TryGetProperty("elevation", out _), Is.True);
            Assert.That(results[2].GetProperty("errors").TryGetProperty("roomLabel", out _), Is.True);
            Assert.That(results[3].GetProperty("errors").TryGetProperty("payload", out var payloadErrors) && !payloadErrors[0].GetString()!.Contains("Nope"), Is.True, "Pas d'écho de la valeur reçue.");
        });
    }

    [Test]
    public async Task Fields_the_client_may_not_set_are_ignored_in_the_payload()
    {
        var (chef, site) = await ChefWithSiteAsync();

        var result = (await chef.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 07", body =>
        {
            body["archivedAt"] = DateTimeOffset.UtcNow;
            body["createdBy"] = Guid.NewGuid();
            body["id"] = Guid.NewGuid();
            body["siteId"] = Guid.NewGuid();
        })))[0];

        var zone = result.GetProperty("resource");
        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("applied"));
            Assert.That(zone.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(zone.GetProperty("siteId").GetGuid(), Is.EqualTo(site.Id));
            Assert.That(zone.GetProperty("createdByName").GetString(), Is.EqualTo(chef.Account.FullName));
        });
    }

    [Test]
    public async Task A_missing_payload_is_rejected_as_VALIDATION()
    {
        var (chef, site) = await ChefWithSiteAsync();
        var operation = new Dictionary<string, object?>
        {
            ["clientId"] = Guid.NewGuid(),
            ["entity"] = "zone",
            ["operation"] = "create",
            ["siteId"] = site.Id,
        };

        var result = (await chef.PushAsync(operation))[0];

        Assert.Multiple(() =>
        {
            Assert.That(result.Status(), Is.EqualTo("rejected"));
            Assert.That(result.Code(), Is.EqualTo("VALIDATION"));
        });
    }

    [Test]
    public async Task A_batch_of_100_operations_is_accepted_and_101_is_413_LOT_TROP_GRAND()
    {
        var (chef, site) = await ChefWithSiteAsync();
        object Build(int index) => ZoneOperation(Guid.NewGuid(), site.Id, $"Lot {index:D3}");

        var accepted = await chef.PushAsync(Enumerable.Range(1, 100).Select(Build).ToArray());
        var tooBig = await chef.PostAsync(PushUrl, new { operations = Enumerable.Range(101, 101).Select(Build).ToArray() });
        var problem = await tooBig.JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(accepted.EnumerateArray().Select(result => result.Status()), Is.All.EqualTo("applied"));
            Assert.That(tooBig.StatusCode, Is.EqualTo(HttpStatusCode.RequestEntityTooLarge));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("LOT_TROP_GRAND"));
            Assert.That(await CountZonesAsync(chef, site.Id), Is.EqualTo(100), "Un lot refusé n'écrit rien.");
        });
    }

    [Test]
    public async Task A_body_without_operations_is_400()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);

        var response = await chef.PostAsync(PushUrl, new { });

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That((await response.JsonAsync()).GetProperty("code").GetString(), Is.EqualTo("VALIDATION"));
        });
    }

    [Test]
    public async Task Push_requires_authentication()
    {
        var response = await _factory.CreateClient().PostAsJsonAsync(PushUrl, new { operations = Array.Empty<object>() });

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
    }

    [Test]
    public async Task A_zone_pushed_by_one_phone_reaches_a_colleague_at_the_next_pull()
    {
        var (first, site) = await ChefWithSiteAsync();
        var colleague = await _factory.SignInAsync(RoleNames.ChefEquipe);
        await _factory.AssignDirectlyAsync(site.Id, colleague.Account.Id);
        var (_, _, cursor) = await colleague.PullAllAsync();

        var pushed = (await first.PushAsync(ZoneOperation(Guid.NewGuid(), site.Id, "Bloc 10")))[0];
        var (changes, _, _) = await colleague.PullAllAsync(cursor);

        Assert.That(changes.Single().GetProperty("id").GetGuid(), Is.EqualTo(pushed.GetProperty("resource").GetProperty("id").GetGuid()));
    }
}
