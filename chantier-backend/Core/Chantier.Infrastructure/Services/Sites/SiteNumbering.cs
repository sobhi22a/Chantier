using Chantier.Core.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services.Sites;

/// <summary>
/// Incrementation atomique du compteur d'un chantier : <c>UPDATE ... SET LastValue = LastValue + 1 OUTPUT inserted.LastValue</c> dans la
/// transaction de l'appelant. Le verrou d'ecriture reste pris jusqu'a la fin de la transaction : les creations d'un meme chantier se
/// mettent en file, et une annulation ne consomme aucun numero.
/// <para>
/// Les cinq compteurs (DEM, LIV, T, PB, SIT, valeur 0) sont crees <b>avec le chantier</b> (<c>Site.Create</c>) et, pour les chantiers
/// existants, par la migration <c>BackfillSiteCounters</c> : le chemin normal ne cree donc jamais de ligne (defaut D-6 de la QA).
/// </para>
/// <para>
/// Repli pour un chantier sans compteur (insertion manuelle, import) : la ligne est creee <b>dans la transaction de l'appelant</b>, sous un
/// verrou applicatif lie a la transaction qui met les createurs en file. Pas de seconde connexion : sa cle etrangere vers le chantier attendait
/// la transaction de l'appelant quand celle-ci avait ecrit la ligne du chantier (D-6). Pas de verrou de plage (<c>HOLDLOCK</c>) : il
/// s'interbloquait avec les transactions annulees (SQL 1205, D-1). Une annulation retire la ligne avec le reste : aucun numero consomme.
/// </para>
/// </summary>
public sealed class SiteNumbering(ApplicationDbContext db) : ISiteNumbering
{
    private const int LockTimeoutMilliseconds = 15000;

    public async Task<string> NextAsync(Guid siteId, string prefix, CancellationToken cancellationToken = default)
    {
        if (!NumberPrefixes.IsKnown(prefix))
        {
            throw new ArgumentException("Préfixe de numérotation inconnu.", nameof(prefix));
        }

        if (db.Database.CurrentTransaction is null)
        {
            throw new InvalidOperationException(
                "La numérotation doit être appelée dans la transaction qui écrit l'entité : sinon un numéro serait consommé même si l'écriture échoue.");
        }

        var value = await IncrementAsync(siteId, prefix, cancellationToken);
        if (value is null)
        {
            await EnsureCounterAsync(siteId, prefix, cancellationToken);
            value = await IncrementAsync(siteId, prefix, cancellationToken)
                ?? throw new InvalidOperationException("Le compteur de numérotation du chantier est introuvable.");
        }

        return SiteNumber.Format(prefix, value.Value);
    }

    private async Task<int?> IncrementAsync(Guid siteId, string prefix, CancellationToken cancellationToken)
    {
        // OUTPUT : la valeur lue est celle de cette transaction, sans second aller-retour ni lecture « sale ».
        var values = await db.Database
            .SqlQuery<int>($"UPDATE SiteCounters SET LastValue = LastValue + 1 OUTPUT inserted.LastValue AS [Value] WHERE SiteId = {siteId} AND Prefix = {prefix}")
            .ToListAsync(cancellationToken);
        return values.Count == 0 ? null : values[0];
    }

    private async Task EnsureCounterAsync(Guid siteId, string prefix, CancellationToken cancellationToken)
    {
        // Verrou applicatif lie a la transaction : un seul createur a la fois par (chantier, prefixe) ; les autres reprennent apres lui et
        // trouvent la ligne (validee) ou la recreent (annulee). Le verrou tombe avec la transaction.
        var resource = $"site-counter:{siteId:N}:{prefix}";
        var status = (await db.Database
            .SqlQuery<int>($"DECLARE @status int; EXEC @status = sp_getapplock @Resource = {resource}, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = {LockTimeoutMilliseconds}; SELECT @status AS [Value]")
            .ToListAsync(cancellationToken)).Single();
        if (status < 0)
        {
            throw new InvalidOperationException("Le compteur de numérotation du chantier est occupé : réessayer.");
        }

        await db.Database.ExecuteSqlAsync(
            $"INSERT INTO SiteCounters (SiteId, Prefix, LastValue) SELECT {siteId}, {prefix}, 0 WHERE NOT EXISTS (SELECT 1 FROM SiteCounters WHERE SiteId = {siteId} AND Prefix = {prefix})",
            cancellationToken);
    }
}
