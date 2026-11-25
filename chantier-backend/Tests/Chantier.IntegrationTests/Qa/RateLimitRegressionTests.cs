using System.Net;
using Chantier.IntegrationTests.Support;

namespace Chantier.IntegrationTests.Qa;

/// <summary>
/// Q1, seconde passe : le limiteur global a ete deplace APRES l'autorisation pour voir l'utilisateur du jeton (R1-01). Les demandes
/// refusees par l'authentification (401) ou l'autorisation (403) ne passent donc plus par lui : un anonyme peut marteler une route
/// protegee sans jamais recevoir de 429 (defaut D-7 du rapport QA).
/// </summary>
[TestFixture]
public class RateLimitRegressionTests
{
    [Test]
    public async Task An_anonymous_caller_hammering_a_protected_route_is_eventually_limited()
    {
        using var factory = new ChantierWebApplicationFactory { RemoteIpAddress = IPAddress.Parse("198.51.100.77") };
        factory.Settings["RateLimiting:Global:PermitLimit"] = "20";
        using var client = factory.CreateClient();

        var codes = new List<HttpStatusCode>();
        for (var index = 0; index < 60; index++)
        {
            codes.Add((await client.GetAsync("/api/v1/sites")).StatusCode);
        }

        Assert.That(codes, Does.Contain(HttpStatusCode.TooManyRequests), $"60 appels sans jeton : {codes.Count(c => c == HttpStatusCode.Unauthorized)} x 401, aucun 429.");
    }

    [Test]
    public async Task A_caller_sending_an_invalid_bearer_token_is_eventually_limited()
    {
        using var factory = new ChantierWebApplicationFactory { RemoteIpAddress = IPAddress.Parse("198.51.100.78") };
        factory.Settings["RateLimiting:Global:PermitLimit"] = "20";
        using var client = factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", "garbage.token.value");

        var codes = new List<HttpStatusCode>();
        for (var index = 0; index < 60; index++)
        {
            codes.Add((await client.GetAsync("/api/v1/sites")).StatusCode);
        }

        Assert.That(codes, Does.Contain(HttpStatusCode.TooManyRequests));
    }
}
