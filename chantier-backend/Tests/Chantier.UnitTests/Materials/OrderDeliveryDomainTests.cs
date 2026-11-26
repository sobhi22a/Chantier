using Chantier.Core.Entities.Materials;
using Chantier.Core.Exceptions;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Imaging;
using Chantier.Infrastructure.Storage;

namespace Chantier.UnitTests.Materials;

/// <summary>Domaine pur des commandes et livraisons (B5, B6) et du traitement des photos (B7) : sans base ni HTTP.</summary>
[TestFixture]
public class OrderDeliveryDomainTests
{
    private static readonly MaterialsOptions Options = new();
    private static readonly DateOnly Today = new(2026, 11, 25);
    private static readonly Guid Supplier = Guid.NewGuid();

    // --- Commande ---

    [Test]
    public void An_order_amount_is_quantity_times_price_rounded_away_from_zero()
    {
        var fields = OrderRules.Validate(new OrderFields(Supplier, Today, null, 780m, null, null), Options, Today);
        var order = MaterialOrder.Create(Guid.NewGuid(), Guid.NewGuid(), null, fields, new Quantity(300m, MeasureUnit.Bag));
        var rounded = MaterialOrder.Create(Guid.NewGuid(), Guid.NewGuid(), null, fields with { UnitPrice = 245.25m }, new Quantity(2.5m, MeasureUnit.Kilogram));

        Assert.Multiple(() =>
        {
            Assert.That(order.Amount, Is.EqualTo(234000.00m));
            Assert.That(rounded.Amount, Is.EqualTo(613.13m), "613,125 -> 613,13");
        });
    }

    [TestCase(null, "supplierId")]
    [TestCase("future", "orderDate")]
    public void An_invalid_order_is_refused_by_field(string? case_, string field)
    {
        var fields = case_ == "future"
            ? new OrderFields(Supplier, Today.AddDays(1), null, null, null, null)
            : new OrderFields(null, Today, null, null, null, null);

        var error = Assert.Throws<ValidationException>(() => OrderRules.Validate(fields, Options, Today))!;

        Assert.That(error.Errors.Keys, Does.Contain(field));
    }

    [TestCase(0)]
    [TestCase(-5)]
    [TestCase(10.001)]
    public void A_price_must_be_positive_with_two_decimals(double price)
    {
        var error = Assert.Throws<ValidationException>(() => OrderRules.Validate(new OrderFields(Supplier, Today, null, (decimal)price, null, null), Options, Today))!;

        Assert.That(error.Errors.Keys, Does.Contain("unitPrice"));
    }

    [Test]
    public void The_planned_delivery_cannot_precede_the_order_and_the_overrun_is_counted_in_days()
    {
        var before = Assert.Throws<ValidationException>(() => OrderRules.Validate(new OrderFields(Supplier, Today, Today.AddDays(-1), null, null, null), Options, Today))!;

        Assert.Multiple(() =>
        {
            Assert.That(before.Code, Is.EqualTo(ErrorCodes.DateInvalide));
            Assert.That(OrderRules.PlannedAfterNeedDays(Today, Today.AddDays(2)), Is.EqualTo(2));
            Assert.That(OrderRules.PlannedAfterNeedDays(Today, Today.AddDays(-2)), Is.Zero);
            Assert.That(OrderRules.PlannedAfterNeedDays(Today, null), Is.Zero);
        });
    }

    [Test]
    public void Editing_an_order_separates_the_commercial_changes_from_the_others()
    {
        var fields = OrderRules.Validate(new OrderFields(Supplier, Today, null, 780m, "BC-1", null), Options, Today);
        var order = MaterialOrder.Create(Guid.NewGuid(), Guid.NewGuid(), null, fields, new Quantity(300m, MeasureUnit.Bag));
        var changed = OrderRules.Validate(new OrderChanges(null, Today.AddDays(1), 800m, "BC-2", "remarque").ApplyTo(order.CurrentFields()), Options, Today);

        var (general, commercial) = order.ApplyEdit(changed, new Quantity(300m, MeasureUnit.Bag));

        Assert.Multiple(() =>
        {
            Assert.That(general.Select(change => change.Field), Is.EquivalentTo(new[] { "expectedDeliveryDate", "note" }));
            Assert.That(commercial.Select(change => change.Field), Is.EquivalentTo(new[] { "unitPrice", "purchaseOrderNumber" }));
            Assert.That(commercial[0].Old, Is.EqualTo("780.00"));
            Assert.That(order.Amount, Is.EqualTo(240000.00m));
        });
    }

