using Chantier.Infrastructure.Persistence;
using Chantier.WebApi.Extensions;
using Chantier.WebApi.OpenApi;
using Chantier.WebApi.Options;

var builder = WebApplication.CreateBuilder(args);

if (OpenApiGeneration.IsRunning)
{
    builder.Configuration.AddInMemoryCollection(OpenApiGeneration.Settings());
}

// Ne pas annoncer l'implementation du serveur.
builder.WebHost.ConfigureKestrel(options =>
{
    options.AddServerHeader = false;

    // Corps limite a 64 Ko par defaut (R1-08) : un anonyme ne peut pas faire lire de gros corps. Les routes qui en ont besoin le relevent
    // avec [RequestSizeLimit] (push de synchronisation : 1 Mo ; photos plus tard).
    options.Limits.MaxRequestBodySize = RequestLimits.DefaultMaxBodyBytes;
});

// Secrets : user-secrets en developpement, variables d'environnement ailleurs (JwtSettings__Key,
// ConnectionStrings__ChantierDb...). Rien de sensible dans appsettings*.json.
builder.Services.AddWebApi(builder.Configuration);

var app = builder.Build();

// Migration (si Database:MigrateOnStartup) puis amorcage idempotent : roles, permissions, premier Admin, referentiel.
// Pas pendant la generation du document OpenAPI au build (outil GetDocument.Insider) : ni base, ni secret necessaires (ADR 0006).
if (!OpenApiGeneration.IsRunning)
{
    await DatabaseInitializer.InitializeAsync(app.Services);
}

app.UseWebApiPipeline();

app.Run();

/// <summary>Point d'entree visible des tests d'integration (<c>WebApplicationFactory&lt;Program&gt;</c>).</summary>
public partial class Program;
