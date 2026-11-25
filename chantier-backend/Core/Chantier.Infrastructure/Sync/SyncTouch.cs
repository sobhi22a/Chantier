using Chantier.Core.Entities.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// « Toucher » un chantier : <c>UPDATE ... SET UpdatedAt = UpdatedAt</c> ne change aucune valeur mais fait avancer le
/// <c>rowversion</c>, donc les lignes anciennes d'un chantier sont renvoyees a un utilisateur nouvellement affecte (ADR 0009).
/// Contourne l'audit exprès : ce n'est pas une modification de l'utilisateur.
/// <b>Toute entite d'un chantier doit etre ajoutee ici</b> (un test d'architecture verifie que chaque entite <c>ISiteScoped</c> y figure).
/// </summary>
public sealed class SyncTouch(ApplicationDbContext db) : ISyncTouch
{
    private const int BatchSize = 500;

    /// <summary>Entites touchees, en plus du chantier lui-meme.</summary>
    public static readonly IReadOnlyList<Type> TouchedEntityTypes = [typeof(Zone), typeof(SiteMember)];

    /// <summary>
    /// Verrou <b>applicatif</b> (<c>sp_getapplock</c>, lie a la transaction) pour mettre les affectations d'un meme chantier en file, puis ligne du chantier
    /// touchee (verrou d'ecriture). Un simple <c>UPDLOCK</c> sur la ligne ne suffit pas : en attente, il fait patienter derriere lui les lectures « cle etrangere »
    /// des creations de zones, ce qui a produit des interblocages a trois.
    /// </summary>
    public async Task LockSiteAsync(Guid siteId, CancellationToken cancellationToken = default)
    {
        var resource = $"site-assign:{siteId}";
        var status = await db.Database
            .SqlQuery<int>($"DECLARE @status int; EXEC @status = sp_getapplock @Resource = {resource}, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 15000; SELECT @status AS [Value]")
            .ToListAsync(cancellationToken);

        // 0 et 1 : accorde ; negatif : delai depasse, interblocage ou erreur.
        if (status.Single() < 0)
        {
            throw new InvalidOperationException("Le verrou d'affectation du chantier n'a pas pu être obtenu.");
        }

        await db.Sites
            .Where(site => site.Id == siteId)
            .ExecuteUpdateAsync(set => set.SetProperty(site => site.UpdatedAt, site => site.UpdatedAt), cancellationToken);
    }

    public async Task TouchLinesAsync(Guid siteId, CancellationToken cancellationToken = default)
    {
        // Zones : on releve d'abord celles qui sont lisibles (READPAST ignore les lignes verrouillees en ecriture par d'autres transactions),
        // puis on touche chacune par sa cle primaire. Un UPDATE filtre par chantier parcourrait les zones en prenant un verrou sur chaque ligne
        // visitee, y compris la ligne d'une creation en cours : c'est l'attente qu'il faut eviter (interblocage avec sa verification de cle etrangere).
        var zoneIds = await db.Database
            .SqlQuery<Guid>($"SELECT Id AS [Value] FROM Zones WITH (READPAST) WHERE SiteId = {siteId} AND DeletedAt IS NULL")
            .ToListAsync(cancellationToken);

        foreach (var batch in zoneIds.Chunk(BatchSize))
        {
            var statements = string.Join(' ', batch.Select((_, index) => $"UPDATE Zones SET UpdatedAt = UpdatedAt WHERE Id = @p{index};"));
            var parameters = batch.Select((id, index) => (object)new SqlParameter($"@p{index}", id)).ToArray();
            await db.Database.ExecuteSqlRawAsync(statements, parameters, cancellationToken);
        }

        // Affectations : seules les (rares) suppressions concurrentes peuvent les verrouiller, et elles n'attendent rien de nous.
        await db.SiteMembers
            .Where(member => member.SiteId == siteId)
            .ExecuteUpdateAsync(set => set.SetProperty(member => member.UpdatedAt, member => member.UpdatedAt), cancellationToken);
    }
}
