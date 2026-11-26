using System.Diagnostics;
using System.IO.Compression;
using System.Net;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Materials;
using Chantier.IntegrationTests.Support;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;
using static Chantier.IntegrationTests.Support.RequestsTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Qa;

/// <summary>
/// Q3 : volumes du plan. 5 000 demandes et 3 000 livraisons sur un chantier (base jetable de la classe, lignes inserees directement), dont 300 demandes ouvertes :
/// listes, suivi et premiere synchronisation doivent rester sous 2 s et sous 300 Ko compresses (cible de R2-02), et la fenetre de synchronisation doit laisser les lignes anciennes closes.
/// </summary>
[TestFixture]
public class MaterialsQaVolumeTests : DeliveryFixtureBase
{
    private const int Requests = 5000;
    private const int Open = 300;
    private const int Deliveries = 3000;

    private SeededSite _big = null!;

    [OneTimeSetUp]
    public async Task InsertTheVolume()
    {
        _big = await NewSiteAsync();
        await using var scope = Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        db.ChangeTracker.AutoDetectChangesEnabled = false;

        var requests = new List<MaterialRequest>(Requests);
        for (var index = 1; index <= Requests; index++)
        {
            var fields = new ValidatedRequestFields(CementId, null, new Quantity(100m + index % 50, MeasureUnit.Bag), null, Factory.Today().AddDays(index % 20 - 10), Priority.Normal, index % 7 == 0 ? "remise urgente إسمنت" : null);
            requests.Add(MaterialRequest.Create(_big.Id, $"DEM-{index:0000}", Guid.NewGuid(), null, fields, null));
        }

        db.MaterialRequests.AddRange(requests);
        await db.SaveChangesAsync();

        var old = Factory.Time.GetUtcNow().AddDays(-90);
        var openIds = requests.Take(Open).Select(request => request.Id).ToList();
        var closedIds = requests.Skip(Open).Select(request => request.Id).ToList();
        await db.MaterialRequests.Where(request => closedIds.Contains(request.Id) && request.SiteId == _big.Id)
            .ExecuteUpdateAsync(set => set.SetProperty(request => request.Status, RequestStatus.Received).SetProperty(request => request.UpdatedAt, old));
        await db.MaterialRequests.Where(request => openIds.Contains(request.Id))
            .ExecuteUpdateAsync(set => set.SetProperty(request => request.Status, RequestStatus.Validated));

        var deliveries = new List<Delivery>(Deliveries);
        for (var index = 1; index <= Deliveries; index++)
        {
            var target = requests[Open + index % (Requests - Open)];
            var fields = new ValidatedDeliveryFields(null, "Fournisseur fictif", CementId, null, new Quantity(10m, MeasureUnit.Tonne), Factory.Today().AddDays(-30), index % 3 == 0 ? $"BL-{index:00000}" : null, Conformity.Conform, null, null);
            deliveries.Add(Delivery.Create(_big.Id, $"LIV-{index:0000}", Guid.NewGuid(), null, fields, target.Id, null, null));
        }

        db.Deliveries.AddRange(deliveries);
        await db.SaveChangesAsync();
        await db.Deliveries.Where(delivery => delivery.SiteId == _big.Id).ExecuteUpdateAsync(set => set.SetProperty(delivery => delivery.UpdatedAt, old));
    }

    private async Task<(HttpStatusCode Status, long Millis, JsonElement Json)> TimedAsync(ApiSession session, string url)
    {
        var watch = Stopwatch.StartNew();
        var response = await session.GetAsync(url);
        var json = await response.JsonAsync();
        watch.Stop();
        return (response.StatusCode, watch.ElapsedMilliseconds, json);
    }

