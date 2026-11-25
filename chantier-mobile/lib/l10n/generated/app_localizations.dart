import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// Nom de l'application
  ///
  /// In fr, this message translates to:
  /// **'Chantier'**
  String get appName;

  /// No description provided for @sitesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes chantiers'**
  String get sitesTitle;

  /// No description provided for @languageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageLabel;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @actionRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get actionRetry;

  /// Code serveur VALIDATION
  ///
  /// In fr, this message translates to:
  /// **'Certaines informations sont invalides. Vérifiez les champs.'**
  String get errorValidation;

  /// No description provided for @errorDateInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Date invalide : le jour, le mois et l\'année sont obligatoires.'**
  String get errorDateInvalide;

  /// No description provided for @errorQuantiteInvalide.
  ///
  /// In fr, this message translates to:
  /// **'La quantité doit être supérieure à zéro.'**
  String get errorQuantiteInvalide;

  /// No description provided for @errorCurseurInvalide.
  ///
  /// In fr, this message translates to:
  /// **'La synchronisation doit repartir de zéro. Vos saisies en attente sont conservées.'**
  String get errorCurseurInvalide;

  /// No description provided for @errorNonAuthentifie.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée. Reconnectez-vous.'**
  String get errorNonAuthentifie;

  /// No description provided for @errorIdentifiantsInvalides.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe incorrect, ou compte inactif. Contactez votre administrateur.'**
  String get errorIdentifiantsInvalides;

  /// No description provided for @errorRefreshInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Votre session n\'est plus valide. Reconnectez-vous : vos saisies en attente sont conservées.'**
  String get errorRefreshInvalide;

  /// No description provided for @errorAccesRetire.
  ///
  /// In fr, this message translates to:
  /// **'Accès retiré, contactez votre administrateur.'**
  String get errorAccesRetire;

  /// No description provided for @errorInterdit.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas le droit de faire cette action.'**
  String get errorInterdit;

  /// No description provided for @errorIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Élément introuvable.'**
  String get errorIntrouvable;

  /// No description provided for @errorConflitVersion.
  ///
  /// In fr, this message translates to:
  /// **'Cet élément a été modifié entre-temps. Rechargez-le.'**
  String get errorConflitVersion;

  /// No description provided for @errorLotTropGrand.
  ///
  /// In fr, this message translates to:
  /// **'Envoi trop volumineux.'**
  String get errorLotTropGrand;

  /// No description provided for @errorCodeChantierExistant.
  ///
  /// In fr, this message translates to:
  /// **'Ce code de chantier existe déjà.'**
  String get errorCodeChantierExistant;

  /// No description provided for @errorZoneExistante.
  ///
  /// In fr, this message translates to:
  /// **'Cette zone existe déjà sur ce chantier.'**
  String get errorZoneExistante;

  /// No description provided for @errorChantierArchive.
  ///
  /// In fr, this message translates to:
  /// **'Ce chantier est archivé : plus aucune saisie n\'est possible.'**
  String get errorChantierArchive;

  /// No description provided for @errorCompteDesactive.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est désactivé.'**
  String get errorCompteDesactive;

  /// No description provided for @errorMotDePasseFaible.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible. Choisissez-en un plus long et plus varié.'**
  String get errorMotDePasseFaible;

  /// No description provided for @errorMotDePasseAChanger.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe provisoire : choisissez votre mot de passe avant de continuer.'**
  String get errorMotDePasseAChanger;

  /// No description provided for @errorEntiteNonSynchronisable.
  ///
  /// In fr, this message translates to:
  /// **'Ce type de saisie ne peut pas encore être envoyé.'**
  String get errorEntiteNonSynchronisable;

  /// No description provided for @errorTropDEssais.
  ///
  /// In fr, this message translates to:
  /// **'Trop d\'essais, réessayez plus tard.'**
  String get errorTropDEssais;

  /// No description provided for @errorTropDeRequetes.
  ///
  /// In fr, this message translates to:
  /// **'Trop de requêtes, patientez un instant.'**
  String get errorTropDeRequetes;

  /// No description provided for @errorErreurInterne.
  ///
  /// In fr, this message translates to:
  /// **'Erreur du serveur. Réessayez plus tard.'**
  String get errorErreurInterne;

  /// No description provided for @errorUniteObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'L\'unité est obligatoire.'**
  String get errorUniteObligatoire;

  /// No description provided for @errorUnitesIncompatibles.
  ///
  /// In fr, this message translates to:
  /// **'Unités incompatibles : impossible de les additionner.'**
  String get errorUnitesIncompatibles;

  /// No description provided for @errorExpressionInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Expression de métré invalide.'**
  String get errorExpressionInvalide;

  /// No description provided for @errorTransitionInterdite.
  ///
  /// In fr, this message translates to:
  /// **'Ce changement de statut n\'est pas autorisé.'**
  String get errorTransitionInterdite;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réseau. Vos saisies sont conservées et partiront au retour du réseau.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur met trop de temps à répondre. Réessayez.'**
  String get errorTimeout;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errorUnknown;

  /// No description provided for @actionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get actionConfirm;

  /// No description provided for @actionRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get actionRefresh;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginUserName.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get loginUserName;

  /// No description provided for @loginPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPassword;

  /// No description provided for @loginShowPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get loginHidePassword;

  /// No description provided for @loginSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginSubmit;

  /// No description provided for @loginSubmitting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion en cours…'**
  String get loginSubmitting;

  /// No description provided for @loginFieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get loginFieldRequired;

  /// No description provided for @loginFirstConnectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Première connexion : réseau nécessaire'**
  String get loginFirstConnectionTitle;

  /// No description provided for @loginFirstConnectionBody.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous à internet pour ouvrir votre session. Vos chantiers seront ensuite disponibles sans réseau.'**
  String get loginFirstConnectionBody;

  /// No description provided for @noticeSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expiré. Reconnectez-vous : vos saisies en attente sont conservées.'**
  String get noticeSessionExpired;

  /// No description provided for @passwordChangeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get passwordChangeTitle;

  /// No description provided for @passwordChangeIntro.
  ///
  /// In fr, this message translates to:
  /// **'Votre mot de passe est provisoire. Choisissez-en un nouveau avant de continuer.'**
  String get passwordChangeIntro;

  /// No description provided for @passwordCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe provisoire'**
  String get passwordCurrent;

  /// No description provided for @passwordNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get passwordNew;

  /// No description provided for @passwordConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le nouveau mot de passe'**
  String get passwordConfirm;

  /// No description provided for @passwordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux mots de passe sont différents.'**
  String get passwordMismatch;

  /// No description provided for @passwordChangeSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le mot de passe'**
  String get passwordChangeSubmit;

  /// No description provided for @logoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous allez fermer votre session. Les données chantier seront effacées de ce téléphone.'**
  String get logoutConfirmBody;

  /// No description provided for @logoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logoutConfirm;

  /// No description provided for @logoutPendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 saisie n\'est pas encore envoyée} other{{count} saisies ne sont pas encore envoyées}}'**
  String logoutPendingTitle(int count);

  /// No description provided for @logoutSendFirst.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer d\'abord'**
  String get logoutSendFirst;

  /// No description provided for @logoutStay.
  ///
  /// In fr, this message translates to:
  /// **'Rester connecté'**
  String get logoutStay;

  /// No description provided for @logoutAnyway.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter quand même'**
  String get logoutAnyway;

  /// No description provided for @logoutAnywayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter avec des saisies en attente ?'**
  String get logoutAnywayTitle;

  /// No description provided for @logoutAnywayBody.
  ///
  /// In fr, this message translates to:
  /// **'Elles restent sur ce téléphone, mais ne partiront qu\'après votre reconnexion avec ce même compte.'**
  String get logoutAnywayBody;

  /// No description provided for @logoutSending.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours…'**
  String get logoutSending;

  /// No description provided for @logoutSendFailed.
  ///
  /// In fr, this message translates to:
  /// **'L\'envoi n\'a pas abouti. Vos saisies sont conservées.'**
  String get logoutSendFailed;

  /// No description provided for @syncUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'À jour'**
  String get syncUpToDate;

  /// No description provided for @syncUpToDateAt.
  ///
  /// In fr, this message translates to:
  /// **'À jour · {when}'**
  String syncUpToDateAt(String when);

  /// No description provided for @syncOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get syncOffline;

  /// No description provided for @syncPending.
  ///
  /// In fr, this message translates to:
  /// **'{count} à envoyer'**
  String syncPending(int count);

  /// No description provided for @syncSyncing.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation…'**
  String get syncSyncing;

  /// No description provided for @syncProblem.
  ///
  /// In fr, this message translates to:
  /// **'{count} à vérifier'**
  String syncProblem(int count);

  /// No description provided for @syncProblemServer.
  ///
  /// In fr, this message translates to:
  /// **'Problème de synchronisation'**
  String get syncProblemServer;

  /// No description provided for @syncAuthRequired.
  ///
  /// In fr, this message translates to:
  /// **'Reconnexion nécessaire'**
  String get syncAuthRequired;

  /// No description provided for @syncWhenToday.
  ///
  /// In fr, this message translates to:
  /// **'aujourd\'hui {time}'**
  String syncWhenToday(String time);

  /// No description provided for @syncStaleBanner.
  ///
  /// In fr, this message translates to:
  /// **'Données du {when}'**
  String syncStaleBanner(String when);

  /// No description provided for @syncNow.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser maintenant'**
  String get syncNow;

  /// No description provided for @syncDetailsHint.
  ///
  /// In fr, this message translates to:
  /// **'Voir les envois en attente'**
  String get syncDetailsHint;

  /// No description provided for @sitesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun chantier ne vous est affecté. Contactez votre administrateur.'**
  String get sitesEmpty;

  /// No description provided for @sitesPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation de vos chantiers…'**
  String get sitesPreparing;

  /// No description provided for @sitesPreparingCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun élément reçu pour l\'instant} =1{1 élément reçu} other{{count} éléments reçus}}'**
  String sitesPreparingCount(int count);

  /// No description provided for @sitesFirstSyncOffline.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réseau : vos chantiers n\'ont pas encore été reçus. Connectez-vous à internet pour les préparer.'**
  String get sitesFirstSyncOffline;

  /// No description provided for @sitesSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un chantier'**
  String get sitesSearchHint;

  /// No description provided for @sitesShowArchived.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les archivés'**
  String get sitesShowArchived;

  /// No description provided for @sitesNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun chantier ne correspond.'**
  String get sitesNoResult;

  /// No description provided for @sitesCurrentBadge.
  ///
  /// In fr, this message translates to:
  /// **'Chantier courant'**
  String get sitesCurrentBadge;

  /// No description provided for @sitesArchivedBadge.
  ///
  /// In fr, this message translates to:
  /// **'Archivé'**
  String get sitesArchivedBadge;

  /// No description provided for @sitesDataFrom.
  ///
  /// In fr, this message translates to:
  /// **'Données du {when}'**
  String sitesDataFrom(String when);

  /// No description provided for @sitesChooseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un chantier'**
  String get sitesChooseTitle;

  /// No description provided for @sitesChooseRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre chantier avant de faire une saisie.'**
  String get sitesChooseRequired;

  /// No description provided for @sitesCurrentRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Votre chantier courant ne vous est plus affecté. Choisissez-en un autre.'**
  String get sitesCurrentRemoved;

  /// No description provided for @siteInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get siteInfoTitle;

  /// No description provided for @siteType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'ouvrage'**
  String get siteType;

  /// No description provided for @siteTypeSchool.
  ///
  /// In fr, this message translates to:
  /// **'École'**
  String get siteTypeSchool;

  /// No description provided for @siteTypeHousing.
  ///
  /// In fr, this message translates to:
  /// **'Logements'**
  String get siteTypeHousing;

  /// No description provided for @siteTypePublicFacility.
  ///
  /// In fr, this message translates to:
  /// **'Équipement public'**
  String get siteTypePublicFacility;

  /// No description provided for @siteTypeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get siteTypeOther;

  /// No description provided for @siteWilaya.
  ///
  /// In fr, this message translates to:
  /// **'Wilaya'**
  String get siteWilaya;

  /// No description provided for @siteCommune.
  ///
  /// In fr, this message translates to:
  /// **'Commune'**
  String get siteCommune;

  /// No description provided for @siteCoordinates.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées GPS'**
  String get siteCoordinates;

  /// No description provided for @siteOwner.
  ///
  /// In fr, this message translates to:
  /// **'Maître d\'ouvrage'**
  String get siteOwner;

  /// No description provided for @siteContractNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° de marché'**
  String get siteContractNumber;

  /// No description provided for @siteContractAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get siteContractAmount;

  /// No description provided for @siteDelay.
  ///
  /// In fr, this message translates to:
  /// **'Délai'**
  String get siteDelay;

  /// No description provided for @siteDelayDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 jour} other{{count} jours}}'**
  String siteDelayDays(int count);

  /// No description provided for @siteOds.
  ///
  /// In fr, this message translates to:
  /// **'ODS de démarrage'**
  String get siteOds;

  /// No description provided for @siteEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Fin contractuelle'**
  String get siteEndDate;

  /// No description provided for @siteToDefine.
  ///
  /// In fr, this message translates to:
  /// **'À définir'**
  String get siteToDefine;

  /// No description provided for @siteZonesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Zones'**
  String get siteZonesTitle;

  /// No description provided for @siteNoZones.
  ///
  /// In fr, this message translates to:
  /// **'Aucune zone pour ce chantier.'**
  String get siteNoZones;

  /// No description provided for @siteMembersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Personnes affectées'**
  String get siteMembersTitle;

  /// No description provided for @siteCreatedBy.
  ///
  /// In fr, this message translates to:
  /// **'Créé par {name} le {when}'**
  String siteCreatedBy(String name, String when);

  /// No description provided for @siteUpdatedBy.
  ///
  /// In fr, this message translates to:
  /// **'Modifié par {name} le {when}'**
  String siteUpdatedBy(String name, String when);

  /// No description provided for @siteNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Chantier introuvable.'**
  String get siteNotFound;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleDirection.
  ///
  /// In fr, this message translates to:
  /// **'Direction'**
  String get roleDirection;

  /// No description provided for @roleConducteurTravaux.
  ///
  /// In fr, this message translates to:
  /// **'Conducteur de travaux'**
  String get roleConducteurTravaux;

  /// No description provided for @roleAchats.
  ///
  /// In fr, this message translates to:
  /// **'Achats'**
  String get roleAchats;

  /// No description provided for @roleChefChantier.
  ///
  /// In fr, this message translates to:
  /// **'Chef de chantier'**
  String get roleChefChantier;

  /// No description provided for @roleChefEquipe.
  ///
  /// In fr, this message translates to:
  /// **'Chef d\'équipe'**
  String get roleChefEquipe;

  /// No description provided for @roomTypeClassroom.
  ///
  /// In fr, this message translates to:
  /// **'Classe'**
  String get roomTypeClassroom;

  /// No description provided for @roomTypeCorridor.
  ///
  /// In fr, this message translates to:
  /// **'Couloir'**
  String get roomTypeCorridor;

  /// No description provided for @roomTypeCanteen.
  ///
  /// In fr, this message translates to:
  /// **'Cantine'**
  String get roomTypeCanteen;

  /// No description provided for @roomTypeRefectory.
  ///
  /// In fr, this message translates to:
  /// **'Réfectoire'**
  String get roomTypeRefectory;

  /// No description provided for @roomTypeKitchen.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine'**
  String get roomTypeKitchen;

  /// No description provided for @roomTypeOffice.
  ///
  /// In fr, this message translates to:
  /// **'Bureau'**
  String get roomTypeOffice;

  /// No description provided for @roomTypeSanitary.
  ///
  /// In fr, this message translates to:
  /// **'Sanitaires'**
  String get roomTypeSanitary;

  /// No description provided for @roomTypeTechnicalRoom.
  ///
  /// In fr, this message translates to:
  /// **'Local technique'**
  String get roomTypeTechnicalRoom;

  /// No description provided for @roomTypeFacade.
  ///
  /// In fr, this message translates to:
  /// **'Façade'**
  String get roomTypeFacade;

  /// No description provided for @roomTypeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get roomTypeOther;

  /// No description provided for @zonePendingBadge.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'envoi'**
  String get zonePendingBadge;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsAccount;

  /// No description provided for @zoneAddButton.
  ///
  /// In fr, this message translates to:
  /// **'+ Zone'**
  String get zoneAddButton;

  /// No description provided for @zoneAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une zone'**
  String get zoneAddTitle;

  /// No description provided for @zoneBlock.
  ///
  /// In fr, this message translates to:
  /// **'Bloc'**
  String get zoneBlock;

  /// No description provided for @zoneBlockNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau bloc'**
  String get zoneBlockNew;

  /// No description provided for @zoneBlockNewLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du bloc'**
  String get zoneBlockNewLabel;

  /// No description provided for @zoneElevation.
  ///
  /// In fr, this message translates to:
  /// **'Cote'**
  String get zoneElevation;

  /// No description provided for @zoneElevationOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre cote'**
  String get zoneElevationOther;

  /// No description provided for @zoneElevationNone.
  ///
  /// In fr, this message translates to:
  /// **'Sans cote'**
  String get zoneElevationNone;

  /// No description provided for @zoneElevationUnit.
  ///
  /// In fr, this message translates to:
  /// **'en mètres'**
  String get zoneElevationUnit;

  /// No description provided for @zoneElevationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Cote (m)'**
  String get zoneElevationLabel;

  /// No description provided for @zoneElevationHelp.
  ///
  /// In fr, this message translates to:
  /// **'En mètres, de {min} à {max}.'**
  String zoneElevationHelp(String min, String max);

  /// No description provided for @zoneElevationInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Cote invalide : chiffres seulement (par exemple 3,4).'**
  String get zoneElevationInvalid;

  /// No description provided for @zoneElevationOutOfRange.
  ///
  /// In fr, this message translates to:
  /// **'La cote doit être comprise entre {min} et {max} m.'**
  String zoneElevationOutOfRange(String min, String max);

  /// No description provided for @zoneRoomType.
  ///
  /// In fr, this message translates to:
  /// **'Type de local'**
  String get zoneRoomType;

  /// No description provided for @zoneRoomNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun local'**
  String get zoneRoomNone;

  /// No description provided for @zoneRoomNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro'**
  String get zoneRoomNumber;

  /// No description provided for @zoneRoomNumberMore.
  ///
  /// In fr, this message translates to:
  /// **'Numéro suivant'**
  String get zoneRoomNumberMore;

  /// No description provided for @zoneRoomNumberLess.
  ///
  /// In fr, this message translates to:
  /// **'Numéro précédent'**
  String get zoneRoomNumberLess;

  /// No description provided for @zoneRoomLabel.
  ///
  /// In fr, this message translates to:
  /// **'Libellé du local'**
  String get zoneRoomLabel;

  /// No description provided for @zoneRoomLabelRequired.
  ///
  /// In fr, this message translates to:
  /// **'Précisez le local.'**
  String get zoneRoomLabelRequired;

  /// No description provided for @zoneBlockRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez ou créez un bloc.'**
  String get zoneBlockRequired;

  /// No description provided for @zoneSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get zoneSave;

  /// No description provided for @zoneSavedPending.
  ///
  /// In fr, this message translates to:
  /// **'Zone enregistrée. En attente d\'envoi.'**
  String get zoneSavedPending;

  /// No description provided for @zoneExists.
  ///
  /// In fr, this message translates to:
  /// **'Cette zone existe déjà.'**
  String get zoneExists;

  /// No description provided for @zoneSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher (par exemple « cl 02 »)'**
  String get zoneSearchHint;

  /// No description provided for @zonePickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une zone'**
  String get zonePickerTitle;

  /// No description provided for @zonePickerConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get zonePickerConfirm;

  /// No description provided for @zonePickerNone.
  ///
  /// In fr, this message translates to:
  /// **'Non précisée'**
  String get zonePickerNone;

  /// No description provided for @zonePickerNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucune zone ne correspond.'**
  String get zonePickerNoResult;

  /// No description provided for @pendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envois en attente'**
  String get pendingTitle;

  /// No description provided for @pendingEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien à envoyer. Tout est à jour.'**
  String get pendingEmpty;

  /// No description provided for @pendingSavedAt.
  ///
  /// In fr, this message translates to:
  /// **'Saisi le {when}'**
  String pendingSavedAt(String when);

  /// No description provided for @pendingStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'envoi'**
  String get pendingStatusPending;

  /// No description provided for @pendingStatusSending.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours'**
  String get pendingStatusSending;

  /// No description provided for @pendingStatusToCheck.
  ///
  /// In fr, this message translates to:
  /// **'À vérifier'**
  String get pendingStatusToCheck;

  /// No description provided for @pendingEntityZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get pendingEntityZone;

  /// No description provided for @pendingCorrect.
  ///
  /// In fr, this message translates to:
  /// **'Corriger'**
  String get pendingCorrect;

  /// No description provided for @pendingAbandon.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner'**
  String get pendingAbandon;

  /// No description provided for @pendingAbandonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner cette saisie ?'**
  String get pendingAbandonTitle;

  /// No description provided for @pendingAbandonBody.
  ///
  /// In fr, this message translates to:
  /// **'Elle sera supprimée de ce téléphone. Cette action est définitive.'**
  String get pendingAbandonBody;

  /// No description provided for @pendingReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}'**
  String pendingReason(String reason);

  /// No description provided for @pendingSyncFailed.
  ///
  /// In fr, this message translates to:
  /// **'La synchronisation n\'a pas abouti. Vos saisies sont conservées.'**
  String get pendingSyncFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
