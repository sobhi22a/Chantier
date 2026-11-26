using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Time.Testing;

namespace Chantier.IntegrationTests.Support;

/// <summary>
/// Hote de test : configuration surchargee (cle JWT aleatoire, limites de debit relevees), horloge controlee,
/// journaux captures. Une instance = un hote ; les tests sensibles au temps ou aux journaux creent la leur.
/// </summary>
public class ChantierWebApplicationFactory : WebApplicationFactory<Program>
{
    public static string NewJwtKey() => Convert.ToBase64String(System.Security.Cryptography.RandomNumberGenerator.GetBytes(48));

    public FakeTimeProvider Time { get; } = new(DateTimeOffset.UtcNow);

    public CapturingLoggerProvider Logs { get; } = new();

    /// <summary>Reglages ajoutes apres tous les autres (ils l'emportent sur appsettings, user-secrets et variables d'environnement).</summary>
    public Dictionary<string, string?> Settings { get; } = new()
    {
        ["JwtSettings:Key"] = NewJwtKey(),
        ["ConnectionStrings:ChantierDb"] = SqlServerFixture.ConnectionString,
        ["Database:MigrateOnStartup"] = "true",
        ["DataProtection:AllowUnencryptedKeys"] = "true",
        ["Storage:DataProtectionKeys"] = Path.Combine(Path.GetTempPath(), "chantier-tests-keys", Guid.NewGuid().ToString("N")),
        ["Storage:PhotosRoot"] = Path.Combine(Path.GetTempPath(), "chantier-tests-photos", Guid.NewGuid().ToString("N")),
        ["RateLimiting:Global:PermitLimit"] = "100000",
        ["RateLimiting:Auth:PermitLimit"] = "100000",
    };

    public string EnvironmentName { get; set; } = "Development";

    /// <summary>Adresse que le serveur de test voit pour le client (<c>null</c> par defaut avec TestServer) : sert aux tests de proxy inverse.</summary>
    public System.Net.IPAddress? RemoteIpAddress { get; set; }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment(EnvironmentName);

        builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(Settings));

        builder.ConfigureLogging(logging =>
        {
            logging.ClearProviders();
            logging.AddProvider(Logs);
            logging.SetMinimumLevel(LogLevel.Debug);
        });

        builder.ConfigureTestServices(services =>
        {
            services.RemoveAll<TimeProvider>();
            services.AddSingleton<TimeProvider>(Time);
            services.AddControllers().AddApplicationPart(typeof(TestSupportController).Assembly);
            if (RemoteIpAddress is { } address)
            {
                services.AddTransient<IStartupFilter>(_ => new RemoteIpStartupFilter(address));
            }
        });
    }
}

/// <summary>Pose l'adresse distante de la connexion avant tout le reste du pipeline (TestServer n'en fournit pas).</summary>
internal sealed class RemoteIpStartupFilter(System.Net.IPAddress address) : IStartupFilter
{
    public Action<IApplicationBuilder> Configure(Action<IApplicationBuilder> next) => builder =>
    {
        builder.Use((context, nextMiddleware) =>
        {
            context.Connection.RemoteIpAddress = address;
            return nextMiddleware();
        });
        next(builder);
    };
}
