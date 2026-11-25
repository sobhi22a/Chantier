using System.Net;
using System.Threading.RateLimiting;
using Chantier.Core.Abstractions;
using Chantier.Core.Identity;
using Chantier.Infrastructure;
using Chantier.Infrastructure.Persistence;
using Chantier.WebApi.Errors;
using Chantier.WebApi.Json;
using Chantier.WebApi.OpenApi;
using Chantier.WebApi.Options;
using Chantier.WebApi.Services;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding.Metadata;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Options;

namespace Chantier.WebApi.Extensions;

public static class ServiceCollectionExtensions
{
    public const string CorsPolicyName = "BackOffice";

    /// <summary>
    /// Enregistre tout ce qui releve de la couche WebApi. La configuration est lue <b>tardivement</b> (options),
    /// jamais dans Program.cs : les tests peuvent ainsi la surcharger. Seule exception : le certificat qui chiffre les cles de protection des donnees,
    /// necessaire a l'enregistrement du service (fichiers et variables d'environnement, deja charges).
    /// </summary>
    public static IServiceCollection AddWebApi(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddHttpContextAccessor();
        services.TryAddSingleton(TimeProvider.System);
        services.AddScoped<ICurrentUser, HttpContextCurrentUser>();
        services.AddInfrastructure();

        services.AddScoped<IUserPermissions, HttpContextUserPermissions>();
        services.AddJwtSettings();
        services.AddChantierAuthentication(configuration);
        services.AddSingleton<AuthRateLimiter>();

        services.AddBackOfficeCors();
        services.AddProxyHeaders();
        services.AddLimiter();

        // Compression (R1-14) : un premier pull de zones passe de ~17 Ko a ~2 Ko. Aucun secret dans les corps (jeton en en-tete) : pas de risque BREACH.
        services.AddResponseCompression(options =>
        {
            options.EnableForHttps = true;
            options.Providers.Add<BrotliCompressionProvider>();
            options.Providers.Add<GzipCompressionProvider>();
            options.MimeTypes = ["application/json", "application/problem+json"];
        });
        services.Configure<BrotliCompressionProviderOptions>(options => options.Level = System.IO.Compression.CompressionLevel.Fastest);
        services.Configure<GzipCompressionProviderOptions>(options => options.Level = System.IO.Compression.CompressionLevel.Fastest);

        services.AddProblemDetails(options => options.CustomizeProblemDetails = Normalize);

        services
            .AddControllers(options =>
            {
                options.MaxValidationDepth = 32;
                options.SuppressImplicitRequiredAttributeForNonNullableReferenceTypes = true;
                SetGenericBindingMessages(options.ModelBindingMessageProvider);
            })
            .ConfigureApiBehaviorOptions(options => options.InvalidModelStateResponseFactory = ModelStateProblemFactory.Create)
            .AddJsonOptions(options => JsonDefaults.Configure(options.JsonSerializerOptions));
        services.ConfigureHttpJsonOptions(options => JsonDefaults.Configure(options.SerializerOptions));

        services.AddChantierOpenApi();
        services.AddHealthChecks().AddCheck<DatabaseHealthCheck>("database", tags: [WebApplicationExtensions.ReadyTag]);

        return services;
    }

    private static void AddJwtSettings(this IServiceCollection services)
    {
        // Demarrage refuse sans cle d'au moins 32 octets (CT-15) ; le message ne contient jamais la cle.
        services.AddOptions<JwtSettings>()
            .BindConfiguration(JwtSettings.SectionName)
            .Validate(
                settings => settings.ValidateKey() is null,
                $"{JwtSettings.SectionName}:Key est absente ou plus courte que {JwtSettings.MinimumKeyBytes} octets. "
                + "Renseignez-la avec user-secrets (développement) ou la variable d'environnement JwtSettings__Key.")
            .ValidateOnStart();
    }

    private static void AddBackOfficeCors(this IServiceCollection services)
    {
        services.AddCors();
        services.AddOptions<CorsSettings>()
            .BindConfiguration(CorsSettings.SectionName)
            .Validate(
                settings => !settings.HasWildcard,
                "Cors:Origins ne doit pas contenir de joker : les identifiants (cookie) sont autorisés.")
            .ValidateOnStart();
        services.AddOptions<Microsoft.AspNetCore.Cors.Infrastructure.CorsOptions>()
            .Configure<IOptions<CorsSettings>>((options, settings) =>
            {
                var origins = settings.Value.Origins;
                options.AddPolicy(CorsPolicyName, policy =>
                {
                    if (origins.Length == 0)
                    {
                        return;
                    }

                    policy.WithOrigins(origins)
                        .WithMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                        .WithHeaders("Content-Type", "Authorization", "Accept", "Accept-Language", "If-Match")
                        .WithExposedHeaders("Retry-After")
                        .AllowCredentials();
                });
            });
    }

