using System.Net;
using System.Text.Json;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.DeliveriesTestKit;
using static Chantier.IntegrationTests.Support.MaterialsTestKit;

namespace Chantier.IntegrationTests.Materials;

/// <summary>B7, photos du bon (CT-MAT-14, 19, ADR 0013) : metadonnees idempotentes, octets magiques, empreinte, EXIF retire, 5 photos, droits, lecture authentifiee.</summary>
[TestFixture]
public class PhotoTests : DeliveryFixtureBase
{
    private string PhotosRoot => Path.GetFullPath(Factory.Settings["Storage:PhotosRoot"]!);

    private static object Metadata(byte[] jpeg, Guid? clientId = null, string contentType = "image/jpeg", long? size = null, string? sha = null) => new
    {
        clientId = clientId ?? Guid.NewGuid(),
        takenAt = "2026-11-25T08:10:00Z",
        contentType,
        sizeBytes = size ?? jpeg.Length,
        sha256 = sha ?? Sha256Hex(jpeg),
    };

    private async Task<Guid> NewDeliveryAsync(Guid? siteId = null)
    {
        var site = siteId ?? Site.Id;
        var id = await OrderedRequestAsync(600m, siteId: site);
        return (await DeliverAsync(id, 10m, "t", siteId: site)).Id();
    }

