using Chantier.Core.Abstractions;
using Chantier.Core.Entities.Sites;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Time.Testing;

namespace Chantier.IntegrationTests.Persistence;

/// <summary>B2 : audit automatique (CT-6), suppression logique et filtre nomme.</summary>
[TestFixture]
public class AuditAndFilterTests
{
    private static readonly Guid UserA = Guid.CreateVersion7();
    private static readonly Guid UserB = Guid.CreateVersion7();
    private static readonly Guid UserC = Guid.CreateVersion7();

    [OneTimeSetUp]
    public Task MigrateAsync() => TestDb.EnsureMigratedAsync();

    [Test]
    public async Task Audit_is_filled_on_create_update_and_archive_from_the_current_user_and_the_server_clock()
    {
        var created = new DateTimeOffset(2026, 11, 24, 8, 0, 0, TimeSpan.Zero);
        var clock = new FakeTimeProvider(created);
        var site = TestDb.NewSite();

        await using (var db = TestDb.Create(UserA, clock))
        {
            db.Sites.Add(site);
            await db.SaveChangesAsync();
        }

        clock.Advance(TimeSpan.FromHours(2));
        await using (var db = TestDb.Create(UserB, clock))
        {
            var loaded = await db.Sites.SingleAsync(s => s.Id == site.Id);
            loaded.Update(TestDb.SiteInput("Nouveau nom"));
            await db.SaveChangesAsync();
        }

        clock.Advance(TimeSpan.FromHours(1));
        await using (var db = TestDb.Create(UserC, clock))
        {
            var loaded = await db.Sites.SingleAsync(s => s.Id == site.Id);
            loaded.Archive(UserC, clock.GetUtcNow());
            await db.SaveChangesAsync();
        }

        await using var read = TestDb.Create();
        var stored = await read.Sites.AsNoTracking().SingleAsync(s => s.Id == site.Id);

        Assert.Multiple(() =>
        {
            Assert.That(stored.CreatedBy, Is.EqualTo(UserA));
            Assert.That(stored.CreatedAt, Is.EqualTo(created));
            Assert.That(stored.UpdatedBy, Is.EqualTo(UserC), "Dernière modification = archivage par C.");
            Assert.That(stored.UpdatedAt, Is.EqualTo(created.AddHours(3)));
            Assert.That(stored.ArchivedBy, Is.EqualTo(UserC));
            Assert.That(stored.ArchivedAt, Is.EqualTo(created.AddHours(3)));
            Assert.That(stored.Name, Is.EqualTo("Nouveau nom"));
            Assert.That(stored.IsDeleted, Is.False, "Archiver n'est pas supprimer.");
        });
    }

    [Test]
    public async Task Update_by_B_keeps_the_creator_and_sets_the_modifier()
    {
        var clock = new FakeTimeProvider(new DateTimeOffset(2026, 11, 24, 8, 0, 0, TimeSpan.Zero));
        var site = TestDb.NewSite();
        await using (var db = TestDb.Create(UserA, clock))
        {
            db.Sites.Add(site);
            await db.SaveChangesAsync();
        }

        clock.Advance(TimeSpan.FromMinutes(5));
        await using (var db = TestDb.Create(UserB, clock))
        {
            (await db.Sites.SingleAsync(s => s.Id == site.Id)).Update(TestDb.SiteInput("Autre nom"));
            await db.SaveChangesAsync();
        }

        await using var read = TestDb.Create();
        var stored = await read.Sites.AsNoTracking().SingleAsync(s => s.Id == site.Id);
        Assert.Multiple(() =>
        {
            Assert.That(stored.CreatedBy, Is.EqualTo(UserA));
            Assert.That(stored.UpdatedBy, Is.EqualTo(UserB));
            Assert.That(stored.UpdatedAt, Is.EqualTo(clock.GetUtcNow()));
        });
    }

    [Test]
    public async Task Writes_outside_a_request_are_attributed_to_the_system_actor()
    {
        var site = TestDb.NewSite();
        await using var db = TestDb.Create(userId: null);
        db.Sites.Add(site);
        await db.SaveChangesAsync();

        Assert.That(site.CreatedBy, Is.EqualTo(SystemActor.Id));
    }

    [Test]
    public async Task Client_cannot_forge_audit_fields_because_the_entity_exposes_no_setter()
    {
        // Les champs d'audit n'ont que des setters prives : seuls MarkCreated/MarkUpdated (reserves a l'intercepteur) les posent.
        var properties = new[] { nameof(Site.CreatedAt), nameof(Site.CreatedBy), nameof(Site.UpdatedAt), nameof(Site.UpdatedBy), nameof(Site.DeletedAt), nameof(Site.DeletedBy), nameof(Site.RowVersion) };
        foreach (var name in properties)
        {
            var setter = typeof(Site).GetProperty(name)!.SetMethod;
            Assert.That(setter is null || !setter.IsPublic, Is.True, $"{name} ne doit pas avoir de setter public.");
        }

        await Task.CompletedTask;
    }

