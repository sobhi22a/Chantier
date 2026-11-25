using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;
using static Chantier.IntegrationTests.Support.SitesTestKit;

namespace Chantier.IntegrationTests.Sites;

/// <summary>Chantiers : creation, modification, archivage (CT-6 audit, CT-7 concurrence, CT-18 fin contractuelle) et droits par role.</summary>
[TestFixture]
public class SitesCrudTests
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

    private static async Task<string> CodeOf(HttpResponseMessage response) => (await response.JsonAsync()).GetProperty("code").GetString()!;

    // --- Creation ---

    [Test]
    public async Task Admin_creates_a_site_and_gets_201_with_location_and_computed_end_date()
    {
        var body = SiteBody();

        var response = await _admin.PostAsync(SiteBase, body);
        var json = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(response.Headers.Location!.ToString(), Does.EndWith($"/api/v1/sites/{json.GetProperty("id").GetGuid()}"));
            Assert.That(json.GetProperty("code").GetString(), Is.EqualTo((string)body["code"]!));
            Assert.That(json.GetProperty("type").GetString(), Is.EqualTo("School"));
            Assert.That(json.GetProperty("contractualEndDate").GetString(), Is.EqualTo("2027-08-24"));
            Assert.That(json.GetProperty("contractAmount").GetDecimal(), Is.EqualTo(185000000.00m));
            Assert.That(json.GetProperty("odsDate").GetString(), Is.EqualTo("2026-03-02"));
            Assert.That(json.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(json.GetProperty("version").GetString(), Is.Not.Empty);
        });
    }

    [Test]
    public async Task Code_is_normalized_to_upper_case()
    {
        var code = "t-" + Guid.NewGuid().ToString("N")[..8];

        var response = await _admin.PostAsync(SiteBase, SiteBody(code));

        Assert.That(await CodeOf(response), Is.EqualTo(code.ToUpperInvariant()));
    }

    [Test]
    public async Task Duplicate_code_is_422_CODE_CHANTIER_EXISTANT_and_creates_nothing()
    {
        var body = SiteBody();
        var first = await _admin.PostAsync(SiteBase, body);
        var second = await _admin.PostAsync(SiteBase, body);

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(second.StatusCode, Is.EqualTo((HttpStatusCode)422));
            Assert.That(await CodeOf(second), Is.EqualTo("CODE_CHANTIER_EXISTANT"));
        });
    }

    [Test]
    public async Task Two_parallel_creations_of_the_same_code_give_exactly_one_site()
    {
        var body = SiteBody();

        var responses = await Task.WhenAll(Enumerable.Range(0, 6).Select(_ => _admin.PostAsync(SiteBase, body)));

        Assert.Multiple(() =>
        {
            Assert.That(responses.Count(r => r.StatusCode == HttpStatusCode.Created), Is.EqualTo(1));
            Assert.That(responses.Count(r => r.StatusCode == (HttpStatusCode)422), Is.EqualTo(5), "Les autres reçoivent CODE_CHANTIER_EXISTANT, jamais un 500.");
        });
    }

    [Test]
    public async Task An_archived_site_still_reserves_its_code()
    {
        var body = SiteBody();
        var created = await (await _admin.PostAsync(SiteBase, body)).JsonAsync();
        await _admin.PostAsync($"{SiteBase}/{created.GetProperty("id").GetGuid()}/archive");

        var again = await _admin.PostAsync(SiteBase, body);

        Assert.That(await CodeOf(again), Is.EqualTo("CODE_CHANTIER_EXISTANT"));
    }

    [TestCase("ab")]
    [TestCase("code avec espaces")]
    [TestCase("-DEBUT")]
    [TestCase("CODE_SOULIGNE")]
    public async Task Invalid_code_is_400(string code)
    {
        var response = await _admin.PostAsync(SiteBase, SiteBody(code));
        var json = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(json.GetProperty("code").GetString(), Is.EqualTo("VALIDATION"));
            Assert.That(json.GetProperty("errors").TryGetProperty("code", out _), Is.True);
        });
    }

    [Test]
    public async Task Missing_required_fields_are_reported_by_field_and_nothing_is_created()
    {
        var response = await _admin.PostAsync(SiteBase, new { code = "T-VIDE-" + Guid.NewGuid().ToString("N")[..6] });
        var json = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            foreach (var field in new[] { "name", "type", "wilaya", "commune", "owner" })
            {
                Assert.That(json.GetProperty("errors").TryGetProperty(field, out _), Is.True, field);
            }
        });
    }

    [Test]
    public async Task Unknown_site_type_and_numeric_type_are_400()
    {
        var unknown = await _admin.PostAsync(SiteBase, SiteBody(overrides: b => b["type"] = "Chateau"));
        var numeric = await _admin.PostAsync(SiteBase, SiteBody(overrides: b => b["type"] = 1));

        Assert.Multiple(() =>
        {
            Assert.That(unknown.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(numeric.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest), "Les énumérations sont des chaînes, jamais des entiers.");
        });
    }

    // --- CT-18 : fin contractuelle, dates, delai ---

    [TestCase("2026-03-02", 540, "2027-08-24")]
    [TestCase("2026-06-15", 420, "2027-08-09")]
    [TestCase("2026-01-15", 30, "2026-02-14")]
    [TestCase("2027-03-01", 366, "2028-03-01")]
    public async Task End_date_is_computed_by_the_server_for_the_four_reference_cases(string ods, int delay, string expectedEnd)
    {
        var response = await _admin.PostAsync(SiteBase, SiteBody(overrides: b => { b["odsDate"] = ods; b["delayDays"] = delay; }));
        var json = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(json.GetProperty("contractualEndDate").GetString(), Is.EqualTo(expectedEnd));
        });
    }

    [Test]
    public async Task Missing_ods_or_delay_gives_a_null_end_date_not_an_error()
    {
        var withoutDelay = await (await _admin.PostAsync(SiteBase, SiteBody(overrides: b => b["delayDays"] = null))).JsonAsync();
        var withoutOds = await (await _admin.PostAsync(SiteBase, SiteBody(overrides: b => b["odsDate"] = null))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(withoutDelay.GetProperty("contractualEndDate").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(withoutOds.GetProperty("contractualEndDate").ValueKind, Is.EqualTo(JsonValueKind.Null));
        });
    }

    [TestCase("../03/2026")]
    [TestCase("2026-03")]
    [TestCase("02/03/2026")]
    [TestCase("2026-02-30")]
    [TestCase("")]
    public async Task Incomplete_ods_date_is_400_DATE_INVALIDE(string date)
    {
        var response = await _admin.PostAsync(SiteBase, SiteBody(overrides: b => b["odsDate"] = date));
        var json = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(json.GetProperty("code").GetString(), Is.EqualTo("DATE_INVALIDE"));
            Assert.That(json.GetProperty("errors").GetProperty("odsDate").GetArrayLength(), Is.EqualTo(1));
            Assert.That(date.Length == 0 || !json.GetRawText().Contains(date, StringComparison.Ordinal), Is.True, "La valeur saisie n'est jamais renvoyée en écho.");
        });
    }

    [TestCase(0)]
    [TestCase(-1)]
    [TestCase(-30)]
    public async Task Delay_zero_or_negative_is_422_QUANTITE_INVALIDE(int delay)
    {
        var response = await _admin.PostAsync(SiteBase, SiteBody(overrides: b => b["delayDays"] = delay));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo((HttpStatusCode)422));
            Assert.That(await CodeOf(response), Is.EqualTo("QUANTITE_INVALIDE"));
        });
    }

    [Test]
    public async Task A_decimal_delay_is_refused()
    {
        var response = await _admin.PostAsync(SiteBase, SiteBody(overrides: b => b["delayDays"] = 12.5m));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
    }

    [Test]
    public async Task Update_recomputes_the_end_date()
    {
        var created = await (await _admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var id = created.GetProperty("id").GetGuid();

        var body = SiteBody(overrides: b => { b.Remove("code"); b["version"] = created.GetProperty("version").GetString(); b["delayDays"] = 30; b["odsDate"] = "2026-01-15"; });
        var response = await _admin.PutAsync($"{SiteBase}/{id}", body);
        var json = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(json.GetProperty("contractualEndDate").GetString(), Is.EqualTo("2026-02-14"));
        });
    }

    // --- CT-7 : concurrence ---

    [Test]
    public async Task Stale_version_is_409_CONFLIT_VERSION_with_the_current_state()
    {
        var created = await (await _admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var id = created.GetProperty("id").GetGuid();
        var staleVersion = created.GetProperty("version").GetString();

        var firstEdit = await _admin.PutAsync($"{SiteBase}/{id}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = staleVersion; b["name"] = "Nom du premier"; }));
        var secondEdit = await _admin.PutAsync($"{SiteBase}/{id}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = staleVersion; b["name"] = "Nom du second"; }));
        var conflict = await secondEdit.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(firstEdit.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(secondEdit.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
            Assert.That(conflict.GetProperty("code").GetString(), Is.EqualTo("CONFLIT_VERSION"));
            Assert.That(conflict.GetProperty("current").GetProperty("name").GetString(), Is.EqualTo("Nom du premier"), "L'état courant permet à l'interface de proposer de recharger.");
            Assert.That(conflict.GetProperty("current").GetProperty("version").GetString(), Is.Not.EqualTo(staleVersion));
            Assert.That(conflict.GetProperty("current").GetProperty("updatedByName").GetString(), Is.EqualTo(_admin.Account.FullName), "« Modifié entre-temps par <nom> ».");
        });
    }

    [Test]
    public async Task Concurrent_updates_with_the_same_version_let_exactly_one_win()
    {
        var created = await (await _admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var id = created.GetProperty("id").GetGuid();
        var version = created.GetProperty("version").GetString();

        var responses = await Task.WhenAll(Enumerable.Range(0, 5).Select(i =>
            _admin.PutAsync($"{SiteBase}/{id}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = version; b["name"] = $"Concurrent {i}"; }))));

        Assert.Multiple(() =>
        {
            Assert.That(responses.Count(r => r.StatusCode == HttpStatusCode.OK), Is.EqualTo(1));
            Assert.That(responses.Count(r => r.StatusCode == HttpStatusCode.Conflict), Is.EqualTo(4), "Aucune modification n'en écrase une autre sans qu'on le sache (CA-008.9).");
        });
    }

    [Test]
    public async Task Each_update_gives_a_new_increasing_version()
    {
        var created = await (await _admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var id = created.GetProperty("id").GetGuid();

        var first = await (await _admin.PutAsync($"{SiteBase}/{id}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = created.GetProperty("version").GetString(); }))).JsonAsync();
        var second = await (await _admin.PutAsync($"{SiteBase}/{id}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = first.GetProperty("version").GetString(); }))).JsonAsync();

        var versions = new[] { created, first, second }.Select(j => ulong.Parse(j.GetProperty("version").GetString()!)).ToList();
        Assert.That(versions, Is.Ordered.Ascending.And.Unique);
    }

    [TestCase(null)]
    [TestCase("abc")]
    [TestCase("-5")]
    [TestCase("1.5")]
    public async Task Missing_or_unreadable_version_is_400(string? version)
    {
        var created = await (await _admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var id = created.GetProperty("id").GetGuid();

        var response = await _admin.PutAsync($"{SiteBase}/{id}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = version; }));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
    }

    [Test]
    public async Task The_code_is_immutable_a_code_sent_in_an_update_is_ignored()
    {
        var created = await (await _admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var id = created.GetProperty("id").GetGuid();

        var response = await _admin.PutAsync($"{SiteBase}/{id}", SiteBody("T-AUTRE-CODE", b => b["version"] = created.GetProperty("version").GetString()));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await response.JsonAsync()).GetProperty("code").GetString(), Is.EqualTo(created.GetProperty("code").GetString()));
        });
    }

    // --- CT-6 : audit automatique ---

    [Test]
    public async Task Audit_comes_from_the_token_and_the_server_clock_never_from_the_client()
    {
        using var factory = new ChantierWebApplicationFactory();
        var start = factory.Time.GetUtcNow();
        var first = await factory.SignInAsync(RoleNames.Admin);
        var second = await factory.SignInAsync(RoleNames.Admin);

        // Le client tente de forcer l'auteur et les dates : ces champs n'existent pas dans le contrat et sont ignores.
        var body = SiteBody(overrides: b =>
        {
            b["createdBy"] = Guid.NewGuid();
            b["createdByName"] = "Pirate";
            b["createdAt"] = "2001-01-01T00:00:00Z";
            b["updatedAt"] = "2001-01-01T00:00:00Z";
            b["archivedAt"] = "2001-01-01T00:00:00Z";
            b["id"] = Guid.NewGuid();
        });
        var created = await (await first.PostAsync(SiteBase, body)).JsonAsync();
        var id = created.GetProperty("id").GetGuid();

        factory.Time.Advance(TimeSpan.FromHours(2));
        var updated = await (await second.PutAsync($"{SiteBase}/{id}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = created.GetProperty("version").GetString(); b["name"] = "Modifié"; }))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(created.GetProperty("id").GetGuid(), Is.Not.EqualTo(body["id"]));
            Assert.That(created.GetProperty("createdByName").GetString(), Is.EqualTo(first.Account.FullName));
            Assert.That(created.GetProperty("createdAt").GetDateTimeOffset(), Is.EqualTo(start), "Heure du serveur.");
            Assert.That(created.GetProperty("updatedAt").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(created.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(updated.GetProperty("createdByName").GetString(), Is.EqualTo(first.Account.FullName), "Le créateur ne change pas.");
            Assert.That(updated.GetProperty("updatedByName").GetString(), Is.EqualTo(second.Account.FullName));
            Assert.That(updated.GetProperty("updatedAt").GetDateTimeOffset(), Is.EqualTo(start.AddHours(2)));
        });
    }

    [Test]
    public async Task Archive_and_restore_are_traced_and_nothing_is_deleted()
    {
        using var factory = new ChantierWebApplicationFactory();
        var start = factory.Time.GetUtcNow();
        var admin = await factory.SignInAsync(RoleNames.Admin);
        var created = await (await admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var id = created.GetProperty("id").GetGuid();

        factory.Time.Advance(TimeSpan.FromMinutes(30));
        var archived = await (await admin.PostAsync($"{SiteBase}/{id}/archive")).JsonAsync();
        var archivedAgain = await (await admin.PostAsync($"{SiteBase}/{id}/archive")).JsonAsync();
        var restored = await (await admin.PostAsync($"{SiteBase}/{id}/restore")).JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(archived.GetProperty("archivedAt").GetDateTimeOffset(), Is.EqualTo(start.AddMinutes(30)));
            Assert.That(archived.GetProperty("archivedByName").GetString(), Is.EqualTo(admin.Account.FullName));
            Assert.That(archivedAgain.GetProperty("version").GetString(), Is.EqualTo(archived.GetProperty("version").GetString()), "Archiver deux fois ne change rien.");
            Assert.That(restored.GetProperty("archivedAt").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(await factory.CountRowsAsync(id), Is.EqualTo(1), "Aucune suppression physique.");
        });
    }

    [Test]
    public async Task There_is_no_delete_route_for_sites()
    {
        var created = await (await _admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var id = created.GetProperty("id").GetGuid();

        var response = await _admin.DeleteAsync($"{SiteBase}/{id}");

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.AnyOf(HttpStatusCode.MethodNotAllowed, HttpStatusCode.NotFound));
            Assert.That((await _admin.GetAsync($"{SiteBase}/{id}")).StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    // --- Archivage et lecture seule ---

    [Test]
    public async Task Archived_sites_are_hidden_from_the_list_unless_requested_and_become_read_only()
    {
        var marker = Guid.NewGuid().ToString("N")[..8].ToUpperInvariant();
        var created = await (await _admin.PostAsync(SiteBase, SiteBody($"T-{marker}"))).JsonAsync();
        var id = created.GetProperty("id").GetGuid();
        var archived = await (await _admin.PostAsync($"{SiteBase}/{id}/archive")).JsonAsync();

        var hidden = await (await _admin.GetAsync($"{SiteBase}?q={marker}")).JsonAsync();
        var shown = await (await _admin.GetAsync($"{SiteBase}?q={marker}&includeArchived=true")).JsonAsync();
        var update = await _admin.PutAsync($"{SiteBase}/{id}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = archived.GetProperty("version").GetString(); }));
        var addZone = await _admin.PostAsync($"{SiteBase}/{id}/zones", new { block = "Bloc 01" });
        var stillReadable = await _admin.GetAsync($"{SiteBase}/{id}");

        Assert.Multiple(async () =>
        {
            Assert.That(hidden.GetProperty("items").GetArrayLength(), Is.Zero);
            Assert.That(shown.GetProperty("items").GetArrayLength(), Is.EqualTo(1));
            Assert.That(update.StatusCode, Is.EqualTo((HttpStatusCode)422));
            Assert.That(await CodeOf(update), Is.EqualTo("CHANTIER_ARCHIVE"));
            Assert.That(addZone.StatusCode, Is.EqualTo((HttpStatusCode)422));
            Assert.That(await CodeOf(addZone), Is.EqualTo("CHANTIER_ARCHIVE"));
            Assert.That(stillReadable.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    // --- Droits par role ---

    [TestCase(RoleNames.Direction)]
    [TestCase(RoleNames.ConducteurTravaux)]
    [TestCase(RoleNames.Achats)]
    [TestCase(RoleNames.ChefChantier)]
    [TestCase(RoleNames.ChefEquipe)]
    public async Task Only_admin_creates_updates_and_archives_sites(string role)
    {
        var admin = await _factory.SignInAsync(RoleNames.Admin);
        var site = await (await admin.PostAsync(SiteBase, SiteBody())).JsonAsync();
        var id = site.GetProperty("id").GetGuid();
        var user = await _factory.SignInAsync(role);
        await _factory.AssignDirectlyAsync(id, user.Account.Id);

        var create = await user.PostAsync(SiteBase, SiteBody());
        var update = await user.PutAsync($"{SiteBase}/{id}", SiteBody(overrides: b => { b.Remove("code"); b["version"] = site.GetProperty("version").GetString(); }));
        var archive = await user.PostAsync($"{SiteBase}/{id}/archive");
        var restore = await user.PostAsync($"{SiteBase}/{id}/restore");
        var suggestion = await user.GetAsync($"{SiteBase}/code-suggestion?type=School&name=Test");
        var read = await user.GetAsync($"{SiteBase}/{id}");

        Assert.Multiple(() =>
        {
            Assert.That(create.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(update.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden), "CA-008.7 : seul l'Admin modifie un chantier.");
            Assert.That(archive.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(restore.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(suggestion.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(read.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    // --- Suggestion de code ---

    [Test]
    public async Task Code_suggestion_follows_the_type_and_the_name_and_adds_a_suffix_when_taken()
    {
        var marker = Guid.NewGuid().ToString("N")[..4].ToUpperInvariant();
        var name = $"École Z{marker}9";
        var first = await (await _admin.GetAsync($"{SiteBase}/code-suggestion?type=School&name={Uri.EscapeDataString(name)}")).JsonAsync();
        var expected = first.GetProperty("code").GetString()!;

        Assert.That(expected, Is.EqualTo($"CH-ECO-Z{marker}9"));

        await _admin.PostAsync(SiteBase, SiteBody(expected));
        var second = await (await _admin.GetAsync($"{SiteBase}/code-suggestion?type=School&name={Uri.EscapeDataString(name)}")).JsonAsync();

        Assert.That(second.GetProperty("code").GetString(), Is.EqualTo(expected + "-2"));
    }

    [Test]
    public async Task Code_suggestion_requires_a_name_and_a_valid_type()
    {
        var withoutName = await _admin.GetAsync($"{SiteBase}/code-suggestion?type=School");
        var badType = await _admin.GetAsync($"{SiteBase}/code-suggestion?type=Chateau&name=x");

        Assert.Multiple(() =>
        {
            Assert.That(withoutName.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(badType.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    // --- Liste ---

    [Test]
    public async Task List_is_paged_sorted_and_counted()
    {
        var marker = Guid.NewGuid().ToString("N")[..8].ToUpperInvariant();
        foreach (var letter in new[] { "C", "A", "B", "E", "D" })
        {
            await _admin.PostAsync(SiteBase, SiteBody($"T-{marker}-{letter}", b => b["name"] = $"{letter} {marker}"));
        }

        var page1 = await (await _admin.GetAsync($"{SiteBase}?q={marker}&sort=name&page=1&pageSize=2")).JsonAsync();
        var page3 = await (await _admin.GetAsync($"{SiteBase}?q={marker}&sort=name&page=3&pageSize=2")).JsonAsync();
        var descending = await (await _admin.GetAsync($"{SiteBase}?q={marker}&sort=-code&pageSize=10")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(page1.GetProperty("totalCount").GetInt32(), Is.EqualTo(5));
            Assert.That(page1.GetProperty("page").GetInt32(), Is.EqualTo(1));
            Assert.That(page1.GetProperty("pageSize").GetInt32(), Is.EqualTo(2));
            Assert.That(page1.GetProperty("items").Strings("name"), Is.EqualTo(new[] { $"A {marker}", $"B {marker}" }));
            Assert.That(page3.GetProperty("items").Strings("name"), Is.EqualTo(new[] { $"E {marker}" }));
            Assert.That(descending.GetProperty("items").Strings("code").First(), Is.EqualTo($"T-{marker}-E"));
        });
    }

    [TestCase("page=0")]
    [TestCase("page=-1")]
    [TestCase("pageSize=0")]
    [TestCase("pageSize=201")]
    [TestCase("sort=password")]
    [TestCase("sort=-secret")]
    [TestCase("type=Chateau")]
    public async Task Invalid_list_parameters_are_400(string query)
    {
        var response = await _admin.GetAsync($"{SiteBase}?{query}");

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
    }

    [Test]
    public async Task Search_treats_wildcards_and_quotes_as_plain_text()
    {
        var marker = Guid.NewGuid().ToString("N")[..8].ToUpperInvariant();
        await _admin.PostAsync(SiteBase, SiteBody($"T-{marker}", b => b["name"] = "Chantier ordinaire"));

        foreach (var query in new[] { "%", "_", "'", "' OR 1=1 --", "[a-z]", "%'; DROP TABLE Sites; --" })
        {
            var response = await _admin.GetAsync($"{SiteBase}?q={Uri.EscapeDataString(query)}&pageSize=200");
            var json = await response.JsonAsync();

            Assert.Multiple(() =>
            {
                Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), query);
                Assert.That(json.GetProperty("items").Strings("code"), Does.Not.Contain($"T-{marker}"), $"« {query} » ne doit pas tout renvoyer.");
            });
        }

        Assert.That((await _admin.GetAsync($"{SiteBase}?q={marker}")).StatusCode, Is.EqualTo(HttpStatusCode.OK));
    }

    [Test]
    public async Task Filter_by_type_and_wilaya()
    {
        var marker = Guid.NewGuid().ToString("N")[..8].ToUpperInvariant();
        await _admin.PostAsync(SiteBase, SiteBody($"T-{marker}-S", b => b["name"] = $"S {marker}"));
        await _admin.PostAsync(SiteBase, SiteBody($"T-{marker}-H", b => { b["name"] = $"H {marker}"; b["type"] = "Housing"; b["wilaya"] = "Alger"; }));

        var housing = (await (await _admin.GetAsync($"{SiteBase}?q={marker}&type=Housing")).JsonAsync()).GetProperty("items").Strings("code");
        var blida = (await (await _admin.GetAsync($"{SiteBase}?q={marker}&wilaya=Blida")).JsonAsync()).GetProperty("items").Strings("code");

        Assert.Multiple(() =>
        {
            Assert.That(housing, Is.EqualTo(new[] { $"T-{marker}-H" }));
            Assert.That(blida, Is.EqualTo(new[] { $"T-{marker}-S" }));
        });
    }

    [Test]
    public async Task Site_response_has_the_contract_shape()
    {
        var created = await (await _admin.PostAsync(SiteBase, SiteBody())).JsonAsync();

        var expected = new[]
        {
            "id", "code", "name", "nameAr", "type", "wilaya", "commune", "latitude", "longitude", "owner", "contractNumber",
            "contractAmount", "delayDays", "odsDate", "contractualEndDate", "archivedAt", "archivedByName", "version",
            "createdAt", "createdByName", "updatedAt", "updatedByName",
        };

        Assert.That(created.EnumerateObject().Select(p => p.Name), Is.EquivalentTo(expected));
    }
}
