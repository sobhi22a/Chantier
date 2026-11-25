using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace Chantier.Infrastructure.Persistence;

/// <summary>
/// Utilise par <c>dotnet ef</c> uniquement. Lit la chaine de connexion comme l'application, sans demarrer l'API :
/// user-secrets (identifiant partage avec le projet WebApi) puis variable d'environnement <c>ConnectionStrings__ChantierDb</c>.
/// Aucun secret dans un fichier versionne (ADR 0003).
/// </summary>
public sealed class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public const string UserSecretsId = "chantier-webapi";

    public ApplicationDbContext CreateDbContext(string[] args)
    {
        var configuration = new ConfigurationBuilder()
            .AddUserSecrets(UserSecretsId, reloadOnChange: false)
            .AddEnvironmentVariables()
            .Build();

        var connectionString = configuration.GetConnectionString("ChantierDb");
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "ConnectionStrings:ChantierDb est absente. Renseignez-la avec user-secrets (projet WebApi) "
                + "ou la variable d'environnement ConnectionStrings__ChantierDb.");
        }

        var builder = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseSqlServer(connectionString, sql => sql.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.GetName().Name));

        return new ApplicationDbContext(builder.Options);
    }
}
