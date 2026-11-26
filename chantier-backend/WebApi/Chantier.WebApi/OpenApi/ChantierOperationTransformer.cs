using System.Globalization;
using Chantier.WebApi.Errors;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.OpenApi;
using Microsoft.OpenApi;

namespace Chantier.WebApi.OpenApi;

/// <summary>
/// Par operation : <c>operationId</c> explicite (<c>Controleur_Action</c>, il devient le nom du hook ou de la methode generes : le renommer
/// est un changement de contrat), securite, reponses d'erreur communes (Problem Details) et un seul type de contenu par corps.
/// </summary>
public sealed class ChantierOperationTransformer : IOpenApiOperationTransformer
{
    public const string ProblemContentType = "application/problem+json";
    private const string JsonContentType = "application/json";

    /// <summary>Routes d'<c>auth</c> encore permises avec un mot de passe provisoire : elles ne renvoient jamais <c>MOT_DE_PASSE_A_CHANGER</c>.</summary>
    private static readonly string[] PasswordChangeExempt = ["Auth_Me", "Auth_UpdateLanguage", "Auth_ChangePassword", "Auth_Logout"];

    public Task TransformAsync(OpenApiOperation operation, OpenApiOperationTransformerContext context, CancellationToken cancellationToken)
    {
        var descriptor = context.Description.ActionDescriptor;
        if (descriptor is ControllerActionDescriptor controllerAction)
        {
            operation.OperationId = $"{controllerAction.ControllerName}_{controllerAction.ActionName}";
        }

        var anonymous = descriptor.EndpointMetadata.OfType<IAllowAnonymous>().Any();
        operation.Security = anonymous
            ? []
            : [Requirement(context, ChantierDocumentTransformer.BearerScheme), Requirement(context, ChantierDocumentTransformer.CookieScheme)];

        AddCommonErrors(operation, context, anonymous);
        KeepOnlyJsonContentTypes(operation);
        DescribeJpegBodies(operation);
        return Task.CompletedTask;
    }

    private static OpenApiSecurityRequirement Requirement(OpenApiOperationTransformerContext context, string scheme)
        => new() { [new OpenApiSecuritySchemeReference(scheme, context.Document)] = [] };

    private static void AddCommonErrors(OpenApiOperation operation, OpenApiOperationTransformerContext context, bool anonymous)
    {
        operation.Responses ??= [];
        // Reference vers le composant « ProblemDetails » (enregistre par le transformateur de document), jamais une copie en ligne.
        IOpenApiSchema schema = new OpenApiSchemaReference(nameof(ProblemDetails), context.Document);

        if (!anonymous)
        {
            AddProblem(operation, schema, 401, "Non authentifié, session expirée ou accès retiré (`NON_AUTHENTIFIE`, `ACCES_RETIRE`).");
            if (!PasswordChangeExempt.Contains(operation.OperationId))
            {
                AddProblem(operation, schema, 403, "Rôle sans la permission requise (`INTERDIT`) ou mot de passe provisoire à changer (`MOT_DE_PASSE_A_CHANGER`).");
            }
        }

        AddProblem(operation, schema, 429, "Limite de débit dépassée (`TROP_DE_REQUETES`) ; l'en-tête `Retry-After` donne l'attente en secondes.");
        AddProblem(operation, schema, 500, "Erreur inattendue (`ERREUR_INTERNE`) ; aucun détail technique, seulement `traceId`.");
        AddProblem(operation, schema, 503, "Échec momentané de la base (`ERREUR_TEMPORAIRE`) : rien n'a été enregistré, la requête peut être renvoyée telle quelle (`Retry-After`).");

        // Les reponses « 400/404/409/413/422 » declarees par les controleurs recoivent la description du catalogue.
        foreach (var (status, response) in operation.Responses)
        {
            if (response is OpenApiResponse concrete && int.TryParse(status, NumberStyles.None, CultureInfo.InvariantCulture, out var code) && code >= 400)
            {
                concrete.Description = Describe(code, concrete.Description);
            }
        }

        // Classement par code HTTP : meme ordre quel que soit l'ordre des attributs.
        var sorted = operation.Responses
            .OrderBy(entry => int.TryParse(entry.Key, NumberStyles.None, CultureInfo.InvariantCulture, out var code) ? code : int.MaxValue)
            .ToList();
        operation.Responses = new OpenApiResponses();
        foreach (var (status, response) in sorted)
        {
            operation.Responses.Add(status, response);
        }
    }

    private static void AddProblem(OpenApiOperation operation, IOpenApiSchema schema, int status, string description)
    {
        var key = status.ToString(CultureInfo.InvariantCulture);
        if (operation.Responses!.ContainsKey(key))
        {
            return;
        }

        operation.Responses[key] = new OpenApiResponse
        {
            Description = description,
            Content = new Dictionary<string, OpenApiMediaType> { [ProblemContentType] = new() { Schema = schema } },
        };
    }

