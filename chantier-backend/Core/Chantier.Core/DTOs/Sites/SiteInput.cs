using Chantier.Core.Entities.Sites;

namespace Chantier.Core.DTOs.Sites;

/// <summary>
/// Donnees modifiables d'un chantier. Ne contient jamais le code (immuable apres creation), le statut,
/// ni aucun champ d'audit (protection contre l'affectation de masse).
/// </summary>
public sealed record SiteInput(
    string Name,
    string? NameAr,
    SiteType Type,
    string Wilaya,
    string Commune,
    decimal? Latitude,
    decimal? Longitude,
    string Owner,
    string? ContractNumber,
    decimal? ContractAmount,
    int? DelayDays,
    DateOnly? OdsDate);

public sealed record CreateSiteDto(string Code, SiteInput Data);

public sealed record UpdateSiteDto(string Version, SiteInput Data);
