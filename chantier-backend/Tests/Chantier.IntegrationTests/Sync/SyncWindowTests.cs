using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Materials;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Sync;

/// <summary>
/// R2-02 : la synchronisation n'envoie plus toute l'histoire d'un chantier. Fenetre de 60 jours pour les demandes closes (et leurs livraisons et photos), aucun historique dans
/// les lignes, et l'affectation d'une personne ne retouche (donc ne fait retelecharger a tous les autres telephones) que les lignes de la fenetre.
/// </summary>
[TestFixture]
public class SyncWindowTests : DeliveryFixtureBase
{
    private const int OldDays = 61;

    private async Task AgeAsync(Guid? requestId = null, Guid? deliveryId = null, int days = OldDays)
    {
        await using var scope = Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var old = Factory.Time.GetUtcNow().AddDays(-days);
        if (requestId is { } request)
        {
            await db.MaterialRequests.Where(row => row.Id == request).ExecuteUpdateAsync(set => set.SetProperty(row => row.UpdatedAt, old));
        }

        if (deliveryId is { } delivery)
        {
            await db.Deliveries.Where(row => row.Id == delivery).ExecuteUpdateAsync(set => set.SetProperty(row => row.UpdatedAt, old));
        }
    }

    private async Task<Guid> AddPhotoAsync(Guid siteId, Guid deliveryId)
    {
        var jpeg = Jpeg();
        var response = await Chef.PostAsync(PhotosUrl(siteId, deliveryId), new
        {
            clientId = Guid.NewGuid(),
            takenAt = "2026-11-25T08:10:00Z",
            contentType = "image/jpeg",
            sizeBytes = jpeg.Length,
            sha256 = Sha256Hex(jpeg),
        });
        return (await response.JsonAsync()).Id();
    }

    /// <summary>Chantier avec : une demande close ancienne (livraison et photo), une close recente, une ouverte ancienne, une livraison annulee ancienne.</summary>
    private async Task<(SeededSite Site, Guid OldClosed, Guid OldClosedDelivery, Guid OldClosedPhoto, Guid RecentClosed, Guid OldOpen, Guid OldCancelledDelivery, Guid OpenDelivery)> BuildAsync()
    {
        var site = await NewSiteAsync();

        var oldClosed = await OrderedRequestAsync(600m, siteId: site.Id);
        var oldClosedDelivery = (await DeliverAsync(oldClosed, 10m, "t", siteId: site.Id)).Id();
        var oldClosedPhoto = await AddPhotoAsync(site.Id, oldClosedDelivery);
        await Factory.SetStatusAsync(oldClosed, RequestStatus.Received);
        await AgeAsync(requestId: oldClosed);

        var recentClosed = await Chef.NewRequestIdAsync(site.Id, CementId);
        await Factory.SetStatusAsync(recentClosed, RequestStatus.Cancelled);

        var oldOpen = await Chef.NewRequestIdAsync(site.Id, CementId);
        await AgeAsync(requestId: oldOpen);

        var openRequest = await OrderedRequestAsync(600m, siteId: site.Id);
        var cancelled = (await DeliverAsync(openRequest, 5m, "t", siteId: site.Id)).Id();
        await Chef.PostAsync($"{DeliveryUrl(site.Id, cancelled)}/cancel", new { reasonCode = "DoubleEntry" });
        await AgeAsync(deliveryId: cancelled);
        var openDelivery = (await DeliverAsync(openRequest, 7m, "t", siteId: site.Id)).Id();

        return (site, oldClosed, oldClosedDelivery, oldClosedPhoto, recentClosed, oldOpen, cancelled, openDelivery);
    }

    [Test]
    public async Task Old_closed_requests_with_their_deliveries_and_photos_and_old_cancelled_deliveries_are_not_sent()
    {
        var data = await BuildAsync();

        var (changes, _, _) = await Chef.PullAllAsync(siteId: data.Site.Id);
        var requests = changes.Of("request").Select(row => row.GetProperty("id").GetGuid()).ToList();
        var deliveries = changes.Of("delivery").Select(row => row.GetProperty("id").GetGuid()).ToList();
        var photos = changes.Of("photo").Select(row => row.GetProperty("id").GetGuid()).ToList();

        Assert.Multiple(() =>
        {
            Assert.That(requests, Does.Not.Contain(data.OldClosed), "demande receptionnee depuis plus de 60 jours");
            Assert.That(deliveries, Does.Not.Contain(data.OldClosedDelivery), "livraison d'une demande hors fenetre");
            Assert.That(photos, Does.Not.Contain(data.OldClosedPhoto), "photo d'une livraison hors fenetre");
            Assert.That(deliveries, Does.Not.Contain(data.OldCancelledDelivery), "livraison annulee depuis plus de 60 jours");
            Assert.That(requests, Does.Contain(data.RecentClosed), "demande close depuis peu");
            Assert.That(requests, Does.Contain(data.OldOpen), "une demande ouverte est toujours envoyee, quel que soit son age");
            Assert.That(deliveries, Does.Contain(data.OpenDelivery));
        });
    }

