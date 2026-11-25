using System.Collections.Concurrent;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Services;

/// <summary>Permissions par role lues dans les claims de role en base, avec un cache memoire (5 minutes par defaut).</summary>
public sealed class PermissionService(IServiceScopeFactory scopes, IOptions<AuthSettings> options, TimeProvider time) : IPermissionService
{
    private readonly ConcurrentDictionary<string, (IReadOnlySet<string> Permissions, DateTimeOffset ExpiresAt)> _cache = new(StringComparer.Ordinal);

    public async Task<IReadOnlySet<string>> GetForRoleAsync(string role, CancellationToken cancellationToken = default)
    {
        var now = time.GetUtcNow();
        if (_cache.TryGetValue(role, out var cached) && cached.ExpiresAt > now)
        {
            return cached.Permissions;
        }

        await using var scope = scopes.CreateAsyncScope();
        var roles = scope.ServiceProvider.GetRequiredService<RoleManager<AppRole>>();
        var entity = await roles.FindByNameAsync(role);
        IReadOnlySet<string> permissions = entity is null
            ? new HashSet<string>()
            : (await roles.GetClaimsAsync(entity))
                .Where(claim => claim.Type == Permissions.ClaimType)
                .Select(claim => claim.Value)
                .ToHashSet(StringComparer.Ordinal);

        _cache[role] = (permissions, now.AddMinutes(Math.Max(0, options.Value.PermissionCacheMinutes)));
        return permissions;
    }

    public void Invalidate() => _cache.Clear();
}
