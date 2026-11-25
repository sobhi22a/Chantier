using System.Text.Json;
using Chantier.Core.Exceptions;
using Chantier.WebApi.Json;
using Chantier.WebApi.Middlewares;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;

namespace Chantier.UnitTests.Errors;

[TestFixture]
public class GlobalExceptionMiddlewareTests
{
    private const string SecretText = "SELECT * FROM Secrets WHERE password = 'hunter2' at Chantier.Infrastructure.Internal";

    private static async Task<(int Status, string ContentType, JsonElement Body, HttpContext Context)> RunAsync(Exception exception)
    {
        var services = new ServiceCollection();
        services.AddLogging();
        services.ConfigureHttpJsonOptions(options => JsonDefaults.Configure(options.SerializerOptions));

        var context = new DefaultHttpContext { RequestServices = services.BuildServiceProvider() };
        context.Response.Body = new MemoryStream();
        context.TraceIdentifier = "trace-test";

        var middleware = new GlobalExceptionMiddleware(_ => throw exception, NullLogger<GlobalExceptionMiddleware>.Instance);
        await middleware.InvokeAsync(context);

        context.Response.Body.Position = 0;
        using var document = await JsonDocument.ParseAsync(context.Response.Body);
        return (context.Response.StatusCode, context.Response.ContentType ?? string.Empty, document.RootElement.Clone(), context);
    }

    private static IEnumerable<TestCaseData> Mappings()
    {
        yield return new TestCaseData(new ValidationException("block", "Le bloc est obligatoire."), 400, "VALIDATION");
        yield return new TestCaseData(new ValidationException("odsDate", "Date.", ErrorCodes.DateInvalide), 400, "DATE_INVALIDE");
        yield return new TestCaseData(new DomainRuleException(ErrorCodes.ZoneExistante, "Une zone identique existe déjà sur ce chantier."), 422, "ZONE_EXISTANTE");
        yield return new TestCaseData(new DomainRuleException(ErrorCodes.QuantiteInvalide, "Le délai doit être supérieur à zéro."), 422, "QUANTITE_INVALIDE");
        yield return new TestCaseData(new NotFoundException(), 404, "INTROUVABLE");
        yield return new TestCaseData(new ForbiddenException(), 403, "INTERDIT");
        yield return new TestCaseData(new PayloadTooLargeException(), 413, "LOT_TROP_GRAND");
        yield return new TestCaseData(new ConflictException(new { version = "12" }), 409, "CONFLIT_VERSION");
        yield return new TestCaseData(new DbUpdateConcurrencyException("secret"), 409, "CONFLIT_VERSION");
        yield return new TestCaseData(new InvalidCredentialsException(), 401, "IDENTIFIANTS_INVALIDES");
        yield return new TestCaseData(new InvalidCredentialsException(ErrorCodes.RefreshInvalide), 401, "REFRESH_INVALIDE");
        yield return new TestCaseData(new AccessRevokedException(), 401, "ACCES_RETIRE");
        yield return new TestCaseData(new TooManyAttemptsException(TimeSpan.FromMinutes(15)), 429, "TROP_D_ESSAIS");
        yield return new TestCaseData(new InvalidOperationException(SecretText), 500, "ERREUR_INTERNE");
    }

    [TestCaseSource(nameof(Mappings))]
    public async Task Each_exception_gives_status_and_stable_code(Exception exception, int expectedStatus, string expectedCode)
    {
        var (status, contentType, body, _) = await RunAsync(exception);

        Assert.Multiple(() =>
        {
            Assert.That(status, Is.EqualTo(expectedStatus));
            Assert.That(contentType, Does.StartWith("application/problem+json"));
            Assert.That(body.GetProperty("code").GetString(), Is.EqualTo(expectedCode));
            Assert.That(body.GetProperty("status").GetInt32(), Is.EqualTo(expectedStatus));
            Assert.That(body.GetProperty("traceId").GetString(), Is.Not.Empty);
            Assert.That(body.GetProperty("title").GetString(), Is.Not.Empty);
            Assert.That(body.GetProperty("type").GetString(), Does.StartWith("https://chantier.local/errors/"));
        });
    }

    [Test]
    public async Task Unexpected_exception_leaks_nothing()
    {
        var (_, _, body, _) = await RunAsync(new InvalidOperationException(SecretText));
        var text = body.GetRawText();

        Assert.Multiple(() =>
        {
            Assert.That(text, Does.Not.Contain("SELECT"));
            Assert.That(text, Does.Not.Contain("hunter2"));
            Assert.That(text, Does.Not.Contain("Chantier.Infrastructure"));
            Assert.That(text, Does.Not.Contain("InvalidOperationException"));
            Assert.That(text, Does.Not.Contain("stackTrace"));
            Assert.That(text, Does.Not.Contain("   at "));
        });
    }

