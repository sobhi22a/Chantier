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

    /// <summary>
    /// S-1 : sans <c>READ_COMMITTED_SNAPSHOT</c> (migration <c>EnableReadCommittedSnapshot</c>), les lectures attendent les ecritures et deux commandes simultanees peuvent s'interbloquer (R2-01).
    /// Un avertissement au demarrage suffit : l'application fonctionne (les interblocages sont rejoues), mais l'exploitation doit appliquer la migration.
    /// </summary>
    public static async Task WarnIfRowVersioningIsOffAsync(IServiceProvider provider, CancellationToken cancellationToken = default)
    {
        try
        {
            var db = provider.GetRequiredService<ApplicationDbContext>();
            var enabled = await db.Database
                .SqlQueryRaw<bool>("SELECT is_read_committed_snapshot_on AS [Value] FROM sys.databases WHERE name = DB_NAME()")
                .SingleOrDefaultAsync(cancellationToken);
            if (!enabled)
            {
                provider.GetRequiredService<ILoggerFactory>().CreateLogger(typeof(DatabaseInitializer)).LogWarning(
                    "READ_COMMITTED_SNAPSHOT est inactif sur la base : appliquer les migrations (EnableReadCommittedSnapshot), sinon les commandes simultanées peuvent s'interbloquer.");
            }
        }
        catch (Exception exception) when (exception is not OperationCanceledException)
        {
            // Un controle d'information ne doit jamais empecher le demarrage (droit de lecture de sys.databases, base absente a la generation OpenAPI...).
            provider.GetRequiredService<ILoggerFactory>().CreateLogger(typeof(DatabaseInitializer))
                .LogDebug("Contrôle READ_COMMITTED_SNAPSHOT impossible {ExceptionType}", exception.GetType().Name);
        }
    }

    public static async Task InitializeAsync(IServiceProvider services, CancellationToken cancellationToken = default)
    {
        await using var scope = services.CreateAsyncScope();
        var provider = scope.ServiceProvider;
        var configuration = provider.GetRequiredService<IConfiguration>();

        if (configuration.GetValue<bool>(MigrateOnStartup))
        {
            await provider.GetRequiredService<ApplicationDbContext>().Database.MigrateAsync(cancellationToken);
        }

        await WarnIfRowVersioningIsOffAsync(provider, cancellationToken);

        await provider.GetRequiredService<IdentityDbInitializer>().InitializeAsync();
        await provider.GetRequiredService<ReferenceDataSeeder>().SeedAsync(cancellationToken: cancellationToken);

        if (configuration.GetValue<bool>(DemoDataSeeder.EnabledKey))
        {
            var environment = provider.GetRequiredService<IHostEnvironment>();
            if (DemoDataSeeder.IsEnabled(configuration, environment))
            {
                await provider.GetRequiredService<DemoDataSeeder>().SeedAsync(cancellationToken);
                await provider.GetRequiredService<MaterialsDemoSeeder>().SeedAsync(cancellationToken);
            }
            else
            {
                provider.GetRequiredService<ILoggerFactory>().CreateLogger(typeof(DatabaseInitializer))
                    .LogWarning("{Key} est ignoré : les données de démonstration n'existent qu'en développement.", DemoDataSeeder.EnabledKey);
            }
        }
    }
}
