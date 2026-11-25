using Ardalis.Specification;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Identity;
using Chantier.Core.Sites;
using Chantier.Core.Sync;
using Chantier.Infrastructure.Persistence;
using Chantier.Infrastructure.Repositories;
using Chantier.Infrastructure.SeedData.Demo;
using Chantier.Infrastructure.Services;
using Chantier.Infrastructure.Services.Sites;
using Chantier.Infrastructure.Sync;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Chantier.Infrastructure;

public static class DependencyInjection
{
    public const string ConnectionStringName = "ChantierDb";

    /// <summary>
    /// Base, identites, depots et services. La configuration est lue tardivement (au premier usage) pour que les tests
    /// puissent la surcharger. Services transitoires, depots scoped, comme Kardinal (ADR 0001).
    /// </summary>
    public static IServiceCollection AddInfrastructure(this IServiceCollection services)
    {
        services.AddScoped<AuditingInterceptor>();
        services.AddDbContext<ApplicationDbContext>((provider, options) =>
        {
            var connectionString = provider.GetRequiredService<IConfiguration>().GetConnectionString(ConnectionStringName);
            if (string.IsNullOrWhiteSpace(connectionString))
            {
                throw new InvalidOperationException(
                    $"ConnectionStrings:{ConnectionStringName} est absente. Renseignez-la avec user-secrets (développement) "
                    + $"ou la variable d'environnement ConnectionStrings__{ConnectionStringName}.");
            }

            options.UseSqlServer(connectionString, sql => sql.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.GetName().Name));
            options.AddInterceptors(provider.GetRequiredService<AuditingInterceptor>());
        });

        services.AddScoped(typeof(IRepositoryBase<>), typeof(RepositoryCommon<>));

        services.AddIdentity<AppUser, AppRole>(options =>
            {
                options.User.RequireUniqueEmail = false;

                // Politique de mot de passe : 8 caracteres minimum dont un chiffre (ADR 0005).
                options.Password.RequiredLength = 8;
                options.Password.RequireDigit = true;
                options.Password.RequireUppercase = false;
                options.Password.RequireLowercase = false;
                options.Password.RequireNonAlphanumeric = false;

                // Le verrouillage d'Identity ne protege que les comptes existants et revele leur existence :
                // remplace par le suivi des tentatives par identifiant (ADR 0005).
                options.Lockout.AllowedForNewUsers = false;
            })
            .AddEntityFrameworkStores<ApplicationDbContext>();

        services.AddOptions<AuthSettings>().BindConfiguration(AuthSettings.SectionName);
        services.AddSingleton<ILoginAttemptTracker, LoginAttemptTracker>();
        services.AddSingleton<IPermissionService, PermissionService>();
        services.AddSingleton<IUserStatusProvider, UserStatusProvider>();
        services.AddTransient<IAuthService, AuthService>();

        services.AddMemoryCache();
        services.AddOptions<ZoneOptions>().BindConfiguration(ZoneOptions.SectionName);
        services.AddTransient<IUserDirectory, UserDirectory>();
        services.AddTransient<ISiteAccess, SiteAccess>();
        services.AddTransient<ISiteService, SiteService>();
        services.AddTransient<IZoneService, ZoneService>();
        services.AddTransient<ISiteMemberService, SiteMemberService>();
        services.AddTransient<IReferenceService, ReferenceService>();
        services.AddTransient<ISiteNumbering, SiteNumbering>();

        // Synchronisation hors ligne (ADR 0009) : une source par entite lue, un handler par entite ecrite.
        services.AddTransient<ISyncClock, SqlServerSyncClock>();
        services.AddTransient<ISyncTouch, SyncTouch>();
        services.AddTransient<ISyncSource, SiteSyncSource>();
        services.AddTransient<ISyncSource, ZoneSyncSource>();
        services.AddTransient<ISyncSource, MemberSyncSource>();
        services.AddTransient<ISyncPushHandler, ZoneSyncPushHandler>();
        services.AddTransient<ISyncPullService, SyncPullService>();
        services.AddTransient<ISyncPushService, SyncPushService>();

        services.AddScoped<IdentityDbInitializer>();
        services.AddScoped<ReferenceDataSeeder>();
        services.AddScoped<DemoDataSeeder>();
        services.AddScoped<DatabaseHealthCheck>();

        return services;
    }
}
