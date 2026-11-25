using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.SitesTestKit;

namespace Chantier.IntegrationTests.Sites;

/// <summary>Zones (CT-17) : validations, unicite, idempotence du clientId, archivage, tri, pagination, audit, droits.</summary>
[TestFixture]
public class ZonesTests
{
    private ChantierWebApplicationFactory _factory = null!;
    private ApiSession _chef = null!;
    private ApiSession _conducteur = null!;
    private SeededSite _site = null!;
    private string _zones = null!;

    [OneTimeSetUp]
    public void CreateFactory() => _factory = new ChantierWebApplicationFactory();

    [SetUp]
    public async Task SetUp()
    {
        _chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        _conducteur = await _factory.SignInAsync(RoleNames.ConducteurTravaux);
        _site = await _factory.SeedSiteAsync(members: [_chef.Account.Id, _conducteur.Account.Id]);
        _zones = $"{SiteBase}/{_site.Id}/zones";
    }

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    private static async Task<string> CodeOf(HttpResponseMessage response) => (await response.JsonAsync()).GetProperty("code").GetString()!;

    private static object Classroom(string block, decimal elevation, int number) => new { block, elevation, roomType = "Classroom", roomNumber = number };

    // --- Creation et validations ---

    [Test]
    public async Task Chef_creates_a_zone_and_gets_201_with_the_signed_elevation_kept_as_a_number()
    {
        var response = await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 2));
        var json = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(response.Headers.Location!.ToString(), Does.Contain($"/zones/{json.GetProperty("id").GetGuid()}"));
            Assert.That(json.GetProperty("siteId").GetGuid(), Is.EqualTo(_site.Id));
            Assert.That(json.GetProperty("block").GetString(), Is.EqualTo("Bloc 01"));
            Assert.That(json.GetProperty("elevation").GetDecimal(), Is.EqualTo(3.40m));
            Assert.That(json.GetProperty("roomType").GetString(), Is.EqualTo("Classroom"));
            Assert.That(json.GetProperty("roomNumber").GetInt32(), Is.EqualTo(2));
            Assert.That(json.GetProperty("roomLabel").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(json.GetProperty("createdByName").GetString(), Is.EqualTo(_chef.Account.FullName));
        });
    }

    [Test]
    public async Task A_block_alone_is_enough_and_negative_zero_and_positive_elevations_are_kept()
    {
        var block = await _chef.PostAsync(_zones, new { block = "Bloc 02" });
        var negative = await (await _chef.PostAsync(_zones, new { block = "Bloc 02", elevation = -1.90m })).JsonAsync();
        var zero = await (await _chef.PostAsync(_zones, new { block = "Bloc 02", elevation = 0.00m })).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(block.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(negative.GetProperty("elevation").GetDecimal(), Is.EqualTo(-1.90m));
            Assert.That(zero.GetProperty("elevation").GetDecimal(), Is.EqualTo(0.00m));
            Assert.That(zero.GetProperty("elevation").ValueKind, Is.EqualTo(JsonValueKind.Number), "±0,00 est une vraie cote, pas une cote absente.");
        });
    }

    [TestCase(-20.00)]
    [TestCase(60.00)]
    public async Task Elevation_bounds_are_inclusive(double elevation)
    {
        var response = await _chef.PostAsync(_zones, new { block = "Bloc 01", elevation = (decimal)elevation });

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
    }

    [TestCase(-20.01)]
    [TestCase(60.01)]
    [TestCase(99.99)]
    public async Task Elevation_out_of_range_is_400_and_nothing_is_created(double elevation)
    {
        var response = await _chef.PostAsync(_zones, new { block = "Bloc 01", elevation = (decimal)elevation });
        var json = await response.JsonAsync();
        var list = await (await _chef.GetAsync(_zones)).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(json.GetProperty("code").GetString(), Is.EqualTo("VALIDATION"));
            Assert.That(json.GetProperty("errors").TryGetProperty("elevation", out _), Is.True);
            Assert.That(list.GetProperty("items").GetArrayLength(), Is.Zero);
        });
    }

    [Test]
    public async Task Elevation_with_three_decimals_or_letters_is_400()
    {
        var threeDecimals = await _chef.PostAsync(_zones, new { block = "Bloc 01", elevation = 3.405m });
        var letters = await _chef.PostAsync(_zones, new { block = "Bloc 01", elevation = "trois" });

        Assert.Multiple(() =>
        {
            Assert.That(threeDecimals.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(letters.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    [Test]
    public async Task Room_label_is_only_for_the_type_Other()
    {
        var refused = await _chef.PostAsync(_zones, new { block = "Bloc 01", roomType = "Classroom", roomNumber = 1, roomLabel = "Libellé libre" });
        var withoutType = await _chef.PostAsync(_zones, new { block = "Bloc 01", roomLabel = "Libellé libre" });
        var accepted = await _chef.PostAsync(_zones, new { block = "Bloc 01", roomType = "Other", roomLabel = "Local gardien" });

        Assert.Multiple(async () =>
        {
            Assert.That(refused.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That((await refused.JsonAsync()).GetProperty("errors").TryGetProperty("roomLabel", out _), Is.True);
            Assert.That(withoutType.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(accepted.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That((await accepted.JsonAsync()).GetProperty("roomLabel").GetString(), Is.EqualTo("Local gardien"));
        });
    }

    [Test]
    public async Task Missing_block_unknown_room_type_and_bad_room_number_are_400_by_field()
    {
        var noBlock = await _chef.PostAsync(_zones, new { elevation = 1m });
        var blankBlock = await _chef.PostAsync(_zones, new { block = "   " });
        var badType = await _chef.PostAsync(_zones, new { block = "Bloc 01", roomType = "Salon" });
        var zeroNumber = await _chef.PostAsync(_zones, new { block = "Bloc 01", roomType = "Classroom", roomNumber = 0 });
        var numberWithoutType = await _chef.PostAsync(_zones, new { block = "Bloc 01", roomNumber = 3 });

        Assert.Multiple(async () =>
        {
            Assert.That(noBlock.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That((await noBlock.JsonAsync()).GetProperty("errors").TryGetProperty("block", out _), Is.True);
            Assert.That(blankBlock.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(badType.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(zeroNumber.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(numberWithoutType.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    [Test]
    public async Task Elevation_bounds_come_from_configuration()
    {
        using var factory = new ChantierWebApplicationFactory();
        factory.Settings["Zones:ElevationMax"] = "12.00";
        factory.Settings["Zones:ElevationMin"] = "-5.00";
        var chef = await factory.SignInAsync(RoleNames.ChefChantier);
        var site = await factory.SeedSiteAsync(members: chef.Account.Id);
        var url = $"{SiteBase}/{site.Id}/zones";

        Assert.Multiple(async () =>
        {
            Assert.That((await chef.PostAsync(url, new { block = "A", elevation = 12.00m })).StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That((await chef.PostAsync(url, new { block = "B", elevation = 12.01m })).StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That((await chef.PostAsync(url, new { block = "C", elevation = -5.01m })).StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    // --- Unicite ---

    [Test]
    public async Task Same_position_is_422_ZONE_EXISTANTE_missing_values_included()
    {
        await _chef.PostAsync(_zones, new { block = "Bloc 01" });
        await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 2));
        await _chef.PostAsync(_zones, new { block = "Bloc 02", roomType = "Other", roomLabel = "Local gardien" });

        foreach (var duplicate in new object[]
                 {
                     new { block = "Bloc 01" },
                     new { block = " Bloc 01 " },
                     Classroom("Bloc 01", 3.40m, 2),
                     new { block = "Bloc 02", roomType = "Other", roomLabel = "Local gardien" },
                 })
        {
            var response = await _chef.PostAsync(_zones, duplicate);

            Assert.Multiple(async () =>
            {
                Assert.That(response.StatusCode, Is.EqualTo((HttpStatusCode)422));
                Assert.That(await CodeOf(response), Is.EqualTo("ZONE_EXISTANTE"));
            });
        }

        var count = (await (await _chef.GetAsync(_zones)).JsonAsync()).GetProperty("items").GetArrayLength();
        Assert.That(count, Is.EqualTo(3), "Aucun doublon créé.");
    }

    [Test]
    public async Task The_same_local_name_on_two_elevations_is_two_zones()
    {
        var ground = await _chef.PostAsync(_zones, Classroom("Bloc 01", 0.00m, 1));
        var first = await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 1));
        var other = await _chef.PostAsync(_zones, Classroom("Bloc 02", 3.40m, 1));

        Assert.Multiple(() =>
        {
            Assert.That(ground.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created), "CA-018 : « Classe 01 » existe à ±0,00 et à +3,40.");
            Assert.That(other.StatusCode, Is.EqualTo(HttpStatusCode.Created));
        });
    }

    [Test]
    public async Task The_same_position_is_free_on_another_site()
    {
        var other = await _factory.SeedSiteAsync(members: _chef.Account.Id);
        await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 2));

        var response = await _chef.PostAsync($"{SiteBase}/{other.Id}/zones", Classroom("Bloc 01", 3.40m, 2));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
    }

    [Test]
    public async Task Parallel_creations_of_the_same_position_give_one_zone_and_no_500()
    {
        var responses = await Task.WhenAll(Enumerable.Range(0, 6).Select(_ => _chef.PostAsync(_zones, Classroom("Bloc 07", 1.00m, 1))));

        Assert.Multiple(async () =>
        {
            Assert.That(responses.Count(r => r.StatusCode == HttpStatusCode.Created), Is.EqualTo(1));
            Assert.That(responses.Count(r => r.StatusCode == (HttpStatusCode)422), Is.EqualTo(5));
            Assert.That((await (await _chef.GetAsync(_zones)).JsonAsync()).GetProperty("items").GetArrayLength(), Is.EqualTo(1));
        });
    }

    // --- Idempotence du clientId ---

    [Test]
    public async Task Same_client_id_returns_200_and_the_same_zone_without_duplicate()
    {
        var clientId = Guid.NewGuid();
        var body = new { clientId, clientCreatedAt = "2026-11-24T06:58:00Z", block = "Bloc 01", elevation = 3.40m, roomType = "Classroom", roomNumber = 7 };

        var first = await _chef.PostAsync(_zones, body);
        var again = await _chef.PostAsync(_zones, body);
        var firstJson = await first.JsonAsync();
        var againJson = await again.JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(againJson.GetProperty("id").GetGuid(), Is.EqualTo(firstJson.GetProperty("id").GetGuid()));
            Assert.That(againJson.GetProperty("version").GetString(), Is.EqualTo(firstJson.GetProperty("version").GetString()), "Aucun effet de bord au renvoi.");
            Assert.That((await (await _chef.GetAsync(_zones)).JsonAsync()).GetProperty("items").GetArrayLength(), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task A_replay_with_a_different_body_still_returns_the_original_zone()
    {
        var clientId = Guid.NewGuid();
        var first = await (await _chef.PostAsync(_zones, new { clientId, block = "Bloc 01" })).JsonAsync();

        var replay = await _chef.PostAsync(_zones, new { clientId, block = "Bloc 99" });

        Assert.Multiple(async () =>
        {
            Assert.That(replay.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await replay.JsonAsync()).GetProperty("block").GetString(), Is.EqualTo("Bloc 01"));
        });
        Assert.That(first.GetProperty("clientId").GetGuid(), Is.EqualTo(clientId));
    }

    [Test]
    public async Task Parallel_replays_of_the_same_client_id_give_one_zone()
    {
        var clientId = Guid.NewGuid();

        var responses = await Task.WhenAll(Enumerable.Range(0, 8).Select(_ => _chef.PostAsync(_zones, new { clientId, block = "Bloc 03", elevation = 2.00m })));
        var ids = new List<Guid>();
        foreach (var response in responses)
        {
            Assert.That(response.StatusCode, Is.AnyOf(HttpStatusCode.Created, HttpStatusCode.OK));
            ids.Add((await response.JsonAsync()).GetProperty("id").GetGuid());
        }

        Assert.Multiple(async () =>
        {
            Assert.That(ids.Distinct().Count(), Is.EqualTo(1));
            Assert.That((await (await _chef.GetAsync(_zones)).JsonAsync()).GetProperty("items").GetArrayLength(), Is.EqualTo(1));
        });
    }

    [Test]
    public async Task The_same_client_id_on_another_site_is_a_different_zone()
    {
        var other = await _factory.SeedSiteAsync(members: _chef.Account.Id);
        var clientId = Guid.NewGuid();

        var first = await _chef.PostAsync(_zones, new { clientId, block = "Bloc 01" });
        var second = await _chef.PostAsync($"{SiteBase}/{other.Id}/zones", new { clientId, block = "Bloc 01" });

        Assert.Multiple(() =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(second.StatusCode, Is.EqualTo(HttpStatusCode.Created), "L'unicité du clientId est par chantier.");
        });
    }

    [Test]
    public async Task An_empty_client_id_is_400()
    {
        var response = await _chef.PostAsync(_zones, new { clientId = Guid.Empty, block = "Bloc 01" });

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
    }

    // --- Audit : le « saisi le » du telephone est conserve a part ---

    [Test]
    public async Task Client_time_is_kept_apart_and_never_replaces_the_server_audit_time()
    {
        var phoneTime = new DateTimeOffset(2026, 11, 24, 6, 58, 0, TimeSpan.Zero);
        var serverTime = _factory.Time.GetUtcNow();

        var json = await (await _chef.PostAsync(_zones, new { clientId = Guid.NewGuid(), clientCreatedAt = phoneTime, block = "Bloc 01" })).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(json.GetProperty("clientCreatedAt").GetDateTimeOffset(), Is.EqualTo(phoneTime));
            Assert.That(json.GetProperty("createdAt").GetDateTimeOffset(), Is.EqualTo(serverTime).Within(TimeSpan.FromSeconds(1)));
            Assert.That(json.GetProperty("createdAt").GetDateTimeOffset(), Is.Not.EqualTo(phoneTime));
        });
    }

    [Test]
    public async Task Forged_audit_fields_in_the_body_are_ignored()
    {
        var json = await (await _chef.PostAsync(_zones, new
        {
            block = "Bloc 01",
            createdBy = Guid.NewGuid(),
            createdByName = "Pirate",
            createdAt = "2001-01-01T00:00:00Z",
            archivedAt = "2001-01-01T00:00:00Z",
            id = Guid.NewGuid(),
            siteId = Guid.NewGuid(),
        })).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(json.GetProperty("createdByName").GetString(), Is.EqualTo(_chef.Account.FullName));
            Assert.That(json.GetProperty("createdAt").GetDateTimeOffset().Year, Is.EqualTo(DateTimeOffset.UtcNow.Year));
            Assert.That(json.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(json.GetProperty("siteId").GetGuid(), Is.EqualTo(_site.Id), "Le chantier vient de la route, jamais du corps.");
        });
    }

    // --- Lecture : tri et pagination ---

    [Test]
    public async Task Zones_are_listed_from_the_lowest_to_the_highest_elevation()
    {
        foreach (var elevation in new[] { 3.40m, -1.90m, 10.20m, 0.00m, 6.80m })
        {
            await _chef.PostAsync(_zones, new { block = "Bloc 01", elevation });
        }

        await _chef.PostAsync(_zones, new { block = "Bloc 01" });
        await _chef.PostAsync(_zones, new { block = "Bloc 02" });

        var items = (await (await _chef.GetAsync(_zones)).JsonAsync()).GetProperty("items");
        var listed = items.EnumerateArray()
            .Select(zone => (Block: zone.GetProperty("block").GetString(), Elevation: zone.GetProperty("elevation").ValueKind == JsonValueKind.Null ? (decimal?)null : zone.GetProperty("elevation").GetDecimal()))
            .ToList();

        Assert.That(listed, Is.EqualTo(new (string?, decimal?)[]
        {
            ("Bloc 01", null), ("Bloc 01", -1.90m), ("Bloc 01", 0.00m), ("Bloc 01", 3.40m), ("Bloc 01", 6.80m), ("Bloc 01", 10.20m), ("Bloc 02", null),
        }));
    }

    [Test]
    public async Task Cursor_paging_walks_the_whole_list_without_duplicates()
    {
        for (var number = 1; number <= 5; number++)
        {
            await _chef.PostAsync(_zones, Classroom("Bloc 01", 0.00m, number));
        }

        var seen = new List<int>();
        string? cursor = null;
        var pages = 0;
        do
        {
            var url = _zones + "?pageSize=2" + (cursor is null ? string.Empty : $"&cursor={Uri.EscapeDataString(cursor)}");
            var json = await (await _chef.GetAsync(url)).JsonAsync();
            seen.AddRange(json.GetProperty("items").EnumerateArray().Select(zone => zone.GetProperty("roomNumber").GetInt32()));
            cursor = json.TryGetProperty("nextCursor", out var next) && next.ValueKind == JsonValueKind.String ? next.GetString() : null;
            pages++;
        }
        while (cursor is not null && pages < 10);

        Assert.Multiple(() =>
        {
            Assert.That(seen, Is.EqualTo(new[] { 1, 2, 3, 4, 5 }));
            Assert.That(pages, Is.EqualTo(3));
        });
    }

    [Test]
    public async Task The_last_page_has_no_next_cursor_and_a_garbage_cursor_is_400_CURSEUR_INVALIDE()
    {
        await _chef.PostAsync(_zones, new { block = "Bloc 01" });

        var last = await (await _chef.GetAsync(_zones)).JsonAsync();
        var garbage = await _chef.GetAsync($"{_zones}?cursor=%%%pas-un-curseur");
        var wrongShape = await _chef.GetAsync($"{_zones}?cursor={Convert.ToBase64String("autre:12"u8.ToArray()).TrimEnd('=')}");

        Assert.Multiple(async () =>
        {
            Assert.That(last.GetProperty("nextCursor").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(garbage.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(await CodeOf(garbage), Is.EqualTo("CURSEUR_INVALIDE"));
            Assert.That(await CodeOf(wrongShape), Is.EqualTo("CURSEUR_INVALIDE"));
        });
    }

    [TestCase(0)]
    [TestCase(201)]
    public async Task Page_size_is_bounded_between_1_and_200(int pageSize)
    {
        var response = await _chef.GetAsync($"{_zones}?pageSize={pageSize}");

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
    }

    [Test]
    public async Task List_filters_by_block_and_search_and_hides_archived_zones_by_default()
    {
        await _chef.PostAsync(_zones, new { block = "Bloc 01" });
        var toArchive = await (await _chef.PostAsync(_zones, new { block = "Bloc 02" })).JsonAsync();
        await _chef.PostAsync(_zones, new { block = "Bloc 03", roomType = "Other", roomLabel = "Local gardien" });
        await _conducteur.PostAsync($"{_zones}/{toArchive.GetProperty("id").GetGuid()}/archive");

        var all = (await (await _chef.GetAsync(_zones)).JsonAsync()).GetProperty("items").Strings("block");
        var withArchived = (await (await _chef.GetAsync($"{_zones}?includeArchived=true")).JsonAsync()).GetProperty("items").Strings("block");
        var byBlock = (await (await _chef.GetAsync($"{_zones}?block=Bloc 01")).JsonAsync()).GetProperty("items").Strings("block");
        var bySearch = (await (await _chef.GetAsync($"{_zones}?q=gardien")).JsonAsync()).GetProperty("items").Strings("block");

        Assert.Multiple(() =>
        {
            Assert.That(all, Is.EqualTo(new[] { "Bloc 01", "Bloc 03" }));
            Assert.That(withArchived, Is.EqualTo(new[] { "Bloc 01", "Bloc 02", "Bloc 03" }));
            Assert.That(byBlock, Is.EqualTo(new[] { "Bloc 01" }));
            Assert.That(bySearch, Is.EqualTo(new[] { "Bloc 03" }));
        });
    }

    // --- Modification, archivage, restauration ---

    [Test]
    public async Task Update_changes_the_position_and_the_version_and_a_stale_version_is_409()
    {
        var created = await (await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 2))).JsonAsync();
        var url = $"{_zones}/{created.GetProperty("id").GetGuid()}";
        var version = created.GetProperty("version").GetString();

        var updated = await _chef.PutAsync(url, new { version, block = "Bloc 01", elevation = 3.40m, roomType = "Classroom", roomNumber = 3 });
        var stale = await _conducteur.PutAsync(url, new { version, block = "Bloc 09" });
        var staleJson = await stale.JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(updated.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await updated.JsonAsync()).GetProperty("roomNumber").GetInt32(), Is.EqualTo(3));
            Assert.That((await updated.JsonAsync()).GetProperty("updatedByName").GetString(), Is.EqualTo(_chef.Account.FullName));
            Assert.That(stale.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
            Assert.That(staleJson.GetProperty("code").GetString(), Is.EqualTo("CONFLIT_VERSION"));
            Assert.That(staleJson.GetProperty("current").GetProperty("roomNumber").GetInt32(), Is.EqualTo(3));
        });
    }

    [Test]
    public async Task Update_into_an_existing_position_is_422_ZONE_EXISTANTE_but_keeping_its_own_position_is_fine()
    {
        await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 1));
        var second = await (await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 2))).JsonAsync();
        var url = $"{_zones}/{second.GetProperty("id").GetGuid()}";
        var version = second.GetProperty("version").GetString();

        var collision = await _chef.PutAsync(url, new { version, block = "Bloc 01", elevation = 3.40m, roomType = "Classroom", roomNumber = 1 });
        var same = await _chef.PutAsync(url, new { version, block = "Bloc 01", elevation = 3.40m, roomType = "Classroom", roomNumber = 2 });

        Assert.Multiple(async () =>
        {
            Assert.That(collision.StatusCode, Is.EqualTo((HttpStatusCode)422));
            Assert.That(await CodeOf(collision), Is.EqualTo("ZONE_EXISTANTE"));
            Assert.That(same.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    [Test]
    public async Task Archive_hides_the_zone_frees_its_position_and_is_traced_and_idempotent()
    {
        var created = await (await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 2))).JsonAsync();
        var url = $"{_zones}/{created.GetProperty("id").GetGuid()}";

        var archived = await _conducteur.PostAsync($"{url}/archive");
        var archivedJson = await archived.JsonAsync();
        var again = await _conducteur.PostAsync($"{url}/archive");
        var recreated = await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 2));

        Assert.Multiple(async () =>
        {
            Assert.That(archived.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(archivedJson.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.String));
            Assert.That(archivedJson.GetProperty("archivedByName").GetString(), Is.EqualTo(_conducteur.Account.FullName));
            Assert.That((await again.JsonAsync()).GetProperty("version").GetString(), Is.EqualTo(archivedJson.GetProperty("version").GetString()));
            Assert.That(recreated.StatusCode, Is.EqualTo(HttpStatusCode.Created), "La position d'une zone archivée est de nouveau libre.");
            Assert.That((await _chef.GetAsync(url)).StatusCode, Is.EqualTo(HttpStatusCode.OK), "Une zone archivée reste lisible (anciennes saisies).");
        });
    }

    [Test]
    public async Task Restore_is_422_ZONE_EXISTANTE_when_the_position_was_taken_meanwhile()
    {
        var created = await (await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 2))).JsonAsync();
        var url = $"{_zones}/{created.GetProperty("id").GetGuid()}";
        await _conducteur.PostAsync($"{url}/archive");
        await _chef.PostAsync(_zones, Classroom("Bloc 01", 3.40m, 2));

        var restore = await _conducteur.PostAsync($"{url}/restore");

        Assert.Multiple(async () =>
        {
            Assert.That(restore.StatusCode, Is.EqualTo((HttpStatusCode)422));
            Assert.That(await CodeOf(restore), Is.EqualTo("ZONE_EXISTANTE"));
        });
    }

    [Test]
    public async Task Restore_brings_back_an_archived_zone()
    {
        var created = await (await _chef.PostAsync(_zones, new { block = "Bloc 05" })).JsonAsync();
        var url = $"{_zones}/{created.GetProperty("id").GetGuid()}";
        await _conducteur.PostAsync($"{url}/archive");

        var restored = await (await _conducteur.PostAsync($"{url}/restore")).JsonAsync();

        Assert.That(restored.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.Null));
    }

    // --- Droits par role ---

    [Test]
    public async Task Chef_chantier_cannot_archive_a_zone_but_conducteur_can()
    {
        var created = await (await _chef.PostAsync(_zones, new { block = "Bloc 01" })).JsonAsync();
        var url = $"{_zones}/{created.GetProperty("id").GetGuid()}";

        var byChef = await _chef.PostAsync($"{url}/archive");
        var byConducteur = await _conducteur.PostAsync($"{url}/archive");

        Assert.Multiple(() =>
        {
            Assert.That(byChef.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(byConducteur.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    [TestCase(RoleNames.Direction)]
    [TestCase(RoleNames.Achats)]
    [TestCase(RoleNames.ChefEquipe)]
    public async Task Roles_without_zone_rights_read_but_cannot_write(string role)
    {
        var user = await _factory.SignInAsync(role);
        await _factory.AssignDirectlyAsync(_site.Id, user.Account.Id);
        var existing = await (await _chef.PostAsync(_zones, new { block = "Bloc 01" })).JsonAsync();
        var url = $"{_zones}/{existing.GetProperty("id").GetGuid()}";

        var create = await user.PostAsync(_zones, new { block = "Bloc 77" });
        var update = await user.PutAsync(url, new { version = existing.GetProperty("version").GetString(), block = "Bloc 78" });
        var archive = await user.PostAsync($"{url}/archive");
        var list = await user.GetAsync(_zones);

        Assert.Multiple(async () =>
        {
            Assert.That(create.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(update.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(archive.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(list.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await (await _chef.GetAsync(_zones)).JsonAsync()).GetProperty("items").GetArrayLength(), Is.EqualTo(1), "Rien n'a été enregistré.");
        });
    }

    [Test]
    public async Task Unauthenticated_calls_are_401()
    {
        using var client = _factory.CreateClient();

        Assert.Multiple(async () =>
        {
            Assert.That((await client.GetAsync(_zones)).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That((await client.PostAsync(_zones, JsonContent.Create(new { block = "Bloc 01" }))).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task Unknown_zone_in_a_visible_site_is_404()
    {
        var response = await _chef.GetAsync($"{_zones}/{Guid.NewGuid()}");

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(await CodeOf(response), Is.EqualTo("INTROUVABLE"));
        });
    }
}
