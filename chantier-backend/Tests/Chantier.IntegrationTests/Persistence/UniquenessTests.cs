using Chantier.Core.Entities.Sites;
using Chantier.IntegrationTests.Support;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>B2 : index uniques filtres (une base reelle est indispensable : EF InMemory ne verifie aucune contrainte).</summary>
[TestFixture]
public class UniquenessTests
{
    [OneTimeSetUp]
    public Task MigrateAsync() => TestDb.EnsureMigratedAsync();

    private static async Task AssertUniqueViolationAsync(Func<Task> action)
    {
        var exception = Assert.ThrowsAsync<DbUpdateException>(() => action());
        Assert.That(exception!.InnerException, Is.TypeOf<SqlException>());
        Assert.That(((SqlException)exception.InnerException!).Number, Is.AnyOf(2601, 2627), "Violation d'unicité attendue.");
        await Task.CompletedTask;
    }

    private static async Task<Site> AddSiteAsync()
    {
        await using var db = TestDb.Create();
        var site = TestDb.NewSite();
        db.Sites.Add(site);
        await db.SaveChangesAsync();
        return site;
    }

    [Test]
    public async Task Site_code_is_unique_among_non_deleted_sites()
    {
        var site = await AddSiteAsync();

        await AssertUniqueViolationAsync(async () =>
        {
            await using var db = TestDb.Create();
            db.Sites.Add(TestDb.NewSite(site.Code));
            await db.SaveChangesAsync();
        });
    }

    [Test]
    public async Task Zone_unicity_counts_missing_values_too()
    {
        var site = await AddSiteAsync();
        await using (var db = TestDb.Create())
        {
            db.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 01")));
            await db.SaveChangesAsync();
        }

        // Meme bloc, tout le reste absent : doublon.
        await AssertUniqueViolationAsync(async () =>
        {
            await using var db = TestDb.Create();
            db.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 01")));
            await db.SaveChangesAsync();
        });

        // Autres combinaisons : acceptees.
        await using var other = TestDb.Create();
        other.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 01", elevation: 3.40m)));
        other.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 01", elevation: 3.40m, roomType: RoomType.Classroom, roomNumber: 1)));
        other.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 01", elevation: 3.40m, roomType: RoomType.Classroom, roomNumber: 2)));
        other.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 01", elevation: 0.00m, roomType: RoomType.Classroom, roomNumber: 1)));
        other.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 02", roomType: RoomType.Facade)));
        other.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 02", roomType: RoomType.Other, roomLabel: "Local gardien")));
        Assert.That(async () => await other.SaveChangesAsync(), Throws.Nothing);

        // Meme combinaison avec cote identique et tous les autres champs : doublon, y compris avec libelle.
        await AssertUniqueViolationAsync(async () =>
        {
            await using var db = TestDb.Create();
            db.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 02", roomType: RoomType.Other, roomLabel: "Local gardien")));
            await db.SaveChangesAsync();
        });
    }

    [Test]
    public async Task Same_zone_can_exist_on_two_different_sites()
    {
        var first = await AddSiteAsync();
        var second = await AddSiteAsync();

        await using var db = TestDb.Create();
        db.Zones.Add(TestDb.NewZone(first.Id, TestDb.ZoneInput("Bloc 01", 0m)));
        db.Zones.Add(TestDb.NewZone(second.Id, TestDb.ZoneInput("Bloc 01", 0m)));

        Assert.That(async () => await db.SaveChangesAsync(), Throws.Nothing);
    }

    [Test]
    public async Task Archiving_a_zone_frees_its_combination()
    {
        var site = await AddSiteAsync();
        Guid zoneId;
        await using (var db = TestDb.Create())
        {
            var zone = TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 03", 1.00m));
            db.Zones.Add(zone);
            await db.SaveChangesAsync();
            zoneId = zone.Id;
        }

        await using (var db = TestDb.Create())
        {
            (await db.Zones.SingleAsync(z => z.Id == zoneId)).Archive(Guid.CreateVersion7(), DateTimeOffset.UtcNow);
            await db.SaveChangesAsync();
        }

        await using var again = TestDb.Create();
        again.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc 03", 1.00m)));
        Assert.That(async () => await again.SaveChangesAsync(), Throws.Nothing);
    }

    [Test]
    public async Task Client_id_is_unique_per_site_and_optional()
    {
        var site = await AddSiteAsync();
        var other = await AddSiteAsync();
        var clientId = Guid.NewGuid();
        await using (var db = TestDb.Create())
        {
            db.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc A"), clientId));
            await db.SaveChangesAsync();
        }

        await AssertUniqueViolationAsync(async () =>
        {
            await using var db = TestDb.Create();
            db.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc B"), clientId));
            await db.SaveChangesAsync();
        });

        await using var ok = TestDb.Create();
        ok.Zones.Add(TestDb.NewZone(other.Id, TestDb.ZoneInput("Bloc A"), clientId));
        ok.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc C"), null));
        ok.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput("Bloc D"), null));
        Assert.That(async () => await ok.SaveChangesAsync(), Throws.Nothing);
    }

    [Test]
    public async Task One_active_membership_per_site_and_user_and_removal_frees_the_pair()
    {
        var site = await AddSiteAsync();
        Guid userId;
        await using (var db = TestDb.Create())
        {
            userId = (await TestDb.AddUserAsync(db)).Id;
            db.SiteMembers.Add(SiteMember.Create(site.Id, userId));
            await db.SaveChangesAsync();
        }

        await AssertUniqueViolationAsync(async () =>
        {
            await using var db = TestDb.Create();
            db.SiteMembers.Add(SiteMember.Create(site.Id, userId));
            await db.SaveChangesAsync();
        });

        await using (var db = TestDb.Create())
        {
            db.SiteMembers.Remove(await db.SiteMembers.SingleAsync(m => m.SiteId == site.Id && m.UserId == userId));
            await db.SaveChangesAsync();
        }

        await using var again = TestDb.Create();
        again.SiteMembers.Add(SiteMember.Create(site.Id, userId));
        Assert.That(async () => await again.SaveChangesAsync(), Throws.Nothing, "Après un retrait, une nouvelle affectation est possible.");
    }

    [Test]
    public async Task Foreign_keys_are_enforced()
    {
        await using var db = TestDb.Create();
        db.Zones.Add(TestDb.NewZone(Guid.NewGuid(), TestDb.ZoneInput("Bloc X")));

        var exception = Assert.ThrowsAsync<DbUpdateException>(() => db.SaveChangesAsync());
        Assert.That(((SqlException)exception!.InnerException!).Number, Is.EqualTo(547));
        await Task.CompletedTask;
    }
}
