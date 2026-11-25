using System.Collections.Concurrent;
using Chantier.Core.Identity;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Services;

/// <summary>Etat actif / changement de mot de passe d'un compte, mis en cache au plus 60 secondes (CT-19).</summary>
public sealed class UserStatusProvider(IServiceScopeFactory scopes, IOptions<AuthSettings> options, TimeProvider time) : IUserStatusProvider
{
    private readonly ConcurrentDictionary<Guid, (UserStatus? Status, DateTimeOffset ExpiresAt)> _cache = new();

    public async Task<UserStatus?> GetAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var now = time.GetUtcNow();
        if (_cache.TryGetValue(userId, out var cached) && cached.ExpiresAt > now)
        {
            return cached.Status;
        }

        await using var scope = scopes.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var status = await db.Users
            .AsNoTracking()
            .Where(user => user.Id == userId)
            .Select(user => new UserStatus(user.IsActive, user.MustChangePassword, user.SecurityStamp))
            .FirstOrDefaultAsync(cancellationToken);

        _cache[userId] = (status, now.AddSeconds(Math.Max(0, options.Value.UserStatusCacheSeconds)));
        return status;
    }

    public void Invalidate(Guid userId) => _cache.TryRemove(userId, out _);
}
