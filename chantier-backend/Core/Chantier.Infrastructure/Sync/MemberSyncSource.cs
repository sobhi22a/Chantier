using Chantier.Core.Entities.Sites;
using Chantier.Core.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Sync;

/// <summary>
/// Affectations des chantiers visibles (nom et role, jamais de telephone). Un retrait <b>de l'utilisateur lui-meme</b> produit en plus
/// <c>deleted</c> de <c>site</c> : le chantier n'est plus visible, le client le supprime avec ses enfants (CT-4). Cette pierre tombale
/// est omise si l'utilisateur a ete reaffecte depuis (le chantier lui est alors renvoye, par le « toucher » de l'affectation).
/// </summary>
public sealed class MemberSyncSource(ApplicationDbContext db, IUserDirectory directory) : ISyncSource
{
    public async Task<IReadOnlyList<SyncChangeRow>> ReadAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken = default)
    {
        var rows = new List<SyncChangeRow>();
        rows.AddRange(await ReadVisibleMembersAsync(scope, since, upper, take, cancellationToken));

        if (scope is { SiteFilter: null, VisibleSiteIds: { } visible })
        {
            rows.AddRange(await ReadOwnRemovalsAsync(scope.UserId, visible, since, upper, take, cancellationToken));
        }

        return rows.OrderBy(row => row.Version).Take(take).ToList();
    }

    private async Task<List<SyncChangeRow>> ReadVisibleMembersAsync(SyncScope scope, ulong since, ulong upper, int take, CancellationToken cancellationToken)
    {
        var query = db.SiteMembers.AsNoTracking()
            .IgnoreQueryFilters([QueryFilterNames.SoftDelete])
            .Where(member => member.RowVersion > since && member.RowVersion < upper);

        if (scope.VisibleSiteIds is { } visible)
        {
            query = query.Where(member => visible.Contains(member.SiteId));
        }

        var members = await query.OrderBy(member => member.RowVersion).Take(take).ToListAsync(cancellationToken);
        var people = await directory.GetNamesAndRolesAsync(members.Select(member => member.UserId), cancellationToken);

        return members.Select(member => new SyncChangeRow(
            SyncEntities.Member,
            member.Id,
            member.SiteId,
            member.RowVersion,
            member.IsDeleted ? null : ToData(member, people))).ToList();
    }

    private async Task<List<SyncChangeRow>> ReadOwnRemovalsAsync(Guid userId, IReadOnlyList<Guid> visible, ulong since, ulong upper, int take, CancellationToken cancellationToken)
    {
        var removed = await db.SiteMembers.AsNoTracking()
            .IgnoreQueryFilters([QueryFilterNames.SoftDelete])
            .Where(member => member.UserId == userId
                && member.DeletedAt != null
                && member.RowVersion > since && member.RowVersion < upper
                && !visible.Contains(member.SiteId))
            .OrderBy(member => member.RowVersion)
            .Take(take)
            .ToListAsync(cancellationToken);

        return removed
            .Select(member => new SyncChangeRow(SyncEntities.Site, member.SiteId, member.SiteId, member.RowVersion, null))
            .ToList();
    }

    private static SyncMemberData ToData(SiteMember member, IReadOnlyDictionary<Guid, (string FullName, string Role)> people)
    {
        var (fullName, role) = people.TryGetValue(member.UserId, out var person) ? person : (string.Empty, string.Empty);
        return new SyncMemberData(member.Id, member.SiteId, member.UserId, fullName, role, member.CreatedAt);
    }
}
