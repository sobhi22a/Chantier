using System.Reflection;
using System.Security.Cryptography;

namespace Chantier.WebApi.OpenApi;

/// <summary>
/// Vrai quand l'application est demarree par l'outil de generation du document OpenAPI au build
/// (<c>Microsoft.Extensions.ApiDescription.Server</c> lance <c>GetDocument.Insider</c>). L'hote demarre vraiment (la validation des
/// options a lieu) : il ne faut alors ni migrer ni amorcer la base, et il ne faut exiger aucun secret sur le poste ou l'agent de CI.
/// </summary>
public static class OpenApiGeneration
{
    public static bool IsRunning => Assembly.GetEntryAssembly()?.GetName().Name == "GetDocument.Insider";

    /// <summary>
    /// Reglages jetables, valables pendant la generation seulement : cle JWT aleatoire (jamais ecrite ni reutilisee), pas de vraie base,
    /// cles de protection des donnees dans un dossier temporaire. Rien de sensible n'est donc necessaire pour construire le projet.
    /// </summary>
    public static IReadOnlyDictionary<string, string?> Settings() => new Dictionary<string, string?>
    {
        ["JwtSettings:Key"] = Convert.ToBase64String(RandomNumberGenerator.GetBytes(48)),
        ["ConnectionStrings:ChantierDb"] = "Server=generation-openapi;Database=none;Integrated Security=true",
        ["Storage:DataProtectionKeys"] = Path.Combine(Path.GetTempPath(), "chantier-openapi-keys"),

        // Racine des photos jetable et absolue (validee en production, R2-10) ; aucun fichier n'y est ecrit.
        ["Storage:PhotosRoot"] = Path.Combine(Path.GetTempPath(), "chantier-openapi-photos"),
        ["Storage:MaintenanceIntervalMinutes"] = "0",
        ["Database:MigrateOnStartup"] = "false",
        ["DataProtection:AllowUnencryptedKeys"] = "true",
    };
}
