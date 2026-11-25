using Chantier.Core.Entities.Sites;

namespace Chantier.Core.DTOs.Sites;

/// <summary>Position d'une zone : bloc, cote (metres) et local. Aucun champ d'audit ni de statut.</summary>
public sealed record ZoneInput(
    string Block,
    decimal? Elevation,
    RoomType? RoomType,
    int? RoomNumber,
    string? RoomLabel);

/// <summary><c>ClientId</c> et <c>ClientCreatedAt</c> : creation hors ligne idempotente (regle 6).</summary>
public sealed record CreateZoneDto(Guid? ClientId, DateTimeOffset? ClientCreatedAt, ZoneInput Data);

public sealed record UpdateZoneDto(string Version, ZoneInput Data);
