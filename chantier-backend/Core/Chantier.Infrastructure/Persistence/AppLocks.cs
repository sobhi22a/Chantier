using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Persistence;

/// <summary>
/// Verrou applicatif (<c>sp_getapplock</c>) lie a la transaction en cours : met en file les ecrivains d'une meme ressource (une demande, une livraison) avant qu'ils
/// ne touchent a ses lignes. Sans lui, deux ecritures simultanees prennent leurs verrous de lignes dans un ordre different (l'evenement d'historique avant la demande,
/// ou la relecture de l'historique apres l'ecriture) et se bloquent mutuellement : interblocage SQL 1205, mesure sur vraie base. Le verrou tombe avec la transaction.
/// </summary>
public static class AppLocks
{
    private const int TimeoutMilliseconds = 15000;

    /// <summary>Exige une transaction ouverte (<see cref="DbTransactions"/>) : sinon le verrou serait relache aussitot.</summary>
    public static async Task AcquireAsync(ApplicationDbContext db, string resource, CancellationToken cancellationToken = default)
    {
        if (db.Database.CurrentTransaction is null)
        {
            throw new InvalidOperationException("Un verrou applicatif exige la transaction de l'appelant.");
        }

        var status = (await db.Database
            .SqlQuery<int>($"DECLARE @status int; EXEC @status = sp_getapplock @Resource = {resource}, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = {TimeoutMilliseconds}; SELECT @status AS [Value]")
            .ToListAsync(cancellationToken)).Single();

        // 0 et 1 : accorde ; negatif : delai depasse, interblocage ou erreur.
        if (status < 0)
        {
            throw new InvalidOperationException("La ressource est occupée : réessayer.");
        }
    }
}
