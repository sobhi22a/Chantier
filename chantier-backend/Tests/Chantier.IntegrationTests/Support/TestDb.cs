using Chantier.Core.Abstractions;
using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Chantier.IntegrationTests.Support;

/// <summary>Acces direct a la base de test (sans hote HTTP) avec l'intercepteur d'audit, pour les tests de persistance.</summary>
public static class TestDb
{
    public sealed class FixedUser(Guid? id) : ICurrentUser
    {
        public Guid? Id => id;

        public string? Role => null;

        public bool IsAuthenticated => id is not null;
    }

    public static ApplicationDbContext Create(Guid? userId = null, TimeProvider? time = null)
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseSqlServer(
                SqlServerFixture.ConnectionString,
                sql => sql.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.GetName().Name).CommandTimeout(15))
            .AddInterceptors(new AuditingInterceptor(new FixedUser(userId), time ?? TimeProvider.System))
            .Options;
        return new ApplicationDbContext(options);
    }

    public static async Task EnsureMigratedAsync()
    {
        await using var db = Create();
        await db.Database.MigrateAsync();
    }

    public static string UniqueCode(string prefix = "T") => $"{prefix}-{Guid.NewGuid().ToString("N")[..12].ToUpperInvariant()}";

    public static SiteInput SiteInput(string name = "Chantier de test", SiteType type = SiteType.School) => new(
        name, null, type, "Blida", "Boufarik", null, null, "Maître d'ouvrage fictif", null, null, null, null);

    public static Site NewSite(string? code = null, SiteInput? input = null)
        => Site.Create(code ?? UniqueCode(), input ?? SiteInput());

    public static ZoneInput ZoneInput(string block = "Bloc 01", decimal? elevation = null, RoomType? roomType = null, int? roomNumber = null, string? roomLabel = null)
        => new(block, elevation, roomType, roomNumber, roomLabel);

    public static Zone NewZone(Guid siteId, ZoneInput? input = null, Guid? clientId = null)
        => Zone.Create(siteId, new CreateZoneDto(clientId, null, input ?? ZoneInput()), new Chantier.Core.Sites.ZoneOptions());

    public static async Task<AppUser> AddUserAsync(ApplicationDbContext db)
    {
        var user = AppUser.Create("u" + Guid.NewGuid().ToString("N")[..10], "Utilisateur Fictif");
        user.NormalizedUserName = user.UserName!.ToUpperInvariant();
        db.Users.Add(user);
        await db.SaveChangesAsync();
        return user;
    }
}
