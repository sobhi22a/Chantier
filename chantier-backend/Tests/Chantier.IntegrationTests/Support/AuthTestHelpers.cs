using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using Chantier.Core.Entities.Identity;
using Chantier.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Chantier.IntegrationTests.Support;

public sealed record TestAccount(Guid Id, string UserName, string Password, string FullName, string Phone, string Role);

public static class AuthTestHelpers
{
    public const string DefaultPassword = "Terrain2026";

    /// <summary>Compte fictif unique (identifiant, nom et telephone fictifs : jamais de donnee reelle).</summary>
    public static async Task<TestAccount> CreateUserAsync(
        this ChantierWebApplicationFactory factory,
        string role = RoleNames.ChefChantier,
        string password = DefaultPassword,
        bool mustChangePassword = false,
        bool isActive = true)
    {
        _ = factory.Server;
        await using var scope = factory.Services.CreateAsyncScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<AppUser>>();

        var suffix = Guid.NewGuid().ToString("N")[..8];
        var userName = $"fictif.{suffix}";
        var fullName = $"Nom Fictif {suffix}";
        var phone = $"0550 99 {Random.Shared.Next(10, 99)} {Random.Shared.Next(10, 99)}";
        var user = AppUser.Create(userName, fullName, phoneNumber: phone, mustChangePassword: mustChangePassword);
        user.IsActive = isActive;

        var created = await users.CreateAsync(user, password);
        if (!created.Succeeded)
        {
            throw new InvalidOperationException("Création du compte de test refusée : " + string.Join(',', created.Errors.Select(e => e.Code)));
        }

        await users.AddToRoleAsync(user, role);
        return new TestAccount(user.Id, userName, password, fullName, phone, role);
    }

    public static async Task SetActiveAsync(this ChantierWebApplicationFactory factory, Guid userId, bool active)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        await db.Users.Where(u => u.Id == userId).ExecuteUpdateAsync(s => s.SetProperty(u => u.IsActive, active));
    }

    public static Task<HttpResponseMessage> LoginAsync(this HttpClient client, string userName, string password, bool mobile)
        => client.PostAsJsonAsync("/api/v1/auth/login", new { userName, password, isAppMobile = mobile });

    public static async Task<JsonElement> ReadJsonAsync(this HttpResponseMessage response)
    {
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    /// <summary>Connexion mobile : renvoie (jeton d'acces, jeton de rafraichissement).</summary>
    public static async Task<(string Access, string Refresh)> LoginMobileAsync(this HttpClient client, TestAccount account)
    {
        var response = await client.LoginAsync(account.UserName, account.Password, mobile: true);
        response.EnsureSuccessStatusCode();
        var json = await response.ReadJsonAsync();
        return (json.GetProperty("accessToken").GetString()!, json.GetProperty("refreshToken").GetString()!);
    }

    public static HttpRequestMessage Get(string url, string? bearer = null)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, url);
        if (bearer is not null)
        {
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearer);
        }

        return request;
    }

    public static HttpRequestMessage Json(HttpMethod method, string url, object body, string? bearer = null)
    {
        var request = new HttpRequestMessage(method, url) { Content = JsonContent.Create(body) };
        if (bearer is not null)
        {
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearer);
        }

        return request;
    }

    /// <summary>Corps d'erreur sans le traceId (propre a chaque requete), pour comparer deux reponses.</summary>
    public static string WithoutTraceId(JsonElement problem)
        => string.Join('|', problem.EnumerateObject().Where(p => p.Name != "traceId").Select(p => $"{p.Name}={p.Value.GetRawText()}"));
}
