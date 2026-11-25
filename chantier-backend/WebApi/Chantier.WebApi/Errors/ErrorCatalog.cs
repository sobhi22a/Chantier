using Chantier.Core.Exceptions;

namespace Chantier.WebApi.Errors;

/// <summary>
/// Catalogue des codes d'erreur : statut, titre et message francais par defaut (docs/api/codes-erreur.md).
/// Les clients traduisent par <c>code</c> ; le message francais ne sert que de repli.
/// Aucun message ne contient de nom, d'identifiant de connexion ni de telephone (CA-017.2).
/// </summary>
public static class ErrorCatalog
{
    public sealed record Entry(int Status, string Title, string Detail);

    private static readonly Dictionary<string, Entry> Entries = new(StringComparer.Ordinal)
    {
        [ErrorCodes.Validation] = new(400, "Données invalides", "Une ou plusieurs valeurs sont invalides."),
        [ErrorCodes.DateInvalide] = new(400, "Date invalide", "La date est incomplète ou impossible."),
        [ErrorCodes.QuantiteInvalide] = new(422, "Quantité invalide", "La quantité doit être supérieure à zéro."),
        [ErrorCodes.CurseurInvalide] = new(400, "Curseur invalide", "Le curseur de synchronisation est illisible."),
        [ErrorCodes.NonAuthentifie] = new(401, "Non authentifié", "Connexion requise."),
        [ErrorCodes.IdentifiantsInvalides] = new(401, "Identifiants invalides", "Identifiant ou mot de passe incorrect, ou compte inactif. Contactez votre administrateur."),
        [ErrorCodes.RefreshInvalide] = new(401, "Session expirée", "Session expirée. Reconnectez-vous."),
        [ErrorCodes.AccesRetire] = new(401, "Accès retiré", "Accès retiré, contactez votre administrateur."),
        [ErrorCodes.Interdit] = new(403, "Action non autorisée", "Action non autorisée pour votre rôle."),
        [ErrorCodes.Introuvable] = new(404, "Introuvable", NotFoundException.DefaultMessage),
        [ErrorCodes.ConflitVersion] = new(409, "Conflit de version", "La ressource a été modifiée entre-temps."),
        [ErrorCodes.LotTropGrand] = new(413, "Lot trop volumineux", "Le lot envoyé est trop volumineux."),
        [ErrorCodes.CodeChantierExistant] = new(422, "Code de chantier déjà utilisé", "Ce code de chantier existe déjà."),
        [ErrorCodes.ZoneExistante] = new(422, "Zone déjà existante", "Une zone identique existe déjà sur ce chantier."),
        [ErrorCodes.ChantierArchive] = new(422, "Chantier archivé", "Ce chantier est archivé : il est en lecture seule."),
        [ErrorCodes.CompteDesactive] = new(422, "Compte désactivé", "Ce compte est désactivé."),
        [ErrorCodes.MotDePasseFaible] = new(422, "Mot de passe faible", "Le mot de passe ne respecte pas la politique de sécurité."),
        [ErrorCodes.MotDePasseAChanger] = new(403, "Changement de mot de passe requis", "Vous devez choisir un nouveau mot de passe avant de continuer."),
        [ErrorCodes.EntiteNonSynchronisable] = new(422, "Entité non synchronisable", "Cette entité ne peut pas être synchronisée."),
        [ErrorCodes.TropDEssais] = new(429, "Trop d'essais", "Trop d'essais, réessayez plus tard."),
        [ErrorCodes.TropDeRequetes] = new(429, "Trop de requêtes", "Trop de requêtes, réessayez dans un instant."),
        [ErrorCodes.ErreurInterne] = new(500, "Erreur interne", "Une erreur inattendue est survenue. Si elle persiste, communiquez l'identifiant de trace au support."),
        [ErrorCodes.UniteObligatoire] = new(422, "Unité obligatoire", "Une quantité doit toujours avoir une unité."),
        [ErrorCodes.UnitesIncompatibles] = new(422, "Unités incompatibles", "Des unités différentes ne peuvent pas être additionnées."),
        [ErrorCodes.ExpressionInvalide] = new(422, "Expression invalide", "L'expression de métré est invalide."),
        [ErrorCodes.TransitionInterdite] = new(422, "Transition interdite", "Ce changement de statut n'est pas autorisé."),
    };

    public static Entry Get(string code) =>
        Entries.TryGetValue(code, out var entry) ? entry : new Entry(422, "Règle métier non respectée", "Une règle métier n'est pas respectée.");

    /// <summary>Code par defaut d'une reponse generee par le framework (route inconnue, 401 sans corps, etc.).</summary>
    public static string CodeForStatus(int status) => status switch
    {
        401 => ErrorCodes.NonAuthentifie,
        403 => ErrorCodes.Interdit,
        404 => ErrorCodes.Introuvable,
        409 => ErrorCodes.ConflitVersion,
        413 => ErrorCodes.LotTropGrand,
        429 => ErrorCodes.TropDeRequetes,
        >= 500 => ErrorCodes.ErreurInterne,
        _ => ErrorCodes.Validation,
    };

    /// <summary>URI stable de type d'erreur (RFC 9457), derivee du code.</summary>
    public static string TypeUri(string code) =>
        $"https://chantier.local/errors/{code.ToLowerInvariant().Replace('_', '-')}";
}
