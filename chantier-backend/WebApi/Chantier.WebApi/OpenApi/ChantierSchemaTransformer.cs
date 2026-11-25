using System.Reflection;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.Json.Serialization;
using System.Text.Json.Serialization.Metadata;
using Chantier.Core.Sync;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OpenApi;
using Microsoft.OpenApi;

namespace Chantier.WebApi.OpenApi;

/// <summary>
/// Corrige les schemas pour qu'ils decrivent exactement le JSON reellement echange (et que les generateurs produisent des types justes) :
/// nombres sans variante « chaine », enumerations typees, champs obligatoires exacts, Problem Details complet, objets libres de synchronisation.
/// </summary>
public sealed class ChantierSchemaTransformer : IOpenApiSchemaTransformer
{
    private const string RequestModelsNamespace = "Chantier.WebApi.Models";

    public Task TransformAsync(OpenApiSchema schema, OpenApiSchemaTransformerContext context, CancellationToken cancellationToken)
    {
        NormalizeNumbers(schema);

        var type = context.JsonTypeInfo.Type;
        var underlying = Nullable.GetUnderlyingType(type) ?? type;

        if (underlying.IsEnum)
        {
            NormalizeEnum(schema);
        }
        else if (underlying == typeof(DateOnly))
        {
            // Le convertisseur strict (yyyy-MM-dd) cache le type au generateur de schema : une date metier est une chaine au format « date ».
            schema.Type = type == underlying ? JsonSchemaType.String : JsonSchemaType.String | JsonSchemaType.Null;
            schema.Format = "date";
        }
        else if (context.JsonPropertyInfo is null && underlying == typeof(ProblemDetails))
        {
            DescribeProblemDetails(schema);
        }
        else if (underlying == typeof(JsonElement) || underlying == typeof(object))
        {
            MakeFreeObject(schema, context);
        }
        else if (context.JsonPropertyInfo is null && context.JsonTypeInfo.Kind == JsonTypeInfoKind.Object)
        {
            FixRequiredProperties(schema, context, underlying);
        }

        return Task.CompletedTask;
    }

    /// <summary>
    /// ASP.NET accepte aussi un nombre ecrit en chaine (<c>"12"</c>) et le declare dans le schema (<c>["integer","string"]</c> + <c>pattern</c>).
    /// Le contrat n'echange que des nombres : on retire la variante chaine, sinon les clients generes recevraient <c>number | string</c>.
    /// </summary>
    private static void NormalizeNumbers(OpenApiSchema schema)
    {
        if (schema.Type is { } type
            && (type.HasFlag(JsonSchemaType.Integer) || type.HasFlag(JsonSchemaType.Number))
            && type.HasFlag(JsonSchemaType.String))
        {
            schema.Type = type & ~JsonSchemaType.String;
            schema.Pattern = null;
        }
    }

    /// <summary>Une enumeration est une chaine parmi des valeurs fixes ; <c>null</c> n'est pas une valeur de l'enumeration (c'est la propriete qui est facultative).</summary>
    private static void NormalizeEnum(OpenApiSchema schema)
    {
        if (schema.Enum is { Count: > 0 } values)
        {
            foreach (var nullValue in values.Where(value => value is null || value.GetValueKind() == JsonValueKind.Null).ToList())
            {
                values.Remove(nullValue);
            }

            schema.Type = JsonSchemaType.String;
        }
    }

