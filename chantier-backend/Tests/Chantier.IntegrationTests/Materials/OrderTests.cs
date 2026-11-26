using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>B5, commandes (CT-MAT-07, 09, 12, 14, 15) : montant, idempotence, doublon, droits par role, prix absents du terrain, annulation, concurrence.</summary>
[TestFixture]
public class OrderTests : DeliveryFixtureBase
{
    private async Task<JsonElement> OrderedAsync(decimal value = 600m, decimal? price = 780m, DateOnly? expected = null)
    {
        var id = await ValidatedAsync(value);
        var response = await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId, price, expected: expected));
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created), await response.Content.ReadAsStringAsync());
        return await response.JsonAsync();
    }

    [Test]
    public async Task Ordering_a_validated_request_computes_the_amount_and_moves_it_to_ordered()
    {
        var id = await ValidatedAsync(300m);

        var response = await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId, 780m));
        var json = await response.JsonAsync();
        var commercial = json.GetProperty("order").GetProperty("commercial");

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(json.StatusOf(), Is.EqualTo("Ordered"));
            Assert.That(commercial.GetProperty("amount").GetDecimal(), Is.EqualTo(234000.00m), "300 sacs x 780,00");
            Assert.That(commercial.GetProperty("unitPrice").GetDecimal(), Is.EqualTo(780m));
            Assert.That(commercial.GetProperty("purchaseOrderNumber").GetString(), Is.EqualTo("BC-2026-044"));
            Assert.That(json.GetProperty("order").GetProperty("supplierId").GetGuid(), Is.EqualTo(SupplierId));
            Assert.That(json.GetProperty("quantity").GetProperty("unit").GetString(), Is.EqualTo("sac"), "quantite et unite de la demande");
            Assert.That(json.HistoryTypes(), Is.EqualTo(new[] { "Created", "Approved", "Ordered" }));
        });
    }

    [Test]
    public async Task The_amount_rounds_away_from_zero()
    {
        var id = await Chef.NewRequestIdAsync(Site.Id, SteelId, 2.5m, "kg");
        await Conducteur.PostAsync($"{RequestUrl(Site.Id, id)}/approve");

        var json = await (await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId, 245.25m))).JsonAsync();

        Assert.That(json.GetProperty("order").GetProperty("commercial").GetProperty("amount").GetDecimal(), Is.EqualTo(613.13m), "2,5 x 245,25 = 613,125 -> 613,13 (jamais l'arrondi bancaire)");
    }

    [Test]
    public async Task The_price_is_optional_but_must_be_positive_when_given()
    {
        var withoutPrice = await ValidatedAsync();
        var zero = await ValidatedAsync();
        var tooPrecise = await ValidatedAsync();

        var none = await Achats.PostAsync(OrderUrl(Site.Id, withoutPrice), OrderBody(SupplierId, null));
        var refusedZero = await Achats.PostAsync(OrderUrl(Site.Id, zero), OrderBody(SupplierId, 0m));
        var refusedPrecision = await Achats.PostAsync(OrderUrl(Site.Id, tooPrecise), OrderBody(SupplierId, 10.123m));

        Assert.Multiple(async () =>
        {
            Assert.That(none.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That((await none.JsonAsync()).GetProperty("order").GetProperty("commercial").TryGetProperty("amount", out _), Is.False, "sans prix : pas de montant");
            Assert.That(refusedZero.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(refusedPrecision.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    [Test]
    public async Task Ordering_validates_the_supplier_and_the_dates()
    {
        var inactive = (await Admin.CreateSupplierAsync()).Id();
        await Admin.PostAsync($"{Suppliers}/{inactive}/deactivate");
        var today = Factory.Today();

        var results = new Dictionary<string, (HttpResponseMessage Response, string Code)>
        {
            ["fournisseur inactif"] = (await Achats.PostAsync(OrderUrl(Site.Id, await ValidatedAsync()), OrderBody(inactive)), "FOURNISSEUR_INACTIF"),
            ["date de commande dans le futur"] = (await Achats.PostAsync(OrderUrl(Site.Id, await ValidatedAsync()), OrderBody(SupplierId, orderDate: today.AddDays(2))), "DATE_INVALIDE"),
            ["livraison prevue avant la commande"] = (await Achats.PostAsync(OrderUrl(Site.Id, await ValidatedAsync()), OrderBody(SupplierId, orderDate: today, expected: today.AddDays(-1))), "DATE_INVALIDE"),
            ["fournisseur absent"] = (await Achats.PostAsync(OrderUrl(Site.Id, await ValidatedAsync()), OrderBody(Guid.Empty)), "VALIDATION"),
        };

        Assert.Multiple(async () =>
        {
            foreach (var (name, (response, code)) in results)
            {
                Assert.That(await CodeOf(response), Is.EqualTo(code), name);
            }

            Assert.That(results["fournisseur inactif"].Response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(results["date de commande dans le futur"].Response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    [Test]
    public async Task A_planned_delivery_after_the_need_date_is_a_warning_not_a_refusal()
    {
        var id = await Chef.NewRequestIdAsync(Site.Id, CementId, 100m, "sac");
        var needed = Factory.Today().AddDays(3);
        await Chef.PutAsync(RequestUrl(Site.Id, id), new { version = (await (await Chef.GetAsync(RequestUrl(Site.Id, id))).JsonAsync()).Version(), neededBy = Iso(needed) });
        await Conducteur.PostAsync($"{RequestUrl(Site.Id, id)}/approve");

        var json = await (await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId, expected: needed.AddDays(2)))).JsonAsync();

        Assert.That(json.GetProperty("order").GetProperty("plannedAfterNeedDays").GetInt32(), Is.EqualTo(2));
    }

    [Test]
    public async Task Only_a_validated_request_can_be_ordered()
    {
        var requested = await Chef.NewRequestIdAsync(Site.Id, CementId);
        var rejected = await Chef.NewRequestIdAsync(Site.Id, CementId);
        await Factory.SetStatusAsync(rejected, RequestStatus.Rejected);

        var first = await Achats.PostAsync(OrderUrl(Site.Id, requested), OrderBody(SupplierId));
        var second = await Achats.PostAsync(OrderUrl(Site.Id, rejected), OrderBody(SupplierId));

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(first), Is.EqualTo("TRANSITION_INTERDITE"));
            Assert.That(await CodeOf(second), Is.EqualTo("TRANSITION_INTERDITE"));
        });
    }

    [Test]
    public async Task The_same_client_id_gives_the_same_order_and_another_one_is_refused()
    {
        var id = await ValidatedAsync();
        var clientId = Guid.NewGuid();

        var first = await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId, clientId: clientId));
        var again = await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId, clientId: clientId));
        var other = await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId));

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(other.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(other), Is.EqualTo("COMMANDE_EXISTANTE"));
            Assert.That((await again.JsonAsync()).HistoryTypes().Count(type => type == "Ordered"), Is.EqualTo(1), "aucun nouvel effet");
        });
    }

    [Test]
    public async Task Two_simultaneous_orders_make_exactly_one_order()
    {
        var id = await ValidatedAsync();

        var responses = await Task.WhenAll(Enumerable.Range(0, 6).Select(_ => Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId))));

        Assert.Multiple(() =>
        {
            Assert.That(responses.Count(response => response.StatusCode == HttpStatusCode.Created), Is.EqualTo(1));
            Assert.That(responses.Count(response => response.StatusCode == HttpStatusCode.UnprocessableEntity), Is.EqualTo(5));
        });
        Assert.That((await (await Achats.GetAsync(RequestUrl(Site.Id, id))).JsonAsync()).HistoryTypes().Count(type => type == "Ordered"), Is.EqualTo(1));
    }

    [Test]
    public async Task Only_purchasing_and_admin_can_order_modify_and_cancel_and_nothing_is_written_otherwise()
    {
        var id = await ValidatedAsync();
        var body = OrderBody(SupplierId);

        var forbidden = new[] { Conducteur, Direction, Chef, Equipe };
        var statuses = new List<HttpStatusCode>();
        foreach (var session in forbidden)
        {
            statuses.Add((await session.PostAsync(OrderUrl(Site.Id, id), body)).StatusCode);
            statuses.Add((await session.PutAsync(OrderUrl(Site.Id, id), new { version = "1", note = "x" })).StatusCode);
            statuses.Add((await session.PostAsync($"{OrderUrl(Site.Id, id)}/cancel", new { reasonCode = "PriceRefused" })).StatusCode);
        }

        var anonymous = await Factory.CreateClient().PostAsJsonAsync(OrderUrl(Site.Id, id), body);
        var admin = await Admin.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId));

        Assert.Multiple(() =>
        {
            Assert.That(statuses, Is.All.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(anonymous.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(admin.StatusCode, Is.EqualTo(HttpStatusCode.Created), "l'Admin commande");
        });
    }

    [Test]
    public async Task An_order_on_a_site_the_user_is_not_assigned_to_is_not_found()
    {
        var other = await Factory.SeedSiteAsync();

        var response = await Achats.PostAsync(OrderUrl(other.Id, Guid.NewGuid()), OrderBody(SupplierId));
        var missing = await Achats.PostAsync(OrderUrl(Guid.NewGuid(), Guid.NewGuid()), OrderBody(SupplierId));

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(await response.Content.ReadAsStringAsync(), Does.Not.Contain(other.Id.ToString()));
            Assert.That(missing.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(await CodeOf(missing), Is.EqualTo("INTROUVABLE"));
        });
    }

    [Test]
    public async Task A_request_of_another_site_cannot_be_ordered_through_this_site()
    {
        var other = await NewSiteAsync();
        var foreign = await Chef.NewRequestIdAsync(other.Id, CementId);
        await Conducteur.PostAsync($"{RequestUrl(other.Id, foreign)}/approve");

        var response = await Achats.PostAsync(OrderUrl(Site.Id, foreign), OrderBody(SupplierId));

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
    }

    // --- Prix reserves (CT-MAT-12) ---

    [Test]
    public async Task Prices_never_reach_the_field_roles_on_any_route()
    {
        var ordered = await OrderedAsync(600m, 780m, Factory.Today().AddDays(1));
        var id = ordered.Id();
        await Factory.SeedDeliveryRowAsync(Site.Id, id, 100m);
        await Achats.PutAsync(OrderUrl(Site.Id, id), new { version = ordered.GetProperty("order").Version(), unitPrice = 800m });

        var banned = new[] { "unitPrice", "\"amount\"", "receivedValue", "purchaseOrderNumber", "commercial", "OrderCommercialEdited", "orderedAmount", "BC-2026-044" };
        var urls = new[]
        {
            RequestUrl(Site.Id, id), RequestsUrl(Site.Id), $"/api/v1/requests?siteId={Site.Id}", DeliveriesUrl(Site.Id), FollowUpUrl(Site.Id),
            $"/api/v1/sync/changes?siteId={Site.Id}&limit=500",
        };

        foreach (var session in new[] { Chef, Equipe })
        {
            foreach (var url in urls)
            {
                var text = await (await session.GetAsync(url)).Content.ReadAsStringAsync();
                Assert.That(banned.Where(text.Contains), Is.Empty, $"{session.Account.UserName} {url}");
            }
        }

        var withPrices = await (await Conducteur.GetAsync(RequestUrl(Site.Id, id))).Content.ReadAsStringAsync();
        Assert.Multiple(() =>
        {
            Assert.That(withPrices, Does.Contain("commercial"));
            Assert.That(withPrices, Does.Contain("OrderCommercialEdited"));
        });
    }

    [Test]
    public async Task The_field_roles_still_see_the_supplier_the_planned_date_and_the_status()
    {
        var id = (await OrderedAsync(600m, 780m, Factory.Today().AddDays(2))).Id();

        var json = await (await Chef.GetAsync(RequestUrl(Site.Id, id))).JsonAsync();
        var order = json.GetProperty("order");

        Assert.Multiple(() =>
        {
            Assert.That(json.StatusOf(), Is.EqualTo("Ordered"));
            Assert.That(order.GetProperty("supplierId").GetGuid(), Is.EqualTo(SupplierId));
            Assert.That(order.GetProperty("supplierName").GetString(), Is.Not.Empty);
            Assert.That(order.GetProperty("expectedDeliveryDate").GetString(), Is.EqualTo(Iso(Factory.Today().AddDays(2))));
            Assert.That(order.TryGetProperty("commercial", out _), Is.False);
        });
    }

    // --- Modification et annulation ---

    [Test]
    public async Task Changing_the_price_recomputes_the_amount_and_keeps_the_old_value_in_the_sensitive_history()
    {
        var ordered = await OrderedAsync(300m, 780m);
        var id = ordered.Id();

        var response = await Achats.PutAsync(OrderUrl(Site.Id, id), new { version = ordered.GetProperty("order").Version(), unitPrice = 800m });
        var json = await response.JsonAsync();
        var edit = json.GetProperty("history").EnumerateArray().Single(item => item.GetProperty("type").GetString() == "OrderCommercialEdited");
        var change = edit.GetProperty("changes")[0];

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), json.ToString());
            Assert.That(json.GetProperty("order").GetProperty("commercial").GetProperty("amount").GetDecimal(), Is.EqualTo(240000.00m));
            Assert.That(change.GetProperty("old").GetString(), Is.EqualTo("780.00"));
            Assert.That(change.GetProperty("new").GetString(), Is.EqualTo("800.00"));
        });
    }

    [Test]
    public async Task A_non_commercial_change_is_visible_to_the_field_in_the_history()
    {
        var ordered = await OrderedAsync(300m);
        var id = ordered.Id();
        var newSupplier = (await Admin.CreateSupplierAsync()).Id();

        await Achats.PutAsync(OrderUrl(Site.Id, id), new { version = ordered.GetProperty("order").Version(), supplierId = newSupplier, note = "Camion benne" });
        var json = await (await Chef.GetAsync(RequestUrl(Site.Id, id))).JsonAsync();

        Assert.That(json.HistoryTypes(), Does.Contain("OrderEdited"));
    }

    [Test]
    public async Task A_stale_version_gives_a_conflict_with_the_current_state()
    {
        var ordered = await OrderedAsync(300m);
        var id = ordered.Id();
        var version = ordered.GetProperty("order").Version();
        await Achats.PutAsync(OrderUrl(Site.Id, id), new { version, note = "premiere modification" });

        var stale = await Achats.PutAsync(OrderUrl(Site.Id, id), new { version, note = "seconde modification" });

        Assert.Multiple(async () =>
        {
            Assert.That(stale.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
            Assert.That(await CodeOf(stale), Is.EqualTo("CONFLIT_VERSION"));
            Assert.That((await stale.JsonAsync()).GetProperty("current").GetProperty("order").GetProperty("note").GetString(), Is.EqualTo("premiere modification"));
        });
    }

    [Test]
    public async Task A_delivered_request_no_longer_accepts_an_order_change()
    {
        var ordered = await OrderedAsync(100m);
        var id = ordered.Id();
        await Factory.SetStatusAsync(id, RequestStatus.Delivered);

        var response = await Achats.PutAsync(OrderUrl(Site.Id, id), new { version = ordered.GetProperty("order").Version(), note = "trop tard" });

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(response), Is.EqualTo("TRANSITION_INTERDITE"));
        });
    }

    [Test]
    public async Task Cancelling_an_order_without_delivery_returns_the_request_to_validated_and_allows_a_new_order()
    {
        var id = (await OrderedAsync(300m)).Id();

        var cancelled = await Achats.PostAsync($"{OrderUrl(Site.Id, id)}/cancel", new { reasonCode = "SupplierUnavailable" });
        var json = await cancelled.JsonAsync();
        var again = await Achats.PostAsync($"{OrderUrl(Site.Id, id)}/cancel", new { reasonCode = "SupplierUnavailable" });
        var reordered = await Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId));

        Assert.Multiple(async () =>
        {
            Assert.That(cancelled.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(json.StatusOf(), Is.EqualTo("Validated"));
            Assert.That(json.GetProperty("order").ValueKind, Is.EqualTo(JsonValueKind.Null), "une commande annulee n'apparait plus");
            Assert.That(json.HistoryTypes(), Does.Contain("OrderCancelled"));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK), "deux appuis : idempotent");
            Assert.That((await again.JsonAsync()).HistoryTypes().Count(type => type == "OrderCancelled"), Is.EqualTo(1));
            Assert.That(reordered.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That((await reordered.JsonAsync()).StatusOf(), Is.EqualTo("Ordered"));
        });
    }

    [Test]
    public async Task Cancelling_an_order_needs_a_reason_from_the_list_and_is_refused_with_a_delivery()
    {
        var withDelivery = (await OrderedAsync(300m)).Id();
        await Factory.SeedDeliveryRowAsync(Site.Id, withDelivery, 100m);
        await Factory.SetStatusAsync(withDelivery, RequestStatus.PartiallyDelivered);
        var plain = (await OrderedAsync(300m)).Id();

        var noReason = await Achats.PostAsync($"{OrderUrl(Site.Id, plain)}/cancel", new { });
        var foreignReason = await Achats.PostAsync($"{OrderUrl(Site.Id, plain)}/cancel", new { reasonCode = "EntryError" });
        var blocked = await Achats.PostAsync($"{OrderUrl(Site.Id, withDelivery)}/cancel", new { reasonCode = "PriceRefused" });

        Assert.Multiple(async () =>
        {
            Assert.That(noReason.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(foreignReason.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(blocked.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(blocked), Is.EqualTo("TRANSITION_INTERDITE"));
        });
    }

    [Test]
    public async Task An_ordered_request_can_no_longer_be_cancelled_by_the_conducteur()
    {
        var id = (await OrderedAsync(300m)).Id();

        var response = await Conducteur.PostAsync($"{RequestUrl(Site.Id, id)}/cancel", new { reasonCode = "EntryError" });

        Assert.That(await CodeOf(response), Is.EqualTo("TRANSITION_INTERDITE"));
    }

    [Test]
    public async Task An_order_on_an_archived_site_is_refused()
    {
        var archived = await NewSiteAsync();
        var id = await Chef.NewRequestIdAsync(archived.Id, CementId);
        await Conducteur.PostAsync($"{RequestUrl(archived.Id, id)}/approve");
        await Factory.ArchiveSiteAsync(archived.Id);

        var response = await Achats.PostAsync(OrderUrl(archived.Id, id), OrderBody(SupplierId));

        Assert.That(await CodeOf(response), Is.EqualTo("CHANTIER_ARCHIVE"));
    }
}