    [Test]
    public async Task Database_exception_leaks_nothing()
    {
        var inner = new InvalidOperationException("Cannot insert duplicate key in object 'dbo.Users'. The duplicate key value is (admin.dev).");
        var (status, _, body, _) = await RunAsync(new DbUpdateException("save failed", inner));
        var text = body.GetRawText();

        Assert.Multiple(() =>
        {
            Assert.That(status, Is.EqualTo(500));
            Assert.That(text, Does.Not.Contain("duplicate"));
            Assert.That(text, Does.Not.Contain("admin.dev"));
            Assert.That(text, Does.Not.Contain("dbo."));
        });
    }

    [Test]
    public async Task Validation_errors_are_returned_by_field()
    {
        var (_, _, body, _) = await RunAsync(new ValidationException("block", "Le bloc est obligatoire."));

        Assert.That(body.GetProperty("errors").GetProperty("block")[0].GetString(), Is.EqualTo("Le bloc est obligatoire."));
    }

    [Test]
    public async Task Conflict_carries_the_current_state()
    {
        var (_, _, body, _) = await RunAsync(new ConflictException(new { version = "42" }));

        Assert.That(body.GetProperty("current").GetProperty("version").GetString(), Is.EqualTo("42"));
    }

    [Test]
    public async Task Too_many_attempts_sets_retry_after()
    {
        var (_, _, _, context) = await RunAsync(new TooManyAttemptsException(TimeSpan.FromMinutes(15)));

        Assert.That(context.Response.Headers.RetryAfter.ToString(), Is.EqualTo("900"));
    }

    [Test]
    public async Task Not_found_is_identical_whatever_the_cause()
    {
        // Ressource absente ou chantier non affecte : meme exception, donc meme corps (hors traceId).
        var (_, _, first, _) = await RunAsync(new NotFoundException());
        var (_, _, second, _) = await RunAsync(new NotFoundException());

        Assert.That(Strip(first), Is.EqualTo(Strip(second)));
        return;

        static string Strip(JsonElement element)
            => string.Join('|', element.EnumerateObject().Where(p => p.Name != "traceId").Select(p => $"{p.Name}={p.Value.GetRawText()}"));
    }

    [Test]
    public async Task Aborted_request_is_not_an_error()
    {
        using var cts = new CancellationTokenSource();
        var context = new DefaultHttpContext();
        context.RequestAborted = cts.Token;
        await cts.CancelAsync();

        var middleware = new GlobalExceptionMiddleware(_ => throw new OperationCanceledException(cts.Token), NullLogger<GlobalExceptionMiddleware>.Instance);
        await middleware.InvokeAsync(context);

        Assert.That(context.Response.StatusCode, Is.EqualTo(499));
    }

    [Test]
    public void Unhandled_exception_is_logged_with_user_id_only()
    {
        var logger = new ListLogger<GlobalExceptionMiddleware>();
        var context = new DefaultHttpContext();
        context.User = new System.Security.Claims.ClaimsPrincipal(new System.Security.Claims.ClaimsIdentity(
        [
            new System.Security.Claims.Claim(System.Security.Claims.ClaimTypes.NameIdentifier, "0192aaaa-0000-7000-8000-000000000001"),
            new System.Security.Claims.Claim(System.Security.Claims.ClaimTypes.Name, "mourad.secret"),
        ], "test"));

        var services = new ServiceCollection();
        services.AddLogging();
        services.ConfigureHttpJsonOptions(options => JsonDefaults.Configure(options.SerializerOptions));
        context.RequestServices = services.BuildServiceProvider();
        context.Response.Body = new MemoryStream();

        var middleware = new GlobalExceptionMiddleware(_ => throw new InvalidOperationException("boom"), logger);
        middleware.InvokeAsync(context).GetAwaiter().GetResult();

        Assert.Multiple(() =>
        {
            Assert.That(logger.Messages, Has.Count.EqualTo(1));
            Assert.That(logger.Messages[0], Does.Contain("0192aaaa-0000-7000-8000-000000000001"));
            Assert.That(logger.Messages[0], Does.Not.Contain("mourad.secret"));
        });
    }

    private sealed class ListLogger<T> : ILogger<T>
    {
        public List<string> Messages { get; } = [];

        public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;

        public bool IsEnabled(LogLevel logLevel) => true;

        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception? exception, Func<TState, Exception?, string> formatter)
            => Messages.Add(formatter(state, exception));
    }
}
