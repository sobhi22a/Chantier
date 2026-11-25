using Chantier.Core.Exceptions;
using Chantier.WebApi.Errors;
using Chantier.WebApi.Extensions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Chantier.WebApi.Middlewares;

/// <summary>
/// Capture toute exception et la transforme en Problem Details (ADR 0002) : table exception -> statut + <c>code</c>.
/// Une exception inattendue donne 500 <c>ERREUR_INTERNE</c> sans aucun detail (ni pile, ni SQL, ni message interne).
/// Seul l'identifiant de l'utilisateur (GUID anonyme) est journalise, jamais son nom (CA-017.1).
/// </summary>
public sealed class GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
{
    /// <summary>Statut renvoye quand le client a abandonne la requete (convention nginx).</summary>
    private const int ClientClosedRequest = 499;

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested)
        {
            context.Response.StatusCode = ClientClosedRequest;
        }
        catch (Exception exception) when (!context.Response.HasStarted)
        {
            await HandleAsync(context, exception);
        }
    }

    private async Task HandleAsync(HttpContext context, Exception exception)
    {
        var (problem, retryAfter) = Map(context, exception);

        Log(context, exception, problem);

        if (retryAfter is { } wait)
        {
            context.Response.Headers.RetryAfter = ((int)Math.Ceiling(wait.TotalSeconds)).ToString(System.Globalization.CultureInfo.InvariantCulture);
        }

        await ProblemResponses.WriteAsync(context, problem);
    }

    /// <summary>Table exception -> Problem Details. Publique pour etre testee sans serveur.</summary>
    public static (ProblemDetails Problem, TimeSpan? RetryAfter) Map(HttpContext context, Exception exception) => exception switch
    {
        ValidationException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status400BadRequest, errors: e.Errors), null),
        DomainRuleException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status422UnprocessableEntity, detail: e.Message), null),
        NotFoundException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status404NotFound), null),
        ForbiddenException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status403Forbidden), null),
        PayloadTooLargeException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status413PayloadTooLarge), null),
        ConflictException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status409Conflict, current: e.Current), null),
        InvalidCredentialsException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status401Unauthorized), null),
        AccessRevokedException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status401Unauthorized), null),
        TooManyAttemptsException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status429TooManyRequests), e.RetryAfter),
        RateLimitedException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status429TooManyRequests), e.RetryAfter),
        PasswordChangeRequiredException e => (ProblemResponses.Create(context, e.Code, StatusCodes.Status403Forbidden), null),
        DbUpdateConcurrencyException => (ProblemResponses.Create(context, ErrorCodes.ConflitVersion, StatusCodes.Status409Conflict), null),
        BadHttpRequestException e => (ProblemResponses.ForStatus(context, e.StatusCode), null),
        _ => (ProblemResponses.Create(context, ErrorCodes.ErreurInterne, StatusCodes.Status500InternalServerError), null),
    };

    private void Log(HttpContext context, Exception exception, ProblemDetails problem)
    {
        var userId = context.User.GetUserId();
        var status = problem.Status;
        var code = problem.Extensions["code"];

        switch (exception)
        {
            case DomainException:
            case BadHttpRequestException:
            case DbUpdateConcurrencyException:
                logger.LogInformation(
                    "Requête refusée {Status} {Code} {Method} {Path} utilisateur={UserId}",
                    status, code, context.Request.Method, context.Request.Path.Value, userId);
                break;

            case DbUpdateException dbException:
                // Le message d'une erreur SQL (cle en double, valeur de colonne) peut contenir des donnees : on ne journalise
                // que les types d'exception et le numero d'erreur.
                logger.LogError(
                    "Erreur de base de données {Method} {Path} utilisateur={UserId} {ExceptionType}/{InnerType} sqlNumber={SqlNumber}",
                    context.Request.Method, context.Request.Path.Value, userId,
                    dbException.GetType().Name, dbException.InnerException?.GetType().Name,
                    (dbException.InnerException as Microsoft.Data.SqlClient.SqlException)?.Number);
                break;

            default:
                logger.LogError(
                    exception,
                    "Erreur non gérée {Method} {Path} utilisateur={UserId}",
                    context.Request.Method, context.Request.Path.Value, userId);
                break;
        }
    }
}

public static class GlobalExceptionMiddlewareExtensions
{
    public static IApplicationBuilder UseGlobalExceptionHandling(this IApplicationBuilder app)
        => app.UseMiddleware<GlobalExceptionMiddleware>();
}
