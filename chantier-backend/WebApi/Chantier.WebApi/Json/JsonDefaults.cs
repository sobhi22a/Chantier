using System.Text.Json;
using System.Text.Json.Serialization;

namespace Chantier.WebApi.Json;

/// <summary>Reglages JSON du contrat : camelCase, enumerations en chaines (jamais en entiers), dates strictes.</summary>
public static class JsonDefaults
{
    public static void Configure(JsonSerializerOptions options)
    {
        options.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        options.DictionaryKeyPolicy = JsonNamingPolicy.CamelCase;
        options.Converters.Add(new JsonStringEnumConverter(namingPolicy: null, allowIntegerValues: false));
        options.Converters.Add(new StrictDateOnlyJsonConverter());
    }
}
