using Chantier.Core.Identity;
using Chantier.Core.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Chantiers visibles de l'utilisateur. Le filtre <c>SoftDelete</c> est desactive <b>par son nom</b> pour lire les pierres tombales ;
/// le perimetre (chantiers affectes) est applique explicitement. Le montant du marche n'est present qu'avec <c>ContractAmount.View</c>.
/// </summary>
public sealed class SiteSyncSource(ApplicationDbContext db, IUserDirectory directory) : ISyncSource
{
    public async Task<IReadOnlyList<SyncChangeRow>> ReadAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken = default)
    {
        var query = db.Sites.AsNoTracking()
            .IgnoreQueryFilters([QueryFilterNames.SoftDelete])
            .Where(site => site.RowVersion > since && site.RowVersion < upper);

        if (scope.VisibleSiteIds is { } visible)
        {
            query = query.Where(site => visible.Contains(site.Id));
        }

        var sites = await query.OrderBy(site => site.RowVersion).Take(take).ToListAsync(cancellationToken);

        var includeAmount = scope.Permissions.Contains(Permissions.ContractAmountView);
        var names = await directory.GetNamesAsync(sites.SelectMany(SiteResponse.AuditUsers), cancellationToken);

        return sites
            .Select(site => new SyncChangeRow(
                SyncEntities.Site,
                site.Id,
                site.Id,
                site.RowVersion,
                site.IsDeleted ? null : SiteResponse.From(site, includeAmount, names)))
            .ToList();
    }
}