    [Test]
    public void Commercial_data_are_built_only_for_the_roles_that_see_prices()
    {
        var fields = OrderRules.Validate(new OrderFields(Supplier, Today, null, 780m, "BC-1", null), Options, Today);
        var order = MaterialOrder.Create(Guid.NewGuid(), Guid.NewGuid(), null, fields, new Quantity(300m, MeasureUnit.Bag));

        Assert.Multiple(() =>
        {
            Assert.That(CommercialProjection.ForOrder(order, 78000m, canViewPrices: false), Is.Null);
            Assert.That(CommercialProjection.ForOrder(order, 78000m, canViewPrices: true)!.ReceivedValue, Is.EqualTo(78000m));
            Assert.That(CommercialProjection.ForFollowUp(1m, 2m, canViewPrices: false), Is.Null);
        });
    }

    // --- Livraison ---

    private static DeliveryFields Delivery(decimal? value = 10m, MeasureUnit? unit = MeasureUnit.Tonne, DateOnly? date = null, string? note = null)
        => new(Supplier, null, Guid.NewGuid(), null, value, unit, date ?? Today, note, null, null, null);

    [Test]
    public void A_valid_delivery_defaults_to_conform_and_uppercases_the_note_number()
    {
        var validated = DeliveryRules.Validate(Delivery(note: "  bl-4471 "), Options, Today);

        Assert.Multiple(() =>
        {
            Assert.That(validated.Conformity, Is.EqualTo(Conformity.Conform));
            Assert.That(validated.DeliveryNoteNumber, Is.EqualTo("BL-4471"));
        });
    }

    [Test]
    public void A_delivery_without_unit_or_with_a_bad_quantity_gets_the_business_code()
    {
        var noUnit = Assert.Throws<DomainRuleException>(() => DeliveryRules.Validate(Delivery(unit: null), Options, Today))!;
        var zero = Assert.Throws<DomainRuleException>(() => DeliveryRules.Validate(Delivery(value: 0m), Options, Today))!;
        var decimalBags = Assert.Throws<DomainRuleException>(() => DeliveryRules.Validate(Delivery(2.5m, MeasureUnit.Bag), Options, Today))!;

        Assert.Multiple(() =>
        {
            Assert.That(noUnit.Code, Is.EqualTo(ErrorCodes.UniteObligatoire));
            Assert.That(zero.Code, Is.EqualTo(ErrorCodes.QuantiteInvalide));
            Assert.That(decimalBags.Code, Is.EqualTo(ErrorCodes.QuantiteEntiereRequise));
        });
    }

    [Test]
    public void The_delivery_date_may_be_today_or_earlier_but_never_in_the_future()
    {
        Assert.Multiple(() =>
        {
            Assert.DoesNotThrow(() => DeliveryRules.Validate(Delivery(date: Today), Options, Today));
            Assert.DoesNotThrow(() => DeliveryRules.Validate(Delivery(date: Today.AddDays(-30)), Options, Today));
            Assert.That(Assert.Throws<ValidationException>(() => DeliveryRules.Validate(Delivery(date: Today.AddDays(1)), Options, Today))!.Code, Is.EqualTo(ErrorCodes.DateInvalide));
        });
    }

