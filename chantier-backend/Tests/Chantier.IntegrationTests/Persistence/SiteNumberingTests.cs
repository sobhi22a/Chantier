using Chantier.Core.Sites;
using Chantier.Infrastructure.Persistence;
using Chantier.Infrastructure.Services.Sites;
using Chantier.IntegrationTests.Support;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>CT-22 : numerotation par chantier atomique, sans doublon ni trou, liberee par une annulation. Vraie base SQL Server.</summary>
[TestFixture]
public class SiteNumberingTests
{
    [OneTimeSetUp]
    public Task MigrateAsync() => TestDb.EnsureMigratedAsync();

    private static async Task<Guid> NewSiteAsync()
    {
        await using var db = TestDb.Create();
        var site = TestDb.NewSite();
        db.Sites.Add(site);
        await db.SaveChangesAsync();
        return site.Id;
    }

    /// <summary>Un numero demande et valide dans sa propre transaction, comme le fera une creation d'entite.</summary>
    private static async Task<string> NextCommittedAsync(Guid siteId, string prefix)
    {
        await using var db = TestDb.Create();
        await using var transaction = await db.Database.BeginTransactionAsync();
        var number = await new SiteNumbering(db).NextAsync(siteId, prefix);
        await transaction.CommitAsync();
        return number;
    }

    private static async Task<string?> NextRolledBackAsync(Guid siteId, string prefix)
    {
        await using var db = TestDb.Create();
        await using var transaction = await db.Database.BeginTransactionAsync();
        var number = await new SiteNumbering(db).NextAsync(siteId, prefix);
        await transaction.RollbackAsync();
        return number;
    }

    private static async Task<int> StoredValueAsync(Guid siteId, string prefix)
    {
        await using var db = TestDb.Create();
        return await db.SiteCounters.Where(counter => counter.SiteId == siteId && counter.Prefix == prefix).Select(counter => counter.LastValue).SingleAsync();
    }

