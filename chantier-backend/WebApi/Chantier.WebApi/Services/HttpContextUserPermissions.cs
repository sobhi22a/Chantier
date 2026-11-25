using Chantier.Core.Abstractions;
using Chantier.Core.Identity;

namespace Chantier.WebApi.Services;

/// <summary>Permissions de l'utilisateur de la requete : celles de son role (cache de 5 minutes), resolues une fois par requete.</summary>
public sealed class HttpContextUserPermissions(ICurrentUser currentUser, IPermissionService permissions) : IUserPermissions
{
    private IReadOnlySet<string>? _resolved;

    public async Task<IReadOnlySet<string>> GetAsync(CancellationToken cancellationToken = default)
        => _resolved ??= currentUser.Role is { } role
            ? await permissions.GetForRoleAsync(role, cancellationToken)
            : new HashSet<string>();

    public async Task<bool> HasAsync(string permission, CancellationToken cancellationToken = default)
        => (await GetAsync(cancellationToken)).Contains(permission);
}
