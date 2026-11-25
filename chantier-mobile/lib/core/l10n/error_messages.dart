import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';

/// Traduit une erreur de l'API en texte pour l'utilisateur, **par `code`** (catalogue
/// `docs/api/codes-erreur.md`). Le texte brut du serveur n'est jamais affiche (CA-014.5, M-9).
String apiErrorMessage(AppLocalizations l10n, ApiException error) =>
    errorMessageForCode(l10n, error.code) ?? _fallback(l10n, error);

/// Message d'un code du catalogue ; `null` si le code est inconnu de cette version.
String? errorMessageForCode(AppLocalizations l10n, String? code) =>
    switch (code) {
      'VALIDATION' => l10n.errorValidation,
      'DATE_INVALIDE' => l10n.errorDateInvalide,
      'QUANTITE_INVALIDE' => l10n.errorQuantiteInvalide,
      'CURSEUR_INVALIDE' => l10n.errorCurseurInvalide,
      'NON_AUTHENTIFIE' => l10n.errorNonAuthentifie,
      'IDENTIFIANTS_INVALIDES' => l10n.errorIdentifiantsInvalides,
      'REFRESH_INVALIDE' => l10n.errorRefreshInvalide,
      'ACCES_RETIRE' => l10n.errorAccesRetire,
      'INTERDIT' => l10n.errorInterdit,
      'INTROUVABLE' => l10n.errorIntrouvable,
      'CONFLIT_VERSION' => l10n.errorConflitVersion,
      'LOT_TROP_GRAND' => l10n.errorLotTropGrand,
      'CODE_CHANTIER_EXISTANT' => l10n.errorCodeChantierExistant,
      'ZONE_EXISTANTE' => l10n.errorZoneExistante,
      'CHANTIER_ARCHIVE' => l10n.errorChantierArchive,
      'COMPTE_DESACTIVE' => l10n.errorCompteDesactive,
      'MOT_DE_PASSE_FAIBLE' => l10n.errorMotDePasseFaible,
      'MOT_DE_PASSE_A_CHANGER' => l10n.errorMotDePasseAChanger,
      'ENTITE_NON_SYNCHRONISABLE' => l10n.errorEntiteNonSynchronisable,
      'TROP_D_ESSAIS' => l10n.errorTropDEssais,
      'TROP_DE_REQUETES' => l10n.errorTropDeRequetes,
      'ERREUR_INTERNE' => l10n.errorErreurInterne,
      'UNITE_OBLIGATOIRE' => l10n.errorUniteObligatoire,
      'UNITES_INCOMPATIBLES' => l10n.errorUnitesIncompatibles,
      'EXPRESSION_INVALIDE' => l10n.errorExpressionInvalide,
      'TRANSITION_INTERDITE' => l10n.errorTransitionInterdite,
      _ => null,
    };

/// Code inconnu ou absent : le type d'erreur decide du message.
String _fallback(AppLocalizations l10n, ApiException error) => switch (error) {
  NetworkApiException() => l10n.errorNetwork,
  TimeoutApiException() => l10n.errorTimeout,
  ValidationApiException() => l10n.errorValidation,
  UnauthorizedApiException() => l10n.errorNonAuthentifie,
  ForbiddenApiException() => l10n.errorInterdit,
  NotFoundApiException() => l10n.errorIntrouvable,
  ConflictApiException() => l10n.errorConflitVersion,
  PayloadTooLargeApiException() => l10n.errorLotTropGrand,
  TooManyRequestsApiException() => l10n.errorTropDeRequetes,
  ServerApiException() => l10n.errorErreurInterne,
  BusinessRuleApiException() || UnknownApiException() => l10n.errorUnknown,
};