    [Test]
    public async Task The_first_number_of_a_site_is_001_then_002()
    {
        var site = await NewSiteAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(await NextCommittedAsync(site, NumberPrefixes.Request), Is.EqualTo("DEM-001"));
            Assert.That(await NextCommittedAsync(site, NumberPrefixes.Request), Is.EqualTo("DEM-002"));
        });
    }

    [Test]
    public async Task Two_sites_are_numbered_independently()
    {
        var first = await NewSiteAsync();
        var second = await NewSiteAsync();

        var firstNumbers = new[] { await NextCommittedAsync(first, "DEM"), await NextCommittedAsync(first, "DEM") };
        var secondNumber = await NextCommittedAsync(second, "DEM");

        Assert.Multiple(() =>
        {
            Assert.That(firstNumbers, Is.EqualTo(new[] { "DEM-001", "DEM-002" }));
            Assert.That(secondNumber, Is.EqualTo("DEM-001"), "Un autre chantier repart de 001.");
        });
    }

    [Test]
    public async Task Each_document_type_has_its_own_counter_in_a_site()
    {
        var site = await NewSiteAsync();

        var numbers = new List<string>();
        foreach (var prefix in new[] { "DEM", "LIV", "T", "PB", "SIT", "DEM", "T" })
        {
            numbers.Add(await NextCommittedAsync(site, prefix));
        }

        Assert.That(numbers, Is.EqualTo(new[] { "DEM-001", "LIV-001", "T-001", "PB-001", "SIT-001", "DEM-002", "T-002" }));
    }

    [Test]
    public async Task Sixty_parallel_calls_give_sixty_distinct_numbers_without_gap()
    {
        var site = await NewSiteAsync(); // le compteur n'existe pas encore : la creation simultanee de la ligne est aussi eprouvee

        var numbers = await Task.WhenAll(Enumerable.Range(0, 60).Select(_ => Task.Run(() => NextCommittedAsync(site, NumberPrefixes.Request))));

        var expected = Enumerable.Range(1, 60).Select(value => $"DEM-{value:D3}").ToList();
        Assert.Multiple(async () =>
        {
            Assert.That(numbers, Is.Unique, "Aucun doublon.");
            Assert.That(numbers.Order().ToList(), Is.EqualTo(expected), "Aucun trou : 001 à 060.");
            Assert.That(await StoredValueAsync(site, "DEM"), Is.EqualTo(60));
        });
    }

    [Test]
    public async Task Parallel_calls_on_two_sites_and_two_types_stay_independent()
    {
        var first = await NewSiteAsync();
        var second = await NewSiteAsync();

        var work = new List<Task<(Guid Site, string Prefix, string Number)>>();
        for (var index = 0; index < 20; index++)
        {
            foreach (var (site, prefix) in new[] { (first, "DEM"), (first, "LIV"), (second, "DEM") })
            {
                work.Add(Task.Run(async () => (site, prefix, await NextCommittedAsync(site, prefix))));
            }
        }

        var results = await Task.WhenAll(work);

        Assert.Multiple(() =>
        {
            foreach (var group in results.GroupBy(result => (result.Site, result.Prefix)))
            {
                var expected = Enumerable.Range(1, 20).Select(value => SiteNumber.Format(group.Key.Prefix, value));
                Assert.That(group.Select(result => result.Number).Order().ToList(), Is.EqualTo(expected.Order().ToList()), $"{group.Key.Prefix}");
            }
        });
    }

    [Test]
    public async Task A_rolled_back_transaction_does_not_consume_a_number()
    {
        var site = await NewSiteAsync();
        var lost = await NextRolledBackAsync(site, "DEM");

        var next = await NextCommittedAsync(site, "DEM");

        Assert.Multiple(() =>
        {
            Assert.That(lost, Is.EqualTo("DEM-001"), "Le numéro était bien attribué dans la transaction annulée.");
            Assert.That(next, Is.EqualTo("DEM-001"), "Annulée : le numéro est de nouveau libre, pas de trou.");
        });
    }

    [Test]
    public async Task A_duplicate_client_id_rejected_by_the_unique_index_releases_the_number_it_had_taken()
    {
        // Deux creations simultanees du meme clientId : la perdante a deja pris un numero quand l'index unique (chantier, clientId) la refuse.
        var site = await NewSiteAsync();
        var clientId = Guid.NewGuid();

        await using (var db = TestDb.Create())
        {
            await using var transaction = await db.Database.BeginTransactionAsync();
            await new SiteNumbering(db).NextAsync(site, "DEM");
            db.Zones.Add(TestDb.NewZone(site, TestDb.ZoneInput("Bloc A"), clientId));
            db.Zones.Add(TestDb.NewZone(site, TestDb.ZoneInput("Bloc B"), clientId));

            Assert.ThrowsAsync<DbUpdateException>(() => db.SaveChangesAsync());
            await transaction.RollbackAsync();
        }

        Assert.That(await NextCommittedAsync(site, "DEM"), Is.EqualTo("DEM-001"), "Le numéro de la création refusée est libre.");
    }

    [Test]
    public async Task Rollbacks_mixed_with_commits_in_parallel_leave_no_gap()
    {
        var site = await NewSiteAsync();

        var results = await Task.WhenAll(Enumerable.Range(0, 30).Select(index => Task.Run(async () =>
            index % 3 == 0 ? await NextRolledBackAsync(site, "DEM") : await NextCommittedAsync(site, "DEM"))));

        var committed = results.Where((_, index) => index % 3 != 0).Order().ToList();
        Assert.Multiple(async () =>
        {
            Assert.That(committed, Has.Count.EqualTo(20));
            Assert.That(committed, Is.EqualTo(Enumerable.Range(1, 20).Select(value => $"DEM-{value:D3}")), "Les numéros validés se suivent sans trou.");
            Assert.That(await StoredValueAsync(site, "DEM"), Is.EqualTo(20));
        });
    }

    [Test]
    public async Task The_number_grows_past_999_without_truncation()
    {
        var site = await NewSiteAsync();
        await NextCommittedAsync(site, "DEM");
        await using (var db = TestDb.Create())
        {
            await db.SiteCounters.Where(counter => counter.SiteId == site).ExecuteUpdateAsync(set => set.SetProperty(counter => counter.LastValue, 998));
        }

        var numbers = new[] { await NextCommittedAsync(site, "DEM"), await NextCommittedAsync(site, "DEM"), await NextCommittedAsync(site, "DEM") };

        Assert.That(numbers, Is.EqualTo(new[] { "DEM-999", "DEM-1000", "DEM-1001" }));
    }

    [Test]
    public async Task Numbers_only_go_up_the_counter_cannot_become_negative_and_is_never_reset_by_the_service()
    {
        var site = await NewSiteAsync();
        var numbers = new List<int>();
        for (var index = 0; index < 5; index++)
        {
            await NextCommittedAsync(site, "LIV");
            numbers.Add(await StoredValueAsync(site, "LIV"));
        }

        await using var db = TestDb.Create();
        var negative = Assert.ThrowsAsync<SqlException>(() => db.Database.ExecuteSqlRawAsync("UPDATE SiteCounters SET LastValue = -1 WHERE SiteId = {0}", site));

        Assert.Multiple(() =>
        {
            Assert.That(numbers, Is.EqualTo(new[] { 1, 2, 3, 4, 5 }));
            Assert.That(negative!.Number, Is.EqualTo(547), "Contrainte CHECK LastValue >= 0.");
        });
    }

    [Test]
    public async Task A_transaction_is_required()
    {
        var site = await NewSiteAsync();
        await using var db = TestDb.Create();

        var failure = Assert.ThrowsAsync<InvalidOperationException>(() => new SiteNumbering(db).NextAsync(site, "DEM"));

        Assert.That(failure!.Message, Does.Contain("transaction"));
        Assert.That(await db.SiteCounters.Where(counter => counter.SiteId == site).AllAsync(counter => counter.LastValue == 0), Is.True, "Aucun numéro n'a été consommé.");
    }

    [Test]
    public async Task An_unknown_prefix_is_refused()
    {
        var site = await NewSiteAsync();
        await using var db = TestDb.Create();
        await using var transaction = await db.Database.BeginTransactionAsync();

        Assert.ThrowsAsync<ArgumentException>(() => new SiteNumbering(db).NextAsync(site, "XYZ"));
        Assert.ThrowsAsync<ArgumentException>(() => new SiteNumbering(db).NextAsync(site, "dem"));
    }

    [Test]
    public async Task An_unknown_site_cannot_get_a_counter()
    {
        await using var db = TestDb.Create();
        await using var transaction = await db.Database.BeginTransactionAsync();

        Assert.ThrowsAsync<SqlException>(() => new SiteNumbering(db).NextAsync(Guid.NewGuid(), "DEM"));
    }
}