    [Test]
    public async Task Remove_is_converted_into_a_logical_deletion_traced_with_who_and_when()
    {
        var clock = new FakeTimeProvider(new DateTimeOffset(2026, 11, 24, 9, 0, 0, TimeSpan.Zero));
        Guid memberId;
        Guid siteId;
        await using (var db = TestDb.Create(UserA, clock))
        {
            var user = await TestDb.AddUserAsync(db);
            var site = TestDb.NewSite();
            db.Sites.Add(site);
            await db.SaveChangesAsync();
            var member = SiteMember.Create(site.Id, user.Id);
            db.SiteMembers.Add(member);
            await db.SaveChangesAsync();
            memberId = member.Id;
            siteId = site.Id;
        }

        clock.Advance(TimeSpan.FromMinutes(30));
        await using (var db = TestDb.Create(UserB, clock))
        {
            var member = await db.SiteMembers.SingleAsync(m => m.Id == memberId);
            db.SiteMembers.Remove(member);
            await db.SaveChangesAsync();
        }

        await using var read = TestDb.Create();
        var visible = await read.SiteMembers.Where(m => m.SiteId == siteId).ToListAsync();
        var all = await read.SiteMembers.IgnoreQueryFilters([QueryFilterNames.SoftDelete]).AsNoTracking().Where(m => m.SiteId == siteId).ToListAsync();

        Assert.Multiple(() =>
        {
            Assert.That(visible, Is.Empty, "Le filtre SoftDelete masque la ligne retirée.");
            Assert.That(all, Has.Count.EqualTo(1), "Rien n'est supprimé physiquement.");
            Assert.That(all[0].DeletedBy, Is.EqualTo(UserB));
            Assert.That(all[0].DeletedAt, Is.EqualTo(clock.GetUtcNow()));
            Assert.That(all[0].CreatedBy, Is.EqualTo(UserA));
        });
    }

    [Test]
    public async Task Default_queries_never_return_logically_deleted_rows()
    {
        await using var db = TestDb.Create(UserA);
        var site = TestDb.NewSite();
        db.Sites.Add(site);
        await db.SaveChangesAsync();
        db.Sites.Remove(site);
        await db.SaveChangesAsync();

        await using var read = TestDb.Create();
        Assert.Multiple(async () =>
        {
            Assert.That(await read.Sites.AnyAsync(s => s.Id == site.Id), Is.False);
            Assert.That(await read.Sites.IgnoreQueryFilters([QueryFilterNames.SoftDelete]).AnyAsync(s => s.Id == site.Id), Is.True);
            Assert.That(await read.Sites.CountAsync(s => s.Id == site.Id), Is.Zero);
        });
    }

    [Test]
    public void The_soft_delete_filter_is_a_named_filter_on_every_basic_entity()
    {
        using var db = TestDb.Create();
        var names = new[] { typeof(Site), typeof(Zone), typeof(SiteMember) }
            .Select(type => db.Model.FindEntityType(type)!)
            .Select(entityType => entityType.GetDeclaredQueryFilters().Select(filter => filter.Key).ToArray())
            .ToList();

        Assert.That(names, Is.All.EqualTo(new[] { QueryFilterNames.SoftDelete }));
    }

    [Test]
    public void The_model_has_no_pending_change_compared_with_the_migrations()
    {
        using var db = TestDb.Create();

        Assert.That(db.Database.HasPendingModelChanges(), Is.False, "Une migration manque : dotnet ef migrations add ...");
    }

    [Test]
    public async Task Decimal_columns_have_explicit_precision()
    {
        await using var db = TestDb.Create();
        var decimals = db.Model.GetEntityTypes()
            .SelectMany(type => type.GetProperties())
            .Where(property => property.ClrType == typeof(decimal) || property.ClrType == typeof(decimal?))
            .Select(property => (property.DeclaringType.DisplayName() + "." + property.Name, property.GetPrecision(), property.GetScale()))
            .ToList();

        Assert.Multiple(() =>
        {
            Assert.That(decimals, Is.Not.Empty);
            Assert.That(decimals, Is.All.Matches<(string Name, int? Precision, int? Scale)>(d => d.Precision != null && d.Scale != null));
        });

        await Task.CompletedTask;
    }

    [Test]
    public async Task Enumerations_are_stored_as_strings()
    {
        var site = TestDb.NewSite(input: TestDb.SiteInput(type: SiteType.PublicFacility));
        await using (var db = TestDb.Create(UserA))
        {
            db.Sites.Add(site);
            db.Zones.Add(TestDb.NewZone(site.Id, TestDb.ZoneInput(roomType: RoomType.TechnicalRoom, roomNumber: 1)));
            await db.SaveChangesAsync();
        }

        await using var connection = new Microsoft.Data.SqlClient.SqlConnection(SqlServerFixture.ConnectionString);
        await connection.OpenAsync();
        await using var command = connection.CreateCommand();
        command.CommandText = "SELECT s.Type, z.RoomType FROM Sites s JOIN Zones z ON z.SiteId = s.Id WHERE s.Id = @id";
        command.Parameters.AddWithValue("@id", site.Id);
        await using var reader = await command.ExecuteReaderAsync();
        Assert.That(await reader.ReadAsync(), Is.True);
        Assert.Multiple(() =>
        {
            Assert.That(reader.GetString(0), Is.EqualTo("PublicFacility"));
            Assert.That(reader.GetString(1), Is.EqualTo("TechnicalRoom"));
        });
    }
}
