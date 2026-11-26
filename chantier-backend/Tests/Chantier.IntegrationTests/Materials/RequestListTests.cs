using System.Diagnostics;
using System.Net;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>B4, listes (CT-MAT-14, 23) : vues, filtres, recherche, tri, pagination, liste transversale, isolation des chantiers, retard, performance.</summary>
[TestFixture]
public class RequestListTests : MaterialsFixtureBase
{
    private static IEnumerable<string> Numbers(System.Text.Json.JsonElement page)
        => page.GetProperty("items").EnumerateArray().Select(item => item.GetProperty("number").GetString()!);

    private async Task<System.Text.Json.JsonElement> ListAsync(ApiSession session, Guid siteId, string query = "")
    {
        var response = await session.GetAsync($"{RequestsUrl(siteId)}{(query.Length == 0 ? string.Empty : "?" + query)}");
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), await response.Content.ReadAsStringAsync());
        return await response.JsonAsync();
    }

    [Test]
    public async Task The_default_view_follows_open_requests_most_urgent_first_and_hides_closed_ones()
    {
        var site = await NewSiteAsync();
        var normal = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, neededBy: FutureDate(2)));
        var urgent = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 10m, priority: "Urgent", neededBy: FutureDate(9)));
        var blocking = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 20m, priority: "Blocking", neededBy: FutureDate(20)));
        var rejected = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 30m));
        await Conducteur.PostAsync($"{RequestUrl(site.Id, rejected.Id())}/reject", new { reasonCode = "OverBudget" });

        var page = await ListAsync(Chef, site.Id);

        Assert.Multiple(() =>
        {
            Assert.That(Numbers(page), Is.EqualTo(new[] { blocking.Number(), urgent.Number(), normal.Number() }), "bloquante, urgente, puis normale");
            Assert.That(page.GetProperty("totalCount").GetInt32(), Is.EqualTo(3));
        });
    }

    [Test]
    public async Task Each_view_lists_its_statuses_only()
    {
        var site = await NewSiteAsync();
        var ids = new Dictionary<RequestStatus, string>();
        foreach (var status in Enum.GetValues<RequestStatus>())
        {
            var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 10m + (int)status));
            if (status != RequestStatus.Requested)
            {
                await Factory.SetStatusAsync(created.Id(), status);
            }

            ids[status] = created.Number();
        }

        var expectations = new Dictionary<string, RequestStatus[]>
        {
            ["toFollow"] = [RequestStatus.Requested, RequestStatus.Validated, RequestStatus.Ordered, RequestStatus.PartiallyDelivered, RequestStatus.Delivered],
            ["toApprove"] = [RequestStatus.Requested],
            ["toOrder"] = [RequestStatus.Validated],
            ["expected"] = [RequestStatus.Ordered, RequestStatus.PartiallyDelivered],
            ["toReceive"] = [RequestStatus.Delivered],
            ["received"] = [RequestStatus.Received],
            ["closed"] = [RequestStatus.Rejected, RequestStatus.Cancelled],
        };

        Assert.Multiple(async () =>
        {
            foreach (var (view, statuses) in expectations)
            {
                var page = await ListAsync(Conducteur, site.Id, $"view={view}");
                Assert.That(Numbers(page), Is.EquivalentTo(statuses.Select(status => ids[status])), view);
            }

            var withStatus = await ListAsync(Conducteur, site.Id, "status=Received");
            Assert.That(Numbers(withStatus), Is.EqualTo(new[] { ids[RequestStatus.Received] }), "un statut explicite sans vue n'est pas borne par « a suivre »");
        });
    }

    [Test]
    public async Task Filters_narrow_the_list_and_combine()
    {
        var site = await NewSiteAsync();
        var zoneA = await Factory.SeedZoneAsync(site.Id, "Bloc A");
        var zoneB = await Factory.SeedZoneAsync(site.Id, "Bloc B");
        var a = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 10m, zoneId: zoneA, neededBy: "2026-12-01", priority: "Urgent"));
        var b = await Equipe.CreateRequestAsync(site.Id, RequestBody(SteelId, 2m, "t", zoneB, neededBy: "2026-12-15"));
        var c = await Equipe.CreateRequestAsync(site.Id, RequestBody(CementId, 30m, zoneId: zoneB, neededBy: "2026-12-31"));

        Assert.Multiple(async () =>
        {
            Assert.That(Numbers(await ListAsync(Chef, site.Id, $"zoneId={zoneB}")), Is.EquivalentTo(new[] { b.Number(), c.Number() }));
            Assert.That(Numbers(await ListAsync(Chef, site.Id, $"productId={SteelId}")), Is.EqualTo(new[] { b.Number() }));
            Assert.That(Numbers(await ListAsync(Chef, site.Id, "priority=Urgent")), Is.EqualTo(new[] { a.Number() }));
            Assert.That(Numbers(await ListAsync(Chef, site.Id, "from=2026-12-10&to=2026-12-20")), Is.EqualTo(new[] { b.Number() }));
            Assert.That(Numbers(await ListAsync(Equipe, site.Id, "mine=true")), Is.EquivalentTo(new[] { b.Number(), c.Number() }));
            Assert.That(Numbers(await ListAsync(Chef, site.Id, "mine=true")), Is.EqualTo(new[] { a.Number() }));
            Assert.That(Numbers(await ListAsync(Chef, site.Id, $"zoneId={zoneB}&productId={CementId}")), Is.EqualTo(new[] { c.Number() }));
        });
    }

    [Test]
    public async Task Search_finds_a_number_a_product_without_case_or_accents_and_a_note()
    {
        var site = await NewSiteAsync();
        var tag = Guid.NewGuid().ToString("N")[..6];
        var brick = await Admin.CreateProductAsync(ProductBody($"Brique Rouge {tag}", ["u"], "u", null, "Masonry"));
        var first = await Chef.CreateRequestAsync(site.Id, RequestBody(brick.Id(), 500m, "u"));
        var second = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, note: "Pour la dalle du reau"));

        Assert.Multiple(async () =>
        {
            Assert.That(Numbers(await ListAsync(Chef, site.Id, "q=dem-002")), Is.EqualTo(new[] { second.Number() }));
            Assert.That(Numbers(await ListAsync(Chef, site.Id, "q=DEM-001")), Is.EqualTo(new[] { first.Number() }));
            Assert.That(Numbers(await ListAsync(Chef, site.Id, $"q={Uri.EscapeDataString($"BRÏQUE rouge {tag}")}")), Is.EqualTo(new[] { first.Number() }));
            Assert.That(Numbers(await ListAsync(Chef, site.Id, "q=dalle")), Is.EqualTo(new[] { second.Number() }));
            Assert.That(Numbers(await ListAsync(Chef, site.Id, "q=introuvable")), Is.Empty);
        });
    }

    [Test]
    public async Task The_list_is_paged_sorted_and_counted()
    {
        var site = await NewSiteAsync();
        for (var index = 0; index < 5; index++)
        {
            await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 10 + index, neededBy: FutureDate(10 - index)));
        }

        var second = await ListAsync(Chef, site.Id, "pageSize=2&page=2&sort=number");
        var byDate = await ListAsync(Chef, site.Id, "sort=neededBy");
        var descending = await ListAsync(Chef, site.Id, "sort=-number&pageSize=1");

        Assert.Multiple(() =>
        {
            Assert.That(second.GetProperty("totalCount").GetInt32(), Is.EqualTo(5));
            Assert.That(second.GetProperty("page").GetInt32(), Is.EqualTo(2));
            Assert.That(Numbers(second), Is.EqualTo(new[] { "DEM-003", "DEM-004" }));
            Assert.That(Numbers(byDate), Is.EqualTo(new[] { "DEM-005", "DEM-004", "DEM-003", "DEM-002", "DEM-001" }));
            Assert.That(Numbers(descending), Is.EqualTo(new[] { "DEM-005" }));
        });
    }

    [Test]
    public async Task An_unknown_view_sort_or_page_size_is_a_400()
    {
        var errors = new[] { "view=inconnue", "view=LATE", "sort=couleur", "pageSize=201", "pageSize=0", "page=0", "status=Perdue", "from=hier" };

        foreach (var query in errors)
        {
            var response = await Chef.GetAsync($"{RequestsUrl(Site.Id)}?{query}");
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest), query);
        }
    }

    [Test]
    public async Task Overdue_days_count_calendar_days_in_algeria_for_open_requests_only()
    {
        var site = await NewSiteAsync();
        var today = Factory.Today();
        var late = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 1m, neededBy: today.AddDays(-2).ToString("yyyy-MM-dd")));
        var dueToday = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 2m, neededBy: today.ToString("yyyy-MM-dd")));
        var future = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 3m, neededBy: today.AddDays(5).ToString("yyyy-MM-dd")));
        var delivered = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 4m, neededBy: today.AddDays(-9).ToString("yyyy-MM-dd")));
        await Factory.SetStatusAsync(delivered.Id(), RequestStatus.Delivered, received: 4m);

        var page = await ListAsync(Chef, site.Id, "pageSize=50");
        var byNumber = page.GetProperty("items").EnumerateArray().ToDictionary(item => item.GetProperty("number").GetString()!);

        Assert.Multiple(() =>
        {
            Assert.That(byNumber[late.Number()].GetProperty("overdueDays").GetInt32(), Is.EqualTo(2));
            Assert.That(byNumber[dueToday.Number()].GetProperty("overdueDays").GetInt32(), Is.Zero);
            Assert.That(byNumber[future.Number()].GetProperty("overdueDays").GetInt32(), Is.Zero);
            Assert.That(byNumber[delivered.Number()].GetProperty("overdueDays").GetInt32(), Is.Zero, "une demande livree n'est plus en retard");
            Assert.That(byNumber[delivered.Number()].GetProperty("receivedQuantity").GetProperty("value").GetDecimal(), Is.EqualTo(4m));
            Assert.That(byNumber[delivered.Number()].GetProperty("remainingQuantity").GetProperty("value").GetDecimal(), Is.Zero);
        });
    }

    [Test]
    public async Task A_commanded_request_shows_received_remaining_and_variance_in_its_own_unit()
    {
        var site = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(site.Id, RequestBody(CementId, 600m));
        await Factory.SetStatusAsync(created.Id(), RequestStatus.PartiallyDelivered, received: 400m);

        var json = await (await Chef.GetAsync(RequestUrl(site.Id, created.Id()))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(json.GetProperty("receivedQuantity").GetProperty("unit").GetString(), Is.EqualTo("sac"));
            Assert.That(json.GetProperty("remainingQuantity").GetProperty("value").GetDecimal(), Is.EqualTo(200m));
            Assert.That(json.GetProperty("variance").GetProperty("value").GetDecimal(), Is.EqualTo(-200m));
            Assert.That(json.GetProperty("variance").GetProperty("percent").GetDecimal(), Is.EqualTo(-33.33m));
        });
    }

    // --- Liste transversale et isolation ---

    [Test]
    public async Task The_cross_site_list_only_shows_the_assigned_sites_and_carries_the_site_code()
    {
        var mine = await NewSiteAsync();
        var lonely = await Factory.SignInAsync(RoleNames.ChefChantier);
        var hisSite = await Factory.SeedSiteAsync(members: [lonely.Account.Id]);
        var theirs = await Chef.CreateRequestAsync(mine.Id, RequestBody(CementId));
        var own = await lonely.CreateRequestAsync(hisSite.Id, RequestBody(CementId));

        var list = await (await lonely.GetAsync("/api/v1/requests?pageSize=200")).JsonAsync();
        var admin = await (await Admin.GetAsync($"/api/v1/requests?pageSize=200&q={theirs.Number()}")).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(list.GetProperty("items").EnumerateArray().Select(item => item.Id()), Is.EqualTo(new[] { own.Id() }));
            Assert.That(list.GetProperty("items")[0].GetProperty("siteCode").GetString(), Is.EqualTo(hisSite.Code));
            Assert.That(admin.GetProperty("items").EnumerateArray().Select(item => item.Id()), Does.Contain(theirs.Id()), "l'Admin voit tous les chantiers");
        });
    }

    [Test]
    public async Task The_cross_site_list_filtered_on_a_site_that_is_not_assigned_is_the_same_404_as_an_unknown_site()
    {
        var outsider = await NewSiteAsync();
        var lonely = await Factory.SignInAsync(RoleNames.ChefChantier);

        var notAssigned = await lonely.GetAsync($"/api/v1/requests?siteId={outsider.Id}");
        var unknown = await lonely.GetAsync($"/api/v1/requests?siteId={Guid.NewGuid()}");

        Assert.Multiple(async () =>
        {
            Assert.That(notAssigned.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(AuthTestHelpers.WithoutTraceId(await notAssigned.JsonAsync()), Is.EqualTo(AuthTestHelpers.WithoutTraceId(await unknown.JsonAsync())));
        });
    }

    [Test]
    public async Task Every_route_of_a_site_that_is_not_assigned_is_the_same_404()
    {
        var outsider = await NewSiteAsync();
        var created = await Chef.CreateRequestAsync(outsider.Id, RequestBody(CementId));
        var lonely = await Factory.SignInAsync(RoleNames.ConducteurTravaux);
        var unknownSite = Guid.NewGuid();
        var requestId = created.Id();

        async Task<string> Call(Func<Guid, string> url, HttpMethod method, object? body, Guid siteId)
        {
            var response = await (method == HttpMethod.Get ? lonely.GetAsync(url(siteId)) : method == HttpMethod.Put ? lonely.PutAsync(url(siteId), body) : lonely.PostAsync(url(siteId), body));
            return $"{(int)response.StatusCode} {AuthTestHelpers.WithoutTraceId(await response.JsonAsync())}";
        }

        var routes = new (string Name, Func<Guid, string> Url, HttpMethod Method, object? Body)[]
        {
            ("liste", site => RequestsUrl(site), HttpMethod.Get, null),
            ("detail", site => RequestUrl(site, requestId), HttpMethod.Get, null),
            ("creation", site => RequestsUrl(site), HttpMethod.Post, RequestBody(CementId)),
            ("modification", site => RequestUrl(site, requestId), HttpMethod.Put, new { version = "1" }),
            ("validation", site => RequestUrl(site, requestId) + "/approve", HttpMethod.Post, new { }),
            ("annulation", site => RequestUrl(site, requestId) + "/cancel", HttpMethod.Post, new { reasonCode = "EntryError" }),
            ("lot", site => RequestsUrl(site) + "/batch/approve", HttpMethod.Post, new { requestIds = new[] { requestId } }),
            ("archivage", site => RequestUrl(site, requestId) + "/archive", HttpMethod.Post, new { }),
        };

        Assert.Multiple(async () =>
        {
            foreach (var (name, url, method, body) in routes)
            {
                var hidden = await Call(url, method, body, outsider.Id);
                var absent = await Call(url, method, body, unknownSite);
                Assert.That(hidden, Does.StartWith("404"), name);
                Assert.That(hidden, Is.EqualTo(absent), name);
            }
        });
    }

    [Test]
    public async Task A_removed_assignment_cuts_the_access_at_once()
    {
        var site = await NewSiteAsync();
        var member = await Factory.SignInAsync(RoleNames.ChefChantier);
        await Factory.AssignDirectlyAsync(site.Id, member.Account.Id);
        Assert.That((await member.GetAsync(RequestsUrl(site.Id))).StatusCode, Is.EqualTo(HttpStatusCode.OK));

        await Factory.RemoveMemberAsync(site.Id, member.Account.Id);

        Assert.That((await member.GetAsync(RequestsUrl(site.Id))).StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
    }

    [Test]
    public async Task Every_role_reads_the_requests_of_its_sites()
    {
        var site = await NewSiteAsync();
        await Chef.CreateRequestAsync(site.Id, RequestBody(CementId));

        foreach (var session in AllSessions)
        {
            var response = await session.GetAsync(RequestsUrl(site.Id));
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), session.Account.Role);
        }
    }

    [Test]
    public async Task An_anonymous_read_is_a_401()
    {
        using var anonymous = Factory.CreateClient();

        Assert.Multiple(async () =>
        {
            Assert.That((await anonymous.GetAsync(RequestsUrl(Site.Id))).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That((await anonymous.GetAsync("/api/v1/requests")).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task Five_hundred_requests_list_their_first_twenty_in_under_two_seconds()
    {
        var site = await NewSiteAsync();
        await using (var scope = Factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            for (var index = 1; index <= 500; index++)
            {
                var fields = RequestRules.Validate(
                    new RequestFields(CementId, null, 10 + index % 50, MeasureUnit.Bag, null, new DateOnly(2026, 12, 1).AddDays(index % 30), (Priority)(index % 3), null),
                    null,
                    new MaterialsOptions());
                db.MaterialRequests.Add(MaterialRequest.Create(site.Id, $"DEM-{index:000}", null, null, fields, null));
            }

            await db.SaveChangesAsync();
        }

        await ListAsync(Chef, site.Id, "pageSize=20");
        var watch = Stopwatch.StartNew();
        var page = await ListAsync(Chef, site.Id, "pageSize=20");
        watch.Stop();

        Assert.Multiple(() =>
        {
            Assert.That(page.GetProperty("totalCount").GetInt32(), Is.EqualTo(500));
            Assert.That(page.GetProperty("items").GetArrayLength(), Is.EqualTo(20));
            Assert.That(watch.Elapsed, Is.LessThan(TimeSpan.FromSeconds(2)));
        });
    }
}
