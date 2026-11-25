using System.Net;
using System.Text.Json.Nodes;
using Chantier.IntegrationTests.Support;
using Chantier.WebApi.Extensions;

namespace Chantier.IntegrationTests.Contract;

/// <summary>
/// CT-10 : le document OpenAPI <b>genere</b> fait foi et est commite dans <c>docs/api/openapi.json</c>. Ces tests echouent si le fichier
/// commite derive du code (il faut alors relancer <c>dotnet build</c> et commiter le fichier) et verifient que le document reste
/// exact et lisible par les generateurs de clients (web : RTK Query, mobile : swagger_parser).
/// </summary>
[TestFixture]
public class OpenApiContractTests
{
    private const string SchemaPrefix = "#/components/schemas/";

    private ChantierWebApplicationFactory _factory = null!;
    private JsonNode _runtime = null!;
    private JsonNode _committed = null!;
    private string _committedText = null!;

    [OneTimeSetUp]
    public async Task SetUp()
    {
        _factory = new ChantierWebApplicationFactory();
        using var client = _factory.CreateClient();
        var response = await client.GetAsync("/openapi/v1.json");
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), "Le document est servi en développement, sans authentification.");
        _runtime = JsonNode.Parse(await response.Content.ReadAsStringAsync())!;

        _committedText = await File.ReadAllTextAsync(CommittedPath());
        _committed = JsonNode.Parse(_committedText)!;
    }

    [OneTimeTearDown]
    public void TearDown() => _factory.Dispose();

    private static string CommittedPath()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null)
        {
            var candidate = Path.Combine(directory.FullName, "docs", "api", "openapi.json");
            if (File.Exists(candidate))
            {
                return candidate;
            }

            directory = directory.Parent;
        }

        throw new FileNotFoundException("docs/api/openapi.json introuvable : lancer « dotnet build » pour le générer.");
    }

    private IEnumerable<(string Path, string Method, JsonObject Operation)> Operations()
    {
        foreach (var (path, item) in _committed["paths"]!.AsObject())
        {
            foreach (var (method, operation) in item!.AsObject())
            {
                yield return (path, method, operation!.AsObject());
            }
        }
    }

    private static string Id(JsonObject operation) => operation["operationId"]!.GetValue<string>();

    private static List<string> Strings(JsonNode? array) => array!.AsArray().Select(item => item!.GetValue<string>()).ToList();

    [Test]
    public void The_committed_file_is_the_generated_document()
    {
        // Le serveur de developpement ajoute « servers » (adresse de la requete) : le fichier du build n'en a pas.
        // L'hote de test ajoute aussi ses routes d'aide (/test-support) : elles ne font pas partie du contrat.
        var served = _runtime.DeepClone().AsObject();
        served.Remove("servers");
        foreach (var route in served["paths"]!.AsObject().Select(entry => entry.Key).Where(route => route.StartsWith("/test-support", StringComparison.Ordinal)).ToList())
        {
            served["paths"]!.AsObject().Remove(route);
        }

        if (served["tags"] is JsonArray tags)
        {
            foreach (var tag in tags.Where(tag => tag!["name"]!.GetValue<string>() == "TestSupport").ToList())
            {
                tags.Remove(tag);
            }
        }

        foreach (var schema in served["components"]!["schemas"]!.AsObject().Select(entry => entry.Key).Where(name => name.StartsWith("Echo", StringComparison.Ordinal)).ToList())
        {
            served["components"]!["schemas"]!.AsObject().Remove(schema);
        }

        Assert.That(
            JsonNode.DeepEquals(served, _committed),
            Is.True,
            "docs/api/openapi.json n'est pas à jour avec le code. Lancer « dotnet build » (il le régénère) puis commiter le fichier. Premier écart : "
            + FirstDifference(served, _committed, "$"));
    }

    private static string FirstDifference(JsonNode? generated, JsonNode? committed, string path)
    {
        switch (generated, committed)
        {
            case (JsonObject left, JsonObject right):
                foreach (var key in left.Select(entry => entry.Key).Union(right.Select(entry => entry.Key)))
                {
                    if (!left.ContainsKey(key) || !right.ContainsKey(key))
                    {
                        return $"{path}.{key} absent d'un côté";
                    }

                    if (!JsonNode.DeepEquals(left[key], right[key]))
                    {
                        return FirstDifference(left[key], right[key], $"{path}.{key}");
                    }
                }

                return path;
            case (JsonArray left, JsonArray right):
                for (var index = 0; index < Math.Max(left.Count, right.Count); index++)
                {
                    if (index >= left.Count || index >= right.Count || !JsonNode.DeepEquals(left[index], right[index]))
                    {
                        return index < left.Count && index < right.Count ? FirstDifference(left[index], right[index], $"{path}[{index}]") : $"{path}[{index}] absent d'un côté";
                    }
                }

                return path;
            default:
                return $"{path} : généré {generated?.ToJsonString()} / commité {committed?.ToJsonString()}";
        }
    }

    [Test]
    public void The_committed_file_uses_unix_line_endings()
    {
        Assert.That(_committedText, Does.Not.Contain("\r"), "Le fichier doit être identique sous Windows et sous Linux.");
    }

    [Test]
    public void The_document_is_openapi_3_1_with_the_contract_title_and_version()
    {
        Assert.Multiple(() =>
        {
            Assert.That(_committed["openapi"]!.GetValue<string>(), Does.StartWith("3.1"));
            Assert.That(_committed["info"]!["title"]!.GetValue<string>(), Is.EqualTo("Chantier API"));
            Assert.That(_committed["info"]!["version"]!.GetValue<string>(), Is.EqualTo("1.0.0"));
            Assert.That(_committed["servers"], Is.Null, "Aucune adresse de serveur dans le contrat : chaque client a la sienne.");
        });
    }

    [Test]
    public void Every_operation_has_a_unique_explicit_operation_id_of_the_form_Controller_Action()
    {
        var ids = Operations().Select(operation => operation.Operation["operationId"]?.GetValue<string>()).ToList();

        Assert.Multiple(() =>
        {
            Assert.That(ids, Has.None.Null.Or.Empty);
            Assert.That(ids, Is.Unique);
            Assert.That(ids, Has.All.Matches("^[A-Z][A-Za-z]+_[A-Z][A-Za-z]+$"));
            Assert.That(ids, Does.Contain("Zones_Create").And.Contain("Sync_Changes").And.Contain("Sync_Push").And.Contain("Auth_Login").And.Contain("Sites_List"));
        });
    }

    [Test]
    public void Every_operation_has_a_summary()
    {
        var offenders = Operations()
            .Where(operation => string.IsNullOrWhiteSpace(operation.Operation["summary"]?.GetValue<string>()))
            .Select(operation => Id(operation.Operation));

        Assert.That(offenders, Is.Empty, "Chaque route a un résumé (commentaire XML du contrôleur).");
    }

    [Test]
    public void Every_route_of_the_controllers_is_in_the_document()
    {
        var actions = typeof(AuthenticationExtensions).Assembly.GetTypes()
            .Where(type => typeof(Microsoft.AspNetCore.Mvc.ControllerBase).IsAssignableFrom(type) && !type.IsAbstract)
            .SelectMany(type => type.GetMethods(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.DeclaredOnly))
            .Count(method => method.GetCustomAttributes(typeof(Microsoft.AspNetCore.Mvc.Routing.HttpMethodAttribute), true).Length > 0);

        Assert.That(Operations().Count(), Is.EqualTo(actions));
    }

    [Test]
    public void Only_login_and_refresh_are_anonymous_and_every_other_operation_declares_both_security_schemes()
    {
        var anonymous = Operations().Where(operation => operation.Operation["security"]!.AsArray().Count == 0).Select(operation => Id(operation.Operation));
        var secured = Operations().Where(operation => operation.Operation["security"]!.AsArray().Count > 0).ToList();
        var schemes = secured.Select(operation => string.Join(
            '+',
            operation.Operation["security"]!.AsArray().SelectMany(requirement => requirement!.AsObject().Select(entry => entry.Key)).Order()));

        Assert.Multiple(() =>
        {
            Assert.That(anonymous, Is.EquivalentTo(new[] { "Auth_Login", "Auth_Refresh" }));
            Assert.That(schemes, Is.All.EqualTo("bearerAuth+cookieAuth"));
            Assert.That(_committed["components"]!["securitySchemes"]!["bearerAuth"]!["scheme"]!.GetValue<string>(), Is.EqualTo("bearer"));
            Assert.That(_committed["components"]!["securitySchemes"]!["cookieAuth"]!["name"]!.GetValue<string>(), Is.EqualTo(AuthenticationExtensions.CookieName));
        });
    }

    [Test]
    public void Every_error_response_is_a_problem_details_with_a_code()
    {
        var offenders = new List<string>();
        foreach (var (path, method, operation) in Operations())
        {
            foreach (var (status, response) in operation["responses"]!.AsObject())
            {
                if (!int.TryParse(status, out var code) || code < 400)
                {
                    continue;
                }

                var content = response!["content"]?.AsObject();
                var reference = content?["application/problem+json"]?["schema"]?["$ref"]?.GetValue<string>();
                if (content?.Count != 1 || reference != SchemaPrefix + "ProblemDetails")
                {
                    offenders.Add($"{method.ToUpperInvariant()} {path} {status}");
                }
            }
        }

        var problem = _committed["components"]!["schemas"]!["ProblemDetails"]!;
        Assert.Multiple(() =>
        {
            Assert.That(offenders, Is.Empty);
            Assert.That(problem["properties"]!.AsObject().Select(entry => entry.Key), Is.SupersetOf(new[] { "type", "title", "status", "detail", "code", "traceId", "errors", "current" }));
            Assert.That(Strings(problem["required"]), Is.SupersetOf(new[] { "code", "traceId" }));
        });
    }

    [Test]
    public void Every_operation_documents_the_common_failures()
    {
        // 429 et 500 partout ; 401 et 403 sur toute route protegee (hors les quatre routes encore permises avec un mot de passe provisoire).
        var offenders = new List<string>();
        foreach (var (path, method, operation) in Operations())
        {
            var codes = operation["responses"]!.AsObject().Select(entry => entry.Key).ToHashSet();
            var secured = operation["security"]!.AsArray().Count > 0;
            var mustChangeExempt = Id(operation) is "Auth_Me" or "Auth_UpdateLanguage" or "Auth_ChangePassword" or "Auth_Logout";

            if (!codes.Contains("429") || !codes.Contains("500") || (secured && !codes.Contains("401")) || (secured && !mustChangeExempt && !codes.Contains("403")))
            {
                offenders.Add($"{method.ToUpperInvariant()} {path} : {string.Join(',', codes.Order())}");
            }
        }

        Assert.That(offenders, Is.Empty);
    }

    [Test]
    public void Every_reference_resolves_and_only_the_free_sync_model_is_unreferenced()
    {
        var schemas = _committed["components"]!["schemas"]!.AsObject().Select(entry => entry.Key).ToHashSet();
        var references = new HashSet<string>();
        Collect(_committed, references);

        Assert.Multiple(() =>
        {
            Assert.That(references.Where(name => !schemas.Contains(name)), Is.Empty, "Référence sans schéma.");
            Assert.That(schemas.Where(name => !references.Contains(name)), Is.EquivalentTo(new[] { "SyncMemberData" }), "Seul SyncMemberData est décrit sans être référencé (champ `data` libre de la synchronisation).");
        });

        static void Collect(JsonNode? node, HashSet<string> found)
        {
            switch (node)
            {
                case JsonObject obj:
                    foreach (var (key, value) in obj)
                    {
                        if (key == "$ref" && value?.GetValue<string>() is { } reference && reference.StartsWith(SchemaPrefix, StringComparison.Ordinal))
                        {
                            found.Add(reference[SchemaPrefix.Length..]);
                        }

                        Collect(value, found);
                    }

                    break;
                case JsonArray array:
                    foreach (var item in array)
                    {
                        Collect(item, found);
                    }

                    break;
            }
        }
    }

    [Test]
    public void Schemas_stay_readable_by_the_generators()
    {
        var offenders = new List<string>();
        foreach (var (name, schema) in _committed["components"]!["schemas"]!.AsObject())
        {
            if (schema!["enum"] is JsonArray values && (schema["type"]?.GetValue<string>() != "string" || values.Any(value => value is null)))
            {
                offenders.Add($"enum {name} : chaîne sans null attendue");
            }

            foreach (var (property, definition) in schema["properties"]?.AsObject() ?? [])
            {
                var types = TypeNames(definition!["type"]).ToList();
                var isNumber = types.Contains("integer") || types.Contains("number");

                if (isNumber && types.Contains("string"))
                {
                    offenders.Add($"{name}.{property} : nombre ou chaîne");
                }

                if (isNumber && definition["pattern"] is not null)
                {
                    offenders.Add($"{name}.{property} : motif sur un nombre");
                }

                if (definition["format"]?.GetValue<string>() is "date" or "date-time" or "uuid" && !types.Contains("string"))
                {
                    offenders.Add($"{name}.{property} : format sans type chaîne");
                }
            }
        }

        Assert.That(offenders, Is.Empty);

        static IEnumerable<string> TypeNames(JsonNode? type) => type switch
        {
            JsonArray array => array.Select(item => item!.GetValue<string>()),
            JsonValue value => [value.GetValue<string>()],
            _ => [],
        };
    }

    [Test]
    public void Required_fields_are_exact()
    {
        var schemas = _committed["components"]!["schemas"]!;
        var siteRequired = Strings(schemas["SiteResponse"]!["required"]);

        Assert.Multiple(() =>
        {
            Assert.That(siteRequired, Does.Not.Contain("contractAmount"), "Le montant est absent (et non nul) sans permission.");
            Assert.That(siteRequired, Does.Contain("contractualEndDate").And.Contain("version"));
            Assert.That(schemas["LoginRequest"]!["properties"]!["userName"]!["type"]!.GetValue<string>(), Is.EqualTo("string"), "Un champ obligatoire de requête n'est pas nul.");
            Assert.That(Strings(schemas["AuthResult"]!["required"]), Is.EqualTo(new[] { "user" }), "Les jetons n'existent que pour le mobile.");
            Assert.That(Strings(schemas["SyncPushOperation"]!["required"]), Is.EquivalentTo(new[] { "clientId", "entity", "operation" }));
        });
    }

    [Test]
    public void The_synchronisation_contract_describes_the_pull_and_the_push_exactly()
    {
        var schemas = _committed["components"]!["schemas"]!;
        var changes = _committed["paths"]!["/api/v1/sync/changes"]!["get"]!;
        var queryParameters = changes["parameters"]!.AsArray().Select(parameter => parameter!["name"]!.GetValue<string>()).ToList();

        Assert.Multiple(() =>
        {
            Assert.That(queryParameters, Is.EquivalentTo(new[] { "since", "siteId", "limit" }));
            Assert.That(Strings(schemas["SyncPullResponse"]!["required"]), Is.EquivalentTo(new[] { "changes", "deleted", "cursor", "hasMore" }));
            Assert.That(schemas["SyncPushResult"]!["properties"]!.AsObject().Select(entry => entry.Key), Is.EquivalentTo(new[] { "clientId", "status", "resource", "current", "code", "merged", "errors" }));
            Assert.That(schemas["SyncMemberData"]!["properties"]!.AsObject().Select(entry => entry.Key), Is.EquivalentTo(new[] { "id", "siteId", "userId", "fullName", "role", "assignedAt" }), "Jamais de téléphone.");
            Assert.That(_committed["paths"]!["/api/v1/sync/push"]!["post"]!["responses"]!.AsObject().Select(entry => entry.Key), Does.Contain("413"));
        });
    }

    [Test]
    public void No_phone_number_is_exposed_by_any_schema_except_the_profile_of_its_owner()
    {
        var offenders = _committed["components"]!["schemas"]!.AsObject()
            .Where(schema => schema.Key != "MeResponse")
            .SelectMany(schema => (schema.Value!["properties"]?.AsObject() ?? []).Select(property => (Schema: schema.Key, Property: property.Key)))
            .Where(entry => entry.Property.Contains("phone", StringComparison.OrdinalIgnoreCase))
            .Select(entry => $"{entry.Schema}.{entry.Property}");

        Assert.That(offenders, Is.Empty, "Les téléphones sont des données personnelles : seul GET /auth/me les renvoie, à son titulaire.");
    }
}