    private static string? Describe(int status, string? current) => status switch
    {
        401 when current is "Unauthorized" => "Non authentifié, session expirée ou accès retiré (`NON_AUTHENTIFIE`, `REFRESH_INVALIDE`, `ACCES_RETIRE`, `IDENTIFIANTS_INVALIDES`).",
        403 when current is "Forbidden" => "Rôle sans la permission requise (`INTERDIT`) ou mot de passe provisoire à changer (`MOT_DE_PASSE_A_CHANGER`).",
        400 when current is "Bad Request" => "Données invalides (`VALIDATION`, `DATE_INVALIDE`, `CURSEUR_INVALIDE`) ; le détail par champ est dans `errors`.",
        404 when current is "Not Found" => "Ressource introuvable **ou chantier non affecté** (`INTROUVABLE`) : la réponse est identique.",
        409 when current is "Conflict" => "Version périmée (`CONFLIT_VERSION`) ; `current` contient l'état actuel de la ressource.",
        413 when current is "Content Too Large" or "Request Entity Too Large" or "Payload Too Large" => "Lot trop volumineux (`LOT_TROP_GRAND`).",
        422 when current is "Unprocessable Entity" or "Unprocessable Content" => "Règle métier non respectée ; `code` donne la raison (voir le catalogue des codes d'erreur).",
        _ => current,
    };

    /// <summary>
    /// Corps de requete : <c>application/json</c> seulement, et le schema du corps sans enveloppe « nul ou ... » (un corps facultatif n'est pas <c>required</c>).
    /// Erreurs : <c>application/problem+json</c> seulement. Une reponse sans corps (204) n'annonce aucun contenu : le controleur declarait
    /// <c>application/json</c> sans schema, ce qui faisait generer un type « Blob » cote client.
    /// </summary>
    private static void KeepOnlyJsonContentTypes(OpenApiOperation operation)
    {
        if (operation.RequestBody?.Content is { } requestContent)
        {
            foreach (var key in requestContent.Keys.Where(key => key != JsonContentType).ToList())
            {
                requestContent.Remove(key);
            }

            foreach (var media in requestContent.Values)
            {
                if (media.Schema is OpenApiSchema { OneOf: { Count: 2 } alternatives } && alternatives.FirstOrDefault(IsNotNullSchema) is { } body)
                {
                    media.Schema = body;
                }
            }
        }

        foreach (var (status, response) in operation.Responses ?? [])
        {
            if (response.Content is { } content
                && int.TryParse(status, NumberStyles.None, CultureInfo.InvariantCulture, out var code)
                && code >= 400)
            {
                foreach (var key in content.Keys.Where(key => key != ProblemContentType).ToList())
                {
                    content.Remove(key);
                }
            }
        }

        foreach (var response in (operation.Responses ?? []).Values.OfType<OpenApiResponse>())
        {
            if (response.Content is { } content)
            {
                foreach (var key in content.Where(entry => entry.Value.Schema is null).Select(entry => entry.Key).ToList())
                {
                    content.Remove(key);
                }

                if (content.Count == 0)
                {
                    response.Content = null;
                }
            }
        }
    }

    /// <summary>
    /// Photo de bon (ADR 0013) : le corps de l'envoi et la reponse de la lecture sont l'image JPEG elle-meme (binaire), pas du JSON : le controleur lit le flux brut,
    /// le generateur ne peut pas le deduire.
    /// </summary>
    private static void DescribeJpegBodies(OpenApiOperation operation)
    {
        const string jpeg = "image/jpeg";
        if (operation.OperationId == "Photos_Upload")
        {
            operation.RequestBody = new OpenApiRequestBody
            {
                Required = true,
                Description = "Le fichier JPEG lui-même (5 Mo au plus) ; `Content-Type: image/jpeg`.",
                Content = new Dictionary<string, OpenApiMediaType> { [jpeg] = new() { Schema = new OpenApiSchema { Type = JsonSchemaType.String, Format = "binary" } } },
            };
        }
        else if (operation.OperationId == "Photos_Download" && operation.Responses?.TryGetValue("200", out var ok) == true && ok is OpenApiResponse response)
        {
            response.Description = "Le fichier JPEG (métadonnées EXIF retirées).";
            response.Content = new Dictionary<string, OpenApiMediaType> { [jpeg] = new() { Schema = new OpenApiSchema { Type = JsonSchemaType.String, Format = "binary" } } };
        }
    }

    private static bool IsNotNullSchema(IOpenApiSchema schema) => schema is not OpenApiSchema { Type: JsonSchemaType.Null };
}