    [Test]
    public async Task Rows_in_the_window_carry_no_history_and_the_detail_still_gives_it()
    {
        var data = await BuildAsync();

        var (changes, _, _) = await Chef.PullAllAsync(siteId: data.Site.Id);
        var request = changes.Of("request").Single(row => row.GetProperty("id").GetGuid() == data.OldOpen).GetProperty("data");
        var delivery = changes.Of("delivery").Single(row => row.GetProperty("id").GetGuid() == data.OpenDelivery).GetProperty("data");
        var detail = await (await Chef.GetAsync(RequestUrl(data.Site.Id, data.OldOpen))).JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(request.GetProperty("history").GetArrayLength(), Is.Zero);
            Assert.That(delivery.GetProperty("history").GetArrayLength(), Is.Zero);
            Assert.That(request.GetProperty("status").GetString(), Is.EqualTo("Requested"), "le statut reste dans la ligne");
            Assert.That(detail.HistoryTypes(), Is.EqualTo(new[] { "Created" }));
        });
    }

    [Test]
    public async Task A_phone_whose_cursor_is_older_than_a_closure_now_outside_the_window_is_told_to_reload()
    {
        // R3-05 : le telephone a vu la demande ouverte, puis elle est close il y a plus de 60 jours : aucune ligne ni pierre tombale ne lui arrivera.
        var site = await NewSiteAsync();
        var id = await Chef.NewRequestIdAsync(site.Id, CementId);
        var (_, _, stale) = await Chef.PullAllAsync(siteId: site.Id);
        await Factory.SetStatusAsync(id, RequestStatus.Cancelled);
        await AgeAsync(requestId: id);

        var behind = await Chef.PullAsync(stale, site.Id);
        var (_, _, fresh) = await Chef.PullAllAsync(siteId: site.Id);
        var upToDate = await Chef.PullAsync(fresh, site.Id);
        var fromScratch = await Chef.PullAsync(null, site.Id);

        Assert.Multiple(() =>
        {
            Assert.That(behind.TryGetProperty("resetRequired", out var flag) && flag.GetBoolean(), Is.True, "curseur anterieur a une fermeture hors fenetre");
            Assert.That(behind.GetProperty("changes").EnumerateArray().Of("request").Select(row => row.GetProperty("id").GetGuid()), Does.Not.Contain(id), "la ligne hors fenetre n'est pas envoyee");
            Assert.That(upToDate.TryGetProperty("resetRequired", out _), Is.False, "telephone a jour : pas de signal");
            Assert.That(fromScratch.TryGetProperty("resetRequired", out _), Is.False, "premiere synchronisation : rien a recharger");
        });
    }

    [Test]
    public async Task Assigning_a_person_touches_only_the_rows_of_the_window()
    {
        var data = await BuildAsync();
        var before = await VersionsAsync(data);
        var newcomer = await Factory.SignInAsync(Chantier.Core.Entities.Identity.RoleNames.ChefChantier);

        var response = await Admin.PutAsync($"/api/v1/sites/{data.Site.Id}/members/{newcomer.Account.Id}");
        var after = await VersionsAsync(data);
        var (changes, _, _) = await newcomer.PullAllAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.IsSuccessStatusCode, Is.True);
            Assert.That(after[data.OldClosed], Is.EqualTo(before[data.OldClosed]), "demande close ancienne : non retouchee");
            Assert.That(after[data.OldClosedDelivery], Is.EqualTo(before[data.OldClosedDelivery]), "sa livraison : non retouchee");
            Assert.That(after[data.OldClosedPhoto], Is.EqualTo(before[data.OldClosedPhoto]), "sa photo : non retouchee");
            Assert.That(after[data.OldCancelledDelivery], Is.EqualTo(before[data.OldCancelledDelivery]), "livraison annulee ancienne : non retouchee");
            Assert.That(after[data.OldOpen], Is.GreaterThan(before[data.OldOpen]), "demande ouverte : retouchee (le nouvel affecte la recoit)");
            Assert.That(after[data.RecentClosed], Is.GreaterThan(before[data.RecentClosed]));
            Assert.That(after[data.OpenDelivery], Is.GreaterThan(before[data.OpenDelivery]));
            Assert.That(changes.Of("request").Select(row => row.GetProperty("id").GetGuid()), Does.Not.Contain(data.OldClosed).And.Contain(data.OldOpen).And.Contain(data.RecentClosed));
        });
    }

    private async Task<Dictionary<Guid, ulong>> VersionsAsync((SeededSite Site, Guid OldClosed, Guid OldClosedDelivery, Guid OldClosedPhoto, Guid RecentClosed, Guid OldOpen, Guid OldCancelledDelivery, Guid OpenDelivery) data)
    {
        await using var scope = Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var versions = new Dictionary<Guid, ulong>();
        foreach (var row in await db.MaterialRequests.AsNoTracking().Where(request => request.SiteId == data.Site.Id).Select(request => new { request.Id, request.RowVersion }).ToListAsync())
        {
            versions[row.Id] = row.RowVersion;
        }

        foreach (var row in await db.Deliveries.AsNoTracking().Where(delivery => delivery.SiteId == data.Site.Id).Select(delivery => new { delivery.Id, delivery.RowVersion }).ToListAsync())
        {
            versions[row.Id] = row.RowVersion;
        }

        foreach (var row in await db.Photos.AsNoTracking().Where(photo => photo.SiteId == data.Site.Id).Select(photo => new { photo.Id, photo.RowVersion }).ToListAsync())
        {
            versions[row.Id] = row.RowVersion;
        }

        return versions;
    }
}
