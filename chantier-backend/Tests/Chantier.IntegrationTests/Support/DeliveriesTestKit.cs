using System.Globalization;
using System.Security.Cryptography;
using System.Text.Json;
using Chantier.Core.Entities.Materials;
using Chantier.Core.Materials;
using Chantier.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Chantier.IntegrationTests.Support;

/// <summary>Outils des tests des commandes, livraisons et photos : corps, appels, JPEG fictifs et lectures directes en base.</summary>
public static class DeliveriesTestKit
{
    public static string OrderUrl(Guid siteId, Guid requestId) => $"{RequestsTestKit.RequestUrl(siteId, requestId)}/order";

    public static string DeliveriesUrl(Guid siteId) => $"/api/v1/sites/{siteId}/deliveries";

    public static string DeliveryUrl(Guid siteId, Guid deliveryId) => $"{DeliveriesUrl(siteId)}/{deliveryId}";

    public static string PhotosUrl(Guid siteId, Guid deliveryId) => $"{DeliveryUrl(siteId, deliveryId)}/photos";

    public static string PhotoContentUrl(Guid siteId, Guid photoId) => $"/api/v1/sites/{siteId}/photos/{photoId}/content";

    public static string FollowUpUrl(Guid siteId) => $"/api/v1/sites/{siteId}/follow-up";

    public static string Iso(DateOnly date) => date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    public static Dictionary<string, object?> OrderBody(
        Guid supplierId,
        decimal? unitPrice = 780m,
        DateOnly? orderDate = null,
        DateOnly? expected = null,
        Guid? clientId = null,
        string? purchaseOrder = "BC-2026-044",
        Action<Dictionary<string, object?>>? overrides = null)
    {
        var body = new Dictionary<string, object?>
        {
            ["clientId"] = clientId ?? Guid.NewGuid(),
            ["supplierId"] = supplierId,
            ["orderDate"] = orderDate is { } date ? Iso(date) : Iso(DateOnly.FromDateTime(DateTime.UtcNow)),
            ["expectedDeliveryDate"] = expected is { } planned ? Iso(planned) : null,
            ["unitPrice"] = unitPrice,
            ["purchaseOrderNumber"] = purchaseOrder,
            ["note"] = null,
        };
        overrides?.Invoke(body);
        return body;
    }

    public static Dictionary<string, object?> DeliveryBody(
        Guid? requestId,
        decimal value,
        string? unit,
        DateOnly date,
        Guid? supplierId = null,
        Guid? productId = null,
        string? note = null,
        Guid? clientId = null,
        string? freeSupplier = null,
        string? freeProduct = null,
        Action<Dictionary<string, object?>>? overrides = null)
    {
        var body = new Dictionary<string, object?>
        {
            ["clientId"] = clientId ?? Guid.NewGuid(),
            ["clientCreatedAt"] = "2026-11-25T08:00:00Z",
            ["requestId"] = requestId,
            ["supplierId"] = supplierId,
            ["freeSupplierName"] = freeSupplier,
            ["productId"] = productId,
            ["freeProductName"] = freeProduct,
            ["quantity"] = unit is null ? new { value } : new { value, unit },
            ["deliveryDate"] = Iso(date),
            ["deliveryNoteNumber"] = note,
            ["conformity"] = "Conform",
        };
        overrides?.Invoke(body);
        return body;
    }

    public static async Task<JsonElement> CreateDeliveryAsync(this ApiSession session, Guid siteId, Dictionary<string, object?> body)
    {
        var response = await session.PostAsync(DeliveriesUrl(siteId), body);
        Assert.That((int)response.StatusCode, Is.EqualTo(201).Or.EqualTo(200), "creation de la livraison : " + await response.Content.ReadAsStringAsync());
        return await response.JsonAsync();
    }

    public static decimal Received(this JsonElement request)
        => request.TryGetProperty("receivedQuantity", out var received) ? received.GetProperty("value").GetDecimal() : 0m;

    public static string? Property(this JsonElement element, string name)
        => element.TryGetProperty(name, out var value) && value.ValueKind != JsonValueKind.Null ? value.ToString() : null;

