using Chantier.Core.Abstractions;
using Chantier.Core.Entities.Common;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;

namespace Chantier.Infrastructure.Persistence;

/// <summary>
/// Audit automatique (regle 9, CT-6) : <c>CreatedBy/At</c>, <c>UpdatedBy/At</c> et suppression logique sont poses ici,
/// jamais par le code appelant, jamais par le client. L'auteur est l'utilisateur du jeton (ou <see cref="SystemActor"/>
/// hors requete) et l'heure est celle du serveur (<see cref="TimeProvider"/>), pas celle du telephone.
/// <c>DbSet.Remove</c> est converti en suppression logique : rien n'est supprime physiquement.
/// </summary>
public sealed class AuditingInterceptor(ICurrentUser currentUser, TimeProvider timeProvider) : SaveChangesInterceptor
{
    public override InterceptionResult<int> SavingChanges(DbContextEventData eventData, InterceptionResult<int> result)
    {
        Apply(eventData.Context);
        return result;
    }

    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    {
        Apply(eventData.Context);
        return ValueTask.FromResult(result);
    }

    private void Apply(DbContext? context)
    {
        if (context is null)
        {
            return;
        }

        context.ChangeTracker.DetectChanges();

        var actor = currentUser.Id ?? SystemActor.Id;
        var now = timeProvider.GetUtcNow();

        foreach (var entry in context.ChangeTracker.Entries<BasicEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.MarkCreated(actor, now);
                    break;

                case EntityState.Modified:
                    entry.Entity.MarkUpdated(actor, now);
                    break;

                case EntityState.Deleted:
                    entry.State = EntityState.Modified;
                    entry.Entity.MarkDeleted(actor, now);
                    break;
            }
        }

        // Les champs d'audit viennent d'etre modifies par du code, pas par EF : on rejoue la detection.
        context.ChangeTracker.DetectChanges();
    }
}
