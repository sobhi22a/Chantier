using Chantier.Core.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>Zones des chantiers visibles (archivees comprises : <c>archivedAt</c> fait partie de la ressource) ; pierres tombales pour les zones supprimees.</summary>
public sealed class ZoneSyncSource(ApplicationDbContext db, IUserDirectory directory) : ISyncSource
{
    public async Task<IReadOnlyList<SyncChangeRow>> ReadAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken = default)
    {
        var query = db.Zones.AsNoTracking()
            .IgnoreQueryFilters([QueryFilterNames.SoftDelete])
            .Where(zone => zone.RowVersion > since && zone.RowVersion < upper);

        if (scope.VisibleSiteIds is { } visible)
        {
            query = query.Where(zone => visible.Contains(zone.SiteId));
        }

        var zones = await query.OrderBy(zone => zone.RowVersion).Take(take).ToListAsync(cancellationToken);
        var names = await directory.GetNamesAsync(zones.SelectMany(ZoneResponse.AuditUsers), cancellationToken);

        return zones
            .Select(zone => new SyncChangeRow(
                SyncEntities.Zone,
                zone.Id,
                zone.SiteId,
                zone.RowVersion,
                zone.IsDeleted ? null : ZoneResponse.From(zone, names)))
            .ToList();
    }
}
