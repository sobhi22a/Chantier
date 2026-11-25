using Microsoft.AspNetCore.OpenApi;

namespace Chantier.WebApi.OpenApi;

/// <summary>
/// Document OpenAPI du contrat (ADR 0006). Le fichier genere est commite dans <c>docs/api/openapi.json</c> et fait foi : web et mobile
/// generent leurs clients depuis lui. Les transformateurs ci-dessous le rendent <b>stable</b> (ordre fixe), <b>exact</b> (types, champs
/// obligatoires, erreurs) et <b>lisible par les generateurs</b> (noms d'operations explicites, un seul type de contenu).
/// </summary>
public static class ChantierOpenApi
{
    public const string Title = "Chantier API";

    /// <summary>Version du contrat (et non de l'application) : change seulement avec une evolution du contrat.</summary>
    public const string ContractVersion = "1.0.0";

    public static IServiceCollection AddChantierOpenApi(this IServiceCollection services)
        => services.AddOpenApi(options =>
        {
            options.AddDocumentTransformer<ChantierDocumentTransformer>();
            options.AddOperationTransformer<ChantierOperationTransformer>();
            options.AddSchemaTransformer<ChantierSchemaTransformer>();
        });
}
