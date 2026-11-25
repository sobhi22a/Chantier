using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Sites;
using Chantier.Core.Exceptions;
using Chantier.Core.Sites;

namespace Chantier.UnitTests.Sites;

/// <summary>Regles de la zone (CT-17) sans base ni HTTP.</summary>
[TestFixture]
public class ZoneTests
{
    private static readonly ZoneOptions Rules = new();
    private static readonly Guid SiteId = Guid.CreateVersion7();

    private static Zone Create(ZoneInput input, Guid? clientId = null, ZoneOptions? rules = null)
        => Zone.Create(SiteId, new CreateZoneDto(clientId, null, input), rules ?? Rules);

    private static ZoneInput Position(string block = "Bloc 01", decimal? elevation = null, RoomType? roomType = null, int? roomNumber = null, string? roomLabel = null)
        => new(block, elevation, roomType, roomNumber, roomLabel);

    private static Chantier.Core.Exceptions.ValidationException Refused(ZoneInput input, ZoneOptions? rules = null)
        => Assert.Throws<Chantier.Core.Exceptions.ValidationException>(() => Create(input, rules: rules))!;

    [Test]
    public void A_block_alone_is_a_valid_zone()
    {
        var zone = Create(Position());

        Assert.Multiple(() =>
        {
            Assert.That(zone.Block, Is.EqualTo("Bloc 01"));
            Assert.That(zone.Elevation, Is.Null);
            Assert.That(zone.RoomType, Is.Null);
            Assert.That(zone.SiteId, Is.EqualTo(SiteId));
        });
    }

    [Test]
    public void Block_is_required_and_limited_to_50_characters()
    {
        Assert.Multiple(() =>
        {
            Assert.That(Refused(Position(block: "  ")).Errors, Contains.Key("block"));
            Assert.That(Refused(Position(block: new string('B', 51))).Errors, Contains.Key("block"));
            Assert.That(() => Create(Position(block: new string('B', 50))), Throws.Nothing);
        });
    }

    [Test]
    public void Block_is_trimmed() => Assert.That(Create(Position(block: "  Bloc 02 ")).Block, Is.EqualTo("Bloc 02"));

    // --- Cote : -20,00 a +60,00, 2 decimales ---

    [TestCase(-20.00)]
    [TestCase(-1.90)]
    [TestCase(0.00)]
    [TestCase(3.40)]
    [TestCase(10.20)]
    [TestCase(60.00)]
    public void Elevation_inside_the_range_is_accepted(double elevation)
        => Assert.That(Create(Position(elevation: (decimal)elevation)).Elevation, Is.EqualTo((decimal)elevation));

    [TestCase(-20.01)]
    [TestCase(-100.00)]
    [TestCase(60.01)]
    [TestCase(1000.00)]
    public void Elevation_outside_the_range_is_refused(double elevation)
        => Assert.That(Refused(Position(elevation: (decimal)elevation)).Errors, Contains.Key("elevation"));

    [TestCase(3.405)]
    [TestCase(0.001)]
    public void Elevation_with_more_than_two_decimals_is_refused(double elevation)
        => Assert.That(Refused(Position(elevation: (decimal)elevation)).Errors, Contains.Key("elevation"));

    [Test]
    public void Elevation_bounds_are_configurable()
    {
        var rules = new ZoneOptions { ElevationMin = -5m, ElevationMax = 12m };

        Assert.Multiple(() =>
        {
            Assert.That(() => Create(Position(elevation: 12m), rules: rules), Throws.Nothing);
            Assert.That(Refused(Position(elevation: 12.01m), rules).Errors, Contains.Key("elevation"));
            Assert.That(Refused(Position(elevation: -5.01m), rules).Errors, Contains.Key("elevation"));
        });
    }

    [Test]
    public void Elevation_zero_is_a_real_value_not_a_missing_one()
        => Assert.That(Create(Position(elevation: 0m)).Elevation, Is.EqualTo(0m));

    // --- Local ---

    [Test]
    public void Room_label_is_allowed_only_for_the_type_Other()
    {
        Assert.Multiple(() =>
        {
            Assert.That(() => Create(Position(roomType: RoomType.Other, roomLabel: "Local gardien")), Throws.Nothing);
            Assert.That(Refused(Position(roomType: RoomType.Classroom, roomNumber: 1, roomLabel: "Local gardien")).Errors, Contains.Key("roomLabel"));
            Assert.That(Refused(Position(roomLabel: "Local gardien")).Errors, Contains.Key("roomLabel"));
        });
    }