    [Test]
    public async Task Five_thousand_requests_are_listed_searched_sorted_and_followed_up_in_under_two_seconds_each()
    {
        var url = RequestsUrl(_big.Id);
        var firstPage = await TimedAsync(Chef, $"{url}?pageSize=50");
        var lastPage = await TimedAsync(Chef, $"{url}?view=received&page=94&pageSize=50&sort=neededBy");
        var search = await TimedAsync(Chef, $"{url}?view=received&q=" + Uri.EscapeDataString("إسمنت") + "&pageSize=50");
        var number = await TimedAsync(Chef, $"{url}?view=received&q=DEM-4999");
        var late = await TimedAsync(Chef, $"{url}?view=late&pageSize=200");
        var transversal = await TimedAsync(Chef, "/api/v1/requests?pageSize=200");
        var followUp = await TimedAsync(Conducteur, FollowUpUrl(_big.Id));
        var deliveries = await TimedAsync(Chef, $"{DeliveriesUrl(_big.Id)}?pageSize=200");
        var missingNote = await TimedAsync(Chef, $"{DeliveriesUrl(_big.Id)}?missingNote=true&pageSize=50");

        Assert.Multiple(() =>
        {
            Assert.That(firstPage.Status, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(firstPage.Json.GetProperty("totalCount").GetInt32(), Is.EqualTo(Open), "vue par defaut : les 300 ouvertes, jamais les 4 700 closes");
            Assert.That(lastPage.Status, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(lastPage.Json.GetProperty("totalCount").GetInt32(), Is.EqualTo(Requests - Open));
            Assert.That(lastPage.Json.GetProperty("items").GetArrayLength(), Is.GreaterThan(0));
            Assert.That(number.Json.GetProperty("items").GetArrayLength(), Is.EqualTo(1));
            Assert.That(search.Json.GetProperty("totalCount").GetInt32(), Is.GreaterThan(500), "la recherche en arabe trouve les remarques");
            Assert.That(followUp.Status, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(deliveries.Json.GetProperty("totalCount").GetInt32(), Is.EqualTo(Deliveries));
            Assert.That(
                new[] { firstPage.Millis, lastPage.Millis, search.Millis, number.Millis, late.Millis, transversal.Millis, followUp.Millis, deliveries.Millis, missingNote.Millis },
                Has.All.LessThan(2000),
                $"durees (ms) : liste {firstPage.Millis}, derniere page {lastPage.Millis}, recherche {search.Millis}, numero {number.Millis}, retard {late.Millis}, transversale {transversal.Millis}, suivi {followUp.Millis}, livraisons {deliveries.Millis}, BL manquant {missingNote.Millis}");
        });
        TestContext.Out.WriteLine($"MESURE liste={firstPage.Millis} ms ; derniere page={lastPage.Millis} ms ; recherche={search.Millis} ms ; numero={number.Millis} ms ; retard={late.Millis} ms ; transversale={transversal.Millis} ms ; suivi={followUp.Millis} ms ; livraisons={deliveries.Millis} ms ; BL manquant={missingNote.Millis} ms");
    }

    [Test]
    public async Task The_first_synchronisation_of_a_big_site_is_small_fast_and_leaves_the_old_closed_rows_out()
    {
        var watch = Stopwatch.StartNew();
        var (changes, _, _) = await Chef.PullAllAsync(siteId: _big.Id);
        watch.Stop();
        var raw = System.Text.Encoding.UTF8.GetBytes(string.Join('\n', changes.Select(change => change.GetRawText())));
        using var packed = new MemoryStream();
        using (var gzip = new GZipStream(packed, CompressionLevel.Fastest, leaveOpen: true))
        {
            gzip.Write(raw);
        }

        var requests = changes.Of("request").ToList();
        var deliveries = changes.Of("delivery").ToList();
        TestContext.Out.WriteLine($"MESURE premiere synchro : {changes.Count} lignes ({requests.Count} demandes, {deliveries.Count} livraisons), {raw.Length / 1024} Ko bruts, {packed.Length / 1024} Ko gzip, {watch.ElapsedMilliseconds} ms");

        Assert.Multiple(() =>
        {
            Assert.That(requests, Has.Count.EqualTo(Open), "seules les 300 demandes ouvertes sont envoyees (fenetre de 60 jours)");
            Assert.That(deliveries, Is.Empty, "aucune livraison des demandes closes anciennes");
            Assert.That(packed.Length, Is.LessThan(300 * 1024), "cible de R2-02 : moins de 300 Ko compresses");
            Assert.That(watch.ElapsedMilliseconds, Is.LessThan(5000));
        });
    }

    [Test]
    public async Task Assigning_a_person_to_a_big_site_is_fast_and_does_not_make_the_other_phones_download_the_old_rows()
    {
        var chefBefore = await Chef.PullAllAsync(siteId: _big.Id);
        var newcomer = await Factory.SignInAsync(Chantier.Core.Entities.Identity.RoleNames.ChefChantier);

        var watch = Stopwatch.StartNew();
        var response = await Admin.PutAsync($"/api/v1/sites/{_big.Id}/members/{newcomer.Account.Id}");
        watch.Stop();
        var chefAfter = await Chef.PullAllAsync(chefBefore.Cursor, _big.Id);
        var newcomerPull = await newcomer.PullAllAsync(siteId: _big.Id);
        TestContext.Out.WriteLine($"MESURE affectation : {watch.ElapsedMilliseconds} ms ; relecture du chef {chefAfter.Changes.Count} lignes ; nouvel affecte {newcomerPull.Changes.Count} lignes");

        Assert.Multiple(() =>
        {
            Assert.That(response.IsSuccessStatusCode, Is.True);
            Assert.That(watch.ElapsedMilliseconds, Is.LessThan(3000), "l'affectation ne retouche que la fenetre (R2-02, 3 024 ms avant correction sur 6 936 lignes)");
            Assert.That(chefAfter.Changes.Of("request").Count(), Is.LessThanOrEqualTo(Open), "les autres telephones ne retelechargent pas les 4 700 demandes closes");
            Assert.That(newcomerPull.Changes.Of("request").Count(), Is.EqualTo(Open));
        });
    }
}

/// <summary>
/// Q3 : defense en profondeur de R2-01. La parade complete est <c>READ_COMMITTED_SNAPSHOT</c> (migration) ; la seconde barriere est le rejeu de la transaction victime d'un interblocage.
/// Ici la base est remise en isolation classique (cas d'une base restauree sans la migration) : huit acheteurs simultanes ne doivent toujours obtenir ni 500 ni commande perdue.
/// </summary>
[TestFixture]
public class MaterialsQaDeadlockFallbackTests : DeliveryFixtureBase
{
    private const int Workers = 8;
    private const int Rounds = 6;

    private async Task<int> SnapshotFlagAsync()
    {
        var builder = new SqlConnectionStringBuilder(Factory.Settings["ConnectionStrings:ChantierDb"]);
        await using var connection = new SqlConnection(builder.ConnectionString);
        await connection.OpenAsync();
        await using var command = connection.CreateCommand();
        command.CommandText = "SELECT CAST(is_read_committed_snapshot_on AS int) FROM sys.databases WHERE name = DB_NAME()";
        return (int)(await command.ExecuteScalarAsync())!;
    }

    [Test, Order(1)]
    public async Task The_migration_turns_read_committed_snapshot_on_in_a_new_database()
    {
        Assert.That(await SnapshotFlagAsync(), Is.EqualTo(1), "EnableReadCommittedSnapshot appliquee au demarrage");
    }

    [Test, Order(2)]
    public async Task Without_the_snapshot_option_the_retry_alone_keeps_eight_simultaneous_purchasers_free_of_server_errors()
    {
        var builder = new SqlConnectionStringBuilder(Factory.Settings["ConnectionStrings:ChantierDb"]);
        var name = builder.InitialCatalog;
        builder.InitialCatalog = "master";
        await using (var connection = new SqlConnection(builder.ConnectionString))
        {
            await connection.OpenAsync();
            await using var command = connection.CreateCommand();
            command.CommandText = $"ALTER DATABASE [{name}] SET READ_COMMITTED_SNAPSHOT OFF WITH ROLLBACK IMMEDIATE";
            await command.ExecuteNonQueryAsync();
        }

        SqlConnection.ClearAllPools();
        Assert.That(await SnapshotFlagAsync(), Is.EqualTo(0), "precondition : isolation classique");

        var ids = new List<Guid>();
        for (var index = 0; index < Workers * Rounds; index++)
        {
            ids.Add(await ValidatedAsync(100m));
        }

        var statuses = new List<HttpStatusCode>();
        foreach (var round in ids.Chunk(Workers))
        {
            var responses = await Task.WhenAll(round.Select(id => Achats.PostAsync(OrderUrl(Site.Id, id), OrderBody(SupplierId))));
            statuses.AddRange(responses.Select(response => response.StatusCode));
        }

        var ordered = 0;
        foreach (var id in ids)
        {
            ordered += (await ReadRequestAsync(id)).StatusOf() == "Ordered" ? 1 : 0;
        }

        TestContext.Out.WriteLine($"MESURE sans snapshot : 201={statuses.Count(status => status == HttpStatusCode.Created)} ; 503={statuses.Count(status => status == HttpStatusCode.ServiceUnavailable)} ; 500={statuses.Count(status => status == HttpStatusCode.InternalServerError)} ; commandees={ordered}");

        Assert.Multiple(() =>
        {
            Assert.That(statuses, Does.Not.Contain(HttpStatusCode.InternalServerError), "un interblocage ne remonte jamais en 500");
            Assert.That(statuses.Count(status => status is not (HttpStatusCode.Created or HttpStatusCode.ServiceUnavailable)), Is.Zero, "seuls 201 ou 503 (a rejouer) sont admis");
            Assert.That(ordered, Is.EqualTo(statuses.Count(status => status == HttpStatusCode.Created)), "toute commande annoncee existe, aucune n'est perdue");
        });
    }
}
