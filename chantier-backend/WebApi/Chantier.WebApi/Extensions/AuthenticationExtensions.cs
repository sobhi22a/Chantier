using System.Text;
using Chantier.Core.Identity;
using Chantier.WebApi.Authorization;
using Chantier.WebApi.Options;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.DataProtection.KeyManagement;
using Microsoft.AspNetCore.DataProtection.Repositories;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Chantier.WebApi.Extensions;

/// <summary>Authentification double (cookie web, jeton mobile), politique de repli et permissions (ADR 0005).</summary>
public static class AuthenticationExtensions
{
    public const string CookieName = ".Chantier.Identity.Application";

    public static IServiceCollection AddChantierAuthentication(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddAuthentication().AddJwtBearer();

        services.AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme)
            .Configure<IOptions<JwtSettings>, IHostEnvironment>((options, jwt, environment) =>
            {
                var settings = jwt.Value;
                options.RequireHttpsMetadata = !environment.IsDevelopment();
                options.MapInboundClaims = false;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = settings.Issuer,
                    ValidateAudience = true,
                    ValidAudience = settings.Audience,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(settings.Key)),
                    ValidAlgorithms = [SecurityAlgorithms.HmacSha256],
                    NameClaimType = "sub",
                    RoleClaimType = "role",
                    ClockSkew = TimeSpan.FromSeconds(30),
                };
                options.Events = new JwtBearerEvents { OnTokenValidated = ActiveUserValidator.ValidateJwtAsync };
            });

        // Cookie web : HttpOnly, SameSite=Lax, Secure hors developpement, 8 h glissantes. 401/403 au lieu de redirections.
        services.AddOptions<CookieAuthenticationOptions>(IdentityConstants.ApplicationScheme)
            .Configure<IHostEnvironment, IOptions<AuthSettings>>((options, environment, auth) =>
            {
                options.Cookie.Name = CookieName;
                options.Cookie.HttpOnly = true;
                options.Cookie.SameSite = SameSiteMode.Lax;
                options.Cookie.SecurePolicy = environment.IsDevelopment() ? CookieSecurePolicy.SameAsRequest : CookieSecurePolicy.Always;
                options.ExpireTimeSpan = TimeSpan.FromHours(Math.Max(1, auth.Value.CookieSessionHours));
                options.SlidingExpiration = true;
                options.Events.OnRedirectToLogin = context =>
                {
                    context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                    return Task.CompletedTask;
                };
                options.Events.OnRedirectToAccessDenied = context =>
                {
                    context.Response.StatusCode = StatusCodes.Status403Forbidden;
                    return Task.CompletedTask;
                };

                // Remplace la validation du « security stamp » d'Identity : le cookie ne le porte pas ; l'etat du compte est verifie ici.
                options.Events.OnValidatePrincipal = ActiveUserValidator.ValidateCookieAsync;
            });

        // Tout exige un utilisateur authentifie (cookie OU jeton), sauf [AllowAnonymous] explicite.
        services.AddAuthorization(options =>
        {
            var authenticated = new AuthorizationPolicyBuilder(AuthenticationSchemes.All).RequireAuthenticatedUser().Build();
            options.DefaultPolicy = authenticated;
            options.FallbackPolicy = authenticated;
        });
        services.AddSingleton<IAuthorizationPolicyProvider, PermissionPolicyProvider>();
        services.AddScoped<IAuthorizationHandler, PermissionAuthorizationHandler>();

        services.AddPersistedDataProtection(configuration);
        return services;
    }

    private static System.Security.Cryptography.X509Certificates.X509Certificate2? CertificateFrom(IConfiguration configuration)
    {
        var settings = configuration.GetSection(DataProtectionSettings.SectionName).Get<DataProtectionSettings>();
        if (settings is null || string.IsNullOrWhiteSpace(settings.CertificatePath))
        {
            return null;
        }

        return System.Security.Cryptography.X509Certificates.X509CertificateLoader.LoadPkcs12FromFile(settings.CertificatePath, settings.CertificatePassword);
    }

    /// <summary>Cles de protection des donnees persistees (<c>Storage:DataProtectionKeys</c>) : sinon les sessions web meurent a chaque redemarrage.</summary>
    private static void AddPersistedDataProtection(this IServiceCollection services, IConfiguration configuration)
    {
        var protection = services.AddDataProtection().SetApplicationName("Chantier");

        // Chiffrement des cles au repos (R1-06) : sans lui, quiconque lit le dossier des cles peut forger un cookie. Le certificat est lu dans la
        // configuration deja chargee (variables d'environnement et secrets compris) ; le mot de passe du certificat n'est jamais journalise.
        if (CertificateFrom(configuration) is { } certificate)
        {
            protection.ProtectKeysWithCertificate(certificate);
        }

        services.AddOptions<DataProtectionSettings>()
            .BindConfiguration(DataProtectionSettings.SectionName)
            .Validate<IHostEnvironment>(
                (settings, environment) => settings.IsAcceptableIn(environment.IsDevelopment()),
                "DataProtection : en dehors du développement, les clés de protection des données doivent être chiffrées (DataProtection:CertificatePath et DataProtection:CertificatePassword).")
            .ValidateOnStart();
        services.AddOptions<KeyManagementOptions>()
            .Configure<IConfiguration, IHostEnvironment, ILoggerFactory>((options, configuration, environment, loggers) =>
            {
                var directory = configuration["Storage:DataProtectionKeys"];
                if (string.IsNullOrWhiteSpace(directory))
                {
                    directory = Path.Combine(environment.ContentRootPath, "Storage", "DataProtectionKeys");
                }

                Directory.CreateDirectory(directory);
                options.XmlRepository = new FileSystemXmlRepository(new DirectoryInfo(directory), loggers);
            });
    }
}
