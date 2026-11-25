using System.Net;
using System.Net.Http.Json;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Identity;
using Chantier.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;

namespace Chantier.IntegrationTests.Auth;

/// <summary>B3, CT-1 : connexion web (cookie) et mobile (jetons), reponse unique, blocage par identifiant, limitation de debit.</summary>
[TestFixture]
public class LoginTests
{
    private ChantierWebApplicationFactory _factory = null!;

    [OneTimeSetUp]
    public void SetUp() => _factory = new ChantierWebApplicationFactory();

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    [Test]
    public async Task Web_login_sets_an_httponly_samesite_cookie_and_returns_no_token()
    {
        var account = await _factory.CreateUserAsync(RoleNames.ChefChantier);
        using var client = _factory.CreateClient();

        var response = await client.LoginAsync(account.UserName, account.Password, mobile: false);
        var json = await response.ReadJsonAsync();
        var cookie = response.Headers.GetValues("Set-Cookie").Single(value => value.StartsWith(".Chantier.Identity.Application=", StringComparison.Ordinal));

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(cookie, Does.Contain("httponly").IgnoreCase);
            Assert.That(cookie, Does.Contain("samesite=lax").IgnoreCase);
            Assert.That(json.TryGetProperty("accessToken", out _), Is.False);
            Assert.That(json.TryGetProperty("refreshToken", out _), Is.False);
            Assert.That(json.GetProperty("user").GetProperty("role").GetString(), Is.EqualTo("ChefChantier"));
            Assert.That(json.GetProperty("user").GetProperty("mustChangePassword").GetBoolean(), Is.False);
            Assert.That(json.GetProperty("user").TryGetProperty("phoneNumber", out _), Is.False, "Jamais de téléphone à la connexion.");
        });

        // Le cookie ouvre bien la session.
        var me = await client.GetAsync("/api/v1/auth/me");
        Assert.That(me.StatusCode, Is.EqualTo(HttpStatusCode.OK));
    }

    [Test]
    public async Task Mobile_login_returns_tokens_and_the_access_token_opens_the_session()
    {
        var account = await _factory.CreateUserAsync(RoleNames.ChefEquipe);
        using var client = _factory.CreateClient();

        var response = await client.LoginAsync(account.UserName, account.Password, mobile: true);
        var json = await response.ReadJsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(response.Headers.Contains("Set-Cookie"), Is.False, "Pas de cookie pour le mobile.");
            Assert.That(json.GetProperty("expiresIn").GetInt32(), Is.EqualTo(900));
            Assert.That(json.GetProperty("accessToken").GetString(), Is.Not.Empty);
            Assert.That(json.GetProperty("refreshToken").GetString(), Has.Length.GreaterThan(20));
        });

        var me = await client.SendAsync(Get("/api/v1/auth/me", json.GetProperty("accessToken").GetString()));
        Assert.That(me.StatusCode, Is.EqualTo(HttpStatusCode.OK));
    }

    [Test]
    public async Task Access_token_carries_only_an_anonymous_id_and_the_role()
    {
        var account = await _factory.CreateUserAsync(RoleNames.ChefChantier);
        using var client = _factory.CreateClient();
        var (access, _) = await client.LoginMobileAsync(account);

        var payload = System.Text.Encoding.UTF8.GetString(Microsoft.IdentityModel.Tokens.Base64UrlEncoder.DecodeBytes(access.Split('.')[1]));

        Assert.Multiple(() =>
        {
            Assert.That(payload, Does.Contain(account.Id.ToString()));
            Assert.That(payload, Does.Not.Contain(account.UserName));
            Assert.That(payload, Does.Not.Contain(account.FullName));
            Assert.That(payload, Does.Not.Contain(account.Phone));
        });
    }

    [Test]
    public async Task Unknown_user_wrong_password_and_deactivated_account_get_the_same_401()
    {
        var active = await _factory.CreateUserAsync();
        var deactivated = await _factory.CreateUserAsync(isActive: false);
        using var client = _factory.CreateClient();

        var unknown = await client.LoginAsync("personne." + Guid.NewGuid().ToString("N")[..6], "Terrain2026", mobile: true);
        var wrongPassword = await client.LoginAsync(active.UserName, "MauvaisMotDePasse1", mobile: true);
        var inactive = await client.LoginAsync(deactivated.UserName, deactivated.Password, mobile: true);

        var bodies = new List<string>();
        foreach (var response in new[] { unknown, wrongPassword, inactive })
        {
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            var json = await response.ReadJsonAsync();
            Assert.That(json.GetProperty("code").GetString(), Is.EqualTo("IDENTIFIANTS_INVALIDES"));
            bodies.Add(WithoutTraceId(json));
        }

        Assert.That(bodies.Distinct().Count(), Is.EqualTo(1), "Les trois réponses doivent être strictement identiques.");
    }

    [Test]
    public async Task Five_failures_block_the_identifier_even_with_the_right_password()
    {
        var account = await _factory.CreateUserAsync();
        using var client = _factory.CreateClient();

        for (var attempt = 0; attempt < 5; attempt++)
        {
            var failure = await client.LoginAsync(account.UserName, "MauvaisMotDePasse1", mobile: true);
            Assert.That(failure.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized), $"essai {attempt + 1}");
        }

        var blocked = await client.LoginAsync(account.UserName, account.Password, mobile: true);
        var json = await blocked.ReadJsonAsync();

        Assert.Multiple(() =>
        {
            Assert.That(blocked.StatusCode, Is.EqualTo(HttpStatusCode.TooManyRequests));
            Assert.That(json.GetProperty("code").GetString(), Is.EqualTo("TROP_D_ESSAIS"));
            Assert.That(int.Parse(blocked.Headers.GetValues("Retry-After").Single()), Is.InRange(1, 15 * 60));
        });
    }

    [Test]
    public async Task Five_failures_on_an_unknown_identifier_block_it_the_same_way()
    {
        using var client = _factory.CreateClient();
        var unknown = "inconnu." + Guid.NewGuid().ToString("N")[..8];

        for (var attempt = 0; attempt < 5; attempt++)
        {
            await client.LoginAsync(unknown, "Terrain2026", mobile: true);
        }

        var blocked = await client.LoginAsync(unknown, "Terrain2026", mobile: true);

        Assert.That(blocked.StatusCode, Is.EqualTo(HttpStatusCode.TooManyRequests), "Le blocage ne révèle pas si l'identifiant existe.");
    }

    [Test]
    public async Task Block_is_lifted_after_the_window_and_a_success_resets_the_counter()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();

        for (var attempt = 0; attempt < 5; attempt++)
        {
            await client.LoginAsync(account.UserName, "MauvaisMotDePasse1", mobile: true);
        }

        Assert.That((await client.LoginAsync(account.UserName, account.Password, mobile: true)).StatusCode, Is.EqualTo(HttpStatusCode.TooManyRequests));

        factory.Time.Advance(TimeSpan.FromMinutes(15) + TimeSpan.FromSeconds(1));
        Assert.That((await client.LoginAsync(account.UserName, account.Password, mobile: true)).StatusCode, Is.EqualTo(HttpStatusCode.OK));

        // Succes : compteur remis a zero, quatre nouveaux echecs ne bloquent pas.
        for (var attempt = 0; attempt < 4; attempt++)
        {
            await client.LoginAsync(account.UserName, "MauvaisMotDePasse1", mobile: true);
        }

        Assert.That((await client.LoginAsync(account.UserName, account.Password, mobile: true)).StatusCode, Is.EqualTo(HttpStatusCode.OK));
    }

    [Test]
    public async Task Identifier_is_matched_case_insensitively_for_the_block()
    {
        var account = await _factory.CreateUserAsync();
        using var client = _factory.CreateClient();

        for (var attempt = 0; attempt < 5; attempt++)
        {
            await client.LoginAsync(attempt % 2 == 0 ? account.UserName.ToUpperInvariant() : account.UserName, "MauvaisMotDePasse1", mobile: true);
        }

        Assert.That((await client.LoginAsync(account.UserName, account.Password, mobile: true)).StatusCode, Is.EqualTo(HttpStatusCode.TooManyRequests));
    }

    [Test]
    public async Task Auth_rate_limit_is_per_address_and_identifier_not_per_address_only()
    {
        using var factory = new ChantierWebApplicationFactory();
        factory.Settings["RateLimiting:Auth:PermitLimit"] = "3";
        var other = await factory.CreateUserAsync();
        using var client = factory.CreateClient();

        // Meme adresse, meme identifiant : le 4e appel est limite (429 TROP_DE_REQUETES), avec Retry-After.
        HttpResponseMessage last = null!;
        for (var attempt = 0; attempt < 4; attempt++)
        {
            last = await client.LoginAsync("meme.identifiant", "Terrain2026", mobile: true);
        }

        var json = await last.ReadJsonAsync();
        Assert.Multiple(() =>
        {
            Assert.That(last.StatusCode, Is.EqualTo(HttpStatusCode.TooManyRequests));
            Assert.That(json.GetProperty("code").GetString(), Is.EqualTo("TROP_DE_REQUETES"));
            Assert.That(last.Headers.Contains("Retry-After"), Is.True);
        });

        // Meme adresse, autre identifiant : une equipe derriere la meme adresse n'est pas bloquee.
        var different = await client.LoginAsync(other.UserName, other.Password, mobile: true);
        Assert.That(different.StatusCode, Is.EqualTo(HttpStatusCode.OK));
    }

    [Test]
    public async Task Missing_fields_give_400_and_never_a_500()
    {
        using var client = _factory.CreateClient();

        var empty = await client.PostAsJsonAsync("/api/v1/auth/login", new { });
        var noBody = await client.PostAsync("/api/v1/auth/login", null);
        var tooLong = await client.LoginAsync(new string('x', 5000), "Terrain2026", mobile: false);

        Assert.Multiple(() =>
        {
            Assert.That(empty.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(noBody.StatusCode, Is.AnyOf(HttpStatusCode.BadRequest, HttpStatusCode.UnsupportedMediaType));
            Assert.That(tooLong.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    [Test]
    public async Task Me_lists_the_permissions_of_the_role_and_returns_the_phone_to_its_owner_only()
    {
        var chef = await _factory.CreateUserAsync(RoleNames.ChefChantier);
        var admin = await _factory.CreateUserAsync(RoleNames.Admin);
        using var client = _factory.CreateClient();
        var (chefToken, _) = await client.LoginMobileAsync(chef);
        var (adminToken, _) = await client.LoginMobileAsync(admin);

        var chefMe = await (await client.SendAsync(Get("/api/v1/auth/me", chefToken))).ReadJsonAsync();
        var adminMe = await (await client.SendAsync(Get("/api/v1/auth/me", adminToken))).ReadJsonAsync();

        var chefPermissions = chefMe.GetProperty("permissions").EnumerateArray().Select(p => p.GetString()!).ToList();
        Assert.Multiple(() =>
        {
            Assert.That(chefPermissions, Is.EquivalentTo(RolePermissionMatrix.For(RoleNames.ChefChantier)));
            Assert.That(chefMe.GetProperty("phoneNumber").GetString(), Is.EqualTo(chef.Phone), "Le titulaire voit son téléphone.");
            Assert.That(chefMe.GetProperty("id").GetGuid(), Is.EqualTo(chef.Id));
            Assert.That(chefMe.GetProperty("permissionsVersion").GetString(), Has.Length.EqualTo(8));
            Assert.That(chefMe.GetProperty("permissionsVersion").GetString(), Is.Not.EqualTo(adminMe.GetProperty("permissionsVersion").GetString()));
            Assert.That(adminMe.GetProperty("phoneNumber").GetString(), Is.EqualTo(admin.Phone));
            Assert.That(chefMe.GetRawText(), Does.Not.Contain(admin.Phone), "Aucun téléphone d'un autre compte.");
        });
    }

    [Test]
    public async Task Language_can_be_changed_and_is_validated()
    {
        var account = await _factory.CreateUserAsync();
        using var client = _factory.CreateClient();
        var (token, _) = await client.LoginMobileAsync(account);

        var ok = await client.SendAsync(Json(HttpMethod.Put, "/api/v1/auth/me/language", new { language = "ar" }, token));
        var me = await (await client.SendAsync(Get("/api/v1/auth/me", token))).ReadJsonAsync();
        var bad = await client.SendAsync(Json(HttpMethod.Put, "/api/v1/auth/me/language", new { language = "zz" }, token));
        var tooLong = await client.SendAsync(Json(HttpMethod.Put, "/api/v1/auth/me/language", new { language = "francais" }, token));

        Assert.Multiple(() =>
        {
            Assert.That(ok.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(me.GetProperty("language").GetString(), Is.EqualTo("ar"));
            Assert.That(bad.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
            Assert.That(tooLong.StatusCode, Is.EqualTo(HttpStatusCode.BadRequest));
        });
    }

    [Test]
    public async Task Endpoints_require_authentication_and_a_forged_token_is_refused()
    {
        using var client = _factory.CreateClient();
        var forged = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDEiLCJyb2xlIjoiQWRtaW4ifQ.AAAA";

        var anonymous = await client.GetAsync("/api/v1/auth/me");
        var withForged = await client.SendAsync(Get("/api/v1/auth/me", forged));
        var anonymousChange = await client.PostAsJsonAsync("/api/v1/auth/change-password", new { currentPassword = "a", newPassword = "b" });

        Assert.Multiple(() =>
        {
            Assert.That(anonymous.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(withForged.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
            Assert.That(anonymousChange.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task Permission_attribute_allows_the_role_and_refuses_the_others_with_a_403()
    {
        var chef = await _factory.CreateUserAsync(RoleNames.ChefChantier);
        using var client = _factory.CreateClient();
        var (token, _) = await client.LoginMobileAsync(chef);

        var allowed = await client.SendAsync(Get("/test-support/needs-zones-create", token));
        var refused = await client.SendAsync(Get("/test-support/needs-sites-create", token));
        var anonymous = await client.GetAsync("/test-support/needs-zones-create");

        Assert.Multiple(async () =>
        {
            Assert.That(allowed.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(refused.StatusCode, Is.EqualTo(HttpStatusCode.Forbidden));
            Assert.That((await refused.ReadJsonAsync()).GetProperty("code").GetString(), Is.EqualTo("INTERDIT"));
            Assert.That(anonymous.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task Logout_clears_the_cookie_and_revokes_the_refresh_token()
    {
        var account = await _factory.CreateUserAsync();
        using var client = _factory.CreateClient();
        var (access, refresh) = await client.LoginMobileAsync(account);

        var logout = await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/logout", new { refreshToken = refresh }, access));
        var refreshed = await client.PostAsJsonAsync("/api/v1/auth/refresh", new { refreshToken = refresh });

        Assert.Multiple(() =>
        {
            Assert.That(logout.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(refreshed.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task Web_cookie_session_ends_on_logout()
    {
        var account = await _factory.CreateUserAsync();
        using var client = _factory.CreateClient();
        await client.LoginAsync(account.UserName, account.Password, mobile: false);

        var logout = await client.PostAsync("/api/v1/auth/logout", null);
        var me = await client.GetAsync("/api/v1/auth/me");

        Assert.Multiple(() =>
        {
            Assert.That(logout.StatusCode, Is.EqualTo(HttpStatusCode.NoContent));
            Assert.That(me.StatusCode, Is.EqualTo(HttpStatusCode.Unauthorized));
        });
    }

    [Test]
    public async Task Data_protection_keys_are_persisted_to_the_configured_directory()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync();
        using var client = factory.CreateClient();

        await client.LoginAsync(account.UserName, account.Password, mobile: false);

        var directory = factory.Settings["Storage:DataProtectionKeys"]!;
        Assert.That(Directory.EnumerateFiles(directory, "key-*.xml"), Is.Not.Empty, "Sans clés persistées, les sessions meurent au redémarrage.");
    }

    [Test]
    public void Cookie_is_secure_outside_development_and_lasts_eight_sliding_hours()
    {
        foreach (var (environment, expected) in new[] { ("Production", Microsoft.AspNetCore.Http.CookieSecurePolicy.Always), ("Development", Microsoft.AspNetCore.Http.CookieSecurePolicy.SameAsRequest) })
        {
            using var factory = new ChantierWebApplicationFactory { EnvironmentName = environment };
            _ = factory.Server;
            var options = factory.Services
                .GetRequiredService<Microsoft.Extensions.Options.IOptionsMonitor<Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationOptions>>()
                .Get(Microsoft.AspNetCore.Identity.IdentityConstants.ApplicationScheme);

            Assert.Multiple(() =>
            {
                Assert.That(options.Cookie.SecurePolicy, Is.EqualTo(expected), environment);
                Assert.That(options.Cookie.HttpOnly, Is.True);
                Assert.That(options.Cookie.SameSite, Is.EqualTo(Microsoft.AspNetCore.Http.SameSiteMode.Lax));
                Assert.That(options.ExpireTimeSpan, Is.EqualTo(TimeSpan.FromHours(8)));
                Assert.That(options.SlidingExpiration, Is.True);
            });
        }
    }
}
