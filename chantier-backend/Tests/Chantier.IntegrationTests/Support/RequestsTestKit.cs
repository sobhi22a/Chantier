using System.Globalization;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Chantier.IntegrationTests.Support;

/// <summary>Outils des tests des demandes : corps, appels et ecritures directes en base pour mettre une demande dans un statut donne.</summary>
public static class RequestsTestKit
{
    public static string RequestsUrl(Guid siteId) => $"/api/v1/sites/{siteId}/requests";

    public static string RequestUrl(Guid siteId, Guid requestId) => $"{RequestsUrl(siteId)}/{requestId}";

    public static string FutureDate(int days = 3) => DateOnly.FromDateTime(DateTime.UtcNow).AddDays(days).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    public static Dictionary<string, object?> RequestBody(
        Guid? productId,
        decimal value = 300m,
        string? unit = "sac",
        Guid? zoneId = null,
        string? neededBy = null,
        string priority = "Normal",
        string? note = null,
        Guid? clientId = null,
        string? freeName = null,
        Action<Dictionary<string, object?>>? overrides = null)
    {
        var body = new Dictionary<string, object?>
        {
            ["clientId"] = clientId ?? Guid.NewGuid(),
            ["clientCreatedAt"] = "2026-11-25T06:58:00Z",
            ["productId"] = productId,
            ["freeProductName"] = freeName,
            ["quantity"] = unit is null ? new { value } : new { value, unit },
            ["zoneId"] = zoneId,
            ["neededBy"] = neededBy ?? FutureDate(),
            ["priority"] = priority,
            ["note"] = note,
        };
        overrides?.Invoke(body);
        return body;
    }

    public static async Task<JsonElement> CreateRequestAsync(this ApiSession session, Guid siteId, Dictionary<string, object?> body)
    {
        var response = await session.PostAsync(RequestsUrl(siteId), body);
        Assert.That((int)response.StatusCode, Is.EqualTo(201).Or.EqualTo(200), "creation de la demande : " + await response.Content.ReadAsStringAsync());
        return await response.JsonAsync();
    }

    public static async Task<Guid> NewRequestIdAsync(this ApiSession session, Guid siteId, Guid? productId, decimal value = 300m, string unit = "sac", Guid? zoneId = null)
        => (await session.CreateRequestAsync(siteId, RequestBody(productId, value, unit, zoneId))).Id();

    /// <summary>Force le statut en base (le recalcul des livraisons viendra avec B5 et B6) : sert a tester la table de transitions.</summary>
    public static async Task SetStatusAsync(this ChantierWebApplicationFactory factory, Guid requestId, RequestStatus status, bool settled = false, decimal? received = null)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        await db.MaterialRequests.Where(request => request.Id == requestId).ExecuteUpdateAsync(set => set
            .SetProperty(request => request.Status, status)
            .SetProperty(request => request.IsSettled, settled)
            .SetProperty(request => request.ReceivedQuantity, received ?? 0m));
    }

    public static async Task<List<MaterialEvent>> EventsOfAsync(this ChantierWebApplicationFactory factory, Guid requestId)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        return await db.MaterialEvents.AsNoTracking()
            .Where(materialEvent => materialEvent.SubjectId == requestId)
            .OrderBy(materialEvent => materialEvent.CreatedAt).ThenBy(materialEvent => materialEvent.RowVersion)
            .ToListAsync();
    }

    public static async Task<int> CountRequestsAsync(this ChantierWebApplicationFactory factory, Guid siteId)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        return await db.MaterialRequests.IgnoreQueryFilters([QueryFilterNames.SoftDelete]).CountAsync(request => request.SiteId == siteId);
    }

    public static IEnumerable<string> HistoryTypes(this JsonElement request)
        => request.GetProperty("history").EnumerateArray().Select(item => item.GetProperty("type").GetString()!);

    public static string Number(this JsonElement request) => request.GetProperty("number").GetString()!;

    public static string StatusOf(this JsonElement request) => request.GetProperty("status").GetString()!;

    public static DateOnly Today(this ChantierWebApplicationFactory factory) => AlgeriaDate.Today(factory.Time);
}