    private async Task<JsonElement> CreatePhotoAsync(Guid deliveryId, byte[] jpeg, ApiSession? session = null, Guid? siteId = null)
    {
        var response = await (session ?? Chef).PostAsync(PhotosUrl(siteId ?? Site.Id, deliveryId), Metadata(jpeg));
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Created), await response.Content.ReadAsStringAsync());
        return await response.JsonAsync();
    }

    [Test]
    public async Task The_metadata_are_created_once_per_client_id_and_describe_a_pending_file()
    {
        var delivery = await NewDeliveryAsync();
        var jpeg = Jpeg();
        var clientId = Guid.NewGuid();

        var first = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(jpeg, clientId));
        var again = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(jpeg, clientId));
        var json = await first.JsonAsync();
        var listed = await (await Chef.GetAsync(DeliveryUrl(Site.Id, delivery))).JsonAsync();

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.Created));
            Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await again.JsonAsync()).Id(), Is.EqualTo(json.Id()));
            Assert.That(json.GetProperty("contentStatus").GetString(), Is.EqualTo("Pending"));
            Assert.That(json.GetRawText(), Does.Not.Contain("sha256").IgnoreCase.And.Not.Contain("storageKey").IgnoreCase, "ni empreinte ni chemin");
            Assert.That(listed.GetProperty("photoCount").GetInt32(), Is.Zero, "R2-05 : une metadonnee sans fichier n'est pas une photo recue");
            Assert.That(listed.GetProperty("photos").GetArrayLength(), Is.EqualTo(1));
            Assert.That(listed.GetProperty("missingNote").GetBoolean(), Is.True, "R2-05 : sans fichier, l'alerte « BL manquant » reste");
        });
    }

    [Test]
    public async Task The_missing_note_alert_clears_only_when_the_file_is_received()
    {
        var delivery = await NewDeliveryAsync();
        var jpeg = Jpeg();
        var photo = await CreatePhotoAsync(delivery, jpeg);

        var pending = await (await Chef.GetAsync(DeliveryUrl(Site.Id, delivery))).JsonAsync();
        var missingWhilePending = (await (await Chef.GetAsync($"{DeliveriesUrl(Site.Id)}?missingNote=true&pageSize=200")).JsonAsync()).GetProperty("items").EnumerateArray().Any(item => item.Id() == delivery);
        await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg);
        var received = await (await Chef.GetAsync(DeliveryUrl(Site.Id, delivery))).JsonAsync();
        var missingAfter = (await (await Chef.GetAsync($"{DeliveriesUrl(Site.Id)}?missingNote=true&pageSize=200")).JsonAsync()).GetProperty("items").EnumerateArray().Any(item => item.Id() == delivery);

        Assert.Multiple(() =>
        {
            Assert.That(pending.GetProperty("missingNote").GetBoolean(), Is.True);
            Assert.That(missingWhilePending, Is.True, "le filtre « BL manquant » le liste encore");
            Assert.That(received.GetProperty("missingNote").GetBoolean(), Is.False);
            Assert.That(received.GetProperty("photoCount").GetInt32(), Is.EqualTo(1));
            Assert.That(received.HistoryTypes(), Does.Contain("PhotoAdded"), "l'historique note la photo quand elle est recue");
            Assert.That(missingAfter, Is.False);
        });
    }

    [Test]
    public async Task A_photo_whose_file_never_arrived_frees_its_place_after_the_hold_time()
    {
        var delivery = await NewDeliveryAsync();
        var created = new List<JsonElement>();
        for (var index = 0; index < 5; index++)
        {
            created.Add(await CreatePhotoAsync(delivery, Jpeg((byte)(index + 1))));
        }

        var full = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(Jpeg(9)));
        await AgePhotosAsync(created.Select(photo => photo.Id()), hours: 25);
        var afterHold = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(Jpeg(9)));

        Assert.Multiple(async () =>
        {
            Assert.That(await CodeOf(full), Is.EqualTo("PHOTOS_TROP_NOMBREUSES"), "cinq envois recents en attente : complet");
            Assert.That(afterHold.StatusCode, Is.EqualTo(HttpStatusCode.Created), "les envois restes sans fichier depuis plus de 24 h liberent leurs places");
        });
    }

    [Test]
    public async Task Received_photos_keep_their_place_whatever_their_age()
    {
        var delivery = await NewDeliveryAsync();
        var ids = new List<Guid>();
        for (var index = 0; index < 5; index++)
        {
            var jpeg = Jpeg((byte)(index + 1));
            var photo = await CreatePhotoAsync(delivery, jpeg);
            await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg);
            ids.Add(photo.Id());
        }

        await AgePhotosAsync(ids, hours: 24 * 30);
        var sixth = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(Jpeg(9)));

        Assert.That(await CodeOf(sixth), Is.EqualTo("PHOTOS_TROP_NOMBREUSES"));
    }

    private async Task AgePhotosAsync(IEnumerable<Guid> ids, int hours)
    {
        var list = ids.ToList();
        await using var scope = Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var old = Factory.Time.GetUtcNow().AddHours(-hours);
        await db.Photos.Where(photo => list.Contains(photo.Id)).ExecuteUpdateAsync(set => set.SetProperty(photo => photo.CreatedAt, old));
    }

    [Test]
    public async Task The_metadata_are_validated()
    {
        var delivery = await NewDeliveryAsync();
        var jpeg = Jpeg();

        var png = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(jpeg, contentType: "image/png"));
        var heavy = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(jpeg, size: 6 * 1024 * 1024));
        var badHash = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(jpeg, sha: "abc"));
        var noClient = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), new { takenAt = "2026-11-25T08:10:00Z", contentType = "image/jpeg", sizeBytes = 10, sha256 = Sha256Hex(jpeg) });

        Assert.Multiple(async () =>
        {
            Assert.That(png.StatusCode, Is.EqualTo(HttpStatusCode.UnsupportedMediaType));
            Assert.That(await CodeOf(png), Is.EqualTo("TYPE_FICHIER_REFUSE"));
            Assert.That(heavy.StatusCode, Is.EqualTo(HttpStatusCode.RequestEntityTooLarge));
            Assert.That(await CodeOf(heavy), Is.EqualTo("FICHIER_TROP_GROS"));
            Assert.That(badHash.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(noClient.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    [Test]
    public async Task A_sixth_photo_is_refused()
    {
        var delivery = await NewDeliveryAsync();
        for (var index = 0; index < 5; index++)
        {
            await CreatePhotoAsync(delivery, Jpeg((byte)(index + 1)));
        }

        var sixth = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(Jpeg(9)));

        Assert.Multiple(async () =>
        {
            Assert.That(sixth.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(sixth), Is.EqualTo("PHOTOS_TROP_NOMBREUSES"));
        });
    }

    [Test]
    public async Task Uploading_a_jpeg_stores_it_without_exif_under_a_random_name_outside_the_web_root()
    {
        var delivery = await NewDeliveryAsync();
        var jpeg = Jpeg();
        Assert.That(jpeg.Contains("GPSLatitude"), Is.True, "la fixture porte bien des coordonnees GPS");
        var photo = await CreatePhotoAsync(delivery, jpeg);
        var known = Directory.Exists(PhotosRoot) ? Directory.GetFiles(PhotosRoot, "*.jpg", SearchOption.AllDirectories) : [];

        var upload = await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg);
        var json = await upload.JsonAsync();
        var read = await Achats.GetAsync(PhotoContentUrl(Site.Id, photo.Id()));
        var served = await read.Content.ReadAsByteArrayAsync();
        var files = Directory.GetFiles(PhotosRoot, "*.jpg", SearchOption.AllDirectories).Except(known).ToArray();

        Assert.Multiple(() =>
        {
            Assert.That(upload.StatusCode, Is.EqualTo(HttpStatusCode.OK), json.ToString());
            Assert.That(json.GetProperty("contentStatus").GetString(), Is.EqualTo("Uploaded"));
            Assert.That(json.GetProperty("sizeBytes").GetInt64(), Is.EqualTo(served.Length).And.LessThan(jpeg.Length), "les metadonnees retirees ont reduit le fichier");
            Assert.That(read.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(read.Content.Headers.ContentType!.MediaType, Is.EqualTo("image/jpeg"));
            Assert.That(read.Headers.GetValues("X-Content-Type-Options"), Is.EqualTo(new[] { "nosniff" }));
            Assert.That(read.Headers.CacheControl!.Private, Is.True);
            Assert.That(read.Headers.CacheControl.NoCache, Is.True, "R2-11 : revalidation a chaque lecture");
            Assert.That(read.Headers.CacheControl.MaxAge, Is.Null, "R2-11 : aucune duree de conservation");
            Assert.That(read.Headers.ETag, Is.Not.Null);
            Assert.That(served.Contains("GPSLatitude"), Is.False, "GPS retire");
            Assert.That(served.Contains("Exif"), Is.False, "EXIF retire");
            Assert.That(served.Contains("Photoshop"), Is.False, "APP13 retire");
            Assert.That(served[..3], Is.EqualTo(new byte[] { 0xFF, 0xD8, 0xFF }));
            Assert.That(served[^2..], Is.EqualTo(new byte[] { 0xFF, 0xD9 }));
            Assert.That(files, Has.Length.EqualTo(1));
            Assert.That(Path.GetFileNameWithoutExtension(files[0]), Does.Match("^[0-9a-f]{32}$"), "nom aleatoire");
            Assert.That(files[0], Does.Contain(Site.Id.ToString("N")));
            Assert.That(files[0], Does.Not.Contain("wwwroot"));
        });
    }

    [Test]
    public async Task An_unchanged_photo_is_revalidated_with_a_304_only_for_those_who_may_read_it()
    {
        var jpeg = Jpeg();
        var photo = await CreatePhotoAsync(await NewDeliveryAsync(), jpeg);
        await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg);
        var url = PhotoContentUrl(Site.Id, photo.Id());
        var etag = (await Achats.GetAsync(url)).Headers.ETag!.Tag;

        var unchanged = await Achats.GetAsync(url, "If-None-Match", etag);
        var changed = await Achats.GetAsync(url, "If-None-Match", "\"autre\"");
        var forbidden = await Equipe.GetAsync(url, "If-None-Match", etag);

        Assert.Multiple(() =>
        {
            Assert.That(unchanged.StatusCode, Is.EqualTo(HttpStatusCode.NotModified));
            Assert.That(changed.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(forbidden.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "le droit est controle avant la revalidation : jamais un 304 pour qui ne peut pas lire");
        });
    }

    [Test]
    public async Task Sending_the_same_file_again_is_harmless_and_another_content_is_a_conflict()
    {
        var delivery = await NewDeliveryAsync();
        var jpeg = Jpeg();
        var photo = await CreatePhotoAsync(delivery, jpeg);
        await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg);
        var before = Directory.GetFiles(PhotosRoot, "*.jpg", SearchOption.AllDirectories).Length;

        var same = await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg);
        var other = await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), Jpeg(7));

        Assert.Multiple(async () =>
        {
            Assert.That(same.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(other.StatusCode, Is.EqualTo(HttpStatusCode.Conflict));
            Assert.That(await CodeOf(other), Is.EqualTo("PHOTO_DEJA_ENVOYEE"));
            Assert.That(Directory.GetFiles(PhotosRoot, "*.jpg", SearchOption.AllDirectories), Has.Length.EqualTo(before), "aucun doublon sur disque");
        });
    }

    [Test]
    public async Task Six_simultaneous_uploads_of_the_same_photo_all_answer_200_and_store_one_file()
    {
        // R2-04 : un renvoi du telephone pendant que le premier envoi est en cours donnait 409 CONFLIT_VERSION (ligne relue perimee).
        var jpeg = Jpeg(4, scanBytes: 300_000);
        var known = Directory.Exists(PhotosRoot) ? Directory.GetFiles(PhotosRoot, "*", SearchOption.AllDirectories) : [];
        for (var round = 0; round < 3; round++)
        {
            var photo = await CreatePhotoAsync(await NewDeliveryAsync(), jpeg);

            var responses = await Task.WhenAll(Enumerable.Range(0, 6).Select(_ => Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg)));

            Assert.That(responses.Select(response => response.StatusCode), Is.All.EqualTo(HttpStatusCode.OK), $"tour {round}");
        }

        var files = Directory.GetFiles(PhotosRoot, "*", SearchOption.AllDirectories).Except(known).ToArray();
        Assert.Multiple(() =>
        {
            Assert.That(files.Count(file => file.EndsWith(".jpg", StringComparison.Ordinal)), Is.EqualTo(3), "un fichier par photo, aucun doublon");
            Assert.That(files.Count(file => file.EndsWith(".part", StringComparison.Ordinal)), Is.Zero, "aucun fichier temporaire");
        });
    }

    [Test]
    public async Task A_file_that_is_not_a_jpeg_or_does_not_match_its_hash_is_refused_and_leaves_nothing_on_disk()
    {
        var delivery = await NewDeliveryAsync();
        var jpeg = Jpeg();
        var photo = await CreatePhotoAsync(delivery, jpeg);
        var png = new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0 };
        var truncated = jpeg[..(jpeg.Length - 10)];
        var before = Directory.GetFiles(PhotosRoot, "*", SearchOption.AllDirectories).Length;

        var notJpeg = await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), png);
        var wrongType = await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg, "image/png");
        var damaged = await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), truncated);
        var otherHash = await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), Jpeg(5));
        var pending = await Chef.GetAsync(PhotoContentUrl(Site.Id, photo.Id()));

        Assert.Multiple(async () =>
        {
            Assert.That(notJpeg.StatusCode, Is.EqualTo(HttpStatusCode.UnsupportedMediaType));
            Assert.That(wrongType.StatusCode, Is.EqualTo(HttpStatusCode.UnsupportedMediaType));
            Assert.That(damaged.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity), "JPEG incoherent : pas stocke tel quel");
            Assert.That(otherHash.StatusCode, Is.EqualTo(HttpStatusCode.UnprocessableEntity));
            Assert.That(await CodeOf(otherHash), Is.EqualTo("TYPE_FICHIER_REFUSE"));
            Assert.That(pending.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "toujours en attente");
            Assert.That(Directory.GetFiles(PhotosRoot, "*", SearchOption.AllDirectories), Has.Length.EqualTo(before), "aucun fichier temporaire ni orphelin");
        });
    }

    [Test]
    public async Task A_file_over_the_limit_is_refused_with_413()
    {
        var delivery = await NewDeliveryAsync();
        var big = Jpeg(1, scanBytes: 5 * 1024 * 1024 + 100);
        var photo = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(Jpeg(), size: 1000));
        var id = (await photo.JsonAsync()).Id();

        var response = await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, id), big);

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.RequestEntityTooLarge));
            Assert.That(await CodeOf(response), Is.EqualTo("FICHIER_TROP_GROS"));
            Assert.That(Directory.Exists(PhotosRoot) ? Directory.GetFiles(PhotosRoot, "*.part", SearchOption.AllDirectories) : [], Is.Empty, "fichier temporaire supprime");
        });
    }

    [Test]
    public async Task Photos_are_read_only_by_the_roles_that_see_them_and_never_across_sites()
    {
        var delivery = await NewDeliveryAsync();
        var jpeg = Jpeg();
        var photo = await CreatePhotoAsync(delivery, jpeg);
        await Chef.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg);
        var url = PhotoContentUrl(Site.Id, photo.Id());
        var other = await Factory.SeedSiteAsync();
        var anotherSite = await NewSiteAsync();

        var allowed = new List<HttpStatusCode>();
        foreach (var session in new[] { Admin, Direction, Conducteur, Achats, Chef })
        {
            allowed.Add((await session.GetAsync(url)).StatusCode);
        }

        var equipe = await Equipe.GetAsync(url);
        var elsewhere = await Achats.GetAsync(PhotoContentUrl(other.Id, photo.Id()));
        var wrongSite = await Achats.GetAsync(PhotoContentUrl(anotherSite.Id, photo.Id()));
        var missing = await Achats.GetAsync(PhotoContentUrl(Site.Id, Guid.NewGuid()));
        var anonymous = await Factory.CreateClient().GetAsync(url);

        Assert.Multiple(async () =>
        {
            Assert.That(allowed, Is.All.EqualTo(HttpStatusCode.OK));
            Assert.That(equipe.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "ChefEquipe : meme 404 qu'une photo inexistante");
            Assert.That(await equipe.Content.ReadAsStringAsync(), Is.EqualTo(await missing.Content.ReadAsStringAsync()).Or.Contain("INTROUVABLE"));
            Assert.That(elsewhere.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "chantier non affecte");
            Assert.That(wrongSite.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "photo d'un autre chantier");
            Assert.That(missing.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(anonymous.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task Only_the_roles_that_receive_trucks_can_add_photos()
    {
        var delivery = await NewDeliveryAsync();
        var jpeg = Jpeg();
        var photo = await CreatePhotoAsync(delivery, jpeg);

        var statuses = new List<HttpStatusCode>();
        foreach (var session in new[] { Direction, Equipe })
        {
            statuses.Add((await session.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(Jpeg(3)))).StatusCode);
            statuses.Add((await session.PutBytesAsync(PhotoContentUrl(Site.Id, photo.Id()), jpeg)).StatusCode);
        }

        var other = await Factory.SeedSiteAsync();
        var elsewhere = await Chef.PostAsync(PhotosUrl(other.Id, delivery), Metadata(Jpeg(3)));
        var wrongSite = await Chef.PostAsync(PhotosUrl((await NewSiteAsync()).Id, delivery), Metadata(Jpeg(3)));

        Assert.Multiple(() =>
        {
            Assert.That(statuses, Is.All.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(elsewhere.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(wrongSite.StatusCode, Is.EqualTo(HttpStatusCode.NotFound), "livraison d'un autre chantier");
        });
    }

    [Test]
    public async Task A_cancelled_delivery_receives_no_more_photos()
    {
        var delivery = await NewDeliveryAsync();
        await Chef.PostAsync($"{DeliveryUrl(Site.Id, delivery)}/cancel", new { reasonCode = "DoubleEntry" });

        var response = await Chef.PostAsync(PhotosUrl(Site.Id, delivery), Metadata(Jpeg()));

        Assert.That(await CodeOf(response), Is.EqualTo("TRANSITION_INTERDITE"));
    }

    [Test]
    public async Task Simultaneous_creations_of_the_same_photo_make_one_photo()
    {
        var delivery = await NewDeliveryAsync();
        var jpeg = Jpeg();
        var body = Metadata(jpeg, Guid.NewGuid());

        var responses = await Task.WhenAll(Enumerable.Range(0, 6).Select(_ => Chef.PostAsync(PhotosUrl(Site.Id, delivery), body)));
        var ids = (await Task.WhenAll(responses.Select(async response => (await response.JsonAsync()).Id()))).Distinct().ToList();

        Assert.Multiple(async () =>
        {
            Assert.That(responses.Count(response => response.StatusCode == HttpStatusCode.Created), Is.EqualTo(1));
            Assert.That(ids, Has.Count.EqualTo(1));
            Assert.That((await (await Chef.GetAsync(DeliveryUrl(Site.Id, delivery))).JsonAsync()).GetProperty("photos").GetArrayLength(), Is.EqualTo(1));
        });
    }
}
