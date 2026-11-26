using System.Text.Json;

namespace Chantier.IntegrationTests.Support;

/// <summary>Operations de synchronisation des demandes (corps de <c>POST /sync/push</c>) et lectures des resultats.</summary>
public static class MaterialsSyncKit
{
    private static Dictionary<string, object?> Operation(Guid clientId, Guid siteId, string operation, Dictionary<string, object?> payload) => new()
    {
        ["clientId"] = clientId,
        ["entity"] = "request",
        ["operation"] = operation,
        ["siteId"] = siteId,
        ["baseVersion"] = null,
        ["payload"] = payload,
    };

    /// <summary>Creation hors ligne ; <c>clientId</c> de l'operation = <c>clientId</c> de la demande.</summary>
    public static Dictionary<string, object?> RequestCreate(
        Guid clientId,
        Guid siteId,
        Guid? productId,
        decimal value = 300m,
        string? unit = "sac",
        Guid? zoneId = null,
        Guid? zoneClientId = null,
        string? neededBy = null,
        string priority = "Normal",
        string? note = null,
        string? freeName = null,
        Action<Dictionary<string, object?>>? overrides = null)
    {
        var payload = new Dictionary<string, object?>
        {
            ["clientCreatedAt"] = "2026-11-25T06:58:00Z",
            ["productId"] = productId,
            ["freeProductName"] = freeName,
            ["quantity"] = unit is null ? new { value } : new { value, unit },
            ["zoneId"] = zoneId,
            ["zoneClientId"] = zoneClientId,
            ["neededBy"] = neededBy ?? RequestsTestKit.FutureDate(),
            ["priority"] = priority,
            ["note"] = note,
        };
        overrides?.Invoke(payload);
        return Operation(clientId, siteId, "create", payload);
    }

    public static Dictionary<string, object?> RequestUpdate(
        Guid clientId,
        Guid siteId,
        Dictionary<string, object?> changes,
        Dictionary<string, object?> baseValues,
        Guid? requestId = null,
        Guid? requestClientId = null)
        => Operation(clientId, siteId, "update", new Dictionary<string, object?>
        {
            ["requestId"] = requestId,
            ["requestClientId"] = requestClientId,
            ["clientCreatedAt"] = "2026-11-25T07:30:00Z",
            ["changes"] = changes,
            ["base"] = baseValues,
        });

    public static Dictionary<string, object?> RequestTransition(
        Guid clientId,
        Guid siteId,
        string action,
        Guid? requestId = null,
        Guid? requestClientId = null,
        string? reasonCode = null,
        string? reasonNote = null,
        object? quantity = null,
        string? note = null)
        => Operation(clientId, siteId, "transition", new Dictionary<string, object?>
        {
            ["requestId"] = requestId,
            ["requestClientId"] = requestClientId,
            ["clientCreatedAt"] = "2026-11-25T07:45:00Z",
            ["action"] = action,
            ["reasonCode"] = reasonCode,
            ["reasonNote"] = reasonNote,
            ["quantity"] = quantity,
            ["note"] = note,
        });

    private static Dictionary<string, object?> OperationOf(string entity, Guid clientId, Guid siteId, string operation, Dictionary<string, object?> payload) => new()
    {
        ["clientId"] = clientId,
        ["entity"] = entity,
        ["operation"] = operation,
        ["siteId"] = siteId,
        ["baseVersion"] = null,
        ["payload"] = payload,
    };

    /// <summary>Livraison creee hors ligne ; <c>clientId</c> de l'operation = <c>clientId</c> de la livraison.</summary>
    public static Dictionary<string, object?> DeliveryCreate(
        Guid clientId,
        Guid siteId,
        Guid? requestId,
        decimal value,
        string? unit,
        string deliveryDate,
        Guid? supplierId = null,
        Guid? productId = null,
        Guid? requestClientId = null,
        string? note = null,
        Action<Dictionary<string, object?>>? overrides = null)
    {
        var payload = new Dictionary<string, object?>
        {
            ["clientCreatedAt"] = "2026-11-25T08:00:00Z",
            ["requestId"] = requestId,
            ["requestClientId"] = requestClientId,
            ["supplierId"] = supplierId,
            ["productId"] = productId,
            ["quantity"] = unit is null ? new { value } : new { value, unit },
            ["deliveryDate"] = deliveryDate,
            ["deliveryNoteNumber"] = note,
            ["conformity"] = "Conform",
        };
        overrides?.Invoke(payload);
        return OperationOf("delivery", clientId, siteId, "create", payload);
    }

    public static Dictionary<string, object?> DeliveryUpdate(
        Guid clientId,
        Guid siteId,
        Dictionary<string, object?> changes,
        Dictionary<string, object?> baseValues,
        Guid? deliveryId = null,
        Guid? deliveryClientId = null)
        => OperationOf("delivery", clientId, siteId, "update", new Dictionary<string, object?>
        {
            ["deliveryId"] = deliveryId,
            ["deliveryClientId"] = deliveryClientId,
            ["clientCreatedAt"] = "2026-11-25T09:00:00Z",
            ["changes"] = changes,
            ["base"] = baseValues,
        });

    public static Dictionary<string, object?> DeliveryCancel(Guid clientId, Guid siteId, Guid? deliveryId = null, Guid? deliveryClientId = null, string? reasonCode = "DoubleEntry")
        => OperationOf("delivery", clientId, siteId, "transition", new Dictionary<string, object?>
        {
            ["deliveryId"] = deliveryId,
            ["deliveryClientId"] = deliveryClientId,
            ["clientCreatedAt"] = "2026-11-25T09:30:00Z",
            ["action"] = "cancel",
            ["reasonCode"] = reasonCode,
        });

    public static Dictionary<string, object?> PhotoCreate(Guid clientId, Guid siteId, Guid? deliveryId, Guid? deliveryClientId, byte[] jpeg)
        => OperationOf("photo", clientId, siteId, "create", new Dictionary<string, object?>
        {
            ["deliveryId"] = deliveryId,
            ["deliveryClientId"] = deliveryClientId,
            ["clientCreatedAt"] = "2026-11-25T08:05:00Z",
            ["takenAt"] = "2026-11-25T08:04:00Z",
            ["contentType"] = "image/jpeg",
            ["sizeBytes"] = jpeg.Length,
            ["sha256"] = DeliveriesTestKit.Sha256Hex(jpeg),
        });

    public static JsonElement Resource(this JsonElement result) => result.GetProperty("resource");

    public static JsonElement Current(this JsonElement result) => result.GetProperty("current");

    public static IEnumerable<string> ConflictFields(this JsonElement result)
        => result.TryGetProperty("conflictFields", out var fields) ? fields.EnumerateArray().Select(field => field.GetString()!) : [];

    /// <summary>Le JSON entier d'une reponse ou d'un lot de lignes ne contient aucun de ces mots-cles (prix, telephone, champs commerciaux).</summary>
    public static readonly string[] ForbiddenWords =
        ["commercial", "unitPrice", "amount", "receivedValue", "purchaseOrderNumber", "\"phone\"", "siteCode"];
}
