using Ardalis.Specification;
using Chantier.Core.Entities.Sites;

namespace Chantier.Core.Specifications.Sites;

/// <summary>
/// Zones d'un chantier, du plus bas au plus haut (bloc, puis cote croissante, les zones sans cote d'abord, puis local).
/// Pagination par curseur : le curseur est un decalage opaque (un chantier compte quelques centaines de zones au plus).
/// </summary>
public sealed class ZonesBySiteSpecification : Specification<Zone>
{
    public ZonesBySiteSpecification(Guid siteId, string? block, string? search, bool includeArchived, int skip = 0, int take = 100)
    {
        Query.Where(zone => zone.SiteId == siteId);

        if (!includeArchived)
        {
            Query.Where(zone => zone.ArchivedAt == null);
        }

        if (!string.IsNullOrWhiteSpace(block))
        {
            var blockName = block.Trim();
            Query.Where(zone => zone.Block == blockName);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var text = search.Trim();
            Query.Where(zone => zone.Block.Contains(text) || (zone.RoomLabel != null && zone.RoomLabel.Contains(text)));
        }

        Query.OrderBy(zone => zone.Block)
            .ThenBy(zone => zone.Elevation)
            .ThenBy(zone => zone.RoomType)
            .ThenBy(zone => zone.RoomNumber)
            .ThenBy(zone => zone.RoomLabel)
            .ThenBy(zone => zone.Id);

        Query.Skip(skip).Take(take);
    }
}

/// <summary>Une zone lue par (chantier, identifiant) : jamais par identifiant seul (OWASP API1).</summary>
public sealed class ZoneBySiteAndIdSpecification : Specification<Zone>, ISingleResultSpecification<Zone>
{
    public ZoneBySiteAndIdSpecification(Guid siteId, Guid zoneId)
    {
        Query.Where(zone => zone.SiteId == siteId && zone.Id == zoneId);
    }
}

/// <summary>Idempotence de la creation hors ligne : zone deja recue pour ce (chantier, <c>clientId</c>).</summary>
public sealed class ZoneByClientIdSpecification : Specification<Zone>, ISingleResultSpecification<Zone>
{
    public ZoneByClientIdSpecification(Guid siteId, Guid clientId)
    {
        Query.Where(zone => zone.SiteId == siteId && zone.ClientId == clientId);
    }
}

/// <summary>
/// Zone <b>active</b> (non archivee) a la meme position : meme bloc, cote, type, numero et libelle, valeurs absentes comprises.
/// <c>exceptZoneId</c> exclut la zone en cours de modification ou de restauration.
/// </summary>
public sealed class ZoneByPositionSpecification : Specification<Zone>, ISingleResultSpecification<Zone>
{
    public ZoneByPositionSpecification(Guid siteId, string block, decimal? elevation, RoomType? roomType, int? roomNumber, string? roomLabel, Guid? exceptZoneId = null)
    {
        // La comparaison avec une valeur nulle devient « IS NULL » (semantique C# d'EF Core).
        Query.Where(zone => zone.SiteId == siteId
            && zone.ArchivedAt == null
            && zone.Block == block
            && zone.Elevation == elevation
            && zone.RoomType == roomType
            && zone.RoomNumber == roomNumber
            && zone.RoomLabel == roomLabel);

        if (exceptZoneId is { } except)
        {
            Query.Where(zone => zone.Id != except);
        }
    }
}
