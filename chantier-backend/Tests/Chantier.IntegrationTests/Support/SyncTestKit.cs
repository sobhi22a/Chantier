using System.Text.Json;
using Chantier.Core.Entities.Sites;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Chantier.IntegrationTests.Support;

/// <summary>Appels et lectures de la synchronisation, partages par les tests de pull et de push.</summary>
public static class SyncTestKit
{
    public const string ChangesUrl = "/api/v1/sync/changes";
    public const string PushUrl = "/api/v1/sync/push";

    public static async Task<JsonElement> PullAsync(this ApiSession session, string? since = null, Guid? siteId = null, int? limit = null)
    {
        var response = await session.PullRawAsync(since, siteId, limit);
        Assert.That((int)response.StatusCode, Is.EqualTo(200), "pull");
        return await response.JsonAsync();
    }

    public static Task<HttpResponseMessage> PullRawAsync(this ApiSession session, string? since = null, Guid? siteId = null, int? limit = null)
    {
        var query = new List<string>();
        if (since is not null)
        {
            query.Add("since=" + Uri.EscapeDataString(since));
        }

        if (siteId is { } id)
        {
            query.Add("siteId=" + id);
        }

        if (limit is { } max)
        {
            query.Add("limit=" + max);
        }

        return session.GetAsync(query.Count == 0 ? ChangesUrl : ChangesUrl + "?" + string.Join('&', query));
    }

    /// <summary>Pull jusqu'a <c>hasMore = false</c> ; renvoie toutes les lignes lues et le dernier curseur.</summary>
    public static async Task<(List<JsonElement> Changes, List<JsonElement> Deleted, string Cursor)> PullAllAsync(
        this ApiSession session, string? since = null, Guid? siteId = null, int? limit = null)
    {
        var changes = new List<JsonElement>();
        var deleted = new List<JsonElement>();
        var cursor = since;
        while (true)
        {
            var page = await session.PullAsync(cursor, siteId, limit);
            changes.AddRange(page.GetProperty("changes").EnumerateArray());
            deleted.AddRange(page.GetProperty("deleted").EnumerateArray());
            cursor = page.GetProperty("cursor").GetString();
            if (!page.GetProperty("hasMore").GetBoolean())
            {
                return (changes, deleted, cursor!);
            }
        }
    }

    public static IEnumerable<JsonElement> Of(this IEnumerable<JsonElement> rows, string entity)
        => rows.Where(row => row.GetProperty("entity").GetString() == entity);

    public static object ZoneOperation(Guid clientId, Guid? siteId, string block = "Bloc 01", Action<Dictionary<string, object?>>? payload = null, string operation = "create", string entity = "zone")
    {
        var body = new Dictionary<string, object?> { ["block"] = block };
        payload?.Invoke(body);
        return new Dictionary<string, object?>
        {
            ["clientId"] = clientId,
            ["entity"] = entity,
            ["operation"] = operation,
            ["siteId"] = siteId,
            ["baseVersion"] = null,
            ["payload"] = body,
        };
    }

    public static async Task<JsonElement> PushAsync(this ApiSession session, params object[] operations)
    {
        var response = await session.PostAsync(PushUrl, new { operations });
        Assert.That((int)response.StatusCode, Is.EqualTo(200), "push");
        return (await response.JsonAsync()).GetProperty("results");
    }

    public static string Status(this JsonElement result) => result.GetProperty("status").GetString()!;

    public static string? Code(this JsonElement result) => result.TryGetProperty("code", out var code) ? code.GetString() : null;

    /// <summary>Contexte sur une base precise (pas la base partagee), avec l'audit du systeme.</summary>
    public static ApplicationDbContext CreateContext(string connectionString)
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseSqlServer(connectionString, sql => sql.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.GetName().Name).CommandTimeout(20))
            .AddInterceptors(new AuditingInterceptor(new TestDb.FixedUser(null), TimeProvider.System))
            .Options;
        return new ApplicationDbContext(options);
    }

    public static async Task RemoveMemberAsync(this ChantierWebApplicationFactory factory, Guid siteId, Guid userId)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var member = await db.SiteMembers.SingleAsync(m => m.SiteId == siteId && m.UserId == userId);
        db.SiteMembers.Remove(member);
        await db.SaveChangesAsync();
    }

    public static async Task DeleteZoneAsync(this ChantierWebApplicationFactory factory, Guid zoneId)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        db.Zones.Remove(await db.Zones.SingleAsync(z => z.Id == zoneId));
        await db.SaveChangesAsync();
    }
}
