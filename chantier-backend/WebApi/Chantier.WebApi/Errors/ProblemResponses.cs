using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace Chantier.WebApi.Errors;

/// <summary>
/// Point unique de fabrication et d'ecriture des erreurs <c>application/problem+json</c> (RFC 9457) :
/// <c>type</c>, <c>title</c>, <c>status</c>, <c>detail</c>, <c>code</c>, <c>traceId</c>, et selon le cas <c>errors</c> / <c>current</c>.
/// </summary>
public static class ProblemResponses
{
    public const string ContentType = "application/problem+json";

    /// <summary>
    /// Cle de <c>HttpContext.Items</c> : code a renvoyer pour un 401 produit par l'authentification
    /// (ex. <c>ACCES_RETIRE</c> pour un compte desactive).
    /// </summary>
    public const string AuthFailureCodeItem = "Chantier.AuthFailureCode";

    public static ProblemDetails Create(
        HttpContext context,
        string code,
        int? status = null,
        string? detail = null,
        IReadOnlyDictionary<string, string[]>? errors = null,
        object? current = null)
    {
        var entry = ErrorCatalog.Get(code);
        var problem = new ProblemDetails
        {
            Type = ErrorCatalog.TypeUri(code),
            Title = entry.Title,
            Status = status ?? entry.Status,
            Detail = detail ?? entry.Detail,
        };

        problem.Extensions["code"] = code;
        if (errors is { Count: > 0 })
        {
            problem.Extensions["errors"] = errors;
        }

        if (current is not null)
        {
            problem.Extensions["current"] = current;
        }

        problem.Extensions["traceId"] = TraceId(context);
        return problem;
    }

    /// <summary>Erreur generique pour une reponse sans corps produite par le framework (401, 403, 404, 405, 415...).</summary>
    public static ProblemDetails ForStatus(HttpContext context, int status)
    {
        var code = ErrorCatalog.CodeForStatus(status);
        if (status == StatusCodes.Status401Unauthorized
            && context.Items.TryGetValue(AuthFailureCodeItem, out var failureCode)
            && failureCode is string authCode)
        {
            code = authCode;
        }

        // Titre, detail et type viennent du catalogue : un 404 de route inconnue et un 404 de chantier non affecte
        // sont ainsi strictement identiques (CA-006.2).
        return Create(context, code, status);
    }

    public static async Task WriteAsync(HttpContext context, ProblemDetails problem)
    {
        context.Response.StatusCode = problem.Status ?? StatusCodes.Status500InternalServerError;
        await context.Response.WriteAsJsonAsync(problem, problem.GetType(), options: null, contentType: ContentType);
    }

    public static string TraceId(HttpContext context) => Activity.Current?.Id ?? context.TraceIdentifier;
}
