using System.Collections.Concurrent;
using System.Diagnostics;
using Chantier.Core.Sites;
using Chantier.Infrastructure.Services.Sites;
using Chantier.IntegrationTests.Support;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Chantier.IntegrationTests.Qa;

/// <summary>
/// Q1 : diagnostic du test signale instable <c>Rollbacks_mixed_with_commits_in_parallel_leave_no_gap</c> (CT-22).
/// Rejoue le meme scenario plusieurs fois, journalise la duree de chaque tour et le type exact des echecs (delai, interblocage, autre),
/// pour distinguer un defaut de la numerotation d'un test sensible a la charge du poste.
/// </summary>
[TestFixture]
public class NumberingStabilityTests
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
            failures.Add($"SqlException {exception.Number} : {exception.Message}");
            return null;
        }
    }

    [TestCase(false, TestName = "Rollbacks_mixed_with_commits_stay_gapless_and_fast_over_repeated_rounds_cold_counter")]
    [TestCase(true, TestName = "Rollbacks_mixed_with_commits_stay_gapless_and_fast_over_repeated_rounds_warm_counter")]
    public async Task Rollbacks_mixed_with_commits_stay_gapless_and_fast_over_repeated_rounds(bool warmCounter)
    {
        const int Rounds = 15;
        var durations = new List<long>();
        var failures = new ConcurrentBag<string>();
        var wrongSequences = 0;

        for (var round = 0; round < Rounds; round++)
        {
            var site = await NewSiteAsync();
            var offset = 0;
            if (warmCounter)
            {
                // La ligne du compteur existe deja : seul le chemin « UPDATE » est eprouve, pas la creation simultanee de la ligne.
                await RunAsync(site, false, failures);
                offset = 1;
            }

            var watch = Stopwatch.StartNew();
            var results = await Task.WhenAll(Enumerable.Range(0, 30).Select(index => Task.Run(() => RunAsync(site, index % 3 == 0, failures))));
            watch.Stop();
            durations.Add(watch.ElapsedMilliseconds);

            var committed = results.Where(number => number is not null).Select(number => number!).Order().ToList();
            var expected = Enumerable.Range(1 + offset, 20).Select(value => SiteNumber.Format("DEM", value)).OrderBy(value => value).ToList();
            if (failures.IsEmpty && !committed.SequenceEqual(expected))
            {
                wrongSequences++;
            }
        }

        TestContext.Out.WriteLine($"Durees (ms) par tour de 30 appels : {string.Join(", ", durations)} ; max = {durations.Max()} ms");
        TestContext.Out.WriteLine($"Echecs SQL : {failures.Count} ; suites erronees : {wrongSequences}");
        foreach (var failure in failures.Distinct())
        {
            TestContext.Out.WriteLine(failure);
        }

        Assert.Multiple(() =>
        {
            Assert.That(failures, Is.Empty, "Aucune exception SQL (delai ou interblocage).");
            Assert.That(wrongSequences, Is.Zero, "Les numeros valides se suivent sans trou.");
            Assert.That(durations.Max(), Is.LessThan(5000), "Un tour de 30 transactions en file ne doit pas approcher le delai de commande de 15 s.");
        });
    }

    [Test]
    public async Task Sixty_parallel_calls_stay_fast_over_repeated_rounds()
    {
        var durations = new List<long>();
        var failures = new ConcurrentBag<string>();
        for (var round = 0; round < 8; round++)
        {
            var site = await NewSiteAsync();
            var watch = Stopwatch.StartNew();
            var results = await Task.WhenAll(Enumerable.Range(0, 60).Select(_ => Task.Run(() => RunAsync(site, false, failures))));
            watch.Stop();
            durations.Add(watch.ElapsedMilliseconds);
            Assert.That(results.Select(number => number!).Order().ToList(), Is.EqualTo(Enumerable.Range(1, 60).Select(value => SiteNumber.Format("DEM", value))));
        }

        TestContext.Out.WriteLine($"60 appels : durees (ms) {string.Join(", ", durations)}");
        Assert.That(failures, Is.Empty);
        Assert.That(durations.Max(), Is.LessThan(8000));
    }

    [TestCase("plain_read", TestName = "A_first_number_can_be_taken_after_a_plain_read_of_the_site")]
    [TestCase("update_lock_read", TestName = "A_first_number_can_be_taken_while_the_caller_holds_an_update_lock_read_on_the_site")]
    [TestCase("update", TestName = "A_first_number_can_be_taken_while_the_caller_has_updated_the_site_row")]
    [TestCase("zone_insert", TestName = "A_first_number_can_be_taken_after_inserting_a_zone_of_the_site_in_the_same_transaction")]
    public async Task A_first_number_can_be_taken_while_the_caller_holds_a_lock_on_the_site_row(string how)
    {
        // Cas probable du lot « Demandes » : la creation verifie ou touche le chantier (verrou d'ecriture) puis demande son numero.
        // La ligne du compteur est creee sur une AUTRE connexion : sa cle etrangere vers le chantier ne doit pas attendre la transaction de l'appelant.
        var site = await NewSiteAsync();
        await using var db = TestDb.Create();
        await using var transaction = await db.Database.BeginTransactionAsync();
        switch (how)
        {
            case "plain_read":
                await db.Database.ExecuteSqlAsync($"DECLARE @x int; SELECT @x = 1 FROM Sites WHERE Id = {site}");
                break;
            case "update_lock_read":
                await db.Database.ExecuteSqlAsync($"DECLARE @x int; SELECT @x = 1 FROM Sites WITH (UPDLOCK) WHERE Id = {site}");
                break;
            case "update":
                await db.Database.ExecuteSqlAsync($"UPDATE Sites SET Name = Name WHERE Id = {site}");
                break;
            default:
                db.Zones.Add(TestDb.NewZone(site, TestDb.ZoneInput("Bloc 01")));
                await db.SaveChangesAsync();
                break;
        }

        var watch = Stopwatch.StartNew();
        string? number = null;
        Exception? failure = null;
        try
        {
            number = await new SiteNumbering(db).NextAsync(site, "DEM");
        }
        catch (Exception exception)
        {
            failure = exception;
        }

        watch.Stop();
        await transaction.RollbackAsync();
        TestContext.Out.WriteLine($"Premier numero ({how}) : {number ?? failure?.GetType().Name} en {watch.ElapsedMilliseconds} ms");
        Assert.Multiple(() =>
        {
            Assert.That(failure, Is.Null, failure?.Message);
            Assert.That(number, Is.EqualTo("DEM-001"));
            Assert.That(watch.ElapsedMilliseconds, Is.LessThan(5000));
        });
    }

    [Test]
    public async Task A_legacy_site_without_counter_rows_takes_the_fallback_path_without_deadlock_even_with_a_locked_site_row()
    {
        // Chantier cree avant la migration BackfillSiteCounters (ou ligne supprimee) : repli par verrou applicatif.
        const int Rounds = 15;
        var durations = new List<long>();
        var failures = new ConcurrentBag<string>();
        var wrong = 0;
        for (var round = 0; round < Rounds; round++)
        {
            var site = await NewSiteAsync();
            await using (var cleanup = TestDb.Create())
            {
                await cleanup.Database.ExecuteSqlAsync($"DELETE FROM SiteCounters WHERE SiteId = {site}");
            }

            var watch = Stopwatch.StartNew();
            var results = await Task.WhenAll(Enumerable.Range(0, 30).Select(index => Task.Run(() => RunAsync(site, index % 3 == 0, failures))));
            watch.Stop();
            durations.Add(watch.ElapsedMilliseconds);
            var committed = results.Where(number => number is not null).Select(number => number!).Order().ToList();
            if (failures.IsEmpty && !committed.SequenceEqual(Enumerable.Range(1, 20).Select(value => SiteNumber.Format("DEM", value)).OrderBy(value => value)))
            {
                wrong++;
            }
        }

        // Et le premier numero d'un chantier ancien dont la ligne du chantier est deja ecrite par l'appelant.
        var locked = await NewSiteAsync();
        await using (var cleanup = TestDb.Create())
        {
            await cleanup.Database.ExecuteSqlAsync($"DELETE FROM SiteCounters WHERE SiteId = {locked}");
        }

        string? lockedNumber = null;
        var lockedWatch = Stopwatch.StartNew();
        await using (var db = TestDb.Create())
        {
            await using var transaction = await db.Database.BeginTransactionAsync();
            await db.Database.ExecuteSqlAsync($"UPDATE Sites SET Name = Name WHERE Id = {locked}");
            try
            {
                lockedNumber = await new SiteNumbering(db).NextAsync(locked, "DEM");
            }
            catch (Exception exception)
            {
                failures.Add(exception.GetType().Name + " : " + exception.Message);
            }

            await transaction.RollbackAsync();
        }

        lockedWatch.Stop();
        TestContext.Out.WriteLine($"Chantier ancien : tours {string.Join(", ", durations)} ms ; premier numero avec verrou {lockedNumber} en {lockedWatch.ElapsedMilliseconds} ms ; echecs {failures.Count}");
        Assert.Multiple(() =>
        {
            Assert.That(failures, Is.Empty);
            Assert.That(wrong, Is.Zero);
            Assert.That(durations.Max(), Is.LessThan(5000));
            Assert.That(lockedNumber, Is.EqualTo("DEM-001"));
            Assert.That(lockedWatch.ElapsedMilliseconds, Is.LessThan(5000));
        });
    }
}
