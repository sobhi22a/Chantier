using System.Linq.Expressions;
using Chantier.Core.Entities.Common;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Reference;
using Chantier.Core.Entities.Sites;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Chantier.Infrastructure.Persistence;

public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
    : IdentityDbContext<AppUser, AppRole, Guid>(options)
{
    public DbSet<Site> Sites => Set<Site>();

    public DbSet<Zone> Zones => Set<Zone>();

    public DbSet<SiteMember> SiteMembers => Set<SiteMember>();

    public DbSet<SiteCounter> SiteCounters => Set<SiteCounter>();

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    public DbSet<Wilaya> Wilayas => Set<Wilaya>();

    public DbSet<Commune> Communes => Set<Commune>();

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        // Aucun decimal sans precision explicite (ADR 0003) : montants (18,2) et cotes (7,2) sont fixes par entite ;
        // (18,3) est la precision par defaut des quantites.
        configurationBuilder.Properties<decimal>().HavePrecision(18, 3);

        // Enumerations toujours en chaines (contrat d'API), jamais en entiers.
        configurationBuilder.Properties<Enum>().HaveConversion<string>().HaveMaxLength(50);
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        builder.Entity<AppUser>().ToTable("Users");
        builder.Entity<AppRole>().ToTable("Roles");
        builder.Entity<IdentityUserRole<Guid>>().ToTable("UserRoles");
        builder.Entity<IdentityUserClaim<Guid>>().ToTable("UserClaims");
        builder.Entity<IdentityUserLogin<Guid>>().ToTable("UserLogins");
        builder.Entity<IdentityUserToken<Guid>>().ToTable("UserTokens");
        builder.Entity<IdentityRoleClaim<Guid>>().ToTable("RoleClaims");

        ApplySoftDeleteFilter(builder);
    }

    /// <summary>
    /// Filtre de requete <b>nomme</b> (EF Core 10) sur toutes les entites <see cref="BasicEntity"/> : les lignes supprimees
    /// logiquement ne sont jamais lues par megarde. La synchronisation le desactive nommement pour les pierres tombales.
    /// </summary>
    private static void ApplySoftDeleteFilter(ModelBuilder builder)
    {
        foreach (var entityType in builder.Model.GetEntityTypes()
                     .Where(type => type.BaseType is null && typeof(BasicEntity).IsAssignableFrom(type.ClrType)))
        {
            var parameter = Expression.Parameter(entityType.ClrType, "entity");
            var isNotDeleted = Expression.Equal(
                Expression.Property(parameter, nameof(BasicEntity.DeletedAt)),
                Expression.Constant(null, typeof(DateTimeOffset?)));

            entityType.SetQueryFilter(QueryFilterNames.SoftDelete, Expression.Lambda(isNotDeleted, parameter));
        }
    }
}
