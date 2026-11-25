using System.Net;
using System.Net.Http.Json;
using Chantier.Core.Entities.Identity;
using Chantier.IntegrationTests.Support;
using static Chantier.IntegrationTests.Support.AuthTestHelpers;

namespace Chantier.IntegrationTests.Auth;

/// <summary>B3, CT-14 : aucun nom, identifiant, telephone, mot de passe ni jeton dans les journaux du serveur (CA-017.1).</summary>
[TestFixture]
public class NoPersonalDataInLogsTests
{
    [Test]
    public async Task A_full_journey_leaves_no_personal_data_in_the_server_logs()
    {
        using var factory = new ChantierWebApplicationFactory();
        var account = await factory.CreateUserAsync(RoleNames.ChefChantier);
        var inactive = await factory.CreateUserAsync(isActive: false);
        using var client = factory.CreateClient();

        // Connexions reussies (web et mobile), echouees (mot de passe faux, identifiant inconnu, compte desactive).
        await client.LoginAsync(account.UserName, account.Password, mobile: false);
        var (access, refresh) = await client.LoginMobileAsync(account);
        await client.LoginAsync(account.UserName, "MauvaisMotDePasse1", mobile: true);
        await client.LoginAsync("inconnu.secret.nom", "MotDePasseSecret9", mobile: true);
        await client.LoginAsync(inactive.UserName, inactive.Password, mobile: true);

        // Profil, langue, rotation, mauvais jeton, erreur volontaire, validation, route interdite.
        await client.SendAsync(Get("/api/v1/auth/me", access));
        await client.SendAsync(Json(HttpMethod.Put, "/api/v1/auth/me/language", new { language = "ar" }, access));
        var rotated = await (await client.PostAsJsonAsync("/api/v1/auth/refresh", new { refreshToken = refresh })).ReadJsonAsync();
        await client.PostAsJsonAsync("/api/v1/auth/refresh", new { refreshToken = refresh });
        await client.SendAsync(Get("/api/v1/auth/me", "jeton.invalide.secret"));
        await client.GetAsync("/test-support/boom");
        await client.SendAsync(Get("/test-support/needs-sites-create", access));
        await client.PostAsJsonAsync("/api/v1/auth/login", new { userName = "x", password = (string?)null });

        // Changement de mot de passe (ancien incorrect, faible, puis valide) et deconnexion.
        await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/change-password", new { currentPassword = "Mauvais12345", newPassword = "NouveauSecret2026" }, access));
        await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/change-password", new { currentPassword = account.Password, newPassword = "faible" }, access));
        await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/change-password", new { currentPassword = account.Password, newPassword = "NouveauSecret2026" }, access));
        await client.SendAsync(Json(HttpMethod.Post, "/api/v1/auth/logout", new { refreshToken = rotated.GetProperty("refreshToken").GetString() }, access));

        var logs = factory.Logs.AllText;
        var forbidden = new Dictionary<string, string>
        {
            ["identifiant"] = account.UserName,
            ["identifiant en majuscules"] = account.UserName.ToUpperInvariant(),
            ["nom complet"] = account.FullName,
            ["téléphone"] = account.Phone,
            ["mot de passe"] = account.Password,
            ["nouveau mot de passe"] = "NouveauSecret2026",
            ["mot de passe d'un inconnu"] = "MotDePasseSecret9",
            ["identifiant inconnu"] = "inconnu.secret.nom",
            ["identifiant désactivé"] = inactive.UserName,
            ["nom désactivé"] = inactive.FullName,
            ["téléphone désactivé"] = inactive.Phone,
            ["jeton d'accès"] = access,
            ["jeton de rafraîchissement"] = refresh,
            ["jeton invalide"] = "jeton.invalide.secret",
        };

        Assert.That(factory.Logs.Entries, Is.Not.Empty, "Les journaux doivent exister pour que la recherche ait un sens.");
        foreach (var (label, value) in forbidden)
        {
            Assert.That(logs, Does.Not.Contain(value), $"Donnée interdite dans les journaux : {label}");
        }

        // L'utilisateur n'est designe que par son GUID anonyme.
        Assert.That(logs, Does.Contain(account.Id.ToString()));
    }

    [Test]
    public async Task Rejected_requests_are_logged_without_the_rejected_value()
    {
        using var factory = new ChantierWebApplicationFactory();
        using var client = factory.CreateClient();

        await client.PostAsync("/test-support/echo", new StringContent("""{ "name": "valeur.sensible.9", "date": "../03/2026" }""", System.Text.Encoding.UTF8, "application/json"));

        Assert.That(factory.Logs.AllText, Does.Not.Contain("valeur.sensible.9"));
        Assert.That((await client.GetAsync("/health/live")).StatusCode, Is.EqualTo(HttpStatusCode.OK));
    }
}
