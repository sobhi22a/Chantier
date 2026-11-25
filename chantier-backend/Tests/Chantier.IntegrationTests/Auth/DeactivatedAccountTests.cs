using System.Net;
using System.Net.Http.Json;
using Chantier.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;

namespace Chantier.IntegrationTests.Auth;

/// <summary>B3, CT-19 : un compte desactive ne peut plus rien, meme avec un jeton ou un cookie encore valide (60 s au plus).</summary>
[TestFixture]
public class DeactivatedAccountTests
{
    private static async Task<string> CodeAsync(HttpResponseMessage response) => (await response.ReadJsonAsync()).GetProperty("code").GetString()!;

    [Test]
    public async Task A_valid_access_token_is_refused_within_60_seconds_of_the_deactivation()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (access, _) = await client.LoginMobileAsync(account);

        // L'etat « actif » est mis en cache (60 s) par ce premier appel.
        Assert.That((await client.SendAsync(Get("/api/v1/auth/me", access))).StatusCode, Is.EqualTo(HttpStatusCode.OK));

        await factory.SetActiveAsync(account.Id, active: false);
        factory.Time.Advance(TimeSpan.FromSeconds(61));
        var refused = await client.SendAsync(Get("/api/v1/auth/me", access));

        Assert.Multiple(async () =>
        {
            Assert.That(refused.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(await CodeAsync(refused), Is.EqualTo("ACCES_RETIRE"));
        });
    }

    [Test]
    public async Task The_status_is_cached_for_less_than_60_seconds_only()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (access, _) = await client.LoginMobileAsync(account);
        await client.SendAsync(Get("/api/v1/auth/me", access));

        await factory.SetActiveAsync(account.Id, active: false);
        factory.Time.Advance(TimeSpan.FromSeconds(30));
        var stillCached = await client.SendAsync(Get("/api/v1/auth/me", access));
        factory.Time.Advance(TimeSpan.FromSeconds(31));
        var refused = await client.SendAsync(Get("/api/v1/auth/me", access));

        Assert.Multiple(() =>
        {
            Assert.That(stillCached.StatusCode, Is.EqualTo(HttpStatusCode.OK), "Le cache évite une requête SQL par appel.");
            Assert.That(refused.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task A_deactivated_account_cannot_log_in_and_gets_the_standard_answer()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        await factory.SetActiveAsync(account.Id, active: false);

        var response = await client.LoginAsync(account.UserName, account.Password, mobile: true);

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(await CodeAsync(response), Is.EqualTo("IDENTIFIANTS_INVALIDES"));
        });
    }

    [Test]
    public async Task Refresh_of_a_deactivated_account_is_ACCES_RETIRE_and_revokes_its_tokens()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (_, refresh) = await client.LoginMobileAsync(account);
        var (_, otherDevice) = await client.LoginMobileAsync(account);

        await factory.SetActiveAsync(account.Id, active: false);
        var refused = await client.PostAsJsonAsync("/api/v1/auth/refresh", new { refreshToken = refresh });

        // Meme reactive, les anciens jetons ne reviennent pas.
        await factory.SetActiveAsync(account.Id, active: true);
        var afterReactivation = await client.PostAsJsonAsync("/api/v1/auth/refresh", new { refreshToken = otherDevice });

        Assert.Multiple(async () =>
        {
            Assert.That(refused.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(await CodeAsync(refused), Is.EqualTo("ACCES_RETIRE"));
            Assert.That(afterReactivation.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(await CodeAsync(afterReactivation), Is.EqualTo("REFRESH_INVALIDE"));
        });
    }

    [Test]
    public async Task A_valid_web_cookie_of_a_deactivated_account_is_refused_with_ACCES_RETIRE()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        await client.LoginAsync(account.UserName, account.Password, mobile: false);
        Assert.That((await client.GetAsync("/api/v1/auth/me")).StatusCode, Is.EqualTo(HttpStatusCode.OK));

        await factory.SetActiveAsync(account.Id, active: false);
        factory.Time.Advance(TimeSpan.FromSeconds(61));
        var refused = await client.GetAsync("/api/v1/auth/me");

        Assert.Multiple(async () =>
        {
            Assert.That(refused.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(await CodeAsync(refused), Is.EqualTo("ACCES_RETIRE"));
        });
    }

    [Test]
    public async Task Deactivation_is_immediate_once_the_status_cache_is_invalidated()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (access, _) = await client.LoginMobileAsync(account);
        await client.SendAsync(Get("/api/v1/auth/me", access));

        await factory.SetActiveAsync(account.Id, active: false);
        factory.Services.GetRequiredService<Chantier.Core.Identity.IUserStatusProvider>().Invalidate(account.Id);

        var refused = await client.SendAsync(Get("/api/v1/auth/me", access));
        Assert.That(refused.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
    }

    [Test]
    public async Task A_token_signed_with_another_key_is_refused()
    {
        using var signer = new ChantierWebApplicationFactory();
        var account = await signer.CreateUserAsync();
        using var signerClient = signer.CreateClient();
        var (access, _) = await signerClient.LoginMobileAsync(account);

        // Meme base (le compte existe), autre cle de signature : le jeton ne vaut rien.
        using var other = new ChantierWebApplicationFactory();
        using var otherClient = other.CreateClient();

        Assert.Multiple(async () =>
        {
            Assert.That((await signerClient.SendAsync(Get("/api/v1/auth/me", access))).StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await otherClient.SendAsync(Get("/api/v1/auth/me", access))).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }
}
