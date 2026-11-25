using System.Globalization;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.SitesTestKit;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Sync;

/// <summary>
/// CT-8, le risque majeur du curseur : une ligne de version basse validee <b>apres</b> une ligne de version haute ne doit jamais etre perdue.
/// Base dediee : <c>MIN_ACTIVE_ROWVERSION()</c> est propre a la base, les autres tests ne doivent pas y interferer.
/// </summary>
[TestFixture]
public class SyncOpenTransactionTests
{
    private string _connectionString = null!;
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public async Task SetUp()
    {
        _connectionString = await SqlServerFixture.CreateDatabaseAsync("sync");
        _factory = new ChantierWebApplicationFactory();
        _factory.Settings["ConnectionStrings:ChantierDb"] = _connectionString;
    }

    [OneTimeTearDown]
    public async Task TearDown()
    {
        _factory.Dispose();
        await SqlServerFixture.DropDatabaseAsync(_connectionString);
    }

    [Test]
    public async Task A_row_committed_late_with_a_low_version_is_never_lost()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(members: chef.Account.Id);
        await _factory.SeedZoneAsync(site.Id, "Bloc 01");
        var (_, _, cursorBefore) = await chef.PullAllAsync();

        // Transaction A : zone inseree (version basse), pas encore validee.
        await using var contextA = CreateContext(_connectionString);
        await using var transactionA = await contextA.Database.BeginTransactionAsync();
        var lateZone = TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc A"));
        contextA.Zones.Add(lateZone);
        await contextA.SaveChangesAsync();

        // Transaction B : validee apres A mais avec une version PLUS HAUTE.
        await using var contextB = CreateContext(_connectionString);
        var earlyZone = TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc B"));
        contextB.Zones.Add(earlyZone);
        await contextB.SaveChangesAsync();
        Assert.That(earlyZone.RowVersion, Is.GreaterThan(lateZone.RowVersion), "B est écrite après A : version plus haute.");

        // Pendant que A est ouverte : le curseur ne dépasse pas la version de A, et B n'est pas encore donnée (elle est derrière A).
        var duringOpen = await chef.PullAsync(cursorBefore);
        var cursorDuring = ulong.Parse(duringOpen.GetProperty("cursor").GetString()!, CultureInfo.InvariantCulture);

        Assert.Multiple(() =>
        {
            Assert.That(duringOpen.GetProperty("changes").GetArrayLength(), Is.Zero, "Ni A (non validée) ni B (derrière A).");
            Assert.That(duringOpen.GetProperty("hasMore").GetBoolean(), Is.False);
            Assert.That(cursorDuring, Is.LessThan(lateZone.RowVersion), "Le curseur n'avance jamais au-delà d'une transaction ouverte.");
        });

        await transactionA.CommitAsync();

        // A validee : les deux lignes arrivent, dans l'ordre des versions, sans perte.
        var (changes, _, _) = await chef.PullAllAsync(duringOpen.GetProperty("cursor").GetString());
        Assert.That(
            changes.Of("zone").Select(row => row.GetProperty("id").GetGuid()),
            Is.EqualTo(new[] { lateZone.Id, earlyZone.Id }));
    }

    [Test]
    public async Task Paging_through_an_open_transaction_never_skips_a_row()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var site = await _factory.SeedSiteAsync(members: chef.Account.Id);
        var (_, _, start) = await chef.PullAllAsync();

        await using var contextA = CreateContext(_connectionString);
        await using var transactionA = await contextA.Database.BeginTransactionAsync();
        var late = TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc Late"));
        contextA.Zones.Add(late);
        await contextA.SaveChangesAsync();

        var committed = new List<Guid>();
        for (var index = 0; index < 5; index++)
        {
            committed.Add(await _factory.SeedZoneAsync(site.Id, $"Bloc {index}"));
        }

        var firstRead = await chef.PullAllAsync(start, limit: 2);
        await transactionA.CommitAsync();
        var secondRead = await chef.PullAllAsync(firstRead.Cursor, limit: 2);

        var received = firstRead.Changes.Concat(secondRead.Changes).Of("zone").Select(row => row.GetProperty("id").GetGuid()).ToList();
        Assert.Multiple(() =>
        {
            Assert.That(firstRead.Changes, Is.Empty);
            Assert.That(received, Is.EquivalentTo(committed.Append(late.Id)), "Aucune ligne perdue, aucune en double.");
            Assert.That(received, Is.Unique);
        });
    }
}