    /// <summary>
    /// En-tetes de proxy inverse (R1-01) : lus seulement s'ils viennent d'un proxy declare. Reglage invalide ou « actif sans proxy » =
    /// demarrage refuse (jamais de confiance aveugle).
    /// </summary>
    private static void AddProxyHeaders(this IServiceCollection services)
    {
        services.AddOptions<ForwardedHeadersSettings>()
            .BindConfiguration(ForwardedHeadersSettings.SectionName)
            .Validate(settings => settings.IsValid(out _), "ForwardedHeaders : réglage invalide (proxy de confiance absent ou illisible).")
            .ValidateOnStart();

        services.AddOptions<ForwardedHeadersOptions>()
            .Configure<IOptions<ForwardedHeadersSettings>>((options, settings) =>
            {
                var forwarded = settings.Value;
                options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
                options.ForwardLimit = forwarded.ForwardLimit;

                // Par defaut ASP.NET fait confiance a la boucle locale : on repart d'une liste vide, remplie par la configuration seulement.
                options.KnownProxies.Clear();
                options.KnownIPNetworks.Clear();
                foreach (var proxy in forwarded.KnownProxies.Where(value => IPAddress.TryParse(value, out _)))
                {
                    options.KnownProxies.Add(IPAddress.Parse(proxy));
                }

                foreach (var network in forwarded.KnownNetworks.Where(value => System.Net.IPNetwork.TryParse(value, out _)))
                {
                    options.KnownIPNetworks.Add(System.Net.IPNetwork.Parse(network));
                }
            });
    }

    private static void AddLimiter(this IServiceCollection services)
    {
        services.AddRateLimiter(_ => { });
        services.AddOptions<RateLimitSettings>().BindConfiguration(RateLimitSettings.SectionName);
        services.AddOptions<RateLimiterOptions>()
            .Configure<IOptions<RateLimitSettings>>((options, settings) =>
            {
                var global = settings.Value.Global;
                options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

                options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
                    RateLimitPartition.GetFixedWindowLimiter(
                        context.User.GetUserId()?.ToString() ?? "ip:" + (context.Connection.RemoteIpAddress?.ToString() ?? "unknown"),
                        _ => new FixedWindowRateLimiterOptions
                        {
                            PermitLimit = global.PermitLimit,
                            Window = TimeSpan.FromMinutes(global.WindowMinutes),
                        }));

                options.OnRejected = async (rejected, _) =>
                {
                    var context = rejected.HttpContext;
                    if (rejected.Lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter))
                    {
                        context.Response.Headers.RetryAfter = ((int)Math.Ceiling(retryAfter.TotalSeconds)).ToString(System.Globalization.CultureInfo.InvariantCulture);
                    }

                    await ProblemResponses.WriteAsync(
                        context,
                        ProblemResponses.Create(context, Core.Exceptions.ErrorCodes.TropDeRequetes, StatusCodes.Status429TooManyRequests));
                };
            });
    }

    private static void Normalize(ProblemDetailsContext context)
    {
        var problem = context.ProblemDetails;
        if (!problem.Extensions.ContainsKey("code"))
        {
            var status = problem.Status ?? context.HttpContext.Response.StatusCode;
            var normalized = ProblemResponses.ForStatus(context.HttpContext, status);
            problem.Type = normalized.Type;
            problem.Title = normalized.Title;
            problem.Detail = normalized.Detail;
            problem.Status = normalized.Status;
            problem.Extensions["code"] = normalized.Extensions["code"];
        }

        problem.Extensions["traceId"] = ProblemResponses.TraceId(context.HttpContext);
    }

    /// <summary>Messages de liaison de modele sans echo de la valeur saisie (CA-017.2).</summary>
    private static void SetGenericBindingMessages(DefaultModelBindingMessageProvider provider)
    {
        const string message = ModelStateProblemFactory.GenericMessage;
        provider.SetValueIsInvalidAccessor(_ => message);
        provider.SetAttemptedValueIsInvalidAccessor((_, _) => message);
        provider.SetUnknownValueIsInvalidAccessor(_ => message);
        provider.SetValueMustBeANumberAccessor(_ => message);
        provider.SetNonPropertyAttemptedValueIsInvalidAccessor(_ => message);
        provider.SetNonPropertyUnknownValueIsInvalidAccessor(() => message);
        provider.SetNonPropertyValueMustBeANumberAccessor(() => message);
        provider.SetMissingBindRequiredValueAccessor(_ => "Le champ est obligatoire.");
        provider.SetMissingKeyOrValueAccessor(() => "Le champ est obligatoire.");
        provider.SetMissingRequestBodyRequiredValueAccessor(() => "Le corps de la requête est obligatoire.");
        provider.SetValueMustNotBeNullAccessor(_ => "Le champ est obligatoire.");
    }
}
