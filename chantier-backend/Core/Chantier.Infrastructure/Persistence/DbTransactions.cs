using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Persistence;

/// <summary>
/// Transaction explicite <b>ou rejointe</b> : une action qui a besoin d'une transaction (numerotation, plusieurs ecritures) la cree si aucune n'est
/// ouverte, et rejoint celle de l'appelant sinon (la synchronisation ouvre la sienne pour y ecrire aussi le journal d'operations).
/// Une exception annule tout : le numero consomme est libere, aucun trou.
/// <b>Interblocage (SQL 1205)</b> : la transaction qui en est la victime est annulee par SQL Server ; son proprietaire la rejoue (nouvelle transaction, contexte
/// vide), car toutes les actions sont idempotentes (<c>clientId</c>, verrou applicatif, relecture). Une transaction rejointe ne se rejoue pas : c'est celle de l'appelant qui l'est.
/// </summary>
public static class DbTransactions
{
    /// <summary>Premier essai compris : un interblocage isole est rejoue, une serie d'interblocages remonte (503, jamais une saisie perdue en silence).</summary>
    public const int MaxAttempts = 4;

    public static async Task<T> RunAsync<T>(ApplicationDbContext db, Func<Task<T>> action, CancellationToken cancellationToken = default)
    {
        if (db.Database.CurrentTransaction is not null)
        {
            return await action();
        }

        for (var attempt = 1; ; attempt++)
        {
            try
            {
                await using var transaction = await db.Database.BeginTransactionAsync(cancellationToken);
                var result = await action();
                await transaction.CommitAsync(cancellationToken);
                return result;
            }
            catch (Exception exception) when (attempt < MaxAttempts && SqlErrors.IsDeadlock(exception))
            {
                // Entites suivies d'une tentative annulee : jamais reutilisees. Pause courte et inegale pour ne pas reproduire le meme croisement.
                db.ChangeTracker.Clear();
                await Task.Delay(Random.Shared.Next(10, 40) * attempt, cancellationToken);
            }
        }
    }
}
