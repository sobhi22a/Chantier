using System.Net;
using System.Net.Http.Json;
using Chantier.Core.Entities.Identity;
using Chantier.Infrastructure.Persistence;
using Chantier.IntegrationTests.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using static Chantier.IntegrationTests.Support.SyncTestKit;

namespace Chantier.IntegrationTests.Security;

/// <summary>R1-01 : limiteur global par utilisateur (jeton porteur compris) et en-tetes de proxy inverse lus seulement depuis un proxy declare.</summary>
[TestFixture]
public class RateLimitAndProxyTests
{
    private static ChantierWebApplicationFactory Factory(int globalLimit, Action<ChantierWebApplicationFactory>? configure = null)
    {
        var factory = new ChantierWebApplicationFactory { RemoteIpAddress = IPAddress.Parse("198.51.100.20") };
        factory.Settings["RateLimiting:Global:PermitLimit"] = globalLimit.ToString();
        configure?.Invoke(factory);
        return factory;
    }

    [Test]
    public async Task Two_bearer_users_behind_the_same_address_do_not_share_their_quota()
    {
        using var factory = Factory(globalLimit: 8);
        var busy = await factory.SignInAsync(RoleNames.ChefChantier);
        var quiet = await factory.SignInAsync(RoleNames.ChefEquipe);

        var codes = new List<HttpStatusCode>();
        for (var index = 0; index < 12; index++)
        {
            codes.Add((await busy.GetAsync("/api/v1/auth/me")).StatusCode);
        }

        var other = await quiet.GetAsync("/api/v1/auth/me");

        Assert.Multiple(() =>
        {
            Assert.That(codes.Count(code => code == HttpStatusCode.OK), Is.EqualTo(8), "Le premier utilisateur épuise SON quota.");
            Assert.That(codes.Skip(8), Has.All.EqualTo(HttpStatusCode.TooManyRequests));
            Assert.That(other.StatusCode, Is.EqualTo(HttpStatusCode.OK), "Le second, même adresse, n'est pas pénalisé.");
        });
    }

