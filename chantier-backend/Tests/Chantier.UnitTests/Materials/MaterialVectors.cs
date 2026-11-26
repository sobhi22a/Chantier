using System.Globalization;
using System.Text.Json;
using Chantier.Core.Materials;

namespace Chantier.UnitTests.Materials;

/// <summary>Lecture de <c>docs/api/vecteurs-materiaux.json</c> (ADR 0014) : le meme fichier que les suites Dart et TypeScript.</summary>
public static class MaterialVectors
{
    private static readonly JsonElement Root = Load();

    public static IEnumerable<JsonElement> Section(string name) => Root.GetProperty(name).EnumerateArray();

    public static IEnumerable<TestCaseData> Cases(string section)
        => Section(section).Select((vector, index) => new TestCaseData(vector).SetName($"{section}: {(vector.TryGetProperty("name", out var name) ? name.GetString() : "#" + (index + 1))}"));

    public static string Name(JsonElement vector) => vector.TryGetProperty("name", out var name) ? name.GetString()! : vector.ToString();

    public static decimal Decimal(JsonElement value) => decimal.Parse(value.GetString()!, NumberStyles.Number, CultureInfo.InvariantCulture);

    public static decimal? OptionalDecimal(JsonElement vector, string property)
        => vector.TryGetProperty(property, out var value) && value.ValueKind == JsonValueKind.String ? Decimal(value) : null;

    public static Quantity Qty(JsonElement value)
    {
        Assert.That(MeasureUnits.TryParse(value.GetProperty("unit").GetString(), out var unit), "unité du vecteur inconnue");
        return new Quantity(Decimal(value.GetProperty("value")), unit);
    }

    public static MeasureUnit Unit(string code)
    {
        Assert.That(MeasureUnits.TryParse(code, out var unit), $"unité {code} inconnue");
        return unit;
    }

    public static DateOnly Date(JsonElement value) => DateOnly.ParseExact(value.GetString()!, "yyyy-MM-dd", CultureInfo.InvariantCulture);

    public static bool HasError(JsonElement vector, out string code)
    {
        code = vector.TryGetProperty("error", out var error) ? error.GetString()! : string.Empty;
        return code.Length > 0;
    }

    private static JsonElement Load()
    {
        var path = Path.Combine(AppContext.BaseDirectory, "Materials", "vecteurs-materiaux.json");
        using var document = JsonDocument.Parse(File.ReadAllText(path));
        return document.RootElement.Clone();
    }
}
