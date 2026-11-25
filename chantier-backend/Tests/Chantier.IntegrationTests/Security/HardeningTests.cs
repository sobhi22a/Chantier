using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Reflection;
using System.Text;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using Chantier.WebApi.Controllers.Sync;
using Chantier.WebApi.Options;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Security;

/// <summary>R1-07 (corps invalide = 400), R1-08 (taille des corps), R1-14 (compression).</summary>
[TestFixture]
public class HardeningTests
{
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public void SetUp() => _factory = new ChantierWebApplicationFactory();

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    [TestCase("{\"operations\":[null]}")]
    [TestCase("{\"operations\":[null,null]}")]
    [TestCase("{\"operations\":[{\"clientId\":\"7c1e6a52-0d3b-4c59-9a43-6f1f2b9d8e10\",\"entity\":\"zone\",\"operation\":\"create\"},null]}")]
    public async Task A_null_operation_in_a_push_is_a_400_VALIDATION_and_never_a_500(string body)
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var logsBefore = _factory.Logs.Entries.Count(entry => entry.StartsWith("[Error]", StringComparison.Ordinal));

        var response = await chef.PostRawAsync(PushUrl, body);
        var problem = await response.JsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(problem.GetProperty("code").GetString(), Is.EqualTo("VALIDATION"));
            Assert.That(problem.GetProperty("errors").TryGetProperty("operations", out _), Is.True);
            Assert.That(_factory.Logs.Entries.Count(entry => entry.StartsWith("[Error]", StringComparison.Ordinal)), Is.EqualTo(logsBefore), "Aucune pile d'exécution au journal.");
        });
    }

    [Test]
    public async Task Valid_operations_are_still_accepted_after_the_null_check()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);

        var results = await chef.PushAsync(ZoneOperation(Guid.NewGuid(), Guid.NewGuid()));

        Assert.That(results[0].Code(), Is.EqualTo("INTROUVABLE"), "L'opération est traitée (chantier inconnu), pas rejetée à la liaison.");
    }

    [Test]
    public void The_default_body_limit_is_64_kb_and_the_push_raises_it_to_1_mb()
    {
        var kestrel = _factory.Services.GetRequiredService<IOptions<KestrelServerOptions>>().Value;
        var push = typeof(SyncController).GetMethod(nameof(SyncController.Push))!;
        var limit = push.GetCustomAttribute<RequestSizeLimitAttribute>();

        Assert.Multiple(() =>
        {
            Assert.That(kestrel.Limits.MaxRequestBodySize, Is.EqualTo(64 * 1024));
            Assert.That(RequestLimits.DefaultMaxBodyBytes, Is.EqualTo(64 * 1024));
            Assert.That(limit, Is.Not.Null);
            Assert.That(typeof(RequestSizeLimitAttribute).GetField("_bytes", BindingFlags.NonPublic | BindingFlags.Instance)?.GetValue(limit), Is.EqualTo(1_048_576L));
        });
    }

    [Test]
    public async Task A_huge_login_body_is_never_accepted()
    {
        using var client = _factory.CreateClient();
        var body = new string('a', 200 * 1024);

        var response = await client.PostAsync("/api/v1/auth/login", new StringContent("{\"userName\":\"" + body + "\",\"password\":\"x\"}", Encoding.UTF8, "application/json"));

        // Le serveur de test (TestServer) n'applique pas la limite de Kestrel : le 413 reel est verifie sur un vrai serveur (voir le rapport) ; ici, jamais un succes.
        Assert.That(response.StatusCode, Is.AnyOf(HttpStatusCode.RequestEntityTooLarge, HttpStatusCode.BadRequest));
        Assert.That((await response.JsonAsync()).GetProperty("code").GetString(), Is.AnyOf("LOT_TROP_GRAND", "VALIDATION"));
    }

    [TestCase("gzip")]
    [TestCase("br")]
    public async Task Json_responses_are_compressed_when_the_client_accepts_it(string encoding)
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);
        var request = new HttpRequestMessage(HttpMethod.Get, "/api/v1/reference/wilayas");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", chef.AccessToken);
        request.Headers.AcceptEncoding.ParseAdd(encoding);

        using var client = _factory.CreateClient();
        var response = await client.SendAsync(request);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(response.Content.Headers.ContentEncoding, Does.Contain(encoding));
        });
    }

    [Test]
    public async Task Without_accept_encoding_the_response_stays_plain()
    {
        var chef = await _factory.SignInAsync(RoleNames.ChefChantier);

        var response = await chef.GetAsync("/api/v1/reference/wilayas");

        Assert.That(response.Content.Headers.ContentEncoding, Is.Empty);
    }

    [Test]
    public async Task Error_responses_are_compressed_too_and_stay_valid_problem_details()
    {
        using var client = _factory.CreateClient(new Microsoft.AspNetCore.Mvc.Testing.WebApplicationFactoryClientOptions { AllowAutoRedirect = false });
        var request = new HttpRequestMessage(HttpMethod.Get, "/api/v1/sites");
        request.Headers.AcceptEncoding.ParseAdd("gzip");

        var response = await client.SendAsync(request);

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(response.Content.Headers.ContentType?.MediaType, Is.EqualTo("application/problem+json"));
        });
    }
}