    /// <summary>Livraison inseree directement en base (ligne vivante rattachee a la demande) : pour mettre une demande dans un statut deja « livre » sans passer par l'API.</summary>
    public static async Task SeedDeliveryRowAsync(this ChantierWebApplicationFactory factory, Guid siteId, Guid requestId, decimal quantity = 100m)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var request = await db.MaterialRequests.AsNoTracking().FirstAsync(candidate => candidate.Id == requestId);
        var fields = new ValidatedDeliveryFields(
            null, "Fournisseur fictif", request.ProductId, null, new Quantity(quantity, request.Unit), factory.Today(), null, Conformity.Conform, null, null);
        var delivery = Delivery.Create(siteId, "LIV-T" + Guid.NewGuid().ToString("N")[..8], null, null, fields, requestId, null, null);
        db.Deliveries.Add(delivery);
        await db.SaveChangesAsync();
    }

    public static async Task ArchiveSiteAsync(this ChantierWebApplicationFactory factory, Guid siteId)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        (await db.Sites.FindAsync(siteId))!.Archive(Chantier.Core.Abstractions.SystemActor.Id, DateTimeOffset.UtcNow);
        await db.SaveChangesAsync();
    }

    public static async Task<List<MaterialEvent>> DeliveryEventsAsync(this ChantierWebApplicationFactory factory, Guid deliveryId)
        => await factory.EventsOfAsync(deliveryId);

    public static async Task<List<Delivery>> LiveDeliveriesAsync(this ChantierWebApplicationFactory factory, Guid requestId)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        return await db.Deliveries.AsNoTracking()
            .Where(delivery => delivery.RequestId == requestId && delivery.Status == DeliveryStatus.Recorded)
            .ToListAsync();
    }

    public static async Task<MaterialRequest> RequestRowAsync(this ChantierWebApplicationFactory factory, Guid requestId)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        return await db.MaterialRequests.AsNoTracking().FirstAsync(request => request.Id == requestId);
    }

    // --- JPEG fictifs ---

    /// <summary>
    /// JPEG minimal structurellement valide (SOI, JFIF, <b>APP1 Exif avec des coordonnees GPS</b>, tables, cadre, balayage, EOI), assez gros pour la taille demandee.
    /// L'octet de remplissage change avec <paramref name="seed"/> : deux images different, donc leurs empreintes aussi.
    /// </summary>
    public static byte[] Jpeg(byte seed = 1, int scanBytes = 200, bool withExif = true)
    {
        using var stream = new MemoryStream();
        stream.Write([0xFF, 0xD8]);
        Segment(stream, 0xE0, "JFIF\0"u8.ToArray().Concat(new byte[] { 1, 1, 0, 0, 1, 0, 1, 0, 0 }).ToArray());
        if (withExif)
        {
            Segment(stream, 0xE1, "Exif\0\0GPSLatitude=36.4711N GPSLongitude=2.8277E"u8.ToArray());
            Segment(stream, 0xED, "Photoshop 3.0\0IPTC-legende"u8.ToArray());
        }

        Segment(stream, 0xDB, new byte[65]);
        Segment(stream, 0xC0, [8, 0, 1, 0, 1, 1, 1, 0x11, 0]);
        Segment(stream, 0xC4, new byte[17]);
        Segment(stream, 0xDA, [1, 1, 0, 0, 0x3F, 0]);

        var scan = new byte[scanBytes];
        Array.Fill(scan, seed);
        stream.Write(scan);
        stream.Write([0xFF, 0xD9]);
        return stream.ToArray();
    }

    private static void Segment(Stream stream, byte code, byte[] data)
    {
        var length = data.Length + 2;
        stream.Write([0xFF, code, (byte)(length >> 8), (byte)(length & 0xFF)]);
        stream.Write(data);
    }

    public static string Sha256Hex(byte[] bytes) => Convert.ToHexStringLower(SHA256.HashData(bytes));

    public static bool Contains(this byte[] bytes, string text)
        => bytes.AsSpan().IndexOf(System.Text.Encoding.ASCII.GetBytes(text)) >= 0;
}