    private static void DescribeProblemDetails(OpenApiSchema schema)
    {
        schema.Description = "Erreur au format RFC 9457 (`application/problem+json`). Les clients traduisent `code` ; `title` et `detail` ne sont qu'un repli en français.";
        schema.Properties ??= new Dictionary<string, IOpenApiSchema>();
        schema.Properties["type"] = new OpenApiSchema { Type = JsonSchemaType.String, Description = "URI stable du type d'erreur, dérivée de `code`." };
        schema.Properties["title"] = new OpenApiSchema { Type = JsonSchemaType.String };
        schema.Properties["status"] = new OpenApiSchema { Type = JsonSchemaType.Integer, Format = "int32", Description = "Code HTTP." };
        schema.Properties["detail"] = new OpenApiSchema { Type = JsonSchemaType.String };
        schema.Properties["instance"] = new OpenApiSchema { Type = JsonSchemaType.String | JsonSchemaType.Null };
        schema.Properties["code"] = new OpenApiSchema
        {
            Type = JsonSchemaType.String,
            Description = "Code métier stable (`VALIDATION`, `INTROUVABLE`, `ZONE_EXISTANTE`...). Ensemble ouvert : un client ignore un code qu'il ne connaît pas et affiche `title`.",
        };
        schema.Properties["traceId"] = new OpenApiSchema { Type = JsonSchemaType.String, Description = "Identifiant à communiquer au support." };
        schema.Properties["errors"] = new OpenApiSchema
        {
            Type = JsonSchemaType.Object,
            Description = "Détail par champ (400 `VALIDATION`) : nom du champ en camelCase, puis les messages.",
            AdditionalProperties = new OpenApiSchema { Type = JsonSchemaType.Array, Items = new OpenApiSchema { Type = JsonSchemaType.String } },
        };
        schema.Properties["current"] = new OpenApiSchema
        {
            Type = JsonSchemaType.Object,
            Description = "409 `CONFLIT_VERSION` : état actuel de la ressource (même JSON que sa réponse REST).",
            AdditionalPropertiesAllowed = true,
        };
        schema.Required = new HashSet<string> { "type", "title", "status", "code", "traceId" };
        schema.AdditionalPropertiesAllowed = true;
    }

    private static void MakeFreeObject(OpenApiSchema schema, OpenApiSchemaTransformerContext context)
    {
        // `object Data` n'est jamais nul ; `object? Resource`, `Current` et `Payload` peuvent l'etre (annotation de nullabilite du code).
        schema.Type = IsDeclaredNullable(context.JsonPropertyInfo)
            ? JsonSchemaType.Object | JsonSchemaType.Null
            : JsonSchemaType.Object;
        schema.OneOf = null;
        schema.AdditionalPropertiesAllowed = true;
        schema.Description ??= context.JsonPropertyInfo?.Name switch
        {
            "data" => "Ressource telle que renvoyée par l'API REST : `SiteResponse` (site), `ZoneResponse` (zone) ou `SyncMemberData` (member).",
            "resource" => "Ressource telle que renvoyée par l'API REST (`ZoneResponse` pour une zone).",
            "current" => "État actuel de la ressource sur le serveur (conflit).",
            "payload" => "Champs de la ressource à créer : pour une zone `block`, `elevation`, `roomType`, `roomNumber`, `roomLabel`, `clientCreatedAt`.",
            _ => "Objet libre.",
        };
    }

    private static bool IsDeclaredNullable(JsonPropertyInfo? property)
        => property?.AttributeProvider is PropertyInfo info
            && new NullabilityInfoContext().Create(info).ReadState == NullabilityState.Nullable;

    /// <summary>
    /// <c>required</c> exact : (1) un champ ecrit seulement s'il n'est pas nul (<c>JsonIgnore(WhenWritingNull)</c>, par exemple le montant du marche
    /// sans permission) n'est pas obligatoire dans la reponse ; (2) un champ obligatoire d'une <b>requete</b> n'est jamais nul.
    /// </summary>
    private static void FixRequiredProperties(OpenApiSchema schema, OpenApiSchemaTransformerContext context, Type type)
    {
        if (schema.Required is not { Count: > 0 } required)
        {
            return;
        }

        foreach (var property in context.JsonTypeInfo.Properties)
        {
            var ignore = property.AttributeProvider?.GetCustomAttributes(typeof(JsonIgnoreAttribute), inherit: true)
                .OfType<JsonIgnoreAttribute>()
                .FirstOrDefault();
            if (ignore?.Condition == JsonIgnoreCondition.WhenWritingNull)
            {
                required.Remove(property.Name);
            }
        }

        if (type.Namespace?.StartsWith(RequestModelsNamespace, StringComparison.Ordinal) == true && schema.Properties is { } properties)
        {
            foreach (var name in required)
            {
                if (properties.TryGetValue(name, out var member) && member is OpenApiSchema { Type: { } memberType } concrete && memberType.HasFlag(JsonSchemaType.Null))
                {
                    concrete.Type = memberType & ~JsonSchemaType.Null;
                }
            }
        }
    }
}
