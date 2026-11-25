using Chantier.Core.Entities.Sites;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Support;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>
/// Risque majeur de l'ADR 0003 verifie sur une vraie base : (1) l'ordre des comparaisons <c>RowVersion</c> avec le convertisseur
/// gros-boutiste ; (2) l'effet de <c>MIN_ACTIVE_ROWVERSION()</c> avec une transaction ouverte (borne sure du curseur de synchro).
/// </summary>
[TestFixture]
public class RowVersionTests
{
    [OneTimeSetUp]
    public Task MigrateAsync() => TestDb.EnsureMigratedAsync();

    [Test]
    public async Task Comparisons_follow_the_numeric_order_even_across_byte_boundaries()
    {
        var marker = TestDb.UniqueCode("RV");
        await using (var write = TestDb.Create())
        {
            // 300 lignes : les versions franchissent 255 -> 256, la ou un convertisseur petit-boutiste inverserait l'ordre.
            for (var index = 0; index < 300; index++)
            {
                write.Sites.Add(TestDb.NewSite($"{marker}-{index:D3}"));
            }

            await write.SaveChangesAsync();
        }

        await using var db = TestDb.Create();
        var viaLinq = await db.Sites
            .Where(site => site.Code.StartsWith(marker))
            .OrderBy(site => site.RowVersion)
            .Select(site => new { site.Code, site.RowVersion })
            .ToListAsync();

        // Verite terrain : l'entier SQL Server lui-meme.
        var viaSql = new List<(string Code, long Version)>();
        await using (var connection = new SqlConnection(SqlServerFixture.ConnectionString))
        {
            await connection.OpenAsync();
            await using var command = connection.CreateCommand();
            command.CommandText = "SELECT Code, CAST(RowVersion AS bigint) FROM Sites WHERE Code LIKE @prefix ORDER BY CAST(RowVersion AS bigint)";
            command.Parameters.AddWithValue("@prefix", marker + "%");
            await using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                viaSql.Add((reader.GetString(0), reader.GetInt64(1)));
            }
        }

        Assert.Multiple(() =>
        {
            Assert.That(viaLinq, Has.Count.EqualTo(300));
            Assert.That(viaLinq.Select(row => row.Code), Is.EqualTo(viaSql.Select(row => row.Code)), "L'ordre EF doit être l'ordre numérique de SQL Server.");
            Assert.That(viaLinq.Select(row => (long)row.RowVersion), Is.EqualTo(viaSql.Select(row => row.Version)), "ulong lu = entier SQL Server.");
            Assert.That(viaLinq.Select(row => row.RowVersion), Is.Ordered.Ascending);
            Assert.That(viaLinq[0].RowVersion / 256, Is.Not.EqualTo(viaLinq[^1].RowVersion / 256), $"Les 300 versions franchissent une frontière d'octet (min {viaLinq[0].RowVersion}, max {viaLinq[^1].RowVersion}).");
        });

