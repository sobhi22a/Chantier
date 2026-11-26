using System.Text.Json;
using Chantier.Core.Entities.Identity;

namespace Chantier.IntegrationTests.Support;

/// <summary>Outils des tests des demandes de materiaux : produits, fournisseurs et corps de demande (donnees fictives).</summary>
public static class MaterialsTestKit
{
    public const string Products = "/api/v1/products";
    public const string Suppliers = "/api/v1/suppliers";

    public static string UniqueName(string prefix) => $"{prefix} {Guid.NewGuid().ToString("N")[..10]}";

    public static Dictionary<string, object?> ProductBody(
        string? nameFr = null,
        string[]? units = null,
        string defaultUnit = "sac",
        decimal? bagMassKg = 50m,
        string category = "Binders",
        Action<Dictionary<string, object?>>? overrides = null)
    {
        var body = new Dictionary<string, object?>
        {
            ["nameFr"] = nameFr ?? UniqueName("Ciment"),
            ["nameAr"] = null,
            ["category"] = category,
            ["allowedUnits"] = units ?? ["sac", "t", "kg"],
            ["defaultUnit"] = defaultUnit,
            ["bagMassKg"] = bagMassKg,
        };
        overrides?.Invoke(body);
        return body;
    }

    public static async Task<JsonElement> CreateProductAsync(this ApiSession admin, Dictionary<string, object?>? body = null)
    {
        var response = await admin.PostAsync(Products, body ?? ProductBody());
        Assert.That((int)response.StatusCode, Is.EqualTo(201), "creation du produit");
        return await response.JsonAsync();
    }

    /// <summary>Produit sans masse de sac (acier, granulats...) : unites t et kg.</summary>
    public static Task<JsonElement> CreateSteelAsync(this ApiSession admin)
        => admin.CreateProductAsync(ProductBody(UniqueName("Rond HA"), ["t", "kg"], "t", null, "Steel"));

    public static async Task<JsonElement> CreateSupplierAsync(this ApiSession admin, string? name = null, string? phone = "0550 00 00 21", Guid[]? productIds = null)
    {
        var response = await admin.PostAsync(Suppliers, new { name = name ?? UniqueName("Fournisseur"), phone, productIds = productIds ?? [] });
        Assert.That((int)response.StatusCode, Is.EqualTo(201), "creation du fournisseur");
        return await response.JsonAsync();
    }

    public static Guid Id(this JsonElement element) => element.GetProperty("id").GetGuid();

    public static string Version(this JsonElement element) => element.GetProperty("version").GetString()!;

    public static async Task<ApiSession> SignInAdminAsync(this ChantierWebApplicationFactory factory)
        => await factory.SignInAsync(RoleNames.Admin);
}