    [Test]
    public void A_reserve_needs_a_reason_from_the_list_and_a_conform_delivery_has_none()
    {
        var noReason = Assert.Throws<ValidationException>(() => DeliveryRules.Validate(Delivery() with { Conformity = Conformity.WithReserve }, Options, Today))!;
        var other = Assert.Throws<ValidationException>(() => DeliveryRules.Validate(Delivery() with { Conformity = Conformity.WithReserve, ReserveReasonCode = "Other" }, Options, Today))!;
        var conformWithReserve = Assert.Throws<ValidationException>(() => DeliveryRules.Validate(Delivery() with { ReserveReasonCode = "DamagedProduct" }, Options, Today))!;
        var ok = DeliveryRules.Validate(Delivery() with { Conformity = Conformity.WithReserve, ReserveReasonCode = "DamagedProduct" }, Options, Today);

        Assert.Multiple(() =>
        {
            Assert.That(noReason.Errors.Keys, Does.Contain("reasonCode"));
            Assert.That(other.Errors.Keys, Does.Contain("reasonNote"));
            Assert.That(conformWithReserve.Errors.Keys, Does.Contain("reserveReasonCode"));
            Assert.That(ok.ReserveReasonCode, Is.EqualTo("DamagedProduct"));
        });
    }

    [Test]
    public void Switching_back_to_conform_clears_the_reserve()
    {
        var current = Delivery() with { Conformity = Conformity.WithReserve, ReserveReasonCode = "DamagedProduct", ReserveNote = "carton ouvert" };

        var changed = new DeliveryChanges(null, null, null, Conformity.Conform, null, null).ApplyTo(current);

        Assert.Multiple(() =>
        {
            Assert.That(changed.Conformity, Is.EqualTo(Conformity.Conform));
            Assert.That(changed.ReserveReasonCode, Is.Null);
            Assert.That(changed.ReserveNote, Is.Null);
        });
    }

    [Test]
    public void A_cancelled_delivery_keeps_its_first_reason_and_cannot_be_corrected_or_attached()
    {
        var validated = DeliveryRules.Validate(Delivery(), Options, Today);
        var delivery = Chantier.Core.Entities.Materials.Delivery.Create(Guid.NewGuid(), "LIV-001", null, null, validated, null, null, null);
        var by = Guid.NewGuid();

        var first = delivery.Cancel("QuantityError", null, by, DateTimeOffset.UtcNow);
        var second = delivery.Cancel("DoubleEntry", null, by, DateTimeOffset.UtcNow);

        Assert.Multiple(() =>
        {
            Assert.That(first, Is.EqualTo(TransitionOutcome.Applied));
            Assert.That(second, Is.EqualTo(TransitionOutcome.AlreadyDone));
            Assert.That(delivery.CancelReasonCode, Is.EqualTo("QuantityError"));
            Assert.That(delivery.UnattachedReason, Is.EqualTo(UnattachedReason.NoRequestChosen));
            Assert.That(() => delivery.ApplyEdit(validated), Throws.TypeOf<DomainRuleException>());
            Assert.That(() => delivery.Attach(Guid.NewGuid()), Throws.TypeOf<DomainRuleException>());
        });
    }

    [Test]
    public void A_delivery_without_note_number_and_photo_is_flagged_missing()
    {
        var validated = DeliveryRules.Validate(Delivery(), Options, Today);
        var delivery = Chantier.Core.Entities.Materials.Delivery.Create(Guid.NewGuid(), "LIV-001", null, null, validated, null, null, null);
        var before = delivery.IsNoteMissing;

        delivery.AddPhoto();

        Assert.Multiple(() =>
        {
            Assert.That(before, Is.True);
            Assert.That(delivery.IsNoteMissing, Is.False);
        });
    }

    // --- Recalcul d'une demande ---

    [Test]
    public void A_validated_request_keeps_its_status_but_records_the_retained_quantity()
    {
        var request = NewRequest();
        request.Approve(null, out _);

        var changed = request.ApplyComputation(RequestStatusCalculator.Compute(request.Ordered, 50m, [new Quantity(10m, MeasureUnit.Tonne)], 0m, false));

        Assert.Multiple(() =>
        {
            Assert.That(changed, Is.False);
            Assert.That(request.Status, Is.EqualTo(RequestStatus.Validated));
            Assert.That(request.ReceivedQuantity, Is.EqualTo(200m));
        });
    }

