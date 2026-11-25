using System.Collections.Concurrent;
using System.Diagnostics;
using Chantier.Core.Sites;
using Chantier.Infrastructure.Services.Sites;
using Chantier.IntegrationTests.Support;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>
/// D-6 : les cinq compteurs naissent avec le chantier (meme ecriture) ; un chantier sans compteur (insertion manuelle, import) reste servi par
/// le repli, qui cree la ligne dans la transaction de l'appelant sous verrou applicatif, sans interblocage ni attente de 30 s.
/// </summary>
[TestFixture]
public class SiteNumberingFallbackTests
{
    [OneTimeSetUp]
    public Task MigrateAsync() => TestDb.EnsureMigratedAsync();

    private static async Task<Guid> NewSiteAsync(bool withoutCounters)
    {
        await using var db = TestDb.Create();
        var site = TestDb.NewSite();
        db.Sites.Add(site);
        await db.SaveChangesAsync();
        if (withoutCounters)
        {
            await db.SiteCounters.Where(counter => counter.SiteId == site.Id).ExecuteDeleteAsync();
        }

        return site.Id;
    }

    [Test]
    public async Task A_new_site_gets_its_five_counters_at_zero_in_the_same_write()
    {
        var site = await NewSiteAsync(withoutCounters: false);

        await using var db = TestDb.Create();
        var counters = await db.SiteCounters.Where(counter => counter.SiteId == site).OrderBy(counter => counter.Prefix).ToListAsync();

        Assert.Multiple(() =>
        {
            Assert.That(counters.Select(counter => counter.Prefix), Is.EquivalentTo(NumberPrefixes.All));
            Assert.That(counters.Select(counter => counter.LastValue), Has.All.Zero);
        });
    }

    [TestCase("update", TestName = "A_site_without_counter_gets_its_first_number_while_the_caller_has_updated_the_site_row")]
    [TestCase("update_lock_read", TestName = "A_site_without_counter_gets_its_first_number_while_the_caller_holds_an_update_lock_read")]
    [TestCase("none", TestName = "A_site_without_counter_gets_its_first_number_in_a_plain_transaction")]
    public async Task A_site_without_counter_gets_its_first_number_through_the_fallback(string how)
    {
        var site = await NewSiteAsync(withoutCounters: true);
        await using var db = TestDb.Create();
        await using var transaction = await db.Database.BeginTransactionAsync();
        if (how == "update")
        {
            await db.Database.ExecuteSqlAsync($"UPDATE Sites SET Name = Name WHERE Id = {site}");
        }
        else if (how == "update_lock_read")
        {
            await db.Database.ExecuteSqlAsync($"DECLARE @x int; SELECT @x = 1 FROM Sites WITH (UPDLOCK) WHERE Id = {site}");
        }

        var watch = Stopwatch.StartNew();
        var first = await new SiteNumbering(db).NextAsync(site, "DEM");
        var second = await new SiteNumbering(db).NextAsync(site, "DEM");
        watch.Stop();
        await transaction.CommitAsync();

        Assert.Multiple(() =>
        {
            Assert.That(first, Is.EqualTo("DEM-001"));
            Assert.That(second, Is.EqualTo("DEM-002"));
            Assert.That(watch.ElapsedMilliseconds, Is.LessThan(5000));
        });
    }

    [Test]
    public async Task A_rolled_back_fallback_leaves_no_counter_and_no_consumed_number()
    {
        var site = await NewSiteAsync(withoutCounters: true);
        await using (var db = TestDb.Create())
        {
            await using var transaction = await db.Database.BeginTransactionAsync();
            _ = await new SiteNumbering(db).NextAsync(site, "LIV");
            await transaction.RollbackAsync();
        }

        await using var check = TestDb.Create();
        Assert.That(await check.SiteCounters.CountAsync(counter => counter.SiteId == site), Is.Zero);
        await using var next = TestDb.Create();
        await using var second = await next.Database.BeginTransactionAsync();
        Assert.That(await new SiteNumbering(next).NextAsync(site, "LIV"), Is.EqualTo("LIV-001"));
    }

    [Test]
    public async Task Rollbacks_mixed_with_commits_stay_gapless_and_fast_through_the_fallback_over_repeated_rounds()
    {
        var durations = new List<long>();
        var failures = new ConcurrentBag<string>();
        var wrongSequences = 0;
        for (var round = 0; round < 15; round++)
        {
            var site = await NewSiteAsync(withoutCounters: true);
            var watch = Stopwatch.StartNew();
            var results = await Task.WhenAll(Enumerable.Range(0, 30).Select(index => Task.Run(() => RunAsync(site, index % 3 == 0, failures))));
            watch.Stop();
            durations.Add(watch.ElapsedMilliseconds);

            var committed = results.Where(number => number is not null).Select(number => number!).Order().ToList();
            var expected = Enumerable.Range(1, 20).Select(value => SiteNumber.Format("DEM", value)).Order().ToList();
            if (!committed.SequenceEqual(expected))
            {
                wrongSequences++;
            }
        }

        TestContext.Out.WriteLine($"Durees (ms) : {string.Join(", ", durations)} ; echecs SQL : {failures.Count}");
        Assert.Multiple(() =>
        {
            Assert.That(failures, Is.Empty, "Aucune exception SQL (delai ou interblocage).");
            Assert.That(wrongSequences, Is.Zero, "Les numeros valides se suivent sans trou.");
            Assert.That(durations.Max(), Is.LessThan(5000));
        });
    }

    private static async Task<string?> RunAsync(Guid siteId, bool rollback, ConcurrentBag<string> failures)
    {
        try
        {
            await using var db = TestDb.Create();
            await using var transaction = await db.Database.BeginTransactionAsync();
            var number = await new SiteNumbering(db).NextAsync(siteId, "DEM");
            if (rollback)
            {
                await transaction.RollbackAsync();
                return null;
            }

            await transaction.CommitAsync();
            return number;
        }
        catch (SqlException exception)
        {
            failures.Add($"SQL {exception.Number} : {exception.Message}");
            return null;
        }
    }
}
