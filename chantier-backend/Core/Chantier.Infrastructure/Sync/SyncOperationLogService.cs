using Chantier.Core.Abstractions;
using Chantier.Core.Entities.Sync;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Journal des operations <c>update</c> et <c>transition</c> (ADR 0011) : une ligne par operation, ecrite <b>dans la transaction de l'operation</b> (jamais
/// un effet sans journal, jamais un journal sans effet). Un renvoi du meme <c>clientId</c> relit la ligne et rend le meme resultat sans rien rejouer :
/// jamais de faux conflit apres une coupure. Le journal ne garde que l'issue (ni contenu, ni prix, ni telephone).
/// </summary>
public sealed class SyncOperationLogService(ApplicationDbContext db, ICurrentUser currentUser, TimeProvider time)
{
    public Task<SyncOperationLog?> FindAsync(Guid clientId, CancellationToken cancellationToken = default)
        => db.SyncOperationLogs.AsNoTracking().FirstOrDefaultAsync(log => log.ClientId == clientId, cancellationToken);

    /// <summary>Ajoute la ligne au contexte : elle est ecrite avec le reste de la transaction par le <c>SaveChanges</c> de l'appelant.</summary>
    public void Add(SyncOperation operation, string outcome, string? code, Guid? resourceId, IReadOnlyList<string>? conflictFields)
        => db.SyncOperationLogs.Add(SyncOperationLog.Create(
            operation.ClientId,
            currentUser.Id ?? SystemActor.Id,
            operation.SiteId,
            operation.Entity,
            operation.Operation,
            outcome,
            code,
            resourceId,
            conflictFields,
            time.GetUtcNow()));
}
