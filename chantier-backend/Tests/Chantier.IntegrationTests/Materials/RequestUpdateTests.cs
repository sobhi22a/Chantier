using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>B4, modification (CT-MAT-06) : droits « la sienne », verrouillage apres validation, version, historique « ancienne -> nouvelle valeur ».</summary>
[TestFixture]
public class RequestUpdateTests : MaterialsFixtureBase
{
    private string Url(Guid requestId) => RequestUrl(Site.Id, requestId);

    private async Task<JsonElement> NewRequestAsync(ApiSession author, decimal value = 300m, string unit = "sac", string? note = null)
        => await author.CreateRequestAsync(Site.Id, RequestBody(CementId, value, unit, ZoneId, note: note));

    private static Dictionary<string, object?> Edit(JsonElement request, Action<Dictionary<string, object?>> change)
    {
        var body = new Dictionary<string, object?> { ["version"] = request.Version() };
        change(body);
        return body;
    }

    [Test]
    public async Task The_author_edits_a_requested_request_and_the_history_keeps_old_and_new_values()
    {
        var created = await NewRequestAsync(Equipe);
        var newDate = FutureDate(10);

        var response = await Equipe.PutAsync(Url(created.Id()), Edit(created, body =>
        {
            body["quantity"] = new { value = 400, unit = "sac" };
            body["neededBy"] = newDate;
            body["priority"] = "Urgent";
            body["note"] = "Dalle haute";
        }));
        var json = await response.JsonAsync();
        var changes = json.GetProperty("history").EnumerateArray().Last().GetProperty("changes").EnumerateArray()
            .ToDictionary(change => change.GetProperty("field").GetString()!);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(json.GetProperty("quantity").GetProperty("value").GetDecimal(), Is.EqualTo(400m));
            Assert.That(json.GetProperty("neededBy").GetString(), Is.EqualTo(newDate));
            Assert.That(json.GetProperty("priority").GetString(), Is.EqualTo("Urgent"));
            Assert.That(json.Version(), Is.Not.EqualTo(created.Version()));
            Assert.That(json.HistoryTypes(), Is.EqualTo(new[] { "Created", "Edited" }));
            Assert.That(changes.Keys, Is.EquivalentTo(new[] { "quantity", "neededBy", "priority", "note" }));
            Assert.That(changes["quantity"].GetProperty("old").GetString(), Is.EqualTo("300 sac"));
            Assert.That(changes["quantity"].GetProperty("new").GetString(), Is.EqualTo("400 sac"));
            Assert.That(changes["priority"].GetProperty("old").GetString(), Is.EqualTo("Normal"));
            Assert.That(changes["priority"].GetProperty("new").GetString(), Is.EqualTo("Urgent"));
            Assert.That(json.GetProperty("updatedByName").GetString(), Is.EqualTo(Equipe.Account.FullName));
        });
    }

    [Test]
    public async Task Sending_the_same_values_changes_nothing_and_writes_no_event()
    {
        var created = await NewRequestAsync(Chef, note: "Dalle");

        var response = await Chef.PutAsync(Url(created.Id()), Edit(created, body =>
        {
            body["quantity"] = new { value = 300, unit = "sac" };
            body["note"] = "Dalle";
        }));
        var json = await response.JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(json.Version(), Is.EqualTo(created.Version()), "aucune ecriture, la version ne bouge pas");
            Assert.That(await Factory.EventsOfAsync(created.Id()), Has.Count.EqualTo(1));
        });
    }

    [Test]
    public async Task A_stale_version_gives_409_with_the_current_state_and_a_missing_version_gives_400()
    {
        var created = await NewRequestAsync(Chef);
        await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["note"] = "Premiere"));

        var stale = await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["note"] = "Seconde"));
        var missing = await Chef.PutAsync(Url(created.Id()), new { note = "x" });
        var json = await stale.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(stale.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
            Assert.That(json.GetProperty("code").GetString(), Is.EqualTo("CONFLIT_VERSION"));
            Assert.That(json.GetProperty("current").GetProperty("note").GetString(), Is.EqualTo("Premiere"));
            Assert.That(json.GetProperty("current").GetProperty("history").GetArrayLength(), Is.EqualTo(2));
            Assert.That(missing.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    [Test]
    public async Task Two_parallel_edits_with_the_same_version_give_one_success_and_one_conflict()
    {
        var created = await NewRequestAsync(Chef);

        var responses = await Task.WhenAll(
            Chef.PutAsync(Url(created.Id()), Edit(created, body => body["note"] = "A")),
            Conducteur.PutAsync(Url(created.Id()), Edit(created, body => body["note"] = "B")),
            Chef.PutAsync(Url(created.Id()), Edit(created, body => body["note"] = "C")));

        var statuses = responses.Select(response => response.StatusCode).OrderBy(status => status).ToList();
        Assert.That(statuses, Is.EqualTo(new[] { HttpStatusCode.OK, HttpStatusCode.Conflict, HttpStatusCode.Conflict }));
    }

    [Test]
    public async Task After_validation_the_product_quantity_unit_and_zone_are_locked_but_date_priority_and_note_stay_editable()
    {
        var created = await NewRequestAsync(Chef);
        var approved = await (await Conducteur.PostAsync(Url(created.Id()) + "/approve")).JsonAsync();
        var otherZone = await Factory.SeedZoneAsync(Site.Id, "Bloc 07");

        var quantity = await Chef.PutAsync(Url(created.Id()), Edit(approved, body => body["quantity"] = new { value = 400, unit = "sac" }));
        var unit = await Chef.PutAsync(Url(created.Id()), Edit(approved, body => body["quantity"] = new { value = 15, unit = "t" }));
        var product = await Chef.PutAsync(Url(created.Id()), Edit(approved, body => body["productId"] = SteelId));
        var zone = await Chef.PutAsync(Url(created.Id()), Edit(approved, body => body["zoneId"] = otherZone));
        var allowed = await Chef.PutAsync(Url(created.Id()), Edit(approved, body =>
        {
            body["neededBy"] = FutureDate(20);
            body["priority"] = "Blocking";
            body["note"] = "Camion bloque";
        }));

        Assert.Multiple(async () =>
        {
            foreach (var locked in new[] { quantity, unit, product, zone })
            {
                Assert.That(locked.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
                Assert.That(await CodeOf(locked), Is.EqualTo("DEMANDE_VERROUILLEE"));
            }

            Assert.That(allowed.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await allowed.JsonAsync()).GetProperty("priority").GetString(), Is.EqualTo("Blocking"));
        });
    }

    [Test]
    public async Task A_team_member_cannot_edit_his_own_request_after_validation_and_not_a_colleagues_before()
    {
        var own = await NewRequestAsync(Equipe);
        var colleague = await NewRequestAsync(Chef);
        var approved = await (await Conducteur.PostAsync(Url(own.Id()) + "/approve")).JsonAsync();

        var afterValidation = await Equipe.PutAsync(Url(own.Id()), Edit(approved, body => body["note"] = "tard"));
        var onColleague = await Equipe.PutAsync(Url(colleague.Id()), Edit(colleague, body => body["note"] = "intrus"));

        Assert.Multiple(() =>
        {
            Assert.That(afterValidation.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden), "date, urgence et remarque apres validation : UpdateAny");
            Assert.That(onColleague.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
        });
    }

    [Test]
    public async Task The_chef_chantier_and_the_conducteur_edit_the_requests_of_the_team()
    {
        var created = await NewRequestAsync(Equipe);

        var byChef = await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["note"] = "vue par le chef"));
        var refreshed = await byChef.JsonAsync();
        var byConducteur = await Conducteur.PutAsync(Url(created.Id()), Edit(refreshed, body => body["priority"] = "Urgent"));

        Assert.Multiple(() =>
        {
            Assert.That(byChef.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(byConducteur.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    [Test]
    public async Task Direction_and_achats_never_edit_a_request()
    {
        var created = await NewRequestAsync(Chef);

        var direction = await Direction.PutAsync(Url(created.Id()), Edit(created, body => body["note"] = "x"));
        var achats = await Achats.PutAsync(Url(created.Id()), Edit(created, body => body["note"] = "x"));

        Assert.Multiple(() =>
        {
            Assert.That(direction.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(achats.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
        });
    }

    [TestCase(RequestStatus.Delivered)]
    [TestCase(RequestStatus.Received)]
    [TestCase(RequestStatus.Rejected)]
    [TestCase(RequestStatus.Cancelled)]
    public async Task A_delivered_or_closed_request_cannot_be_edited(RequestStatus status)
    {
        var created = await NewRequestAsync(Chef);
        await Factory.SetStatusAsync(created.Id(), status);
        var fresh = await (await Chef.GetAsync(Url(created.Id()))).JsonAsync();

        var response = await Chef.PutAsync(Url(created.Id()), Edit(fresh, body => body["note"] = "tard"));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("TRANSITION_INTERDITE"));
        });
    }

    [Test]
    public async Task An_edit_runs_the_same_validations_as_a_creation()
    {
        var created = await NewRequestAsync(Chef);
        var foreignZone = await Factory.SeedZoneAsync((await NewSiteAsync()).Id);

        var results = new Dictionary<string, (HttpResponseMessage Response, string Code)>
        {
            ["unite hors liste"] = (await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["quantity"] = new { value = 3, unit = "m3" })), "UNITE_NON_AUTORISEE"),
            ["quantite nulle"] = (await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["quantity"] = new { value = 0, unit = "sac" })), "QUANTITE_INVALIDE"),
            ["sac decimal"] = (await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["quantity"] = new { value = 2.5, unit = "sac" })), "QUANTITE_ENTIERE_REQUISE"),
            ["sans unite"] = (await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["quantity"] = new { value = 5 })), "UNITE_OBLIGATOIRE"),
            ["date impossible"] = (await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["neededBy"] = "31/11/2026")), "DATE_INVALIDE"),
            ["zone d'un autre chantier"] = (await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["zoneId"] = foreignZone)), "ZONE_HORS_CHANTIER"),
        };

        Assert.Multiple(async () =>
        {
            foreach (var (name, (response, code)) in results)
            {
                Assert.That(await CodeOf(response), Is.EqualTo(code), name);
            }

            Assert.That((await (await Chef.GetAsync(Url(created.Id()))).JsonAsync()).Version(), Is.EqualTo(created.Version()), "aucun refus n'a ecrit");
        });
    }

    [Test]
    public async Task The_product_can_be_swapped_for_a_free_name_and_back_and_an_empty_note_clears_it()
    {
        var created = await NewRequestAsync(Chef, note: "Dalle");

        var toFree = await (await Chef.PutAsync(Url(created.Id()), Edit(created, body =>
        {
            body["freeProductName"] = "Ciment special";
            body["quantity"] = new { value = 300, unit = "sac" };
            body["note"] = string.Empty;
        }))).JsonAsync();
        var back = await (await Chef.PutAsync(Url(created.Id()), Edit(toFree, body => body["productId"] = CementId))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(toFree.GetProperty("product").GetProperty("productId").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(toFree.GetProperty("product").GetProperty("freeName").GetString(), Is.EqualTo("Ciment special"));
            Assert.That(toFree.GetProperty("note").ValueKind, Is.EqualTo(JsonValueKind.Null));
            Assert.That(back.GetProperty("product").GetProperty("productId").GetGuid(), Is.EqualTo(CementId));
            Assert.That(back.GetProperty("product").GetProperty("freeName").ValueKind, Is.EqualTo(JsonValueKind.Null));
        });
    }

    [Test]
    public async Task A_product_deactivated_since_does_not_block_a_correction_of_the_date()
    {
        var product = await Admin.CreateProductAsync();
        var created = await Chef.CreateRequestAsync(Site.Id, RequestBody(product.Id()));
        await Admin.PostAsync($"{Products}/{product.Id()}/deactivate");

        var response = await Chef.PutAsync(Url(created.Id()), Edit(created, body => body["neededBy"] = FutureDate(15)));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
    }

    [Test]
    public async Task A_request_of_another_site_is_a_404_on_this_sites_route()
    {
        var other = await NewSiteAsync();
        var foreign = await Chef.CreateRequestAsync(other.Id, RequestBody(CementId));

        var read = await Chef.GetAsync(Url(foreign.Id()));
        var edit = await Chef.PutAsync(Url(foreign.Id()), Edit(foreign, body => body["note"] = "x"));
        var approve = await Conducteur.PostAsync(Url(foreign.Id()) + "/approve");
        var unknown = await Chef.GetAsync(Url(Guid.NewGuid()));

        Assert.Multiple(async () =>
        {
            Assert.That(read.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(edit.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(approve.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(AuthTestHelpers.WithoutTraceId(await read.JsonAsync()), Is.EqualTo(AuthTestHelpers.WithoutTraceId(await unknown.JsonAsync())));
        });
    }
}
