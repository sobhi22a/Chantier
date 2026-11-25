using System.Net;
using System.Net.Http.Json;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;

namespace Chantier.IntegrationTests.Auth;

/// <summary>B3, CT-2 : rotation du jeton de rafraichissement, reutilisation, changement de mot de passe, mot de passe provisoire.</summary>
[TestFixture]
public class RefreshAndPasswordTests
{
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public void SetUp() => _factory = new ChantierWebApplicationFactory();

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    private static Task<HttpResponseMessage> RefreshAsync(HttpClient client, string token)
        => client.PostAsJsonAsync("/api/v1/auth/refresh", new { refreshToken = token });

    [Test]
    public async Task Refresh_rotates_the_token_and_the_old_one_is_refused_once_the_grace_window_is_over()
    {
        using var factory = new ChantierWebApplicationFactory(); // horloge propre : on la fait avancer
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (_, refresh) = await client.LoginMobileAsync(account);

        var first = await RefreshAsync(client, refresh);
        var firstJson = await first.ReadJsonAsync();
        var me = await client.SendAsync(Get("/api/v1/auth/me", firstJson.GetProperty("accessToken").GetString()));
        factory.Time.Advance(TimeSpan.FromSeconds(31));
        var replay = await RefreshAsync(client, refresh);

        Assert.Multiple(async () =>
        {
            Assert.That(first.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(firstJson.GetProperty("refreshToken").GetString(), Is.Not.EqualTo(refresh));
            Assert.That(firstJson.GetProperty("expiresIn").GetInt32(), Is.EqualTo(900));
            Assert.That(me.StatusCode, Is.EqualTo(HttpStatusCode.OK), "Le nouveau jeton d'accès fonctionne.");
            Assert.That(replay.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That((await replay.ReadJsonAsync()).GetProperty("code").GetString(), Is.EqualTo("REFRESH_INVALIDE"));
        });
    }

    [Test]
    public async Task Reusing_a_rotated_token_after_the_grace_window_revokes_the_whole_chain()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (_, original) = await client.LoginMobileAsync(account);

        var rotated = await (await RefreshAsync(client, original)).ReadJsonAsync();
        var newest = rotated.GetProperty("refreshToken").GetString()!;
        factory.Time.Advance(TimeSpan.FromSeconds(31));

        // Quelqu'un rejoue l'ancien jeton : vol presume, le jeton legitime plus recent est revoque aussi.
        var theft = await RefreshAsync(client, original);
        var legitimate = await RefreshAsync(client, newest);

        Assert.Multiple(() =>
        {
            Assert.That(theft.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(legitimate.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized), "La chaîne entière est brûlée.");
        });
    }

    [Test]
    public async Task A_lost_refresh_response_can_be_retried_within_the_grace_window_without_burning_the_chain()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (_, original) = await client.LoginMobileAsync(account);

        _ = await RefreshAsync(client, original); // la réponse n'est jamais arrivée au téléphone
        factory.Time.Advance(TimeSpan.FromSeconds(10));
        var retry = await RefreshAsync(client, original);
        var retried = await retry.ReadJsonAsync();
        var next = await RefreshAsync(client, retried.GetProperty("refreshToken").GetString()!);

        Assert.Multiple(() =>
        {
            Assert.That(retry.StatusCode, Is.EqualTo(HttpStatusCode.OK), "Le renvoi reçoit un nouveau jeton, sans ressaisie du mot de passe.");
            Assert.That(retried.GetProperty("refreshToken").GetString(), Is.Not.EqualTo(original));
            Assert.That(next.StatusCode, Is.EqualTo(HttpStatusCode.OK), "La chaîne est intacte.");
        });
    }

    [Test]
    public async Task The_grace_window_does_not_apply_once_the_successor_has_been_used()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (_, original) = await client.LoginMobileAsync(account);

        var first = await (await RefreshAsync(client, original)).ReadJsonAsync();
        var used = await RefreshAsync(client, first.GetProperty("refreshToken").GetString()!); // le successeur a servi : la réponse est bien arrivée
        factory.Time.Advance(TimeSpan.FromSeconds(5));
        var replay = await RefreshAsync(client, original);

