namespace Chantier.WebApi.Middlewares;

/// <summary>En-tetes de securite de base (API JSON seulement) ; retire <c>Server</c> et <c>X-Powered-By</c> (CT-15).</summary>
public sealed class SecurityHeadersMiddleware(RequestDelegate next)
{
    public Task InvokeAsync(HttpContext context)
    {
        // La CSP stricte ci-dessous bloque tout script : correcte pour /api, mais elle casserait la page Scalar
        // (outil de developpement) et les scripts injectes par l'IDE.
        var isDevToolingPage = context.Request.Path.StartsWithSegments("/scalar")
            || context.Request.Path.StartsWithSegments("/openapi")
            || context.Request.Path.StartsWithSegments("/_vs")
            || context.Request.Path.StartsWithSegments("/_framework");

        context.Response.OnStarting(static state =>
        {
            var (httpContext, devTooling) = ((HttpContext, bool))state;
            var headers = httpContext.Response.Headers;

            headers["X-Content-Type-Options"] = "nosniff";
            headers["Referrer-Policy"] = "no-referrer";
            headers["Cross-Origin-Resource-Policy"] = "same-site";
            headers["X-Permitted-Cross-Domain-Policies"] = "none";
            headers.Remove("Server");
            headers.Remove("X-Powered-By");

            if (!devTooling)
            {
                headers["X-Frame-Options"] = "DENY";
                headers["Cross-Origin-Opener-Policy"] = "same-origin";
                headers["Content-Security-Policy"] = "default-src 'none'; frame-ancestors 'none'";
                headers["Cache-Control"] = "no-store";
            }

            return Task.CompletedTask;
        }, (context, isDevToolingPage));

        return next(context);
    }
}

public static class SecurityHeadersMiddlewareExtensions
{
    public static IApplicationBuilder UseSecurityHeaders(this IApplicationBuilder app)
        => app.UseMiddleware<SecurityHeadersMiddleware>();
}
