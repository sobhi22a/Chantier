using System.Globalization;
using Chantier.Core.Abstractions;
using Chantier.Core.Exceptions;
using Chantier.Core.Identity;
using Chantier.Core.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Pull (ADR 0009). Le curseur est une <b>version serveur</b> (rowversion), jamais l'horloge du telephone.
/// On ne renvoie que les lignes de version strictement inferieure a <c>MIN_ACTIVE_ROWVERSION()</c> : une transaction encore ouverte
/// ne peut donc jamais produire une ligne « derriere » le curseur, et aucun changement n'est perdu.
/// </summary>
public sealed class SyncPullService(
    IEnumerable<ISyncSource> sources,
    ISyncClock clock,
    ICurrentUser currentUser,
    IUserPermissions permissions,
    ISiteAccess siteAccess,
    ApplicationDbContext db,
    SyncWindow window) : ISyncPullService
{
    public async Task<SyncPullResponse> PullAsync(string? since, Guid? siteId, int limit, CancellationToken cancellationToken = default)
    {
        if (limit is < 1 or > SyncLimits.MaxPullLimit)
        {
            throw new Core.Exceptions.ValidationException("limit", $"La taille de page doit être comprise entre 1 et {SyncLimits.MaxPullLimit}.");
        }

        var cursor = ParseCursor(since);
        var userId = currentUser.Id ?? throw new NotFoundException();

        if (siteId is { } requested)
        {
            // Chantier non affecte ou inexistant : meme 404 que partout ailleurs.
            await siteAccess.EnsureAsync(requested, cancellationToken);
        }

        var granted = await permissions.GetAsync(cancellationToken);
        var scope = new SyncScope(userId, await VisibleSitesAsync(userId, siteId, granted, cancellationToken), siteId, granted);

        var upper = await clock.SafeUpperBoundAsync(cancellationToken);

        // Une ligne de plus que la page : sa presence dit s'il y a une suite.
        var rows = new List<SyncChangeRow>();
        foreach (var source in sources)
        {
            rows.AddRange(await source.ReadAsync(scope, cursor, upper, limit + 1, cancellationToken));
        }

        var ordered = rows.OrderBy(row => row.Version).ToList();
        var hasMore = ordered.Count > limit;
        var page = hasMore ? ordered.Take(limit).ToList() : ordered;

        // Sans reste, plus aucune transaction ouverte ne peut produire de version inferieure a la borne : on avance jusqu'a elle.
        var next = hasMore ? page[^1].Version : Math.Max(cursor, upper - 1);

        // Dans la page seulement : parents avant enfants (le curseur, lui, reste la version de la derniere ligne par version).
        page = page.OrderBy(row => ParentRank(row.Entity)).ThenBy(row => row.Version).ToList();

        return new SyncPullResponse(
            page.Where(row => !row.IsTombstone)
                .Select(row => new SyncChange(row.Entity, row.Id, row.SiteId, Format(row.Version), row.Data!))
                .ToList(),
            page.Where(row => row.IsTombstone)
                .Select(row => new SyncDeletion(row.Entity, row.Id, row.SiteId, Format(row.Version)))
                .ToList(),
            Format(next),
            hasMore,
            ResetRequired: cursor > 0 && await window.HasHiddenChangesAsync(scope, cursor, upper, cancellationToken));
    }

    /// <summary>
    /// Rang d'une entite dans une page : une ligne ne depend que d'entites de rang inferieur (chantier, produit et fournisseur, puis zone et affectation,
    /// demande, livraison, photo). Une entite inconnue passe en dernier.
    /// </summary>
    private static int ParentRank(string entity) => entity switch
    {
        SyncEntities.Site or SyncEntities.Product or SyncEntities.Supplier => 0,
        SyncEntities.Zone or SyncEntities.Member => 1,
        SyncEntities.Request => 2,
        SyncEntities.Delivery => 3,
        SyncEntities.Photo => 4,
        _ => 5,
    };

    /// <summary>Chantiers lus : celui demande, sinon tous les affectes ; <c>null</c> = tous (Admin).</summary>
    private async Task<IReadOnlyList<Guid>?> VisibleSitesAsync(Guid userId, Guid? siteId, IReadOnlySet<string> granted, CancellationToken cancellationToken)
    {
        if (siteId is { } only)
        {
            return [only];
        }

        if (granted.Contains(Permissions.AllSitesView))
        {
            return null;
        }

        // Affectations actives seulement (le filtre SoftDelete est actif ici).
        return await db.SiteMembers.AsNoTracking()
            .Where(member => member.UserId == userId)
            .Select(member => member.SiteId)
            .ToListAsync(cancellationToken);
    }

    private static ulong ParseCursor(string? since)
    {
        if (string.IsNullOrWhiteSpace(since))
        {
            return 0;
        }

        if (ulong.TryParse(since, NumberStyles.None, CultureInfo.InvariantCulture, out var cursor))
        {
            return cursor;
        }

        throw new Core.Exceptions.ValidationException("since", "Le curseur est illisible.", ErrorCodes.CurseurInvalide);
    }

    private static string Format(ulong version) => version.ToString(CultureInfo.InvariantCulture);
}
