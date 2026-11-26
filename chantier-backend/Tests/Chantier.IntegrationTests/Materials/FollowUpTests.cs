using System.Diagnostics;
using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>B8, suivi (CT-MAT-14, 23) : compteurs, totaux par produit et unite sans melange, retards, vue « late », filtre fournisseur, montants par role, performance.</summary>
[TestFixture]
public class FollowUpTests : DeliveryFixtureBase
{
    private async Task<JsonElement> FollowUpAsync(Guid siteId, ApiSession? session = null)
    {
        var response = await (session ?? Conducteur).GetAsync(FollowUpUrl(siteId));
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), await response.Content.ReadAsStringAsync());
        return await response.JsonAsync();
    }

    private async Task<Guid> RequestAsync(Guid siteId, Guid productId, decimal value, string unit, bool validate = true, DateOnly? neededBy = null)
    {
        var id = (await Chef.CreateRequestAsync(siteId, RequestBody(productId, value, unit, neededBy: neededBy is { } date ? Iso(date) : null))).Id();
        if (validate)
        {
            await Conducteur.PostAsync($"{RequestUrl(siteId, id)}/approve");
        }

        return id;
    }

    private static JsonElement Line(JsonElement followUp, Guid productId, string unit)
        => followUp.GetProperty("toOrderTotals").EnumerateArray().Single(line => line.GetProperty("productId").GetGuid() == productId && line.GetProperty("total").GetProperty("unit").GetString() == unit);

    [Test]
    public async Task The_five_counters_count_the_requests_of_the_site_only()
    {
        var site = await NewSiteAsync();
        await RequestAsync(site.Id, CementId, 10m, "sac", validate: false);
        await RequestAsync(site.Id, CementId, 10m, "sac", validate: false);
        await RequestAsync(site.Id, CementId, 10m, "sac");
        var ordered = await OrderedRequestAsync(100m, siteId: site.Id);
        var partial = await OrderedRequestAsync(100m, siteId: site.Id);
        await DeliverAsync(partial, 10m, "sac", siteId: site.Id);
        var delivered = await OrderedRequestAsync(100m, siteId: site.Id);
        await DeliverAsync(delivered, 100m, "sac", siteId: site.Id);
        var closed = await RequestAsync(site.Id, CementId, 5m, "sac", validate: false);
        await Factory.SetStatusAsync(closed, RequestStatus.Cancelled);
        await Factory.SeedSiteAsync();

        var counters = (await FollowUpAsync(site.Id)).GetProperty("counters");

        Assert.Multiple(() =>
        {
            Assert.That(counters.GetProperty("toApprove").GetInt32(), Is.EqualTo(2));
            Assert.That(counters.GetProperty("toOrder").GetInt32(), Is.EqualTo(1));
            Assert.That(counters.GetProperty("expected").GetInt32(), Is.EqualTo(2), "commandee et livree partiellement");
            Assert.That(counters.GetProperty("toReceive").GetInt32(), Is.EqualTo(1));
            Assert.That(counters.GetProperty("late").GetInt32(), Is.Zero);
        });
        Assert.That(ordered, Is.Not.EqualTo(Guid.Empty));
    }

    [Test]
    public async Task Totals_add_only_convertible_units_per_product()
    {
        var site = await NewSiteAsync();
        await RequestAsync(site.Id, CementId, 100m, "sac");
        await RequestAsync(site.Id, CementId, 5m, "t");
        await RequestAsync(site.Id, CementId, 200m, "sac");
        await RequestAsync(site.Id, SteelId, 2m, "t");
        await RequestAsync(site.Id, SteelId, 500m, "kg");
        await RequestAsync(site.Id, SandId, 24m, "m3");
        await RequestAsync(site.Id, SandId, 10m, "t");

        var followUp = await FollowUpAsync(site.Id);

        var cement = Line(followUp, CementId, "sac");
        var steel = Line(followUp, SteelId, "t");
        Assert.Multiple(() =>
        {
            Assert.That(cement.GetProperty("total").GetProperty("value").GetDecimal(), Is.EqualTo(400m), "100 sacs + 5 T + 200 sacs");
            Assert.That(cement.GetProperty("massEquivalent").GetProperty("value").GetDecimal(), Is.EqualTo(20m));
            Assert.That(cement.GetProperty("massEquivalent").GetProperty("unit").GetString(), Is.EqualTo("t"));
            Assert.That(cement.GetProperty("requestCount").GetInt32(), Is.EqualTo(3));
            Assert.That(steel.GetProperty("total").GetProperty("value").GetDecimal(), Is.EqualTo(2.5m), "2 T + 500 kg");
            Assert.That(Line(followUp, SandId, "m3").GetProperty("total").GetProperty("value").GetDecimal(), Is.EqualTo(24m));
            Assert.That(Line(followUp, SandId, "t").GetProperty("total").GetProperty("value").GetDecimal(), Is.EqualTo(10m), "m3 et T ne s'additionnent jamais");
            Assert.That(followUp.GetProperty("toOrderTotals").GetArrayLength(), Is.EqualTo(4));
        });
    }

    [Test]
    public async Task The_late_view_and_counter_follow_the_need_date_and_the_planned_delivery()
    {
        var site = await NewSiteAsync();
        var today = Factory.Today();
        var overdue = await ValidatedLateAsync(site.Id, today.AddDays(-2));
        var onTime = await RequestAsync(site.Id, CementId, 10m, "sac", neededBy: today.AddDays(3));
        var lateOrder = await OrderedRequestAsync(100m, siteId: site.Id, expected: today.AddDays(-1));
        var punctualOrder = await OrderedRequestAsync(100m, siteId: site.Id, expected: today.AddDays(2));
        var fiveDays = await ValidatedLateAsync(site.Id, today.AddDays(-5));

        var late = await (await Conducteur.GetAsync($"{RequestsUrl(site.Id)}?view=late")).JsonAsync();
        var items = late.GetProperty("items").EnumerateArray().ToList();
        var days = items.ToDictionary(item => item.GetProperty("id").GetGuid(), item => item.GetProperty("overdueDays").GetInt32());
        var followUp = await FollowUpAsync(site.Id);

        Assert.Multiple(() =>
        {
            Assert.That(days.Keys, Is.EquivalentTo(new[] { overdue, lateOrder, fiveDays }));
            Assert.That(days[overdue], Is.EqualTo(2));
            Assert.That(days[fiveDays], Is.EqualTo(5));
            Assert.That(days[lateOrder], Is.Zero, "la date de besoin n'est pas depassee : seule la livraison prevue l'est");
            Assert.That(days.ContainsKey(onTime), Is.False);
            Assert.That(days.ContainsKey(punctualOrder), Is.False);
            Assert.That(followUp.GetProperty("counters").GetProperty("late").GetInt32(), Is.EqualTo(3));
            Assert.That(late.GetProperty("totalCount").GetInt32(), Is.EqualTo(3));
        });
    }

    private async Task<Guid> ValidatedLateAsync(Guid siteId, DateOnly neededBy)
    {
        // Une date de besoin passee est acceptee a la creation.
        return await RequestAsync(siteId, CementId, 10m, "sac", neededBy: neededBy);
    }

    [Test]
    public async Task A_delivered_request_is_never_late_and_the_supplier_filter_finds_the_orders_of_that_supplier()
    {
        var site = await NewSiteAsync();
        var today = Factory.Today();
        var delivered = await OrderedRequestAsync(100m, siteId: site.Id, expected: today.AddDays(-3));
        await DeliverAsync(delivered, 100m, "sac", siteId: site.Id);
        var other = (await Admin.CreateSupplierAsync()).Id();
        var elsewhere = await ValidatedAsync(100m, siteId: site.Id);
        await Achats.PostAsync(OrderUrl(site.Id, elsewhere), OrderBody(other));

        var late = await (await Conducteur.GetAsync($"{RequestsUrl(site.Id)}?view=late")).JsonAsync();
        var bySupplier = await (await Conducteur.GetAsync($"{RequestsUrl(site.Id)}?supplierId={other}")).JsonAsync();
        var crossSite = await (await Conducteur.GetAsync($"/api/v1/requests?siteId={site.Id}&supplierId={SupplierId}")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(late.GetProperty("items").GetArrayLength(), Is.Zero);
            Assert.That(bySupplier.GetProperty("items").EnumerateArray().Select(item => item.GetProperty("id").GetGuid()), Is.EqualTo(new[] { elsewhere }));
            Assert.That(crossSite.GetProperty("items").EnumerateArray().Select(item => item.GetProperty("id").GetGuid()), Is.EqualTo(new[] { delivered }));
        });
    }

    [Test]
    public async Task Amounts_are_for_the_price_roles_only_and_exclude_cancelled_orders_and_deliveries()
    {
        var site = await NewSiteAsync();
        var first = await OrderedRequestAsync(300m, siteId: site.Id, price: 780m);
        var second = await OrderedRequestAsync(100m, siteId: site.Id, price: 1000m);
        var cancelled = await OrderedRequestAsync(100m, siteId: site.Id, price: 5000m);
        await Achats.PostAsync($"{OrderUrl(site.Id, cancelled)}/cancel", new { reasonCode = "PriceRefused" });
        await DeliverAsync(first, 100m, "sac", siteId: site.Id);
        var dropped = await DeliverAsync(second, 50m, "sac", siteId: site.Id);
        await Chef.PostAsync($"{DeliveryUrl(site.Id, dropped.Id())}/cancel", new { reasonCode = "DoubleEntry" });

        var allowed = new List<decimal[]>();
        foreach (var session in new[] { Admin, Direction, Conducteur, Achats })
        {
            var commercial = (await FollowUpAsync(site.Id, session)).GetProperty("commercial");
            allowed.Add([commercial.GetProperty("orderedAmount").GetDecimal(), commercial.GetProperty("receivedValue").GetDecimal()]);
        }

        var chef = await FollowUpAsync(site.Id, Chef);
        var equipe = await FollowUpAsync(site.Id, Equipe);

        Assert.Multiple(() =>
        {
            Assert.That(allowed, Is.All.EqualTo(new[] { 334000.00m, 78000.00m }), "234 000 + 100 000 ; 100 sacs x 780");
            Assert.That(chef.TryGetProperty("commercial", out _), Is.False);
            Assert.That(equipe.TryGetProperty("commercial", out _), Is.False);
        });
    }

    [Test]
    public async Task The_follow_up_of_a_site_the_user_is_not_assigned_to_is_not_found_and_anonymous_is_refused()
    {
        var other = await Factory.SeedSiteAsync();

        var foreign = await Conducteur.GetAsync(FollowUpUrl(other.Id));
        var missing = await Conducteur.GetAsync(FollowUpUrl(Guid.NewGuid()));
        var anonymous = await Factory.CreateClient().GetAsync(FollowUpUrl(Site.Id));
        var everyone = new List<HttpStatusCode>();
        foreach (var session in AllSessions)
        {
            everyone.Add((await session.GetAsync(FollowUpUrl(Site.Id))).StatusCode);
        }

        Assert.Multiple(async () =>
        {
            Assert.That(foreign.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(await foreign.Content.ReadAsStringAsync(), Is.EqualTo(await missing.Content.ReadAsStringAsync()).Or.Contain("INTROUVABLE"));
            Assert.That(anonymous.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(everyone, Is.All.EqualTo(HttpStatusCode.OK));
        });
    }

    [Test]
    public async Task A_thousand_requests_are_followed_up_in_under_two_seconds()
    {
        var site = await NewSiteAsync();
        await using (var scope = Factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var today = Factory.Today();
            var statuses = new[] { RequestStatus.Requested, RequestStatus.Validated, RequestStatus.Ordered, RequestStatus.PartiallyDelivered, RequestStatus.Delivered };
            for (var index = 0; index < 1000; index++)
            {
                var fields = new ValidatedRequestFields(CementId, null, new Quantity(10m + index % 7, MeasureUnit.Bag), null, today.AddDays(index % 9 - 4), Priority.Normal, null);
                var request = MaterialRequest.Create(site.Id, $"DEM-{index + 1:D3}", null, null, fields, null);
                db.MaterialRequests.Add(request);
            }

            await db.SaveChangesAsync();
            var ids = db.MaterialRequests.Where(request => request.SiteId == site.Id).OrderBy(request => request.Number).Select(request => request.Id).ToList();
            for (var slot = 0; slot < statuses.Length; slot++)
            {
                var status = statuses[slot];
                var chunk = ids.Where((_, index) => index % statuses.Length == slot).ToList();
                await db.MaterialRequests.Where(request => chunk.Contains(request.Id)).ExecuteUpdateAsync(set => set.SetProperty(request => request.Status, status));
            }
        }

        await FollowUpAsync(site.Id);
        var watch = Stopwatch.StartNew();
        var followUp = await FollowUpAsync(site.Id);
        var list = await Conducteur.GetAsync($"{RequestsUrl(site.Id)}?view=late&pageSize=50");
        watch.Stop();

        Assert.Multiple(() =>
        {
            Assert.That(watch.Elapsed, Is.LessThan(TimeSpan.FromSeconds(2)));
            Assert.That(followUp.GetProperty("counters").GetProperty("toApprove").GetInt32(), Is.EqualTo(200));
            Assert.That(list.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }
}
