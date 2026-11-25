using Chantier.WebApi.Errors;
using Chantier.WebApi.Middlewares;
using Chantier.WebApi.Options;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;
using Scalar.AspNetCore;

namespace Chantier.WebApi.Extensions;

public static class WebApplicationExtensions
{
    public const string ReadyTag = "ready";

    public static WebApplication UseWebApiPipeline(this WebApplication app)
    {
        // En premier : tout ce qui suit (limites par IP, journaux) doit voir l'adresse du client et non celle du proxy.
        if (app.Services.GetRequiredService<IOptions<ForwardedHeadersSettings>>().Value.Enabled)
        {
            app.UseForwardedHeaders();
        }

        app.UseResponseCompression();
        app.UseGlobalExceptionHandling();
        app.UseSecurityHeaders();

        // Reponses sans corps du framework (401, 403, 404, 405, 415...) : Problem Details avec code et traceId.
        app.UseStatusCodePages(context => ProblemResponses.WriteAsync(
            context.HttpContext,
            ProblemResponses.ForStatus(context.HttpContext, context.HttpContext.Response.StatusCode)));

        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi().AllowAnonymous();
            app.MapScalarApiReference(options => options.WithTitle("Chantier API")).AllowAnonymous();
        }
        else
        {
            app.UseHsts();
            app.UseHttpsRedirection();
        }

        app.UseRouting();
        app.UseCors(ServiceCollectionExtensions.CorsPolicyName);
        app.UseAuthentication();

        // Limiteur AVANT l'autorisation : les requetes refusees (401, 403) doivent le traverser, sinon un anonyme martelerait l'API sans
        // limite (D-7). Le schema par defaut d'Identity est le cookie : l'intergiciel d'identite evalue d'abord cookie ET jeton porteur,
        // pour un seau par utilisateur, y compris pour tous les telephones (JWT) d'une meme adresse (R1-01). Anonyme ou jeton invalide :
        // seau par adresse IP.
        app.UseMiddleware<RateLimitIdentityMiddleware>();
        app.UseRateLimiter();

        app.UseAuthorization();
        app.UseMiddleware<PasswordChangeRequiredMiddleware>();

        app.MapControllers();

        app.MapHealthChecks("/health/live", new HealthCheckOptions
        {
            Predicate = _ => false,
            ResponseWriter = WriteStatus,
        }).AllowAnonymous();

        app.MapHealthChecks("/health/ready", new HealthCheckOptions
        {
            Predicate = registration => registration.Tags.Contains(ReadyTag),
            ResponseWriter = WriteStatus,
        }).AllowAnonymous();

        return app;
    }

    /// <summary>Sante : un statut seulement, aucun detail (CT-15).</summary>
    private static Task WriteStatus(HttpContext context, HealthReport report)
    {
        context.Response.ContentType = "application/json";
        return context.Response.WriteAsJsonAsync(new { status = report.Status.ToString() });
    }
}
