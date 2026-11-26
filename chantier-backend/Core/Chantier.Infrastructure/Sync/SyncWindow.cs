using Chantier.Core.Entities.Materials;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Fenetre de synchronisation (R2-02) : ce qu'un telephone n'a plus besoin de recevoir. Est <b>hors fenetre</b> : une demande close
/// (<c>Received</c>, <c>Cancelled</c>, <c>Rejected</c>) modifiee il y a plus de <see cref="SyncOptions.ClosedRetentionDays"/> jours, une livraison annulee depuis aussi longtemps,
/// les livraisons d'une demande hors fenetre et les photos d'une livraison hors fenetre. Une demande ouverte et une livraison non rattachee (a traiter) sont toujours dans la fenetre.
/// <b>Une seule definition</b> pour la lecture (pull) et pour l'affectation (<see cref="SyncTouch"/> ne touche que ce qui sera lu) : la version SQL de
/// <see cref="SyncTouch"/> reprend exactement ces regles (un test compare les deux).
/// </summary>
public sealed class SyncWindow(ApplicationDbContext db, IOptions<SyncOptions> options, TimeProvider time)
{
    /// <summary>Statuts d'une demande terminee.</summary>
    public static readonly IReadOnlyList<RequestStatus> ClosedStatuses = [RequestStatus.Received, RequestStatus.Cancelled, RequestStatus.Rejected];

    /// <summary>Limite : avant cette date, une ligne close est hors fenetre ; <c>null</c> = pas de fenetre.</summary>
    public DateTimeOffset? Cutoff => options.Value.ClosedRetentionDays > 0 ? time.GetUtcNow().AddDays(-options.Value.ClosedRetentionDays) : null;

    public IQueryable<MaterialRequest> Requests(IQueryable<MaterialRequest> query)
    {
        if (Cutoff is not { } cutoff)
        {
            return query;
        }

        var closed = ClosedStatuses;
        return query.Where(request => !(closed.Contains(request.Status) && (request.UpdatedAt ?? request.CreatedAt) < cutoff));
    }

    public IQueryable<Delivery> Deliveries(IQueryable<Delivery> query)
    {
        if (Cutoff is not { } cutoff)
        {
            return query;
        }

        var closed = ClosedStatuses;
        return query.Where(delivery =>
            !((delivery.Status == DeliveryStatus.Cancelled && (delivery.UpdatedAt ?? delivery.CreatedAt) < cutoff)
              || (delivery.RequestId != null
                  && db.MaterialRequests.Any(request => request.Id == delivery.RequestId && closed.Contains(request.Status) && (request.UpdatedAt ?? request.CreatedAt) < cutoff))));
    }

    /// <summary>
    /// R3-05 : des lignes visibles de cet utilisateur ont change depuis <paramref name="since"/> et sont aujourd'hui <b>hors fenetre</b> (donc jamais envoyees) : un telephone dont le
    /// curseur est plus ancien que la fenetre a pu manquer la fermeture d'une demande qu'il croit encore ouverte, et ne le saura pas (aucune pierre tombale). Exact et sans etat : un
    /// telephone a jour n'a aucune ligne hors fenetre plus recente que son curseur (une ligne hors fenetre n'a pas ete modifiee depuis plus de 60 jours).
    /// </summary>
    public async Task<bool> HasHiddenChangesAsync(SyncScope scope, ulong since, ulong upper, CancellationToken cancellationToken)
    {
        if (Cutoff is null)
        {
            return false;
        }

        if (scope.Permissions.Contains(Chantier.Core.Identity.Permissions.RequestsView))
        {
            var changed = db.MaterialRequests.AsNoTracking().Where(request => request.RowVersion > since && request.RowVersion < upper);
            if (scope.VisibleSiteIds is { } visible)
            {
                changed = changed.Where(request => visible.Contains(request.SiteId));
            }

            var inside = Requests(changed).Select(request => request.Id);
            if (await changed.AnyAsync(request => !inside.Contains(request.Id), cancellationToken))
            {
                return true;
            }
        }

        if (scope.Permissions.Contains(Chantier.Core.Identity.Permissions.DeliveriesView))
        {
            var changed = db.Deliveries.AsNoTracking().Where(delivery => delivery.RowVersion > since && delivery.RowVersion < upper);
            if (scope.VisibleSiteIds is { } visible)
            {
                changed = changed.Where(delivery => visible.Contains(delivery.SiteId));
            }

            var inside = Deliveries(changed).Select(delivery => delivery.Id);
            if (await changed.AnyAsync(delivery => !inside.Contains(delivery.Id), cancellationToken))
            {
                return true;
            }
        }

        return false;
    }

    public IQueryable<Photo> Photos(IQueryable<Photo> query)
    {
        if (Cutoff is not { } cutoff)
        {
            return query;
        }

        var closed = ClosedStatuses;
        return query.Where(photo => !db.Deliveries.Any(delivery => delivery.Id == photo.DeliveryId
            && ((delivery.Status == DeliveryStatus.Cancelled && (delivery.UpdatedAt ?? delivery.CreatedAt) < cutoff)
                || (delivery.RequestId != null
                    && db.MaterialRequests.Any(request => request.Id == delivery.RequestId && closed.Contains(request.Status) && (request.UpdatedAt ?? request.CreatedAt) < cutoff)))));
    }
}