    [Test]
    public async Task The_quota_of_a_bearer_user_is_not_the_one_of_anonymous_callers_of_the_same_address()
    {
        using var factory = Factory(globalLimit: 5);
        var user = await factory.SignInAsync(RoleNames.ChefChantier);
        using var anonymous = factory.CreateClient();

        for (var index = 0; index < 8; index++)
        {
            _ = await anonymous.GetAsync("/health/live");
        }

        var response = await user.GetAsync("/api/v1/auth/me");

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), "Un anonyme bruyant ne prive pas un utilisateur connecté.");
    }

    [Test]
    public async Task An_anonymous_flood_of_refused_requests_does_not_deprive_a_signed_in_user_of_the_same_address()
    {
        using var factory = Factory(globalLimit: 5);
        var user = await factory.SignInAsync(RoleNames.ChefChantier);
        using var anonymous = factory.CreateClient();

        var codes = new List<HttpStatusCode>();
        for (var index = 0; index < 10; index++)
        {
            codes.Add((await anonymous.GetAsync("/api/v1/sites")).StatusCode);
        }

        var response = await user.GetAsync("/api/v1/auth/me");

        Assert.Multiple(() =>
        {
            // La connexion de l'utilisateur (anonyme) a deja pris un jeton dans le seau de l'adresse : 4 refus 401 restent, puis 429.
            Assert.That(codes.Count(code => code == HttpStatusCode.Unauthorized), Is.InRange(1, 5), "Les refus d'authentification comptent dans le seau de l'adresse.");
            Assert.That(codes.Last(), Is.EqualTo(HttpStatusCode.TooManyRequests));
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), "L'utilisateur connecté garde son propre quota.");
        });
    }

    [Test]
    public async Task A_429_is_a_problem_details_with_the_rate_code_and_retry_after()
    {
        using var factory = Factory(globalLimit: 2);
        var user = await factory.SignInAsync(RoleNames.ChefChantier);
        _ = await user.GetAsync("/api/v1/auth/me");
        _ = await user.GetAsync("/api/v1/auth/me");

        var limited = await user.GetAsync("/api/v1/auth/me");

        Assert.Multiple(async () =>
        {
            Assert.That(limited.StatusCode, Is.EqualTo(HttpStatusCode.TooManyRequests));
            Assert.That((await limited.JsonAsync()).GetProperty("code").GetString(), Is.EqualTo("TROP_DE_REQUETES"));
            Assert.That(limited.Headers.RetryAfter, Is.Not.Null);
        });
    }

    private static async Task<string?> RecordedAddressAsync(ChantierWebApplicationFactory factory, string? forwardedFor)
    {
        var account = await factory.CreateUserAsync(RoleNames.ChefChantier);
        using var client = factory.CreateClient();
        var request = new HttpRequestMessage(HttpMethod.Post, "/api/v1/auth/login")
        {
            Content = JsonContent.Create(new { userName = account.UserName, password = account.Password, isAppMobile = true }),
        };
        if (forwardedFor is not null)
        {
            request.Headers.Add("X-Forwarded-For", forwardedFor);
        }

        (await client.SendAsync(request)).EnsureSuccessStatusCode();

        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        return await db.RefreshTokens.Where(token => token.UserId == account.Id).Select(token => token.CreatedByIp).SingleAsync();
    }

    [Test]
    public async Task Forwarded_headers_are_ignored_by_default()
    {
        using var factory = Factory(300);

        Assert.That(await RecordedAddressAsync(factory, "203.0.113.7"), Is.EqualTo("198.51.100.20"), "Sans proxy déclaré, l'en-tête vient du client : ignoré.");
    }

    [Test]
    public async Task A_declared_proxy_gives_the_real_client_address()
    {
        using var factory = Factory(300, f =>
        {
            f.Settings["ForwardedHeaders:Enabled"] = "true";
            f.Settings["ForwardedHeaders:KnownProxies:0"] = "198.51.100.20";
        });

        Assert.That(await RecordedAddressAsync(factory, "203.0.113.7"), Is.EqualTo("203.0.113.7"));
    }

    [Test]
    public async Task A_declared_network_is_trusted_too()
    {
        using var factory = Factory(300, f =>
        {
            f.Settings["ForwardedHeaders:Enabled"] = "true";
            f.Settings["ForwardedHeaders:KnownNetworks:0"] = "198.51.100.0/24";
        });

        Assert.That(await RecordedAddressAsync(factory, "203.0.113.9"), Is.EqualTo("203.0.113.9"));
    }

    [Test]
    public async Task The_header_is_ignored_when_it_does_not_come_from_a_declared_proxy()
    {
        using var factory = Factory(300, f =>
        {
            f.Settings["ForwardedHeaders:Enabled"] = "true";
            f.Settings["ForwardedHeaders:KnownProxies:0"] = "10.0.0.2";
        });

        Assert.That(await RecordedAddressAsync(factory, "203.0.113.7"), Is.EqualTo("198.51.100.20"), "Un client direct ne peut pas usurper son adresse.");
    }

    [Test]
    public async Task Behind_a_declared_proxy_two_clients_get_their_own_anonymous_quota()
    {
        using var factory = Factory(globalLimit: 3, f =>
        {
            f.Settings["ForwardedHeaders:Enabled"] = "true";
            f.Settings["ForwardedHeaders:KnownProxies:0"] = "198.51.100.20";
        });
        using var client = factory.CreateClient();

        async Task<HttpStatusCode> Probe(string address)
        {
            var request = new HttpRequestMessage(HttpMethod.Get, "/health/live");
            request.Headers.Add("X-Forwarded-For", address);
            return (await client.SendAsync(request)).StatusCode;
        }

        for (var index = 0; index < 5; index++)
        {
            _ = await Probe("203.0.113.1");
        }

        Assert.Multiple(async () =>
        {
            Assert.That(await Probe("203.0.113.1"), Is.EqualTo(HttpStatusCode.TooManyRequests));
            Assert.That(await Probe("203.0.113.2"), Is.EqualTo(HttpStatusCode.OK), "Autre client derrière le même proxy : autre seau.");
        });
    }

    [Test]
    public void Enabling_forwarded_headers_without_a_trusted_proxy_refuses_to_start()
    {
        using var factory = Factory(300, f => f.Settings["ForwardedHeaders:Enabled"] = "true");

        var failure = Assert.Throws<OptionsValidationException>(() => _ = factory.Server);

        Assert.That(failure!.Message, Does.Contain("ForwardedHeaders"));
    }

    [Test]
    public void An_unreadable_proxy_address_refuses_to_start()
    {
        using var factory = Factory(300, f =>
        {
            f.Settings["ForwardedHeaders:Enabled"] = "true";
            f.Settings["ForwardedHeaders:KnownProxies:0"] = "pas-une-adresse";
        });

        Assert.Throws<OptionsValidationException>(() => _ = factory.Server);
    }
}
