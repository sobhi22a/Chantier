using Chantier.Core.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Services;

/// <summary>Noms et roles pour l'audit et les affectations. Jamais de telephone ni d'identifiant de connexion (H-17).</summary>
public sealed class UserDirectory(ApplicationDbContext db) : IUserDirectory
{
    public async Task<IReadOnlyDictionary<Guid, string>> GetNamesAsync(IEnumerable<Guid> userIds, CancellationToken cancellationToken = default)
    {
        var ids = userIds.Distinct().ToList();
        if (ids.Count == 0)
        {
            return new Dictionary<Guid, string>();
        }

        return await db.Users.AsNoTracking()
            .Where(user => ids.Contains(user.Id))
            .Select(user => new { user.Id, user.FullName })
            .ToDictionaryAsync(user => user.Id, user => user.FullName, cancellationToken);
    }

    public async Task<IReadOnlyDictionary<Guid, (string FullName, string Role)>> GetNamesAndRolesAsync(IEnumerable<Guid> userIds, CancellationToken cancellationToken = default)
    {
        var ids = userIds.Distinct().ToList();
        var result = new Dictionary<Guid, (string FullName, string Role)>();
        if (ids.Count == 0)
        {
            return result;
        }

        var names = await GetNamesAsync(ids, cancellationToken);
        var roles = await db.UserRoles.AsNoTracking()
            .Where(userRole => ids.Contains(userRole.UserId))
            .Join(db.Roles, userRole => userRole.RoleId, role => role.Id, (userRole, role) => new { userRole.UserId, role.Name })
            .ToListAsync(cancellationToken);

        foreach (var (id, name) in names)
        {
            result[id] = (name, roles.FirstOrDefault(role => role.UserId == id)?.Name ?? string.Empty);
        }

        return result;
    }

    public Task<bool?> IsActiveAsync(Guid userId, CancellationToken cancellationToken = default)
        => db.Users.AsNoTracking().Where(user => user.Id == userId).Select(user => (bool?)user.IsActive).FirstOrDefaultAsync(cancellationToken);
}