    [Test]
    public void Room_label_is_limited_to_100_characters()
        => Assert.That(Refused(Position(roomType: RoomType.Other, roomLabel: new string('x', 101))).Errors, Contains.Key("roomLabel"));

    [Test]
    public void Blank_room_label_is_ignored_even_without_the_type_Other()
        => Assert.That(Create(Position(roomType: RoomType.Classroom, roomNumber: 2, roomLabel: "   ")).RoomLabel, Is.Null);

    [TestCase(0)]
    [TestCase(-1)]
    [TestCase(1000)]
    public void Room_number_must_be_between_1_and_999(int number)
        => Assert.That(Refused(Position(roomType: RoomType.Classroom, roomNumber: number)).Errors, Contains.Key("roomNumber"));

    [Test]
    public void Room_number_needs_a_room_type()
        => Assert.That(Refused(Position(roomNumber: 3)).Errors, Contains.Key("roomNumber"));

    [Test]
    public void Unknown_room_type_is_refused()
        => Assert.That(Refused(Position(roomType: (RoomType)99)).Errors, Contains.Key("roomType"));

    [Test]
    public void All_room_types_of_the_contract_exist()
        => Assert.That(
            Enum.GetNames<RoomType>(),
            Is.EquivalentTo(new[] { "Classroom", "Corridor", "Canteen", "Refectory", "Kitchen", "Office", "Sanitary", "TechnicalRoom", "Facade", "Other" }));

    // --- Creation hors ligne ---

    [Test]
    public void Client_id_and_client_time_are_kept_apart_from_the_audit_fields()
    {
        var clientId = Guid.NewGuid();
        var phoneTime = new DateTimeOffset(2026, 11, 24, 6, 58, 0, TimeSpan.Zero);

        var zone = Zone.Create(SiteId, new CreateZoneDto(clientId, phoneTime, Position()), Rules);

        Assert.Multiple(() =>
        {
            Assert.That(zone.ClientId, Is.EqualTo(clientId));
            Assert.That(zone.ClientCreatedAt, Is.EqualTo(phoneTime));
            Assert.That(zone.CreatedAt, Is.EqualTo(default(DateTimeOffset)), "createdAt n'est posé que par l'intercepteur d'audit, jamais par le client.");
        });
    }

    [Test]
    public void Empty_client_id_is_refused()
        => Assert.That(Assert.Throws<Chantier.Core.Exceptions.ValidationException>(() => Create(Position(), Guid.Empty))!.Errors, Contains.Key("clientId"));

    [Test]
    public void Errors_are_reported_together()
    {
        var exception = Refused(Position(block: "", elevation: 99m, roomType: RoomType.Classroom, roomLabel: "x"));

        Assert.That(exception.Errors.Keys, Is.SupersetOf(new[] { "block", "elevation", "roomLabel" }));
    }

    // --- Archivage ---

    [Test]
    public void Archive_and_restore_are_traced_and_idempotent()
    {
        var zone = Create(Position());
        var actor = Guid.CreateVersion7();
        var at = new DateTimeOffset(2026, 11, 24, 9, 0, 0, TimeSpan.Zero);

        zone.Archive(actor, at);
        zone.Archive(Guid.CreateVersion7(), at.AddHours(1));
        Assert.Multiple(() =>
        {
            Assert.That(zone.IsArchived, Is.True);
            Assert.That(zone.ArchivedBy, Is.EqualTo(actor));
            Assert.That(zone.ArchivedAt, Is.EqualTo(at));
        });

        zone.Restore();
        Assert.That(zone.IsArchived, Is.False);
    }

    [Test]
    public void Normalize_returns_the_cleaned_input_without_creating_a_zone()
    {
        var normalized = Zone.Normalize(Position(block: " Bloc 03 ", elevation: 3.40m, roomType: RoomType.Classroom, roomNumber: 2), Rules);

        Assert.That(normalized, Is.EqualTo(new ZoneInput("Bloc 03", 3.40m, RoomType.Classroom, 2, null)));
    }
}