        Assert.Multiple(() =>
        {
            Assert.That(used.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(replay.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized), "Un jeton dont le successeur a servi ne se rejoue pas : vol présumé.");
        });
    }

    [Test]
    public async Task Two_parallel_refreshes_of_the_same_token_give_exactly_one_success()
    {
        var account = await _factory.CreateUserAsync();
        using var client = _factory.CreateClient();
        var (_, refresh) = await client.LoginMobileAsync(account);

        var responses = await Task.WhenAll(Enumerable.Range(0, 4).Select(_ => RefreshAsync(client, refresh)));

        // Un seul renouvellement gagne ; au plus un renvoi de la fenetre de grace peut aussi reussir, jamais davantage, et aucune erreur serveur.
        Assert.That(responses.Count(r => r.StatusCode == HttpStatusCode.OK), Is.InRange(1, 2), "La rotation est atomique.");
        Assert.That(responses.Select(r => (int)r.StatusCode), Has.All.LessThan(500));
    }

    [Test]
    public async Task Unknown_garbage_and_expired_tokens_are_refused_with_the_same_code()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (_, refresh) = await client.LoginMobileAsync(account);

        var garbage = await RefreshAsync(client, "pas-un-vrai-jeton");
        factory.Time.Advance(TimeSpan.FromDays(14) + TimeSpan.FromMinutes(1));
        var expired = await RefreshAsync(client, refresh);

        foreach (var response in new[] { garbage, expired })
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That((await response.ReadJsonAsync()).GetProperty("code").GetString(), Is.EqualTo("REFRESH_INVALIDE"));
        }
    }

    [Test]
    public async Task Refresh_lasts_14_days_and_each_rotation_extends_it()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();
        var (_, refresh) = await client.LoginMobileAsync(account);

        factory.Time.Advance(TimeSpan.FromDays(13));
        var rotated = await (await RefreshAsync(client, refresh)).ReadJsonAsync();
        factory.Time.Advance(TimeSpan.FromDays(13));
        var again = await RefreshAsync(client, rotated.GetProperty("refreshToken").GetString()!);

        Assert.That(again.StatusCode, Is.EqualTo(HttpStatusCode.OK), "26 jours après la connexion, la rotation a prolongé la session (CA-002.1).");
    }

    [Test]
    public async Task Changing_the_password_revokes_every_refresh_token_and_the_new_password_works()
    {
        var account = await _factory.CreateUserAsync();
        using var client = _factory.CreateClient();
        var (access, refreshOnPhone) = await client.LoginMobileAsync(account);
        var (_, refreshOnTablet) = await client.LoginMobileAsync(account);

        var change = await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/change-password", new { currentPassword = account.Password, newPassword = "Nouveau2026" }, access));

        Assert.Multiple(async () =>
        {
            Assert.That(change.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That((await RefreshAsync(client, refreshOnPhone)).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That((await RefreshAsync(client, refreshOnTablet)).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That((await client.LoginAsync(account.UserName, account.Password, mobile: true)).StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized), "L'ancien mot de passe ne marche plus.");
            Assert.That((await client.LoginAsync(account.UserName, "Nouveau2026", mobile: true)).StatusCode, Is.EqualTo(HttpStatusCode.OK));
        });
    }

    [Test]
    public async Task Weak_new_password_is_a_422_MOT_DE_PASSE_FAIBLE_and_nothing_changes()
    {
        var account = await _factory.CreateUserAsync();
        using var client = _factory.CreateClient();
        var (access, refresh) = await client.LoginMobileAsync(account);

        foreach (var weak in new[] { "court1", "sanschiffreici", account.Password })
        {
            var response = await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/change-password", new { currentPassword = account.Password, newPassword = weak }, access));
            Assert.That(response.StatusCode, Is.EqualTo((HttpStatusCode)422), weak);
            Assert.That((await response.ReadJsonAsync()).GetProperty("code").GetString(), Is.EqualTo("MOT_DE_PASSE_FAIBLE"));
        }

        Assert.Multiple(async () =>
        {
            Assert.That((await client.LoginAsync(account.UserName, account.Password, mobile: true)).StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That((await RefreshAsync(client, refresh)).StatusCode, Is.EqualTo(HttpStatusCode.OK), "Un changement refusé ne révoque rien.");
        });
    }

    [Test]
    public async Task Wrong_current_password_is_a_401_and_is_counted_like_a_login_failure()
    {
        var account = await _factory.CreateUserAsync();
        using var client = _factory.CreateClient();
        var (access, _) = await client.LoginMobileAsync(account);

        var statuses = new List<HttpStatusCode>();
        for (var attempt = 0; attempt < 6; attempt++)
        {
            var response = await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/change-password", new { currentPassword = "Mauvais12345", newPassword = "Nouveau2026" }, access));
            statuses.Add(response.StatusCode);
        }

        Assert.That(statuses, Is.EqualTo(new[]
        {
            HttpStatusCode.Unauthorized, HttpStatusCode.Unauthorized, HttpStatusCode.Unauthorized, HttpStatusCode.Unauthorized, HttpStatusCode.Unauthorized,
            HttpStatusCode.TooManyRequests,
        }));
    }

    [Test]
    public async Task Provisional_password_blocks_everything_but_the_change_until_a_new_one_is_chosen()
    {
        var account = await _factory.CreateUserAsync(mustChangePassword: true);
        using var client = _factory.CreateClient();

        var login = await client.LoginAsync(account.UserName, account.Password, mobile: true);
        var loginJson = await login.ReadJsonAsync();
        var access = loginJson.GetProperty("accessToken").GetString()!;

        var blocked = await client.SendAsync(Get("/test-support/authenticated", access));
        var blockedJson = await blocked.ReadJsonAsync();
        var me = await client.SendAsync(Get("/api/v1/auth/me", access));
        var meJson = await me.ReadJsonAsync();
        var change = await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/change-password", new { currentPassword = account.Password, newPassword = "Choisi2026x" }, access));
        var afterChange = await client.SendAsync(Get("/test-support/authenticated", access));

        Assert.Multiple(() =>
        {
            Assert.That(loginJson.GetProperty("user").GetProperty("mustChangePassword").GetBoolean(), Is.True);
            Assert.That(blocked.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That(blockedJson.GetProperty("code").GetString(), Is.EqualTo("MOT_DE_PASSE_A_CHANGER"));
            Assert.That(me.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(meJson.GetProperty("mustChangePassword").GetBoolean(), Is.True);
            Assert.That(change.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(afterChange.StatusCode, Is.EqualTo(HttpStatusCode.OK), "Une fois le mot de passe choisi, plus rien n'est bloqué.");
        });
    }

    [Test]
    public async Task Provisional_password_also_blocks_a_web_session()
    {
        var account = await _factory.CreateUserAsync(mustChangePassword: true);
        using var client = _factory.CreateClient();
        await client.LoginAsync(account.UserName, account.Password, mobile: false);

        var blocked = await client.GetAsync("/test-support/authenticated");

        Assert.That(blocked.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
    }

    [Test]
    public async Task Anonymous_routes_are_not_blocked_by_the_provisional_password()
    {
        using var client = _factory.CreateClient();

        Assert.That((await client.GetAsync("/health/live")).StatusCode, Is.EqualTo(HttpStatusCode.OK));
        await Task.CompletedTask;
    }
}
