using Chantier.Core.DTOs.Materials;
using Chantier.Core.Entities.Common;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services.Materials;

/// <summary>
/// Ajoute les evenements d'historique au contexte (ecrits par le <c>SaveChanges</c> de l'appelant, donc dans sa transaction) et <b>touche la ligne du sujet</b> :
/// un evenement ecrit sans modifier la demande ou la livraison ne ferait pas avancer sa version, et la synchronisation (qui envoie la ligne avec son historique)
/// ne le transmettrait jamais.
/// </summary>
public sealed class RequestEventWriter(ApplicationDbContext db) : IRequestEventWriter
{
    public void Add(
        MaterialRequest request,
        MaterialEventType type,
        RequestActionContext context,
        RequestStatus? fromStatus = null,
        RequestStatus? toStatus = null,
        string? reasonCode = null,
        string? note = null,
        IReadOnlyList<FieldChange>? changes = null)
    {
        db.MaterialEvents.Add(MaterialEvent.Create(
            request.SiteId, MaterialSubjectType.Request, request.Id, type, fromStatus, toStatus, reasonCode, note, changes, context.DeviceAt, context.Source));
        Touch(request);
    }

    public void Add(
        Delivery delivery,
        MaterialEventType type,
        RequestActionContext context,
        string? reasonCode = null,
        string? note = null,
        IReadOnlyList<FieldChange>? changes = null)
    {
        db.MaterialEvents.Add(MaterialEvent.Create(
            delivery.SiteId, MaterialSubjectType.Delivery, delivery.Id, type, null, null, reasonCode, note, changes, context.DeviceAt, context.Source));
        Touch(delivery);
    }

    /// <summary>
    /// Force l'ecriture de la ligne meme si aucune valeur ne change : l'intercepteur d'audit renouvelle alors <c>UpdatedAt</c> (donc la version).
    /// Une ligne nouvelle ou deja modifiee n'a rien a faire.
    /// </summary>
    private void Touch(BasicEntity entity)
    {
        var entry = db.Entry(entity);
        if (entry.State == EntityState.Unchanged)
        {
            entry.Property(nameof(BasicEntity.UpdatedAt)).IsModified = true;
        }
    }
}