    [Test]
    public void Placing_an_order_then_recomputing_goes_through_ordered_to_partially_delivered()
    {
        var request = NewRequest();
        request.Approve(null, out _);
        request.PlaceOrder();

        var changed = request.ApplyComputation(RequestStatusCalculator.Compute(request.Ordered, 50m, [new Quantity(10m, MeasureUnit.Tonne)], 0m, false));
        var back = request.ApplyComputation(RequestStatusCalculator.Compute(request.Ordered, 50m, [], 0m, false));

        Assert.Multiple(() =>
        {
            Assert.That(changed, Is.True);
            Assert.That(back, Is.True, "dans les deux sens");
            Assert.That(request.Status, Is.EqualTo(RequestStatus.Ordered));
            Assert.That(() => NewRequest().PlaceOrder(), Throws.TypeOf<DomainRuleException>(), "seule une demande validee se commande");
        });
    }

    private static MaterialRequest NewRequest()
    {
        var fields = RequestRules.Validate(
            new RequestFields(Guid.NewGuid(), null, 600m, MeasureUnit.Bag, null, Today, null, null), null, Options);
        return MaterialRequest.Create(Guid.NewGuid(), "DEM-001", null, null, fields, null);
    }

    // --- JPEG, EXIF, empreinte ---

    private static byte[] Segment(byte code, byte[] data)
        => [0xFF, code, (byte)((data.Length + 2) >> 8), (byte)((data.Length + 2) & 0xFF), .. data];

    private static byte[] Jpeg(bool exif = true, bool end = true)
    {
        var parts = new List<byte[]> { new byte[] { 0xFF, 0xD8 }, Segment(0xE0, "JFIF\0"u8.ToArray()) };
        if (exif)
        {
            parts.Add(Segment(0xE1, "Exif\0\0GPS 36.47N"u8.ToArray()));
            parts.Add(Segment(0xED, "Photoshop"u8.ToArray()));
        }

        parts.Add(Segment(0xDB, new byte[65]));
        parts.Add(Segment(0xC0, [8, 0, 1, 0, 1, 1, 1, 0x11, 0]));
        parts.Add(Segment(0xDA, [1, 1, 0, 0, 0x3F, 0]));
        parts.Add([1, 2, 3, 4, 0xFF, 0x00, 5]);
        if (end)
        {
            parts.Add([0xFF, 0xD9]);
        }

        return parts.SelectMany(part => part).ToArray();
    }

    private static async Task<byte[]> StripAsync(byte[] input)
    {
        using var output = new MemoryStream();
        await JpegMetadataStripper.StripAsync(new MemoryStream(input), output);
        return output.ToArray();
    }

    [Test]
    public async Task The_stripper_removes_exif_and_iptc_and_keeps_the_image_data_byte_for_byte()
    {
        var source = Jpeg();

        var stripped = await StripAsync(source);

        Assert.Multiple(() =>
        {
            Assert.That(System.Text.Encoding.Latin1.GetString(stripped), Does.Not.Contain("Exif").And.Not.Contain("GPS").And.Not.Contain("Photoshop"));
            Assert.That(stripped, Is.EqualTo(Jpeg(exif: false)), "tout le reste est recopie tel quel, sans reencodage");
            Assert.That(stripped.Length, Is.LessThan(source.Length));
        });
    }

    [Test]
    public async Task A_jpeg_without_metadata_is_unchanged()
    {
        var source = Jpeg(exif: false);

        Assert.That(await StripAsync(source), Is.EqualTo(source));
    }

