using Chantier.Infrastructure.SeedData.Demo;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Chantier.Infrastructure.Persistence;

/// <summary>
/// Demarrage de la base : migration automatique si <c>Database:MigrateOnStartup = true</c> (developpement et tests ;
/// ailleurs, script idempotent applique par le deploiement), puis amorcage idempotent des roles, permissions,
/// premier Admin et referentiel geographique. Les donnees de demonstration s'y ajoutent <b>seulement</b> si <c>Seed:Demo = true</c>
/// en environnement Development (jamais ailleurs).
/// </summary>
public static class DatabaseInitializer
{
    public const string MigrateOnStartup = "Database:MigrateOnStartup";

    public static async Task InitializeAsync(IServiceProvider services, CancellationToken cancellationToken = default)
    {
        await using var scope = services.CreateAsyncScope();
        var provider = scope.ServiceProvider;
        var configuration = provider.GetRequiredService<IConfiguration>();

        if (configuration.GetValue<bool>(MigrateOnStartup))
        {
            await provider.GetRequiredService<ApplicationDbContext>().Database.MigrateAsync(cancellationToken);
        }

        await provider.GetRequiredService<IdentityDbInitializer>().InitializeAsync();
        await provider.GetRequiredService<ReferenceDataSeeder>().SeedAsync(cancellationToken: cancellationToken);

        if (configuration.GetValue<bool>(DemoDataSeeder.EnabledKey))
        {
            var environment = provider.GetRequiredService<IHostEnvironment>();
            if (DemoDataSeeder.IsEnabled(configuration, environment))
            {
                await provider.GetRequiredService<DemoDataSeeder>().SeedAsync(cancellationToken);
            }
            else
            {
                provider.GetRequiredService<ILoggerFactory>().CreateLogger(typeof(DatabaseInitializer))
                    .LogWarning("{Key} est ignoré : les données de démonstration n'existent qu'en développement.", DemoDataSeeder.EnabledKey);
            }
        }
    }
}
