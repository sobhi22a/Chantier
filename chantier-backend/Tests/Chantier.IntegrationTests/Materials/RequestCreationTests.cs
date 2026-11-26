using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Materials;
using Chantier.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;
using static Chantier.IntegrationTests.Support.SitesTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>B4, creation (CT-MAT-02, 03, 04) : numero serveur, idempotence du clientId, validations, doublon possible, droits.</summary>
[TestFixture]
public class RequestCreationTests : MaterialsFixtureBase
{
    [Test]
    public async Task A_team_leader_signals_a_need_and_gets_201_with_a_server_number_and_the_status_requested()
    {
        var site = await NewSiteAsync();
        var zone = await Factory.SeedZoneAsync(site.Id);
        var response = await Equipe.PostAsync(RequestsUrl(site.Id), RequestBody(CementId, 300m, "sac", zone, note: "Dalle +10,20", priority: "Blocking"));
        var json = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(response.Headers.Location!.ToString(), Does.Contain($"/requests/{json.Id()}"));
            Assert.That(json.Number(), Is.EqualTo("DEM-001"));
            Assert.That(json.StatusOf(), Is.EqualTo("Requested"));
            Assert.That(json.GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(300m));
            Assert.That(json.GetProperty("quantity").GetProperty("unit").GetString(), Is.EqualTo("sac"));
            Assert.That(json.GetProperty("product").GetProperty("productId").GetGuid(), Is.EqualTo(CementId));
            Assert.That(json.GetProperty("product").GetProperty("name").GetString(), Is.EqualTo(Cement.GetProperty("nameFr").GetString()));
            Assert.That(json.GetProperty("zoneId").GetGuid(), Is.EqualTo(zone));
            Assert.That(json.GetProperty("priority").GetString(), Is.EqualTo("Blocking"));
            Assert.That(json.GetProperty("note").GetString(), Is.EqualTo("Dalle +10,20"));
            Assert.That(json.GetProperty("requestedById").GetGuid(), Is.EqualTo(Equipe.Account.Id));
            Assert.That(json.GetProperty("requestedByName").GetString(), Is.EqualTo(Equipe.Account.FullName));
            Assert.That(json.GetProperty("siteId").GetGuid(), Is.EqualTo(site.Id));
            Assert.That(json.GetProperty("siteCode").GetString(), Is.EqualTo(site.Code));
            Assert.That(json.TryGetProperty("receivedQuantity", out _), Is.False, "pas de recu tant que la demande n'est pas commandee");
            Assert.That(json.GetProperty("isSettled").GetBoolean(), Is.False);
            Assert.That(json.GetProperty("overdueDays").GetInt32(), Is.Zero);
            Assert.That(json.HistoryTypes(), Is.EqualTo(new[] { "Created" }));
        });
    }

    [Test]
    public async Task Numbers_are_per_site_and_continue_without_gap()
    {
        var first = await NewSiteAsync();
        var second = await NewSiteAsync();

        var a1 = await Chef.CreateRequestAsync(first.Id, RequestBody(CementId));
        var a2 = await Chef.CreateRequestAsync(first.Id, RequestBody(CementId, 100m));
        var b1 = await Chef.CreateRequestAsync(second.Id, RequestBody(CementId));

        Assert.Multiple(() =>
        {
            Assert.That(a1.Number(), Is.EqualTo("DEM-001"));
            Assert.That(a2.Number(), Is.EqualTo("DEM-002"));
            Assert.That(b1.Number(), Is.EqualTo("DEM-001"));
        });
    }

    [Test]
    public async Task Resending_the_same_client_id_gives_200_the_same_request_and_no_new_number()
    {
        var site = await NewSiteAsync();
        var clientId = Guid.NewGuid();

        var first = await Chef.PostAsync(RequestsUrl(site.Id), RequestBody(CementId, clientId: clientId));
        var again = await Chef.PostAsync(RequestsUrl(site.Id), RequestBody(CementId, 999m, clientId: clientId));
        var next = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 50m));

        var original = await first.JsonAsync();
        var replay = await again.JsonAsync();
        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(replay.Id(), Is.EqualTo(original.Id()));
            Assert.That(replay.Number(), Is.EqualTo("DEM-001"));
            Assert.That(replay.GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(300m), "le renvoi ne modifie rien");
            Assert.That(next.Number(), Is.EqualTo("DEM-002"), "le renvoi n'a consomme aucun numero");
            Assert.That(await Factory.CountRequestsAsync(site.Id), Is.EqualTo(2));
            Assert.That(await Factory.EventsOfAsync(original.Id()), Has.Count.EqualTo(1));
        });
    }

    [Test]
    public async Task The_same_client_id_is_independent_between_two_sites()
    {
        var first = await NewSiteAsync();
        var second = await NewSiteAsync();
        var clientId = Guid.NewGuid();

        var a = await Chef.CreateRequestAsync(first.Id, RequestBody(CementId, clientId: clientId));
        var b = await Chef.CreateRequestAsync(second.Id, RequestBody(CementId, clientId: clientId));

        Assert.That(a.Id(), Is.Not.EqualTo(b.Id()));
    }

    [Test]
    public async Task Sixty_parallel_creations_give_sixty_distinct_numbers_without_gap()
    {
        var site = await NewSiteAsync();

        var responses = await Task.WhenAll(Enumerable.Range(0, 60).Select(index => (index % 2 == 0 ? Chef : Equipe).PostAsync(RequestsUrl(site.Id), RequestBody(CementId, index + 1))));
        var numbers = new List<int>();
        foreach (var response in responses)
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created), await response.Content.ReadAsStringAsync());
            numbers.Add(int.Parse((await response.JsonAsync()).Number()[4..]));
        }

        Assert.Multiple(async () =>
        {
            Assert.That(numbers.Order(), Is.EqualTo(Enumerable.Range(1, 60)));
            Assert.That(await Factory.CountRequestsAsync(site.Id), Is.EqualTo(60));
        });
    }

    [Test]
    public async Task A_double_tap_sent_ten_times_in_parallel_creates_one_request_and_burns_no_number()
    {
        var site = await NewSiteAsync();
        var body = RequestBody(CementId, clientId: Guid.NewGuid());

        var responses = await Task.WhenAll(Enumerable.Range(0, 10).Select(_ => Chef.PostAsync(RequestsUrl(site.Id), body)));
        var ids = new HashSet<Guid>();
        foreach (var response in responses)
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created).Or.EqualTo(HttpStatusCode.OK));
            ids.Add((await response.JsonAsync()).Id());
        }

        var next = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 5m));
        Assert.Multiple(async () =>
        {
            Assert.That(ids, Has.Count.EqualTo(1));
            Assert.That(responses.Count(response => response.StatusCode == HttpStatusCode.Created), Is.EqualTo(1));
            Assert.That(await Factory.CountRequestsAsync(site.Id), Is.EqualTo(2));
            Assert.That(next.Number(), Is.EqualTo("DEM-002"));
        });
    }

    [Test]
    public async Task The_client_cannot_set_the_status_the_number_or_the_author()
    {
        var site = await NewSiteAsync();
        var body = RequestBody(CementId, overrides: values =>
        {
            values["status"] = "Delivered";
            values["number"] = "DEM-999";
            values["createdBy"] = Admin.Account.Id;
            values["isSettled"] = true;
            values["possibleDuplicateOfId"] = Guid.NewGuid();
            values["receivedQuantity"] = 300;
        });

        var json = await Chef.CreateRequestAsync(site.Id, body);

        Assert.Multiple(() =>
        {
            Assert.That(json.StatusOf(), Is.EqualTo("Requested"));
            Assert.That(json.Number(), Is.EqualTo("DEM-001"));
            Assert.That(json.GetProperty("requestedById").GetGuid(), Is.EqualTo(Chef.Account.Id));
            Assert.That(json.GetProperty("isSettled").GetBoolean(), Is.False);
            Assert.That(json.GetProperty("possibleDuplicateOf").ValueKind, Is.EqualTo(JsonValueKind.Null));
        });
    }

    // --- Validations ---

    [Test]
    public async Task A_quantity_without_a_unit_is_refused_with_UNITE_OBLIGATOIRE()
    {
        var response = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, 300m, unit: null));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("UNITE_OBLIGATOIRE"));
        });
    }

    [Test]
    public async Task A_missing_quantity_is_a_400_and_a_free_text_unit_is_a_400()
    {
        var missing = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, overrides: body => body["quantity"] = null));
        var freeText = await Chef.PostRawAsync(RequestsUrl(Site.Id), $$"""{"productId":"{{CementId}}","quantity":{"value":3,"unit":"boite"},"neededBy":"{{FutureDate()}}"}""");

        Assert.Multiple(() =>
        {
            Assert.That(missing.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(freeText.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest), "l'unite vient du referentiel, jamais du texte libre");
        });
    }

    [TestCase(0, "sac", "QUANTITE_INVALIDE")]
    [TestCase(-5, "kg", "QUANTITE_INVALIDE")]
    [TestCase(0.0004, "t", "QUANTITE_INVALIDE")]
    [TestCase(2.5, "sac", "QUANTITE_ENTIERE_REQUISE")]
    public async Task An_invalid_quantity_is_refused_with_its_business_code(double value, string unit, string code)
    {
        var response = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, (decimal)value, unit));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo(code));
        });
    }

    [TestCase(2.5, "kg")]
    [TestCase(0.125, "t")]
    public async Task Up_to_three_decimals_are_accepted_for_a_weight(double value, string unit)
    {
        var response = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, (decimal)value, unit));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
    }

    [TestCase("../12/2026")]
    [TestCase("31/11/2026")]
    [TestCase("2026-11-31")]
    [TestCase("2026-12")]
    [TestCase("demain")]
    public async Task An_incomplete_or_impossible_date_is_refused_with_DATE_INVALIDE(string neededBy)
    {
        var response = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, neededBy: neededBy));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(await CodeOf(response), Is.EqualTo("DATE_INVALIDE"));
        });
    }

    [Test]
    public async Task A_missing_date_is_refused_and_a_past_date_is_accepted()
    {
        var missing = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, overrides: body => body["neededBy"] = null));
        var past = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, neededBy: "2026-01-05"));

        Assert.Multiple(async () =>
        {
            Assert.That(missing.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(await CodeOf(missing), Is.EqualTo("DATE_INVALIDE"));
            Assert.That(past.StatusCode, Is.EqualTo(HttpStatusCode.Created), "une date passee n'est qu'un avertissement cote client");
        });
    }

    [Test]
    public async Task A_unit_outside_the_allowed_units_of_the_product_is_refused()
    {
        var response = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(SteelId, 2m, "sac"));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("UNITE_NON_AUTORISEE"));
        });
    }

    [Test]
    public async Task A_deactivated_product_cannot_be_requested_any_more()
    {
        var product = await Admin.CreateProductAsync();
        await Admin.PostAsync($"{Products}/{product.Id()}/deactivate");

        var response = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(product.Id()));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("PRODUIT_INACTIF"));
        });
    }

    [Test]
    public async Task An_unknown_product_is_a_400_and_a_zone_of_another_site_is_refused()
    {
        var other = await NewSiteAsync();
        var foreignZone = await Factory.SeedZoneAsync(other.Id, "Bloc 09");

        var unknown = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(Guid.NewGuid()));
        var wrongZone = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, zoneId: foreignZone));
        var ghostZone = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, zoneId: Guid.NewGuid()));

        Assert.Multiple(async () =>
        {
            Assert.That(unknown.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(wrongZone.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(wrongZone), Is.EqualTo("ZONE_HORS_CHANTIER"));
            Assert.That(await CodeOf(ghostZone), Is.EqualTo("ZONE_HORS_CHANTIER"));
        });
    }

    [Test]
    public async Task Exactly_one_of_a_catalogue_product_or_a_free_name_is_required_and_the_free_name_has_three_to_one_hundred_characters()
    {
        var neither = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(null, unit: "u"));
        var both = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, freeName: "Ciment maison"));
        var tooShort = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(null, 4m, "u", freeName: "ab"));
        var tooLong = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(null, 4m, "u", freeName: new string('x', 101)));
        var free = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(null, 4m, "u", freeName: "  Poignées de porte  "));
        var json = await free.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(neither.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(both.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(tooShort.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(tooLong.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(free.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(json.GetProperty("product").GetProperty("freeName").GetString(), Is.EqualTo("Poignées de porte"));
            Assert.That(json.GetProperty("product").GetProperty("productId").ValueKind, Is.EqualTo(JsonValueKind.Null));
        });
    }

    [Test]
    public async Task A_note_longer_than_two_hundred_characters_is_refused()
    {
        var response = await Chef.PostAsync(RequestsUrl(Site.Id), RequestBody(CementId, note: new string('n', 201)));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
    }

    [Test]
    public async Task An_archived_site_is_read_only_but_a_replay_of_a_known_client_id_still_answers()
    {
        var site = await NewSiteAsync();
        var clientId = Guid.NewGuid();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, clientId: clientId));
        await using (var scope = Factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<Chantier.Infrastructure.Persistence.ApplicationDbContext>();
            var entity = await db.Sites.FindAsync(site.Id);
            entity!.Archive(SystemActorId, DateTimeOffset.UtcNow);
            await db.SaveChangesAsync();
        }

        var fresh = await Chef.PostAsync(RequestsUrl(site.Id), RequestBody(CementId));
        var replay = await Chef.PostAsync(RequestsUrl(site.Id), RequestBody(CementId, clientId: clientId));
        var read = await Chef.GetAsync(RequestUrl(site.Id, created.Id()));

        Assert.Multiple(async () =>
        {
            Assert.That(fresh.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(fresh), Is.EqualTo("CHANTIER_ARCHIVE"));
            Assert.That(replay.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(read.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    // --- Doublon possible ---

    [Test]
    public async Task A_second_open_request_for_the_same_product_and_zone_carries_a_possible_duplicate_without_being_blocked()
    {
        var site = await NewSiteAsync();
        var zone = await Factory.SeedZoneAsync(site.Id);
        var first = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, zoneId: zone));

        var second = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 100m, zoneId: zone));
        var otherZone = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 100m, zoneId: await Factory.SeedZoneAsync(site.Id, "Bloc 02")));
        var noZone = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 100m));
        var otherProduct = await Chef.CreateRequestAsync(site.Id, RequestBody(SteelId, 1m, "t", zone));

        Assert.Multiple(() =>
        {
            Assert.That(second.GetProperty("possibleDuplicateOf").GetProperty("id").GetGuid(), Is.EqualTo(first.Id()));
            Assert.That(second.GetProperty("possibleDuplicateOf").GetProperty("number").GetString(), Is.EqualTo(first.Number()));
            Assert.That(otherZone.GetProperty("possibleDuplicateOf").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(noZone.GetProperty("possibleDuplicateOf").ValueKind, Is.EqualTo(JsonValueKind.Null), "« sans zone » n'est pas la zone du premier");
            Assert.That(otherProduct.GetProperty("possibleDuplicateOf").ValueKind, Is.EqualTo(JsonValueKind.Null));
        });
    }

    [Test]
    public async Task A_closed_request_is_not_a_duplicate()
    {
        var site = await NewSiteAsync();
        var first = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));
        await Chef.PostAsync($"{RequestUrl(site.Id, first.Id())}/cancel", new { reasonCode = "EntryError" });

        var second = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));

        Assert.That(second.GetProperty("possibleDuplicateOf").ValueKind, Is.EqualTo(JsonValueKind.Null));
    }

    // --- Droits ---

    [Test]
    public async Task Create_is_allowed_for_admin_conducteur_chef_chantier_and_chef_equipe_only()
    {
        var site = await NewSiteAsync();
        var expected = new Dictionary<ApiSession, bool>
        {
            [Admin] = true,
            [Conducteur] = true,
            [Chef] = true,
            [Equipe] = true,
            [Direction] = false,
            [Achats] = false,
        };

        foreach (var (session, allowed) in expected)
        {
            var response = await session.PostAsync(RequestsUrl(site.Id), RequestBody(CementId));
            Assert.That(response.StatusCode, allowed ? Is.EqualTo(HttpStatusCode.Created) : Is.EqualTo(HttpStatusCode.Forbidden), session.Account.Role);
        }

        Assert.That(await Factory.CountRequestsAsync(site.Id), Is.EqualTo(4), "un refus n'ecrit rien");
    }

    [Test]
    public async Task An_anonymous_call_is_a_401()
    {
        using var anonymous = Factory.CreateClient();

        var response = await anonymous.PostAsJsonAsync(RequestsUrl(Site.Id), RequestBody(CementId));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
    }

    [Test]
    public async Task A_site_where_the_user_is_not_assigned_is_a_404_identical_to_an_unknown_site_even_with_an_invalid_body()
    {
        var outsider = await NewSiteAsync();
        var lonely = await Factory.SignInAsync(RoleNames.ChefChantier);

        var notAssigned = await lonely.PostAsync(RequestsUrl(outsider.Id), RequestBody(CementId));
        var unknown = await lonely.PostAsync(RequestsUrl(Guid.NewGuid()), RequestBody(CementId));
        var invalidBody = await lonely.PostAsync(RequestsUrl(outsider.Id), new { });

        Assert.Multiple(async () =>
        {
            Assert.That(notAssigned.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(
                AuthTestHelpers.WithoutTraceId(await notAssigned.JsonAsync()),
                Is.EqualTo(AuthTestHelpers.WithoutTraceId(await unknown.JsonAsync())));
            Assert.That(invalidBody.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "un corps invalide ne revele pas l'existence du chantier");
        });
    }
}
