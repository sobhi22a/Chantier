using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Chantier.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace Chantier.IntegrationTests.Foundation;

/// <summary>B1 : squelette, erreurs et securite de base (CT-5, CT-15).</summary>
[TestFixture]
public class SkeletonTests
{
    private ChantierWebApplicationFactory _factory = null!;
    private HttpClient _client = null!;

    [OneTimeSetUp]
    public void SetUp()
    {
        _factory = new ChantierWebApplicationFactory();
        _client = _factory.CreateClient();
    }

    [OneTimeTearDown]
    public void TearDown()
    {
        _client.Dispose();
        _factory.Dispose();
    }

    private static async Task<JsonElement> ReadProblemAsync(HttpResponseMessage response)
    {
        Assert.That(response.Content.Headers.ContentType?.MediaType, Is.EqualTo("application/problem+json"));
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    [Test]
    public async Task Health_live_is_anonymous_and_gives_no_detail()
    {
        var response = await _client.GetAsync("/health/live");
        var text = await response.Content.ReadAsStringAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(text, Is.EqualTo("""{"status":"Healthy"}"""));
        });
    }

    [Test]
    public async Task Unauthenticated_call_is_a_401_problem_with_code_and_trace_id()
    {
        var response = await _client.GetAsync("/api/v1/sites");
        var problem = await ReadProblemAsync(response);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("NON_AUTHENTIFIE"));
            Assert.That(problem.GetProperty("traceId").GetString(), Is.Not.Empty);
        });
    }

    [Test]
    public async Task Unknown_route_without_token_is_a_401_problem()
    {
        // Le repli d'autorisation s'applique aussi aux routes inconnues : un anonyme ne peut pas sonder les routes.
        var response = await _client.GetAsync("/api/v1/does-not-exist");
        var problem = await ReadProblemAsync(response);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("NON_AUTHENTIFIE"));
        });
    }

    [Test]
    public async Task Unexpected_error_is_a_500_without_any_leak()
    {
        var response = await _client.GetAsync("/test-support/boom");
        var problem = await ReadProblemAsync(response);
        var text = problem.GetRawText();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.InternalServerError));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("ERREUR_INTERNE"));
            Assert.That(text, Does.Not.Contain("SELECT"));
            Assert.That(text, Does.Not.Contain("Chantier.Infrastructure"));
            Assert.That(text, Does.Not.Contain("InvalidOperationException"));
            Assert.That(text, Does.Not.Contain("stackTrace").IgnoreCase);
            Assert.That(text, Does.Not.Contain("   at "));
        });
    }

    [Test]
    public async Task Not_found_domain_error_is_a_404_problem()
    {
        var response = await _client.GetAsync("/test-support/not-found");
        var problem = await ReadProblemAsync(response);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.NotFound));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("INTROUVABLE"));
        });
    }

    [Test]
    public async Task Model_validation_gives_400_with_errors_by_field_and_no_echo()
    {
        var response = await _client.PostAsJsonAsync("/test-support/echo", new { name = (string?)null });
        var problem = await ReadProblemAsync(response);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("VALIDATION"));
            Assert.That(problem.GetProperty("errors").GetProperty("name")[0].GetString(), Is.EqualTo("Le champ est obligatoire."));
        });
    }

    [Test]
    public async Task Incomplete_date_gives_400_DATE_INVALIDE()
    {
        var response = await _client.PostAsync(
            "/test-support/echo",
            new StringContent("""{ "name": "x", "date": "../03/2026" }""", System.Text.Encoding.UTF8, "application/json"));
        var problem = await ReadProblemAsync(response);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("DATE_INVALIDE"));
            Assert.That(problem.GetProperty("errors").GetProperty("date")[0].GetString(), Is.EqualTo("La date est incomplète ou impossible."));
            Assert.That(problem.GetRawText(), Does.Not.Contain("../03/2026"));
        });
    }

    [Test]
    public async Task Malformed_json_gives_a_generic_400_without_parser_details()
    {
        var response = await _client.PostAsync(
            "/test-support/echo",
            new StringContent("{ not json", System.Text.Encoding.UTF8, "application/json"));
        var problem = await ReadProblemAsync(response);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("VALIDATION"));
            Assert.That(problem.GetRawText(), Does.Not.Contain("LineNumber"));
            Assert.That(problem.GetRawText(), Does.Not.Contain("BytePosition"));
        });
    }

    [Test]
    public async Task Security_headers_are_present_and_server_header_is_absent()
    {
        var response = await _client.GetAsync("/test-support/not-found");

        Assert.Multiple(() =>
        {
            Assert.That(response.Headers.Contains("Server"), Is.False);
            Assert.That(response.Headers.Contains("X-Powered-By"), Is.False);
            Assert.That(response.Headers.GetValues("X-Content-Type-Options"), Is.EqualTo(new[] { "nosniff" }));
            Assert.That(response.Headers.GetValues("X-Frame-Options"), Is.EqualTo(new[] { "DENY" }));
            Assert.That(response.Headers.GetValues("Content-Security-Policy"), Is.EqualTo(new[] { "default-src 'none'; frame-ancestors 'none'" }));
            Assert.That(response.Headers.GetValues("Referrer-Policy"), Is.EqualTo(new[] { "no-referrer" }));
        });
    }

    [Test]
    public async Task Cors_allows_only_the_configured_origin()
    {
        using var factory = new ChantierWebApplicationFactory();
        factory.Settings["Cors:Origins:0"] = "http://localhost:3600";
        using var client = factory.CreateClient();

        using var allowed = new HttpRequestMessage(HttpMethod.Options, "/health/live");
        allowed.Headers.Add("Origin", "http://localhost:3600");
        allowed.Headers.Add("Access-Control-Request-Method", "GET");
        using var denied = new HttpRequestMessage(HttpMethod.Options, "/health/live");
        denied.Headers.Add("Origin", "http://evil.example");
        denied.Headers.Add("Access-Control-Request-Method", "GET");

        var allowedResponse = await client.SendAsync(allowed);
        var deniedResponse = await client.SendAsync(denied);

        Assert.Multiple(() =>
        {
            Assert.That(allowedResponse.Headers.TryGetValues("Access-Control-Allow-Origin", out var origin) ? origin.Single() : null, Is.EqualTo("http://localhost:3600"));
            Assert.That(deniedResponse.Headers.Contains("Access-Control-Allow-Origin"), Is.False);
        });
    }

    [Test]
    public void Startup_is_refused_without_a_jwt_key()
    {
        using var factory = new ChantierWebApplicationFactory();
        factory.Settings["JwtSettings:Key"] = string.Empty;

        var exception = Assert.Throws<OptionsValidationException>(() => factory.CreateClient());

        Assert.That(exception!.Message, Does.Contain("JwtSettings:Key"));
    }

    [Test]
    public void Startup_is_refused_with_a_key_shorter_than_32_bytes()
    {
        using var factory = new ChantierWebApplicationFactory();
        factory.Settings["JwtSettings:Key"] = "trop-courte-aaaaaaaaaaaaaaaa";

        Assert.Throws<OptionsValidationException>(() => factory.CreateClient());
    }

    [Test]
    public void Startup_is_refused_with_a_wildcard_cors_origin()
    {
        using var factory = new ChantierWebApplicationFactory();
        factory.Settings["Cors:Origins:0"] = "*";

        var exception = Assert.Throws<OptionsValidationException>(() => factory.CreateClient());

        Assert.That(exception!.Message, Does.Contain("Cors:Origins"));
    }

    [Test]
    public void Jwt_secret_is_not_in_any_versioned_settings_file()
    {
        var root = Path.GetDirectoryName(Path.GetDirectoryName(FindUp("Chantier.sln")))!;
        var offenders = Directory.EnumerateFiles(root, "appsettings*.json", SearchOption.AllDirectories)
            .Where(path => !path.Contains($"{Path.DirectorySeparatorChar}bin{Path.DirectorySeparatorChar}") && !path.Contains($"{Path.DirectorySeparatorChar}obj{Path.DirectorySeparatorChar}"))
            .Where(path =>
            {
                using var document = JsonDocument.Parse(File.ReadAllText(path));
                return document.RootElement.TryGetProperty("JwtSettings", out var jwt)
                    && jwt.TryGetProperty("Key", out var key)
                    && !string.IsNullOrWhiteSpace(key.GetString());
            })
            .ToList();

        Assert.That(offenders, Is.Empty, "Aucune clé JWT dans un appsettings versionné.");
    }

    private static string FindUp(string fileName)
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null)
        {
            var candidate = Path.Combine(directory.FullName, fileName);
            if (File.Exists(candidate))
            {
                return candidate;
            }

            directory = directory.Parent;
        }

        throw new FileNotFoundException(fileName);
    }
}
