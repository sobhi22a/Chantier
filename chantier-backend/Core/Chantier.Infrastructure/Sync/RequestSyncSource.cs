using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Chantier.Infrastructure.Services.Materials;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Demandes des chantiers visibles, archivees comprises (<c>archivedAt</c> fait partie de la ressource ; aucune pierre tombale). Chaque ligne porte son
/// historique : un evenement ecrit sans modifier la demande ne ferait pas avancer sa version, donc <b>toute ecriture d'evenement modifie aussi la ligne
/// de la demande</b>. Forme de synchronisation : ni code de chantier, ni evenement sensible, ni aucun champ commercial (ADR 0012).
/// </summary>
public sealed class RequestSyncSource(ApplicationDbContext db, RequestProjector projector, SyncWindow window) : ISyncSource
{
    public async Task<IReadOnlyList<SyncChangeRow>> ReadAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken = default)
    {
        if (!scope.Permissions.Contains(Permissions.RequestsView))
        {
            return [];
        }

        var query = db.MaterialRequests.AsNoTracking().Where(request => request.RowVersion > since && request.RowVersion < upper);
        if (scope.VisibleSiteIds is { } visible)
        {
            query = query.Where(request => visible.Contains(request.SiteId));
        }

        // Fenetre de synchronisation (R2-02) : les demandes closes depuis longtemps ne sont plus envoyees.
        var requests = await window.Requests(query).OrderBy(request => request.RowVersion).Take(take).ToListAsync(cancellationToken);
        var details = await projector.ToDetailsAsync(
            requests, includeSiteCode: false, includeCommercial: false, includeDeliveries: false, cancellationToken, includeHistory: false);

        return requests
            .Zip(details, (request, detail) => new SyncChangeRow(SyncEntities.Request, request.Id, request.SiteId, request.RowVersion, RequestSyncData.From(detail)))
            .ToList();
    }
}
