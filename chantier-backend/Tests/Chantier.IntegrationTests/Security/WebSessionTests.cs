using System.Net;
using System.Net.Http.Json;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using Microsoft.AspNetCore.Mvc.Testing;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;

namespace Chantier.IntegrationTests.Security;

/// <summary>R1-02 : un cookie web deja emis ne survit ni a la deconnexion, ni au changement de mot de passe, ni au plafond absolu de session.</summary>
[TestFixture]
public class WebSessionTests
{
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public void SetUp() => _factory = new ChantierWebApplicationFactory();

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    private HttpClient NewClient() => _factory.CreateClient(new WebApplicationFactoryClientOptions { HandleCookies = false });

    /// <summary>Connexion web : renvoie la valeur du cookie de session (nom=valeur), a rejouer a la main.</summary>
    private static async Task<string> LoginWebAsync(HttpClient client, TestAccount account, string? password = null)
    {
        var response = await client.LoginAsync(account.UserName, password ?? account.Password, mobile: false);
        response.EnsureSuccessStatusCode();
        return CookieOf(response);
    }

    private static string CookieOf(HttpResponseMessage response)
        => response.Headers.GetValues("Set-Cookie").Single(header => header.StartsWith(".Chantier.Identity.Application=", StringComparison.Ordinal)).Split(';')[0];

    private static Task<HttpResponseMessage> SendAsync(HttpClient client, HttpMethod method, string url, string cookie, object? body = null)
    {
        var request = new HttpRequestMessage(method, url);
        request.Headers.Add("Cookie", cookie);
        if (body is not null)
        {
            request.Content = JsonContent.Create(body);
        }

        return client.SendAsync(request);
    }

    private static async Task<HttpStatusCode> MeAsync(HttpClient client, string cookie)
        => (await SendAsync(client, HttpMethod.Get, "/api/v1/auth/me", cookie)).StatusCode;

    [Test]
    public async Task A_fresh_cookie_works()
    {
        var account = await _factory.CreateUserAsync(RoleNames.Direction);
        var client = NewClient();

        var cookie = await LoginWebAsync(client, account);

        Assert.That(await MeAsync(client, cookie), Is.EqualTo(HttpStatusCode.OK));
    }

    [Test]
    public async Task A_cookie_replayed_after_logout_is_refused()
    {
        var account = await _factory.CreateUserAsync(RoleNames.Direction);
        var client = NewClient();
        var cookie = await LoginWebAsync(client, account);

        var logout = await SendAsync(client, HttpMethod.Post, "/api/v1/auth/logout", cookie, new { });
        var replay = await SendAsync(client, HttpMethod.Get, "/api/v1/auth/me", cookie);

        Assert.Multiple(async () =>
        {
            Assert.That(logout.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(replay.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized), "Le même cookie, rejoué après « Se déconnecter », est refusé.");
            Assert.That((await replay.JsonAsync()).GetProperty("code").GetString(), Is.EqualTo("NON_AUTHENTIFIE"));
        });
    }