    /// <summary>JPEG hostile (R2-03) : metadonnees partout (APP1 Exif et XMP, APP2, APP13, COM, APP1 entre deux balayages) et un second JPEG avec son Exif apres la fin d'image.</summary>
    private static byte[] HostileJpeg(out byte[] expected)
    {
        byte[] firstScan = [1, 2, 0xFF, 0x00, 3, 0xFF, 0xD0, 4];
        byte[] secondScan = [5, 6, 0xFF, 0x00, 7];
        byte[] header = [.. new byte[] { 0xFF, 0xD8 }, .. Segment(0xE0, "JFIF\0"u8.ToArray())];
        byte[] tables = [.. Segment(0xDB, new byte[65]), .. Segment(0xC2, [8, 0, 1, 0, 1, 1, 1, 0x11, 0]), .. Segment(0xC4, new byte[17])];
        byte[] scanHeader = Segment(0xDA, [1, 1, 0, 0, 0x3F, 0]);
        byte[] secondTable = Segment(0xC4, new byte[17]);

        byte[] second = [0xFF, 0xD8, .. Segment(0xE1, "Exif\0\0SECONDGPS 12.3N"u8.ToArray()), .. Segment(0xDB, new byte[65]), 0xFF, 0xD9];
        byte[] source =
        [
            .. header,
            .. Segment(0xE1, "Exif\0\0GPSLatitude=36.47N"u8.ToArray()),
            .. Segment(0xE1, "http://ns.adobe.com/xap/1.0/\0<x:xmpmeta>XMPDATA</x:xmpmeta>"u8.ToArray()),
            .. Segment(0xE2, "MPF\0MULTIPICTURE"u8.ToArray()),
            .. Segment(0xE2, "ICC_PROFILE\0PROFILEDATA"u8.ToArray()),
            .. Segment(0xED, "Photoshop 3.0\0IPTCLEGENDE"u8.ToArray()),
            .. Segment(0xFE, "COMMENTSECRET"u8.ToArray()),
            .. tables,
            .. scanHeader,
            .. firstScan,
            .. Segment(0xE1, "Exif\0\0APP1AFTERSCAN"u8.ToArray()),
            .. Segment(0xFE, "COMMENTMIDSCAN"u8.ToArray()),
            .. secondTable,
            .. scanHeader,
            .. secondScan,
            0xFF, 0xD9,
            .. second,
        ];

        expected = [.. header, .. tables, .. scanHeader, .. firstScan, .. secondTable, .. scanHeader, .. secondScan, 0xFF, 0xD9];
        return source;
    }

    [Test]
    public async Task The_stripper_keeps_only_the_whitelist_everywhere_and_cuts_everything_after_the_end_of_image()
    {
        var source = HostileJpeg(out var expected);

        var stripped = await StripAsync(source);
        var text = System.Text.Encoding.Latin1.GetString(stripped);

        Assert.Multiple(() =>
        {
            foreach (var secret in new[] { "Exif", "GPS", "XMP", "MPF", "ICC_PROFILE", "Photoshop", "IPTC", "COMMENT", "APP1AFTERSCAN", "SECONDGPS" })
            {
                Assert.That(text, Does.Not.Contain(secret), secret);
            }

            Assert.That(stripped, Is.EqualTo(expected), "tables, cadre, balayages (FF 00 et FF D0 compris) recopies, le reste ecarte, rien apres FF D9");
        });
    }

    [Test]
    public async Task Data_after_the_end_of_image_is_read_for_the_hash_but_never_written()
    {
        var source = HostileJpeg(out var expected);
        await using var metered = new MeteredStream(new MemoryStream(source), 1_000_000);
        using var output = new MemoryStream();

        await JpegMetadataStripper.StripAsync(metered, output);

        Assert.Multiple(() =>
        {
            Assert.That(output.ToArray(), Is.EqualTo(expected));
            Assert.That(metered.BytesRead, Is.EqualTo(source.Length), "tout le fichier recu est lu : l'empreinte declaree par le telephone reste verifiable");
            Assert.That(metered.Sha256Hex(), Is.EqualTo(Convert.ToHexStringLower(System.Security.Cryptography.SHA256.HashData(source))));
        });
    }

    [Test]
    public void A_file_without_the_jpeg_magic_bytes_is_refused_as_an_unsupported_type()
    {
        byte[][] samples = [[0x89, 0x50, 0x4E, 0x47], [0xFF, 0xD8, 0x00, 0x01], [], [0xFF]];

        Assert.Multiple(() =>
        {
            foreach (var sample in samples)
            {
                Assert.ThrowsAsync<UnsupportedFileTypeException>(async () => await StripAsync(sample));
            }
        });
    }

