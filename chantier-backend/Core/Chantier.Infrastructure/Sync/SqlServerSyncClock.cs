using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Borne haute sure du curseur de synchronisation : <c>MIN_ACTIVE_ROWVERSION()</c> (ADR 0003, ADR 0009).
/// Seul endroit du code qui depend de SQL Server pour la synchronisation. Comportement verifie sur vraie base (RowVersionTests).
/// </summary>
public sealed class SqlServerSyncClock(ApplicationDbContext db) : ISyncClock
{
    public async Task<ulong> SafeUpperBoundAsync(CancellationToken cancellationToken = default)
    {
        // binary(8) converti en entier : meme ordre que la comparaison binaire de la colonne (gros-boutiste).
        var value = await db.Database
            .SqlQuery<long>($"SELECT CAST(MIN_ACTIVE_ROWVERSION() AS bigint) AS [Value]")
            .SingleAsync(cancellationToken);
        return (ulong)value;
    }
}