    [Test]
    public async Task Logging_in_again_after_logout_gives_a_working_cookie_and_the_old_one_stays_dead()
    {
        var account = await _factory.CreateUserAsync(RoleNames.Direction);
        var client = NewClient();
        var first = await LoginWebAsync(client, account);
        _ = await SendAsync(client, HttpMethod.Post, "/api/v1/auth/logout", first, new { });

        var second = await LoginWebAsync(client, account);

        Assert.Multiple(async () =>
        {
            Assert.That(await MeAsync(client, second), Is.EqualTo(HttpStatusCode.OK));
            Assert.That(await MeAsync(client, first), Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task A_password_change_invalidates_the_other_cookies_and_keeps_the_session_that_changed_it()
    {
        var account = await _factory.CreateUserAsync(RoleNames.Direction);
        var client = NewClient();
        var changing = await LoginWebAsync(client, account);
        var stolen = await LoginWebAsync(client, account);

        var change = await SendAsync(client, HttpMethod.Post, "/api/v1/auth/change-password", changing, new { currentPassword = account.Password, newPassword = "Nouveau-Terrain-2027" });
        var renewed = CookieOf(change);

        Assert.Multiple(async () =>
        {
            Assert.That(change.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(await MeAsync(client, stolen), Is.EqualTo(HttpStatusCode.Unauthorized), "Un cookie volé ne survit pas au changement de mot de passe.");
            Assert.That(await MeAsync(client, changing), Is.EqualTo(HttpStatusCode.Unauthorized), "L'ancien cookie de la session qui a changé le mot de passe non plus…");
            Assert.That(await MeAsync(client, renewed), Is.EqualTo(HttpStatusCode.OK), "… mais celle-ci reçoit un cookie neuf et reste ouverte.");
        });
    }

    [Test]
    public async Task A_web_logout_does_not_end_the_mobile_session_of_the_same_user()
    {
        var account = await _factory.CreateUserAsync(RoleNames.ChefChantier);
        var client = NewClient();
        var (access, _) = await client.LoginMobileAsync(account);
        var cookie = await LoginWebAsync(client, account);

        _ = await SendAsync(client, HttpMethod.Post, "/api/v1/auth/logout", cookie, new { });
        var mobile = await client.SendAsync(Get("/api/v1/auth/me", access));

        Assert.That(mobile.StatusCode, Is.EqualTo(HttpStatusCode.OK), "Les jetons du téléphone ont leur propre cycle (refresh rotatif).");
    }

    [Test]
    public async Task A_mobile_logout_does_not_end_the_web_session()
    {
        var account = await _factory.CreateUserAsync(RoleNames.ChefChantier);
        var client = NewClient();
        var cookie = await LoginWebAsync(client, account);
        var (access, refresh) = await client.LoginMobileAsync(account);

        var logout = await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/logout", new { refreshToken = refresh }, access));

        Assert.Multiple(async () =>
        {
            Assert.That(logout.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(await MeAsync(client, cookie), Is.EqualTo(HttpStatusCode.OK));
        });
    }

    [Test]
    public async Task The_session_has_an_absolute_ceiling_even_when_it_is_used_all_the_time()
    {
        using var factory = new ChantierWebApplicationFactory();
        factory.Settings["Auth:CookieAbsoluteHours"] = "12";
        var account = await factory.CreateUserAsync(RoleNames.Direction);
        var client = factory.CreateClient(new WebApplicationFactoryClientOptions { HandleCookies = false });
        var cookie = await LoginWebAsync(client, account);

        // Le navigateur remplace son cookie par celui que le serveur renouvelle (expiration glissante).
        async Task<HttpStatusCode> UseAsync()
        {
            var response = await SendAsync(client, HttpMethod.Get, "/api/v1/auth/me", cookie);
            if (response.Headers.TryGetValues("Set-Cookie", out _))
            {
                cookie = CookieOf(response);
            }

            return response.StatusCode;
        }

        var statuses = new List<HttpStatusCode> { await UseAsync() };
        for (var hour = 0; hour < 11; hour++)
        {
            factory.Time.Advance(TimeSpan.FromHours(1));
            statuses.Add(await UseAsync());
        }

        factory.Time.Advance(TimeSpan.FromHours(2));
        var afterCeiling = await UseAsync();

        Assert.Multiple(() =>
        {
            Assert.That(statuses, Has.All.EqualTo(HttpStatusCode.OK), "Utilisée toutes les heures, la session glisse jusqu'à 11 h.");
            Assert.That(afterCeiling, Is.EqualTo(HttpStatusCode.Unauthorized), "Au-delà de 12 h depuis la connexion : reconnexion, quelle que soit l'activité.");
        });
    }

    [Test]
    public async Task A_deactivated_account_is_still_refused_with_a_valid_cookie()
    {
        // Fabrique dediee : l'horloge avance (cache de l'etat du compte), ce qui fausserait les jetons des autres tests.
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync(RoleNames.Direction);
        var client = factory.CreateClient(new WebApplicationFactoryClientOptions { HandleCookies = false });
        var cookie = await LoginWebAsync(client, account);

        await factory.SetActiveAsync(account.Id, false);
        factory.Time.Advance(TimeSpan.FromMinutes(2));
        var response = await SendAsync(client, HttpMethod.Get, "/api/v1/auth/me", cookie);

        Assert.Multiple(async () =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That((await response.JsonAsync()).GetProperty("code").GetString(), Is.EqualTo("ACCES_RETIRE"));
        });
    }

    [Test]
    public async Task A_tampered_cookie_is_refused()
    {
        var account = await _factory.CreateUserAsync(RoleNames.Direction);
        var client = NewClient();
        var cookie = await LoginWebAsync(client, account);

        var tampered = cookie[..^4] + "AAAA"; // ticket altere : refuse aussi (integrite)
        var response = await SendAsync(client, HttpMethod.Get, "/api/v1/auth/me", tampered);

        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
    }
}