        // Comparaison > since : doit couper exactement la ou l'ordre numerique le dit.
        var pivot = viaLinq[149].RowVersion;
        var after = await db.Sites.Where(site => site.Code.StartsWith(marker) && site.RowVersion > pivot).CountAsync();
        var upTo = await db.Sites.Where(site => site.Code.StartsWith(marker) && site.RowVersion <= pivot).CountAsync();
        Assert.Multiple(() =>
        {
            Assert.That(after, Is.EqualTo(150));
            Assert.That(upTo, Is.EqualTo(150));
        });
    }

    [Test]
    public async Task Version_property_is_the_decimal_string_of_the_row_version()
    {
        await using var db = TestDb.Create();
        var site = TestDb.NewSite();
        db.Sites.Add(site);
        await db.SaveChangesAsync();

        Assert.Multiple(() =>
        {
            Assert.That(site.RowVersion, Is.GreaterThan(0UL), "EF relit la version générée par la base après l'insertion.");
            Assert.That(site.Version, Is.EqualTo(site.RowVersion.ToString(System.Globalization.CultureInfo.InvariantCulture)));
        });
    }

    [Test]
    public async Task Min_active_rowversion_hides_later_commits_until_the_open_transaction_ends()
    {
        // Ligne de depart deja validee : le « curseur » du client.
        await using var contextBaseline = TestDb.Create();
        var baseline = TestDb.NewSite();
        contextBaseline.Sites.Add(baseline);
        await contextBaseline.SaveChangesAsync();

        // Transaction A : ligne inseree, pas encore validee (version basse).
        await using var contextA = TestDb.Create();
        await using var transactionA = await contextA.Database.BeginTransactionAsync();
        var siteA = TestDb.NewSite();
        contextA.Sites.Add(siteA);
        await contextA.SaveChangesAsync();

        // Transaction B : validee apres A, mais avec une version PLUS HAUTE.
        await using var contextB = TestDb.Create();
        var siteB = TestDb.NewSite();
        contextB.Sites.Add(siteB);
        await contextB.SaveChangesAsync();

        Assert.That(siteB.RowVersion, Is.GreaterThan(siteA.RowVersion), "B a été écrite après A : version plus haute.");

        await using var reader = TestDb.Create();
        var upper = await ReadMinActiveRowVersionAsync();
        Assert.That(upper, Is.LessThanOrEqualTo(siteA.RowVersion), "La borne sûre ne dépasse jamais la plus basse version d'une transaction ouverte.");

        // Requete de la forme du futur « pull » : fenetre de versions (curseur, borne sure), sans filtre sur l'identifiant,
        // pour ne pas buter sur la ligne verrouillee de A. Pendant que A est ouverte : ni A (non validee) ni B
        // (validee mais derriere A) ne sont dans la fenetre.
        var cursor = baseline.RowVersion;
        var windowBefore = await reader.Sites
            .Where(site => site.RowVersion > cursor && site.RowVersion < upper)
            .OrderBy(site => site.RowVersion)
            .Select(site => site.Id)
            .ToListAsync();
        Assert.That(windowBefore, Does.Not.Contain(siteA.Id).And.Not.Contain(siteB.Id), "Avancer le curseur jusqu'à la borne ne saute aucune ligne.");

        await transactionA.CommitAsync();

        // A validee : la borne avance au-dela des deux versions, les deux lignes arrivent dans l'ordre.
        var upperAfter = await ReadMinActiveRowVersionAsync();
        var windowAfter = await reader.Sites
            .Where(site => site.RowVersion > cursor && site.RowVersion < upperAfter)
            .OrderBy(site => site.RowVersion)
            .Select(site => site.Id)
            .ToListAsync();

        Assert.Multiple(() =>
        {
            Assert.That(upperAfter, Is.GreaterThan(siteB.RowVersion));
            Assert.That(windowAfter.Where(id => id == siteA.Id || id == siteB.Id), Is.EqualTo(new[] { siteA.Id, siteB.Id }));
        });
    }

    private static async Task<ulong> ReadMinActiveRowVersionAsync()
    {
        await using var connection = new SqlConnection(SqlServerFixture.ConnectionString);
        await connection.OpenAsync();
        await using var command = connection.CreateCommand();
        command.CommandText = "SELECT MIN_ACTIVE_ROWVERSION()";
        var bytes = (byte[])(await command.ExecuteScalarAsync())!;
        return RowVersionConverter.ToNumber(bytes);
    }

    [Test]
    public async Task Stale_version_is_detected_as_a_concurrency_conflict()
    {
        await using var seed = TestDb.Create();
        var site = TestDb.NewSite();
        seed.Sites.Add(site);
        await seed.SaveChangesAsync();

        await using var first = TestDb.Create();
        await using var second = TestDb.Create();
        var fromFirst = await first.Sites.SingleAsync(s => s.Id == site.Id);
        var fromSecond = await second.Sites.SingleAsync(s => s.Id == site.Id);

        fromFirst.Update(TestDb.SiteInput("Premier"));
        await first.SaveChangesAsync();

        fromSecond.Update(TestDb.SiteInput("Second"));
        Assert.ThrowsAsync<DbUpdateConcurrencyException>(() => second.SaveChangesAsync());
    }
}
