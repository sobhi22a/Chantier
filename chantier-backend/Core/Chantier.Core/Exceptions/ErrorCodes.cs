namespace Chantier.Core.Exceptions;

/// <summary>
/// Codes d'erreur metier stables du contrat d'API (docs/api/codes-erreur.md).
/// Un code existant ne change jamais de sens ni de nom.
/// </summary>
public static class ErrorCodes
{
    public const string Validation = "VALIDATION";
    public const string DateInvalide = "DATE_INVALIDE";
    public const string QuantiteInvalide = "QUANTITE_INVALIDE";
    public const string CurseurInvalide = "CURSEUR_INVALIDE";
    public const string NonAuthentifie = "NON_AUTHENTIFIE";
    public const string IdentifiantsInvalides = "IDENTIFIANTS_INVALIDES";
    public const string RefreshInvalide = "REFRESH_INVALIDE";
    public const string AccesRetire = "ACCES_RETIRE";
    public const string Interdit = "INTERDIT";
    public const string Introuvable = "INTROUVABLE";
    public const string ConflitVersion = "CONFLIT_VERSION";
    public const string LotTropGrand = "LOT_TROP_GRAND";
    public const string CodeChantierExistant = "CODE_CHANTIER_EXISTANT";
    public const string ZoneExistante = "ZONE_EXISTANTE";
    public const string ChantierArchive = "CHANTIER_ARCHIVE";
    public const string CompteDesactive = "COMPTE_DESACTIVE";
    public const string MotDePasseFaible = "MOT_DE_PASSE_FAIBLE";
    public const string MotDePasseAChanger = "MOT_DE_PASSE_A_CHANGER";
    public const string EntiteNonSynchronisable = "ENTITE_NON_SYNCHRONISABLE";
    public const string TropDEssais = "TROP_D_ESSAIS";
    public const string TropDeRequetes = "TROP_DE_REQUETES";
    public const string ErreurInterne = "ERREUR_INTERNE";
    public const string UniteObligatoire = "UNITE_OBLIGATOIRE";
    public const string UnitesIncompatibles = "UNITES_INCOMPATIBLES";
    public const string ExpressionInvalide = "EXPRESSION_INVALIDE";
    public const string TransitionInterdite = "TRANSITION_INTERDITE";
}
