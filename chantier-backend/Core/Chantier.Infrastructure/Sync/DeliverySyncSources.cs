using Chantier.Core.Entities.Materials;
using Chantier.Core.Identity;
using Chantier.Core.Materials;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Chantier.Infrastructure.Services.Materials;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Livraisons des chantiers visibles, annulees comprises (aucune pierre tombale). Chaque ligne porte son historique : <b>toute ecriture d'evenement modifie aussi la ligne
/// de la livraison</b> (<c>RequestEventWriter</c>). Forme de synchronisation : ni montant, ni photos, ni « BL manquant » (deduits de l'entite <c>photo</c>), ni
/// evenement sensible (ADR 0012).
/// </summary>
public sealed class DeliverySyncSource(ApplicationDbContext db, DeliveryProjector projector, SyncWindow window) : ISyncSource
{
    public async Task<IReadOnlyList<SyncChangeRow>> ReadAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken = default)
    {
        if (!scope.Permissions.Contains(Permissions.DeliveriesView))
        {
            return [];
        }

        var query = db.Deliveries.AsNoTracking().Where(delivery => delivery.RowVersion > since && delivery.RowVersion < upper);
        if (scope.VisibleSiteIds is { } visible)
        {
            query = query.Where(delivery => visible.Contains(delivery.SiteId));
        }

        var deliveries = await window.Deliveries(query).OrderBy(delivery => delivery.RowVersion).Take(take).ToListAsync(cancellationToken);
        var details = await projector.ToDetailsAsync(deliveries, includeCommercial: false, includePhotos: false, cancellationToken, includeHistory: false);

        return deliveries
            .Zip(details, (delivery, detail) => new SyncChangeRow(SyncEntities.Delivery, delivery.Id, delivery.SiteId, delivery.RowVersion, DeliverySyncData.From(detail)))
            .ToList();
    }
}

/// <summary>
/// Metadonnees des photos de bon des chantiers visibles. <b>Aucune ligne pour un utilisateur sans <c>DeliveryPhotos.View</c></b> (un ChefEquipe ne voit pas les bons : ils
/// peuvent montrer des prix). Jamais de chemin de stockage ni d'empreinte ; le fichier se lit par <c>GET .../photos/{id}/content</c>.
/// </summary>
public sealed class PhotoSyncSource(ApplicationDbContext db, SyncWindow window) : ISyncSource
{
    public async Task<IReadOnlyList<SyncChangeRow>> ReadAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken = default)
    {
        if (!scope.Permissions.Contains(Permissions.DeliveryPhotosView))
        {
            return [];
        }

        var query = db.Photos.AsNoTracking().Where(photo => photo.RowVersion > since && photo.RowVersion < upper);
        if (scope.VisibleSiteIds is { } visible)
        {
            query = query.Where(photo => visible.Contains(photo.SiteId));
        }

        var photos = await window.Photos(query).OrderBy(photo => photo.RowVersion).Take(take).ToListAsync(cancellationToken);
        return photos.Select(photo => new SyncChangeRow(SyncEntities.Photo, photo.Id, photo.SiteId, photo.RowVersion, PhotoResponse.From(photo))).ToList();
    }
}
