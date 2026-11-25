using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Common;
using Chantier.Core.Exceptions;
using Chantier.Core.Sites;
using Chantier.Core.Validation;

namespace Chantier.Core.Entities.Sites;

/// <summary>
/// Zone d'un chantier : bloc (obligatoire) + cote en metres (facultative) + local (facultatif). Une meme combinaison
/// n'existe qu'une fois par chantier parmi les zones actives (H-07). Creable hors ligne (<see cref="ClientId"/>).
/// </summary>
public class Zone : BasicEntity, ISiteScoped, IHasClientId
{
    public const int MaxRoomNumber = 999;

    // EF Core
    private Zone()
    {
    }

    public Guid SiteId { get; private set; }

    public Guid? ClientId { get; private set; }

    public DateTimeOffset? ClientCreatedAt { get; private set; }

    public string Block { get; private set; } = string.Empty;

    /// <summary>Cote en metres, 2 decimales (de -20,00 a +60,00 par defaut).</summary>
    public decimal? Elevation { get; private set; }

    public RoomType? RoomType { get; private set; }

    public int? RoomNumber { get; private set; }

    /// <summary>Libelle libre, seulement si <see cref="RoomType"/> vaut <see cref="Sites.RoomType.Other"/>.</summary>
    public string? RoomLabel { get; private set; }

    public DateTimeOffset? ArchivedAt { get; private set; }

    public Guid? ArchivedBy { get; private set; }

    public bool IsArchived => ArchivedAt is not null;

    public static Zone Create(Guid siteId, CreateZoneDto dto, ZoneOptions rules)
    {
        var errors = new ErrorCollector();
        if (dto.ClientId == Guid.Empty)
        {
            errors.Add("clientId", "L'identifiant client est invalide.");
        }

        var zone = new Zone
        {
            SiteId = siteId,
            ClientId = dto.ClientId,
            ClientCreatedAt = dto.ClientCreatedAt,
        };
        zone.Apply(dto.Data, rules, errors);
        return zone;
    }

    public void Update(ZoneInput input, ZoneOptions rules) => Apply(input, rules, new ErrorCollector());

    public void Archive(Guid by, DateTimeOffset at)
    {
        if (IsArchived)
        {
            return;
        }

        ArchivedAt = at;
        ArchivedBy = by;
    }

    public void Restore()
    {
        ArchivedAt = null;
        ArchivedBy = null;
    }

    /// <summary>Normalise et valide une position de zone ; leve <see cref="ValidationException"/> (400) si elle est invalide.</summary>
    public static ZoneInput Normalize(ZoneInput input, ZoneOptions rules)
    {
        var errors = new ErrorCollector();
        var normalized = Validate(input, rules, errors);
        errors.ThrowIfAny();
        return normalized;
    }

    private void Apply(ZoneInput input, ZoneOptions rules, ErrorCollector errors)
    {
        var normalized = Validate(input, rules, errors);
        errors.ThrowIfAny();

        Block = normalized.Block;
        Elevation = normalized.Elevation;
        RoomType = normalized.RoomType;
        RoomNumber = normalized.RoomNumber;
        RoomLabel = normalized.RoomLabel;
    }

    private static ZoneInput Validate(ZoneInput input, ZoneOptions rules, ErrorCollector errors)
    {
        var block = string.IsNullOrWhiteSpace(input.Block) ? null : input.Block.Trim();
        if (block is null)
        {
            errors.Add("block", "Le bloc est obligatoire.");
        }
        else if (block.Length > 50)
        {
            errors.Add("block", "Trop long (50 caractères au maximum).");
        }

        decimal? elevation = null;
        if (input.Elevation is { } value)
        {
            if (decimal.Round(value, 2, MidpointRounding.AwayFromZero) != value)
            {
                errors.Add("elevation", "La cote s'exprime en mètres avec 2 décimales au maximum.");
            }
            else if (value < rules.ElevationMin || value > rules.ElevationMax)
            {
                errors.Add("elevation", $"La cote doit être comprise entre {Format(rules.ElevationMin)} et {Format(rules.ElevationMax)} m.");
            }
            else
            {
                elevation = decimal.Round(value, 2, MidpointRounding.AwayFromZero);
            }
        }

        if (input.RoomType is { } roomType && !Enum.IsDefined(roomType))
        {
            errors.Add("roomType", "Le type de local est invalide.");
        }

        if (input.RoomNumber is { } number)
        {
            if (input.RoomType is null)
            {
                errors.Add("roomNumber", "Le numéro de local exige un type de local.");
            }
            else if (number is < 1 or > MaxRoomNumber)
            {
                errors.Add("roomNumber", $"Le numéro de local doit être compris entre 1 et {MaxRoomNumber}.");
            }
        }

        var label = string.IsNullOrWhiteSpace(input.RoomLabel) ? null : input.RoomLabel.Trim();
        if (label is not null)
        {
            if (input.RoomType != Sites.RoomType.Other)
            {
                errors.Add("roomLabel", "Le libellé libre n'est possible que pour le type de local « Autre ».");
            }
            else if (label.Length > 100)
            {
                errors.Add("roomLabel", "Trop long (100 caractères au maximum).");
            }
        }

        return new ZoneInput(block ?? string.Empty, elevation, input.RoomType, input.RoomNumber, label);
    }

    private static string Format(decimal value)
        => value.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture).Replace('.', ',');
}
