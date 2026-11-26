using Chantier.Core.Entities.Materials;
using Chantier.Core.Entities.Sync;
using Chantier.Infrastructure.Persistence;
using Chantier.Infrastructure.Storage;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>R2-10 : maintenance des photos (fichiers temporaires abandonnes, photos en attente expirees, controle base / disque sans suppression) et purge du journal d'operations.</summary>
[TestFixture]
public class PhotoMaintenanceTests : DeliveryFixtureBase
{
    private string PhotosRoot => Path.GetFullPath(Factory.Settings["Storage:PhotosRoot"]!);

    private async Task<MaintenanceReport> RunAsync()
    {
        await using var scope = Factory.Services.CreateAsyncScope();
        return await scope.ServiceProvider.GetRequiredService<PhotoMaintenance>().RunAsync();
    }

    private async Task<Guid> NewDeliveryAsync()
        => (await DeliverAsync(await OrderedRequestAsync(600m), 10m, "t")).Id();

    private async Task<(Guid Id, byte[] Jpeg)> NewPhotoAsync(Guid delivery, byte seed, bool upload)
    {
        var jpeg = Jpeg(seed);
        var response = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), new
        {
            clientId = Guid.NewGuid(),
            takenAt = "2026-11-25T08:10:00Z",
            contentType = "image/jpeg",
            sizeBytes = jpeg.Length,
            sha256 = Sha256Hex(jpeg),
        });
        var id = (await response.JsonAsync()).Id();
        if (upload)
        {
            await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, id), jpeg);
        }

        return (id, jpeg);
    }

    private async Task SetCreatedAtAsync(Guid photoId, TimeSpan age)
    {
        await using var scope = Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var old = Factory.Time.GetUtcNow() - age;
        await db.Photos.Where(photo => photo.Id == photoId).ExecuteUpdateAsync(set => set.SetProperty(photo => photo.CreatedAt, old));
    }

    [Test]
    public async Task Abandoned_temporary_files_are_deleted_and_recent_ones_are_kept()
    {
        await RunAsync(); // cree le dossier temporaire
        var staging = Path.Combine(PhotosRoot, ".staging");
        var stale = Path.Combine(staging, Guid.NewGuid().ToString("N") + ".part");
        var recent = Path.Combine(staging, Guid.NewGuid().ToString("N") + ".part");
        await File.WriteAllBytesAsync(stale, [1]);
        await File.WriteAllBytesAsync(recent, [1]);
        File.SetLastWriteTimeUtc(stale, DateTime.UtcNow.AddHours(-3));

        var report = await RunAsync();

        Assert.Multiple(() =>
        {
            Assert.That(File.Exists(stale), Is.False, "envoi interrompu par un arret brutal : fichier abandonne");
            Assert.That(File.Exists(recent), Is.True, "un envoi en cours n'est jamais touche");
            Assert.That(report.StagingFilesDeleted, Is.GreaterThanOrEqualTo(1));
        });
        File.Delete(recent);
    }

    [Test]
    public async Task Pending_photos_expire_after_seven_days_and_received_photos_never_do()
    {
        var delivery = await NewDeliveryAsync();
        var stalePending = await NewPhotoAsync(delivery, 1, upload: false);
        var recentPending = await NewPhotoAsync(delivery, 2, upload: false);
        var oldReceived = await NewPhotoAsync(delivery, 3, upload: true);
        await SetCreatedAtAsync(stalePending.Id, TimeSpan.FromDays(8));
        await SetCreatedAtAsync(recentPending.Id, TimeSpan.FromDays(2));
        await SetCreatedAtAsync(oldReceived.Id, TimeSpan.FromDays(200));

        var report = await RunAsync();
        var photos = (await (await Chef.GetAsync(DeliveryUrl(Site.Id, delivery))).JsonAsync()).GetProperty("photos").EnumerateArray().Select(photo => photo.Id()).ToList();

        Assert.Multiple(() =>
        {
            Assert.That(report.PendingPhotosExpired, Is.GreaterThanOrEqualTo(1));
            Assert.That(photos, Does.Not.Contain(stalePending.Id));
            Assert.That(photos, Does.Contain(recentPending.Id).And.Contain(oldReceived.Id));
        });
    }

    [Test]
    public async Task The_consistency_check_reports_missing_files_and_orphan_files_and_deletes_nothing()
    {
        var delivery = await NewDeliveryAsync();
        var photo = await NewPhotoAsync(delivery, 4, upload: true);
        var stored = Directory.GetFiles(PhotosRoot, "*.jpg", SearchOption.AllDirectories);
        var orphan = Path.Combine(PhotosRoot, Guid.NewGuid().ToString("N"), "2026", "11", Guid.NewGuid().ToString("N") + ".jpg");
        Directory.CreateDirectory(Path.GetDirectoryName(orphan)!);
        await File.WriteAllBytesAsync(orphan, [1, 2, 3]);
        var before = await RunAsync();

        var file = await FileOfAsync(photo.Id);
        File.Move(file, file + ".moved");
        var after = await RunAsync();

        Assert.Multiple(() =>
        {
            Assert.That(before.OrphanFiles, Is.GreaterThanOrEqualTo(1), "fichier sans ligne");
            Assert.That(File.Exists(orphan), Is.True, "rien n'est supprime automatiquement");
            Assert.That(after.MissingFiles, Is.GreaterThan(before.MissingFiles), "photo recue dont le fichier a disparu");
            Assert.That(stored, Is.Not.Empty);
        });
        File.Move(file + ".moved", file);
        File.Delete(orphan);
    }

    [Test]
    public async Task Old_synchronisation_operations_are_purged_after_ninety_days()
    {
        var oldId = Guid.NewGuid();
        var recentId = Guid.NewGuid();
        await using (var scope = Factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var now = Factory.Time.GetUtcNow();
            db.SyncOperationLogs.Add(SyncOperationLog.Create(oldId, Chef.Account.Id, Site.Id, "request", "update", SyncOperationLog.OutcomeApplied, null, null, null, now.AddDays(-91)));
            db.SyncOperationLogs.Add(SyncOperationLog.Create(recentId, Chef.Account.Id, Site.Id, "request", "update", SyncOperationLog.OutcomeApplied, null, null, null, now.AddDays(-30)));
            await db.SaveChangesAsync();
        }

        var report = await RunAsync();

        await using var check = Factory.Services.CreateAsyncScope();
        var ids = await check.ServiceProvider.GetRequiredService<ApplicationDbContext>().SyncOperationLogs.Select(log => log.ClientId).ToListAsync();
        Assert.Multiple(() =>
        {
            Assert.That(report.OperationLogsPurged, Is.GreaterThanOrEqualTo(1));
            Assert.That(ids, Does.Not.Contain(oldId));
            Assert.That(ids, Does.Contain(recentId));
        });
    }

    private async Task<string> FileOfAsync(Guid photoId)
    {
        await using var scope = Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var key = await db.Photos.Where(photo => photo.Id == photoId).Select(photo => photo.StorageKey).SingleAsync();
        return Path.Combine(PhotosRoot, key!.Replace('/', Path.DirectorySeparatorChar));
    }
}
