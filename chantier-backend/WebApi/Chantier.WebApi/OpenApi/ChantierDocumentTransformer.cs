using Chantier.Core.Sync;
using Chantier.WebApi.Extensions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OpenApi;
using Microsoft.OpenApi;

namespace Chantier.WebApi.OpenApi;

/// <summary>Informations generales, schemas de securite, schemas utiles aux clients, et ordre stable du document.</summary>
public sealed class ChantierDocumentTransformer : IOpenApiDocumentTransformer
{
    public const string BearerScheme = "bearerAuth";
    public const string CookieScheme = "cookieAuth";

    public async Task TransformAsync(OpenApiDocument document, OpenApiDocumentTransformerContext context, CancellationToken cancellationToken)
    {
        document.Info = new OpenApiInfo
        {
            Title = ChantierOpenApi.Title,
            Version = ChantierOpenApi.ContractVersion,
            Description = """
                API du suivi de chantier (préfixe `/api/v1`). Ce document est **généré** par le backend et fait foi ; les clients web et mobile en génèrent leurs types.

                - **Authentification** : web = cookie `HttpOnly` posé par `POST /auth/login` (`isAppMobile = false`) ; mobile = jeton porteur (`isAppMobile = true`) renouvelé par `POST /auth/refresh`.
                - **Erreurs** : toujours `application/problem+json` avec `code` (code métier stable, traduit par les clients) et `traceId`. Catalogue : `docs/api/codes-erreur.md`.
                - **Versions** : `version` est un jeton de concurrence (entier décimal en chaîne) ; une modification avec une version périmée répond 409 `CONFLIT_VERSION`.
                - **Dates** : date métier `2026-11-24` ; horodatage UTC `2026-11-24T10:15:00Z`.
                - **Hors ligne** : création idempotente par `clientId` ; synchronisation par `GET /sync/changes` (curseur serveur) et `POST /sync/push`.
                - **Évolution** : seuls des ajouts sont permis dans `/api/v1` (champs facultatifs, nouvelles routes).
                """,
        };

        document.Components ??= new OpenApiComponents();
        document.Components.SecuritySchemes = new Dictionary<string, IOpenApiSecurityScheme>
        {
            [BearerScheme] = new OpenApiSecurityScheme
            {
                Type = SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                Description = "Mobile : jeton d'accès (15 minutes) renvoyé par `POST /auth/login` avec `isAppMobile = true`.",
            },
            [CookieScheme] = new OpenApiSecurityScheme
            {
                Type = SecuritySchemeType.ApiKey,
                In = ParameterLocation.Cookie,
                Name = AuthenticationExtensions.CookieName,
                Description = "Web : cookie de session `HttpOnly` posé par `POST /auth/login` avec `isAppMobile = false`.",
            },
        };

        // Modeles que le contrat decrit mais qu'aucune route ne renvoie directement (le champ `data` de la synchronisation est libre).
        document.Components.Schemas ??= new Dictionary<string, IOpenApiSchema>();
        await AddSchemaAsync<SyncMemberData>(document, context, cancellationToken);
        await AddSchemaAsync<ProblemDetails>(document, context, cancellationToken);

        SortForStability(document);
        NormalizeLineEndings(document);
    }

    private static async Task AddSchemaAsync<T>(OpenApiDocument document, OpenApiDocumentTransformerContext context, CancellationToken cancellationToken)
    {
        var schema = await context.GetOrCreateSchemaAsync(typeof(T), cancellationToken: cancellationToken);
        document.Components!.Schemas![typeof(T).Name] = schema;
    }

    /// <summary>
    /// L'ordre des routes et des schemas depend de l'ordre de decouverte des types (donc du systeme de fichiers du poste de build) :
    /// on le fixe, sinon le fichier commite changerait d'un poste a l'autre et le controle de derive de la CI echouerait.
    /// </summary>
    private static void SortForStability(OpenApiDocument document)
    {
        if (document.Paths is { Count: > 0 } paths)
        {
            var sorted = new OpenApiPaths();
            foreach (var (route, item) in paths.OrderBy(entry => entry.Key, StringComparer.Ordinal))
            {
                if (item is OpenApiPathItem pathItem && pathItem.Operations is { Count: > 1 } operations)
                {
                    pathItem.Operations = operations
                        .OrderBy(entry => entry.Key.Method, StringComparer.Ordinal)
                        .ToDictionary(entry => entry.Key, entry => entry.Value);
                }

                sorted.Add(route, item);
            }

            document.Paths = sorted;
        }

        if (document.Components?.Schemas is { Count: > 1 } schemas)
        {
            document.Components.Schemas = schemas
                .OrderBy(entry => entry.Key, StringComparer.Ordinal)
                .ToDictionary(entry => entry.Key, entry => entry.Value, StringComparer.Ordinal);
        }

        if (document.Tags is { Count: > 1 } tags)
        {
            document.Tags = new HashSet<OpenApiTag>(tags.OrderBy(tag => tag.Name, StringComparer.Ordinal));
        }
    }

    /// <summary>
    /// Les commentaires XML multi-lignes sont assembles avec le saut de ligne de la plateforme (CRLF sous Windows, LF sous Linux) :
    /// on le fixe a LF, sinon le fichier commite differerait entre un poste Windows et la CI Linux.
    /// </summary>
    private static void NormalizeLineEndings(OpenApiDocument document)
    {
        var visited = new HashSet<IOpenApiSchema>(ReferenceEqualityComparer.Instance);

        foreach (var pathItem in (document.Paths ?? []).Values)
        {
            foreach (var operation in (pathItem.Operations ?? []).Values)
            {
                operation.Summary = Fix(operation.Summary);
                operation.Description = Fix(operation.Description);

                foreach (var parameter in (operation.Parameters ?? []).OfType<OpenApiParameter>())
                {
                    parameter.Description = Fix(parameter.Description);
                    FixSchema(parameter.Schema, visited);
                }

                if (operation.RequestBody is OpenApiRequestBody body)
                {
                    body.Description = Fix(body.Description);
                }

                foreach (var response in (operation.Responses ?? []).Values.OfType<OpenApiResponse>())
                {
                    response.Description = Fix(response.Description);
                }
            }
        }

        foreach (var schema in (document.Components?.Schemas?.Values ?? Enumerable.Empty<IOpenApiSchema>()))
        {
            FixSchema(schema, visited);
        }
    }

    private static void FixSchema(IOpenApiSchema? schema, HashSet<IOpenApiSchema> visited)
    {
        if (schema is not OpenApiSchema concrete || !visited.Add(concrete))
        {
            return;
        }

        concrete.Description = Fix(concrete.Description);
        foreach (var property in (concrete.Properties?.Values ?? Enumerable.Empty<IOpenApiSchema>()))
        {
            FixSchema(property, visited);
        }

        FixSchema(concrete.Items, visited);
        FixSchema(concrete.AdditionalProperties, visited);
        foreach (var inner in (concrete.OneOf ?? []).Concat(concrete.AnyOf ?? []).Concat(concrete.AllOf ?? []))
        {
            FixSchema(inner, visited);
        }
    }

    private static string? Fix(string? text)
        => text?.Replace("\r\n", "\n", StringComparison.Ordinal).Replace('\r', '\n');
}
