using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using Chantier.Core.DTOs.Sites;
using Chantier.Core.Entities.Identity;
using Chantier.Core.Entities.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Chantier.IntegrationTests.Support;

/// <summary>Client HTTP d'un utilisateur connecte (jeton porteur) : une session de test.</summary>
public sealed class ApiSession(HttpClient client, string accessToken, TestAccount account)
{
    public TestAccount Account => account;

    public string AccessToken => accessToken;

    /// <summary>Corps JSON envoye tel quel (pour les corps volontairement malformes).</summary>
    public Task<HttpResponseMessage> PostRawAsync(string url, string json)
    {
        var request = Build(HttpMethod.Post, url, null);
        request.Content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
        return client.SendAsync(request);
    }

    private HttpRequestMessage Build(HttpMethod method, string url, object? body)
    {
        var request = new HttpRequestMessage(method, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        if (body is not null)
        {
            request.Content = JsonContent.Create(body);
        }

        return request;
    }

    public Task<HttpResponseMessage> GetAsync(string url) => client.SendAsync(Build(HttpMethod.Get, url, null));

    /// <summary>Lecture avec un en-tete de plus (revalidation <c>If-None-Match</c>).</summary>
    public Task<HttpResponseMessage> GetAsync(string url, string headerName, string headerValue)
    {
        var request = Build(HttpMethod.Get, url, null);
        request.Headers.TryAddWithoutValidation(headerName, headerValue);
        return client.SendAsync(request);
    }

    public Task<HttpResponseMessage> PostAsync(string url, object? body = null) => client.SendAsync(Build(HttpMethod.Post, url, body ?? new { }));

    public Task<HttpResponseMessage> PutAsync(string url, object? body = null) => client.SendAsync(Build(HttpMethod.Put, url, body));

    /// <summary>Corps binaire brut (envoi d'une photo : le corps est le fichier lui-meme).</summary>
    public Task<HttpResponseMessage> PutBytesAsync(string url, byte[] bytes, string contentType = "image/jpeg")
    {
        var request = Build(HttpMethod.Put, url, null);
        request.Content = new ByteArrayContent(bytes);
        request.Content.Headers.ContentType = new MediaTypeHeaderValue(contentType);
        return client.SendAsync(request);
    }

    public Task<HttpResponseMessage> DeleteAsync(string url) => client.SendAsync(Build(HttpMethod.Delete, url, null));

    /// <summary>Corps JSON brut, tel quel (valeurs que le serialiseur .NET ne produirait pas : 1e40, surrogate isole...).</summary>
    public Task<HttpResponseMessage> SendRawAsync(HttpMethod method, string url, string json)
    {
        var request = Build(method, url, null);
        request.Content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
        return client.SendAsync(request);
    }
}

public sealed record SeededSite(Guid Id, string Code);

public static class SitesTestKit
{
    public const string SiteBase = "/api/v1/sites";

    public static async Task<ApiSession> SignInAsync(this ChantierWebApplicationFactory factory, string role, bool mustChange = false)
    {
        var account = await factory.CreateUserAsync(role, mustChangePassword: mustChange);
        return await factory.SignInAsync(account);
    }

    public static async Task<ApiSession> SignInAsync(this ChantierWebApplicationFactory factory, TestAccount account)
    {
        var client = factory.CreateClient();
        var (access, _) = await client.LoginMobileAsync(account);
        return new ApiSession(client, access, account);
    }

    /// <summary>Chantier cree directement en base (code unique), avec les affectations demandees. Date d'ODS et delai : cas de reference.</summary>
    public static async Task<SeededSite> SeedSiteAsync(
        this ChantierWebApplicationFactory factory,
        string? marker = null,
        decimal? amount = 185_000_000.00m,
        string name = "École de test",
        bool archived = false,
        params Guid[] members)
    {
        _ = factory.Server;
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var code = $"T-{marker ?? Guid.NewGuid().ToString("N")[..10].ToUpperInvariant()}";
        var site = Site.Create(
            code,
            new SiteInput(name, null, SiteType.School, "Blida", "Boufarik", null, null, "Maître d'ouvrage fictif", "M-TEST-001", amount, 540, new DateOnly(2026, 3, 2)));
        if (archived)
        {
            site.Archive(SystemActorId, DateTimeOffset.UtcNow);
        }

        db.Sites.Add(site);
        foreach (var member in members)
        {
            db.SiteMembers.Add(SiteMember.Create(site.Id, member));
        }

        await db.SaveChangesAsync();
        return new SeededSite(site.Id, code);
    }

    public static async Task AssignDirectlyAsync(this ChantierWebApplicationFactory factory, Guid siteId, params Guid[] userIds)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        foreach (var userId in userIds)
        {
            db.SiteMembers.Add(SiteMember.Create(siteId, userId));
        }

        await db.SaveChangesAsync();
    }

    public static async Task<Guid> SeedZoneAsync(
        this ChantierWebApplicationFactory factory,
        Guid siteId,
        string block = "Bloc 01",
        decimal? elevation = null,
        RoomType? roomType = null,
        int? roomNumber = null)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var zone = TestDb.NewZone(siteId, TestDb.ZoneInput(block, elevation, roomType, roomNumber));
        db.Zones.Add(zone);
        await db.SaveChangesAsync();
        return zone.Id;
    }

    public static Guid SystemActorId => Chantier.Core.Abstractions.SystemActor.Id;

    /// <summary>Corps de creation d'un chantier valide ; <paramref name="overrides"/> remplace des champs.</summary>
    public static Dictionary<string, object?> SiteBody(string? code = null, Action<Dictionary<string, object?>>? overrides = null)
    {
        var body = new Dictionary<string, object?>
        {
            ["code"] = code ?? "T-" + Guid.NewGuid().ToString("N")[..10].ToUpperInvariant(),
            ["name"] = "École UV18",
            ["nameAr"] = null,
            ["type"] = "School",
            ["wilaya"] = "Blida",
            ["commune"] = "Boufarik",
            ["latitude"] = 36.575m,
            ["longitude"] = 2.912m,
            ["owner"] = "Direction des équipements publics (fictive)",
            ["contractNumber"] = "M-2026-UV18-001",
            ["contractAmount"] = 185000000.00m,
            ["delayDays"] = 540,
            ["odsDate"] = "2026-03-02",
        };
        overrides?.Invoke(body);
        return body;
    }

    public static Dictionary<string, object?> ZoneBody(string block = "Bloc 01", Action<Dictionary<string, object?>>? overrides = null)
    {
        var body = new Dictionary<string, object?> { ["block"] = block };
        overrides?.Invoke(body);
        return body;
    }

    public static async Task<JsonElement> JsonAsync(this HttpResponseMessage response) => await response.ReadJsonAsync();

    public static IEnumerable<string> Strings(this JsonElement array, string property)
        => array.EnumerateArray().Select(item => item.GetProperty(property).GetString()!);

    /// <summary>Comptage physique (filtres desactives) : rien ne doit jamais etre supprime.</summary>
    public static async Task<int> CountRowsAsync(this ChantierWebApplicationFactory factory, Guid siteId)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        return await db.Sites.IgnoreQueryFilters([QueryFilterNames.SoftDelete]).CountAsync(site => site.Id == siteId);
    }

    public static async Task SetPhoneAsync(this ChantierWebApplicationFactory factory, Guid userId, string phone)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        await db.Users.Where(user => user.Id == userId).ExecuteUpdateAsync(update => update.SetProperty(user => user.PhoneNumber, phone));
    }

    public static IEnumerable<string> AllRoles => RoleNames.All;
}
