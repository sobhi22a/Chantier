using Chantier.Core.Entities.Materials;
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
public sealed class SyncTouch(ApplicationDbContext db, SyncWindow window) : ISyncTouch
{
    private const int BatchSize = 500;

    /// <summary>Entites touchees, en plus du chantier lui-meme.</summary>
    public static readonly IReadOnlyList<Type> TouchedEntityTypes =
        [typeof(Zone), typeof(SiteMember), typeof(MaterialRequest), typeof(MaterialOrder), typeof(Delivery), typeof(Photo)];

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
        // Entites a nombreuses lignes (zones, demandes...) : on releve d'abord celles qui sont lisibles (READPAST ignore les lignes verrouillees en ecriture par
        // d'autres transactions), puis on touche chacune par sa cle primaire. Un UPDATE filtre par chantier parcourrait les lignes en prenant un verrou sur chacune,
        // y compris la ligne d'une creation en cours : c'est l'attente qu'il faut eviter (interblocage avec sa verification de cle etrangere).
        // Les noms de tables viennent du modele EF (jamais d'une saisie) : une entite d'un chantier de plus = une entree dans TouchedEntityTypes, rien d'autre a ecrire.
        // R2-02 : seules les lignes que le pull enverrait (fenetre de synchronisation) sont touchees ; les demandes closes depuis longtemps, leurs livraisons et leurs
        // photos gardent leur version (des milliers de lignes reecrites a chaque affectation, et retelechargees par tous les autres telephones).
        var cutoff = window.Cutoff;
        foreach (var table in ReadpastTables())
        {
            var select = string.Concat("SELECT Id AS [Value] FROM [", table, "] WITH (READPAST) WHERE SiteId = @siteId AND DeletedAt IS NULL", WindowCondition(table, cutoff is not null));
            var ids = await db.Database.SqlQueryRaw<Guid>(select, SelectParameters(siteId, cutoff)).ToListAsync(cancellationToken);

            foreach (var batch in ids.Chunk(BatchSize))
            {
                var statements = string.Join(' ', batch.Select((_, index) => $"UPDATE [{table}] SET UpdatedAt = UpdatedAt WHERE Id = @p{index};"));
                var parameters = batch.Select((id, index) => (object)new SqlParameter($"@p{index}", id)).ToArray();
                await db.Database.ExecuteSqlRawAsync(statements, parameters, cancellationToken);
            }
        }

        // Affectations : seules les (rares) suppressions concurrentes peuvent les verrouiller, et elles n'attendent rien de nous.
        await db.SiteMembers
            .Where(member => member.SiteId == siteId)
            .ExecuteUpdateAsync(set => set.SetProperty(member => member.UpdatedAt, member => member.UpdatedAt), cancellationToken);
    }

    private static object[] SelectParameters(Guid siteId, DateTimeOffset? cutoff)
        => cutoff is { } limit ? [new SqlParameter("@siteId", siteId), new SqlParameter("@cutoff", limit)] : [new SqlParameter("@siteId", siteId)];

    /// <summary>
    /// Condition SQL « dans la fenetre » d'une table : <b>meme regle que <see cref="SyncWindow"/></b> (un test les compare). Noms de statuts et de tables : constantes du modele,
    /// jamais une saisie ; la limite est un parametre.
    /// </summary>
    private static string WindowCondition(string table, bool active)
    {
        if (!active)
        {
            return string.Empty;
        }

        var closed = string.Join(", ", SyncWindow.ClosedStatuses.Select(status => $"N'{status}'"));
        var requestClosed = $"r.Status IN ({closed}) AND COALESCE(r.UpdatedAt, r.CreatedAt) < @cutoff";
        var deliveryOut = $"(d.Status = N'{DeliveryStatus.Cancelled}' AND COALESCE(d.UpdatedAt, d.CreatedAt) < @cutoff) OR (d.RequestId IS NOT NULL AND EXISTS (SELECT 1 FROM [MaterialRequests] AS r WHERE r.Id = d.RequestId AND {requestClosed}))";

        return table switch
        {
            "MaterialRequests" => $" AND NOT (Status IN ({closed}) AND COALESCE(UpdatedAt, CreatedAt) < @cutoff)",
            "MaterialOrders" => $" AND NOT EXISTS (SELECT 1 FROM [MaterialRequests] AS r WHERE r.Id = [MaterialOrders].RequestId AND {requestClosed})",
            "Deliveries" => $" AND NOT EXISTS (SELECT 1 FROM [Deliveries] AS d WHERE d.Id = [Deliveries].Id AND ({deliveryOut}))",
            "Photos" => $" AND NOT EXISTS (SELECT 1 FROM [Deliveries] AS d WHERE d.Id = [Photos].DeliveryId AND ({deliveryOut}))",
            _ => string.Empty,
        };
    }

    /// <summary>Tables des entites d'un chantier touchees une a une (toutes sauf les affectations, touchees en bloc).</summary>
    private IEnumerable<string> ReadpastTables()
        => TouchedEntityTypes
            .Where(type => type != typeof(SiteMember))
            .Select(type => db.Model.FindEntityType(type)?.GetTableName()
                ?? throw new InvalidOperationException($"L'entité {type.Name} n'est pas mappée : impossible de la toucher."));
}
