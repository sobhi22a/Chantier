// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Chantier';

  @override
  String get sitesTitle => 'Mes chantiers';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get errorValidation =>
      'Certaines informations sont invalides. Vérifiez les champs.';

  @override
  String get errorDateInvalide =>
      'Date invalide : le jour, le mois et l\'année sont obligatoires.';

  @override
  String get errorQuantiteInvalide =>
      'La quantité doit être supérieure à zéro.';

  @override
  String get errorCurseurInvalide =>
      'La synchronisation doit repartir de zéro. Vos saisies en attente sont conservées.';

  @override
  String get errorNonAuthentifie => 'Session expirée. Reconnectez-vous.';

  @override
  String get errorIdentifiantsInvalides =>
      'Identifiant ou mot de passe incorrect, ou compte inactif. Contactez votre administrateur.';

  @override
  String get errorRefreshInvalide =>
      'Votre session n\'est plus valide. Reconnectez-vous : vos saisies en attente sont conservées.';

  @override
  String get errorAccesRetire =>
      'Accès retiré, contactez votre administrateur.';

  @override
  String get errorInterdit =>
      'Vous n\'avez pas le droit de faire cette action.';

  @override
  String get errorIntrouvable => 'Élément introuvable.';

  @override
  String get errorConflitVersion =>
      'Cet élément a été modifié entre-temps. Rechargez-le.';

  @override
  String get errorLotTropGrand => 'Envoi trop volumineux.';

  @override
  String get errorCodeChantierExistant => 'Ce code de chantier existe déjà.';

  @override
  String get errorZoneExistante => 'Cette zone existe déjà sur ce chantier.';

  @override
  String get errorChantierArchive =>
      'Ce chantier est archivé : plus aucune saisie n\'est possible.';

  @override
  String get errorCompteDesactive => 'Ce compte est désactivé.';

  @override
  String get errorMotDePasseFaible =>
      'Mot de passe trop faible. Choisissez-en un plus long et plus varié.';

  @override
  String get errorMotDePasseAChanger =>
      'Mot de passe provisoire : choisissez votre mot de passe avant de continuer.';

  @override
  String get errorEntiteNonSynchronisable =>
      'Ce type de saisie ne peut pas encore être envoyé.';

  @override
  String get errorTropDEssais => 'Trop d\'essais, réessayez plus tard.';

  @override
  String get errorTropDeRequetes => 'Trop de requêtes, patientez un instant.';

  @override
  String get errorErreurInterne => 'Erreur du serveur. Réessayez plus tard.';

  @override
  String get errorUniteObligatoire => 'L\'unité est obligatoire.';

  @override
  String get errorUnitesIncompatibles =>
      'Unités incompatibles : impossible de les additionner.';

  @override
  String get errorExpressionInvalide => 'Expression de métré invalide.';

  @override
  String get errorTransitionInterdite =>
      'Ce changement de statut n\'est pas autorisé.';

  @override
  String get errorNetwork =>
      'Pas de réseau. Vos saisies sont conservées et partiront au retour du réseau.';

  @override
  String get errorTimeout =>
      'Le serveur met trop de temps à répondre. Réessayez.';

  @override
  String get errorUnknown => 'Une erreur est survenue. Réessayez.';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionRefresh => 'Actualiser';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginUserName => 'Identifiant';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginShowPassword => 'Afficher le mot de passe';

  @override
  String get loginHidePassword => 'Masquer le mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginSubmitting => 'Connexion en cours…';

  @override
  String get loginFieldRequired => 'Champ obligatoire';

  @override
  String get loginFirstConnectionTitle =>
      'Première connexion : réseau nécessaire';

  @override
  String get loginFirstConnectionBody =>
      'Connectez-vous à internet pour ouvrir votre session. Vos chantiers seront ensuite disponibles sans réseau.';

  @override
  String get noticeSessionExpired =>
      'Votre session a expiré. Reconnectez-vous : vos saisies en attente sont conservées.';

  @override
  String get passwordChangeTitle => 'Nouveau mot de passe';

  @override
  String get passwordChangeIntro =>
      'Votre mot de passe est provisoire. Choisissez-en un nouveau avant de continuer.';

  @override
  String get passwordCurrent => 'Mot de passe provisoire';

  @override
  String get passwordNew => 'Nouveau mot de passe';

  @override
  String get passwordConfirm => 'Confirmer le nouveau mot de passe';

  @override
  String get passwordMismatch => 'Les deux mots de passe sont différents.';

  @override
  String get passwordChangeSubmit => 'Enregistrer le mot de passe';

  @override
  String get logoutTitle => 'Se déconnecter';

  @override
  String get logoutConfirmBody =>
      'Vous allez fermer votre session. Les données chantier seront effacées de ce téléphone.';

  @override
  String get logoutConfirm => 'Se déconnecter';

  @override
  String logoutPendingTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saisies ne sont pas encore envoyées',
      one: '1 saisie n\'est pas encore envoyée',
    );
    return '$_temp0';
  }

  @override
  String get logoutSendFirst => 'Envoyer d\'abord';

  @override
  String get logoutStay => 'Rester connecté';

  @override
  String get logoutAnyway => 'Se déconnecter quand même';

  @override
  String get logoutAnywayTitle =>
      'Se déconnecter avec des saisies en attente ?';

  @override
  String get logoutAnywayBody =>
      'Elles restent sur ce téléphone, mais ne partiront qu\'après votre reconnexion avec ce même compte.';

  @override
  String get logoutSending => 'Envoi en cours…';

  @override
  String get logoutSendFailed =>
      'L\'envoi n\'a pas abouti. Vos saisies sont conservées.';

  @override
  String get syncUpToDate => 'À jour';

  @override
  String syncUpToDateAt(String when) {
    return 'À jour · $when';
  }

  @override
  String get syncOffline => 'Hors ligne';

  @override
  String syncPending(int count) {
    return '$count à envoyer';
  }

  @override
  String get syncSyncing => 'Synchronisation…';

  @override
  String syncProblem(int count) {
    return '$count à vérifier';
  }

  @override
  String get syncProblemServer => 'Problème de synchronisation';

  @override
  String get syncAuthRequired => 'Reconnexion nécessaire';

  @override
  String syncWhenToday(String time) {
    return 'aujourd\'hui $time';
  }

  @override
  String syncStaleBanner(String when) {
    return 'Données du $when';
  }

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncDetailsHint => 'Voir les envois en attente';

  @override
  String get sitesEmpty =>
      'Aucun chantier ne vous est affecté. Contactez votre administrateur.';

  @override
  String get sitesPreparing => 'Préparation de vos chantiers…';

  @override
  String sitesPreparingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments reçus',
      one: '1 élément reçu',
      zero: 'Aucun élément reçu pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get sitesFirstSyncOffline =>
      'Pas de réseau : vos chantiers n\'ont pas encore été reçus. Connectez-vous à internet pour les préparer.';

  @override
  String get sitesSearchHint => 'Rechercher un chantier';

  @override
  String get sitesShowArchived => 'Afficher les archivés';

  @override
  String get sitesNoResult => 'Aucun chantier ne correspond.';

  @override
  String get sitesCurrentBadge => 'Chantier courant';

  @override
  String get sitesArchivedBadge => 'Archivé';

  @override
  String sitesDataFrom(String when) {
    return 'Données du $when';
  }

  @override
  String get sitesChooseTitle => 'Choisir un chantier';

  @override
  String get sitesChooseRequired =>
      'Choisissez votre chantier avant de faire une saisie.';

  @override
  String get sitesCurrentRemoved =>
      'Votre chantier courant ne vous est plus affecté. Choisissez-en un autre.';

  @override
  String get siteInfoTitle => 'Informations';

  @override
  String get siteType => 'Type d\'ouvrage';

  @override
  String get siteTypeSchool => 'École';

  @override
  String get siteTypeHousing => 'Logements';

  @override
  String get siteTypePublicFacility => 'Équipement public';

  @override
  String get siteTypeOther => 'Autre';

  @override
  String get siteWilaya => 'Wilaya';

  @override
  String get siteCommune => 'Commune';

  @override
  String get siteCoordinates => 'Coordonnées GPS';

  @override
  String get siteOwner => 'Maître d\'ouvrage';

  @override
  String get siteContractNumber => 'N° de marché';

  @override
  String get siteContractAmount => 'Montant';

  @override
  String get siteDelay => 'Délai';

  @override
  String siteDelayDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get siteOds => 'ODS de démarrage';

  @override
  String get siteEndDate => 'Fin contractuelle';

  @override
  String get siteToDefine => 'À définir';

  @override
  String get siteZonesTitle => 'Zones';

  @override
  String get siteNoZones => 'Aucune zone pour ce chantier.';

  @override
  String get siteMembersTitle => 'Personnes affectées';

  @override
  String siteCreatedBy(String name, String when) {
    return 'Créé par $name le $when';
  }

  @override
  String siteUpdatedBy(String name, String when) {
    return 'Modifié par $name le $when';
  }

  @override
  String get siteNotFound => 'Chantier introuvable.';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleDirection => 'Direction';

  @override
  String get roleConducteurTravaux => 'Conducteur de travaux';

  @override
  String get roleAchats => 'Achats';

  @override
  String get roleChefChantier => 'Chef de chantier';

  @override
  String get roleChefEquipe => 'Chef d\'équipe';

  @override
  String get roomTypeClassroom => 'Classe';

  @override
  String get roomTypeCorridor => 'Couloir';

  @override
  String get roomTypeCanteen => 'Cantine';

  @override
  String get roomTypeRefectory => 'Réfectoire';

  @override
  String get roomTypeKitchen => 'Cuisine';

  @override
  String get roomTypeOffice => 'Bureau';

  @override
  String get roomTypeSanitary => 'Sanitaires';

  @override
  String get roomTypeTechnicalRoom => 'Local technique';

  @override
  String get roomTypeFacade => 'Façade';

  @override
  String get roomTypeOther => 'Autre';

  @override
  String get zonePendingBadge => 'En attente d\'envoi';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAccount => 'Compte';

  @override
  String get zoneAddButton => '+ Zone';

  @override
  String get zoneAddTitle => 'Ajouter une zone';

  @override
  String get zoneBlock => 'Bloc';

  @override
  String get zoneBlockNew => 'Nouveau bloc';

  @override
  String get zoneBlockNewLabel => 'Nom du bloc';

  @override
  String get zoneElevation => 'Cote';

  @override
  String get zoneElevationOther => 'Autre cote';

  @override
  String get zoneElevationNone => 'Sans cote';

  @override
  String get zoneElevationUnit => 'en mètres';

  @override
  String get zoneElevationLabel => 'Cote (m)';

  @override
  String zoneElevationHelp(String min, String max) {
    return 'En mètres, de $min à $max.';
  }

  @override
  String get zoneElevationInvalid =>
      'Cote invalide : chiffres seulement (par exemple 3,4).';

  @override
  String zoneElevationOutOfRange(String min, String max) {
    return 'La cote doit être comprise entre $min et $max m.';
  }

  @override
  String get zoneRoomType => 'Type de local';

  @override
  String get zoneRoomNone => 'Aucun local';

  @override
  String get zoneRoomNumber => 'Numéro';

  @override
  String get zoneRoomNumberMore => 'Numéro suivant';

  @override
  String get zoneRoomNumberLess => 'Numéro précédent';

  @override
  String get zoneRoomLabel => 'Libellé du local';

  @override
  String get zoneRoomLabelRequired => 'Précisez le local.';

  @override
  String get zoneBlockRequired => 'Choisissez ou créez un bloc.';

  @override
  String get zoneSave => 'Enregistrer';

  @override
  String get zoneSavedPending => 'Zone enregistrée. En attente d\'envoi.';

  @override
  String get zoneExists => 'Cette zone existe déjà.';

  @override
  String get zoneSearchHint => 'Rechercher (par exemple « cl 02 »)';

  @override
  String get zonePickerTitle => 'Choisir une zone';

  @override
  String get zonePickerConfirm => 'Valider';

  @override
  String get zonePickerNone => 'Non précisée';

  @override
  String get zonePickerNoResult => 'Aucune zone ne correspond.';

  @override
  String get pendingTitle => 'Envois en attente';

  @override
  String get pendingEmpty => 'Rien à envoyer. Tout est à jour.';

  @override
  String pendingSavedAt(String when) {
    return 'Saisi le $when';
  }

  @override
  String get pendingStatusPending => 'En attente d\'envoi';

  @override
  String get pendingStatusSending => 'Envoi en cours';

  @override
  String get pendingStatusToCheck => 'À vérifier';

  @override
  String get pendingEntityZone => 'Zone';

  @override
  String get pendingCorrect => 'Corriger';

  @override
  String get pendingAbandon => 'Abandonner';

  @override
  String get pendingAbandonTitle => 'Abandonner cette saisie ?';

  @override
  String get pendingAbandonBody =>
      'Elle sera supprimée de ce téléphone. Cette action est définitive.';

  @override
  String pendingReason(String reason) {
    return 'Motif : $reason';
  }

  @override
  String get pendingSyncFailed =>
      'La synchronisation n\'a pas abouti. Vos saisies sont conservées.';
}