    [Test]
    public void An_incoherent_jpeg_is_refused_and_never_kept_as_is()
    {
        var full = Jpeg();
        var truncatedSegment = full[..30];
        var withoutEnd = Jpeg(end: false);
        byte[] noFrame = [0xFF, 0xD8, 0xFF, 0xDA, 0, 8, 1, 1, 0, 0, 0x3F, 0, 1, 2, 0xFF, 0xD9];
        byte[] earlyEnd = [0xFF, 0xD8, 0xFF, 0xD9];

        Assert.Multiple(() =>
        {
            foreach (var sample in new[] { truncatedSegment, withoutEnd, noFrame, earlyEnd })
            {
                var error = Assert.ThrowsAsync<DomainRuleException>(async () => await StripAsync(sample))!;
                Assert.That(error.Code, Is.EqualTo(ErrorCodes.TypeFichierRefuse));
            }
        });
    }

    [Test]
    public async Task The_metered_stream_hashes_what_it_reads_and_stops_over_the_limit()
    {
        var bytes = Jpeg();
        await using var ok = new MeteredStream(new MemoryStream(bytes), 1000);
        await ok.DrainAsync(CancellationToken.None);

        await using var tooBig = new MeteredStream(new MemoryStream(new byte[100]), 50);

        Assert.Multiple(() =>
        {
            Assert.That(ok.Sha256Hex(), Is.EqualTo(Convert.ToHexStringLower(System.Security.Cryptography.SHA256.HashData(bytes))));
            Assert.That(ok.BytesRead, Is.EqualTo(bytes.Length));
            Assert.ThrowsAsync<FileTooLargeException>(async () => await tooBig.DrainAsync(CancellationToken.None));
        });
    }

    [Test]
    public async Task The_storage_writes_under_a_random_key_and_never_reads_outside_its_root()
    {
        var root = Path.Combine(Path.GetTempPath(), "chantier-unit-photos", Guid.NewGuid().ToString("N"));
        var outside = Path.Combine(Path.GetTempPath(), "chantier-unit-secret-" + Guid.NewGuid().ToString("N") + ".jpg");
        await File.WriteAllBytesAsync(outside, [1, 2, 3]);
        var storage = new FileSystemPhotoStorage(Microsoft.Extensions.Options.Options.Create(new PhotoStorageOptions { PhotosRoot = root }));
        var siteId = Guid.NewGuid();

        string key;
        await using (var staged = await storage.StageAsync())
        {
            await staged.Stream.WriteAsync(Jpeg());
            key = await storage.CommitAsync(staged, siteId, new DateTimeOffset(2026, 11, 25, 8, 0, 0, TimeSpan.Zero));
        }

        string[] attacks = ["../../x.jpg", "..\\..\\x.jpg", "/etc/passwd", "C:\\Windows\\win.ini", Path.GetRelativePath(root, outside), key.Replace('/', '\\'), key + "/..", string.Empty];

        Assert.Multiple(() =>
        {
            Assert.That(key, Does.Match($"^{siteId:N}/2026/11/[0-9a-f]{{32}}\\.jpg$"));
            Assert.That(File.Exists(Path.Combine(root, key)), Is.True);
            using (var read = storage.OpenRead(key))
            {
                Assert.That(read, Is.Not.Null);
            }

            foreach (var attack in attacks)
            {
                Assert.That(storage.OpenRead(attack), Is.Null, attack);
            }

            Assert.That(Directory.GetFiles(Path.Combine(root, ".staging")), Is.Empty);
        });

        await storage.DeleteAsync("../../x.jpg");
        Assert.That(File.Exists(outside), Is.True);
        await storage.DeleteAsync(key);
        Assert.That(File.Exists(Path.Combine(root, key)), Is.False);
    }

    [Test]
    public async Task A_staged_photo_that_is_not_committed_leaves_no_file()
    {
        var root = Path.Combine(Path.GetTempPath(), "chantier-unit-photos", Guid.NewGuid().ToString("N"));
        var storage = new FileSystemPhotoStorage(Microsoft.Extensions.Options.Options.Create(new PhotoStorageOptions { PhotosRoot = root }));

        await using (var staged = await storage.StageAsync())
        {
            await staged.Stream.WriteAsync(new byte[] { 1, 2, 3 });
        }

        Assert.That(Directory.GetFiles(root, "*", SearchOption.AllDirectories), Is.Empty);
    }
}
