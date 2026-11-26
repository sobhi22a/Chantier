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

  /// No description provided for @errorDemandeVerrouillee.
  ///
  /// In fr, this message translates to:
  /// **'Demande validée : la quantité et le produit ne se modifient plus. Annulez-la et créez-en une nouvelle.'**
  String get errorDemandeVerrouillee;

  /// No description provided for @errorDemandeNonOuverte.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande n\'accepte plus de livraison.'**
  String get errorDemandeNonOuverte;

  /// No description provided for @errorCommandeExistante.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande est déjà commandée.'**
  String get errorCommandeExistante;

  /// No description provided for @errorProduitDifferent.
  ///
  /// In fr, this message translates to:
  /// **'Le produit de la livraison n\'est pas celui de la demande.'**
  String get errorProduitDifferent;

  /// No description provided for @errorQuantiteEntiereRequise.
  ///
  /// In fr, this message translates to:
  /// **'Nombre entier requis.'**
  String get errorQuantiteEntiereRequise;

  /// No description provided for @errorUniteNonAutorisee.
  ///
  /// In fr, this message translates to:
  /// **'Cette unité n\'est pas autorisée pour ce produit.'**
  String get errorUniteNonAutorisee;

  /// No description provided for @errorMasseSacObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez la masse d\'un sac pour ce produit.'**
  String get errorMasseSacObligatoire;

  /// No description provided for @errorProduitExistant.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit existe déjà.'**
  String get errorProduitExistant;

  /// No description provided for @errorFournisseurExistant.
  ///
  /// In fr, this message translates to:
  /// **'Ce fournisseur existe déjà.'**
  String get errorFournisseurExistant;

  /// No description provided for @errorProduitInactif.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit est désactivé : choisissez-en un autre.'**
  String get errorProduitInactif;

  /// No description provided for @errorFournisseurInactif.
  ///
  /// In fr, this message translates to:
  /// **'Ce fournisseur est désactivé.'**
  String get errorFournisseurInactif;

  /// No description provided for @errorZoneHorsChantier.
  ///
  /// In fr, this message translates to:
  /// **'Cette zone n\'appartient pas à ce chantier.'**
  String get errorZoneHorsChantier;

  /// No description provided for @errorLivraisonDejaRattachee.
  ///
  /// In fr, this message translates to:
  /// **'Cette livraison est déjà rattachée à une autre demande.'**
  String get errorLivraisonDejaRattachee;

  /// No description provided for @errorPhotosTropNombreuses.
  ///
  /// In fr, this message translates to:
  /// **'Nombre maximal de photos atteint pour cette livraison.'**
  String get errorPhotosTropNombreuses;

  /// No description provided for @errorPhotoDejaEnvoyee.
  ///
  /// In fr, this message translates to:
  /// **'Cette photo a déjà été envoyée.'**
  String get errorPhotoDejaEnvoyee;

  /// No description provided for @errorFichierTropGros.
  ///
  /// In fr, this message translates to:
  /// **'Image trop volumineuse.'**
  String get errorFichierTropGros;

  /// No description provided for @errorTypeFichierRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Seules les images JPEG sont acceptées.'**
  String get errorTypeFichierRefuse;

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

  /// No description provided for @requestStatusRequested.
  ///
  /// In fr, this message translates to:
  /// **'Demandée'**
  String get requestStatusRequested;

  /// No description provided for @requestStatusValidated.
  ///
  /// In fr, this message translates to:
  /// **'Validée'**
  String get requestStatusValidated;

  /// No description provided for @requestStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get requestStatusRejected;

  /// No description provided for @requestStatusOrdered.
  ///
  /// In fr, this message translates to:
  /// **'Commandée'**
  String get requestStatusOrdered;

  /// No description provided for @requestStatusPartiallyDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livrée partiellement'**
  String get requestStatusPartiallyDelivered;

  /// No description provided for @requestStatusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get requestStatusDelivered;

  /// No description provided for @requestStatusReceived.
  ///
  /// In fr, this message translates to:
  /// **'Réceptionnée'**
  String get requestStatusReceived;

  /// No description provided for @requestStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get requestStatusCancelled;

  /// No description provided for @priorityNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normale'**
  String get priorityNormal;

  /// No description provided for @priorityUrgent.
  ///
  /// In fr, this message translates to:
  /// **'Urgente'**
  String get priorityUrgent;

  /// No description provided for @priorityBlocking.
  ///
  /// In fr, this message translates to:
  /// **'Bloquante'**
  String get priorityBlocking;

  /// No description provided for @deliveryStatusRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrée'**
  String get deliveryStatusRecorded;

  /// No description provided for @deliveryStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get deliveryStatusCancelled;

  /// No description provided for @conformityConform.
  ///
  /// In fr, this message translates to:
  /// **'Conforme'**
  String get conformityConform;

  /// No description provided for @conformityWithReserve.
  ///
  /// In fr, this message translates to:
  /// **'Avec réserve'**
  String get conformityWithReserve;

  /// No description provided for @unitPiece.
  ///
  /// In fr, this message translates to:
  /// **'u'**
  String get unitPiece;

  /// No description provided for @unitLinearMeter.
  ///
  /// In fr, this message translates to:
  /// **'ml'**
  String get unitLinearMeter;

  /// No description provided for @unitSquareMeter.
  ///
  /// In fr, this message translates to:
  /// **'m²'**
  String get unitSquareMeter;

  /// No description provided for @unitCubicMeter.
  ///
  /// In fr, this message translates to:
  /// **'m³'**
  String get unitCubicMeter;

  /// No description provided for @unitKilogram.
  ///
  /// In fr, this message translates to:
  /// **'kg'**
  String get unitKilogram;

  /// No description provided for @unitTonne.
  ///
  /// In fr, this message translates to:
  /// **'T'**
  String get unitTonne;

  /// No description provided for @unitBag.
  ///
  /// In fr, this message translates to:
  /// **'sac'**
  String get unitBag;

  /// No description provided for @unitLiter.
  ///
  /// In fr, this message translates to:
  /// **'L'**
  String get unitLiter;

  /// No description provided for @unitHour.
  ///
  /// In fr, this message translates to:
  /// **'h'**
  String get unitHour;

  /// No description provided for @unitDay.
  ///
  /// In fr, this message translates to:
  /// **'j'**
  String get unitDay;

  /// No description provided for @unitManDay.
  ///
  /// In fr, this message translates to:
  /// **'pers·j'**
  String get unitManDay;

  /// No description provided for @unitLumpSum.
  ///
  /// In fr, this message translates to:
  /// **'forfait'**
  String get unitLumpSum;

  /// No description provided for @productCategoryBinders.
  ///
  /// In fr, this message translates to:
  /// **'Liants'**
  String get productCategoryBinders;

  /// No description provided for @productCategorySteel.
  ///
  /// In fr, this message translates to:
  /// **'Acier'**
  String get productCategorySteel;

  /// No description provided for @productCategoryMasonry.
  ///
  /// In fr, this message translates to:
  /// **'Maçonnerie'**
  String get productCategoryMasonry;

  /// No description provided for @productCategoryAggregates.
  ///
  /// In fr, this message translates to:
  /// **'Granulats'**
  String get productCategoryAggregates;

  /// No description provided for @productCategoryAdmixtures.
  ///
  /// In fr, this message translates to:
  /// **'Adjuvants'**
  String get productCategoryAdmixtures;

  /// No description provided for @productCategoryFinishingWorks.
  ///
  /// In fr, this message translates to:
  /// **'Second œuvre'**
  String get productCategoryFinishingWorks;

  /// No description provided for @productCategoryOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get productCategoryOther;

  /// No description provided for @reasonAlreadyOrdered.
  ///
  /// In fr, this message translates to:
  /// **'Déjà commandé'**
  String get reasonAlreadyOrdered;

  /// No description provided for @reasonStockSufficient.
  ///
  /// In fr, this message translates to:
  /// **'Stock suffisant sur le chantier'**
  String get reasonStockSufficient;

  /// No description provided for @reasonQuantityToReview.
  ///
  /// In fr, this message translates to:
  /// **'Quantité à revoir'**
  String get reasonQuantityToReview;

  /// No description provided for @reasonOverBudget.
  ///
  /// In fr, this message translates to:
  /// **'Hors budget'**
  String get reasonOverBudget;

  /// No description provided for @reasonEntryError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de saisie'**
  String get reasonEntryError;

  /// No description provided for @reasonNoLongerNeeded.
  ///
  /// In fr, this message translates to:
  /// **'Plus besoin'**
  String get reasonNoLongerNeeded;

  /// No description provided for @reasonDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Doublon'**
  String get reasonDuplicate;

  /// No description provided for @reasonSupplierUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur indisponible'**
  String get reasonSupplierUnavailable;

  /// No description provided for @reasonPriceRefused.
  ///
  /// In fr, this message translates to:
  /// **'Prix refusé'**
  String get reasonPriceRefused;

  /// No description provided for @reasonSupplierWillNotDeliver.
  ///
  /// In fr, this message translates to:
  /// **'Le fournisseur ne livrera pas le reste'**
  String get reasonSupplierWillNotDeliver;

  /// No description provided for @reasonQuantitySufficient.
  ///
  /// In fr, this message translates to:
  /// **'Quantité suffisante'**
  String get reasonQuantitySufficient;

  /// No description provided for @reasonDoubleEntry.
  ///
  /// In fr, this message translates to:
  /// **'Saisie en double'**
  String get reasonDoubleEntry;

  /// No description provided for @reasonQuantityError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de quantité'**
  String get reasonQuantityError;

  /// No description provided for @reasonRefusedAtReception.
  ///
  /// In fr, this message translates to:
  /// **'Refusée à la réception'**
  String get reasonRefusedAtReception;

  /// No description provided for @reasonQuantityMissing.
  ///
  /// In fr, this message translates to:
  /// **'Quantité manquante'**
  String get reasonQuantityMissing;

  /// No description provided for @reasonDamagedProduct.
  ///
  /// In fr, this message translates to:
  /// **'Produit abîmé'**
  String get reasonDamagedProduct;

  /// No description provided for @reasonWrongProduct.
  ///
  /// In fr, this message translates to:
  /// **'Mauvais produit'**
  String get reasonWrongProduct;

  /// No description provided for @reasonOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get reasonOther;

  /// No description provided for @materialNumberPending.
  ///
  /// In fr, this message translates to:
  /// **'Numéro en attente'**
  String get materialNumberPending;

  /// No description provided for @materialToConfirm.
  ///
  /// In fr, this message translates to:
  /// **'À confirmer'**
  String get materialToConfirm;

  /// No description provided for @materialOverdueDays.
  ///
  /// In fr, this message translates to:
  /// **'En retard de {days} j'**
  String materialOverdueDays(String days);

  /// No description provided for @requestsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demandes de matériaux'**
  String get requestsTitle;

  /// No description provided for @requestNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle demande'**
  String get requestNew;

  /// No description provided for @requestNewShort.
  ///
  /// In fr, this message translates to:
  /// **'+ Demande'**
  String get requestNewShort;

  /// No description provided for @requestsOpen.
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get requestsOpen;

  /// No description provided for @approvalsTitle.
  ///
  /// In fr, this message translates to:
  /// **'À valider'**
  String get approvalsTitle;

  /// No description provided for @approvalsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande à valider.'**
  String get approvalsEmpty;

  /// No description provided for @requestsViewToFollow.
  ///
  /// In fr, this message translates to:
  /// **'À suivre'**
  String get requestsViewToFollow;

  /// No description provided for @requestsViewReceived.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get requestsViewReceived;

  /// No description provided for @requestsViewClosed.
  ///
  /// In fr, this message translates to:
  /// **'Refusées et annulées'**
  String get requestsViewClosed;

  /// No description provided for @requestsViewArchived.
  ///
  /// In fr, this message translates to:
  /// **'Archivées'**
  String get requestsViewArchived;

  /// No description provided for @requestsMine.
  ///
  /// In fr, this message translates to:
  /// **'Mes demandes'**
  String get requestsMine;

  /// No description provided for @requestsAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get requestsAll;

  /// No description provided for @requestsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande ici.'**
  String get requestsEmpty;

  /// No description provided for @requestsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher (DEM-014, ciment…)'**
  String get requestsSearchHint;

  /// No description provided for @requestPendingSend.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'envoi'**
  String get requestPendingSend;

  /// No description provided for @requestNeedsCheck.
  ///
  /// In fr, this message translates to:
  /// **'À vérifier'**
  String get requestNeedsCheck;

  /// No description provided for @requestNeededBy.
  ///
  /// In fr, this message translates to:
  /// **'Pour le {date}'**
  String requestNeededBy(String date);

  /// No description provided for @requestFormProduct.
  ///
  /// In fr, this message translates to:
  /// **'Matériau'**
  String get requestFormProduct;

  /// No description provided for @requestFormSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Chercher un matériau'**
  String get requestFormSearchHint;

  /// No description provided for @requestFormNoProduct.
  ///
  /// In fr, this message translates to:
  /// **'Aucun matériau trouvé.'**
  String get requestFormNoProduct;

  /// No description provided for @requestFormTopProducts.
  ///
  /// In fr, this message translates to:
  /// **'Les plus demandés'**
  String get requestFormTopProducts;

  /// No description provided for @requestFormOtherProduct.
  ///
  /// In fr, this message translates to:
  /// **'Autre produit'**
  String get requestFormOtherProduct;

  /// No description provided for @requestFormFreeName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du matériau'**
  String get requestFormFreeName;

  /// No description provided for @requestFormFreeNameInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Entrez 3 à 100 caractères.'**
  String get requestFormFreeNameInvalid;

  /// No description provided for @requestFormQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get requestFormQuantity;

  /// No description provided for @requestFormUnit.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get requestFormUnit;

  /// No description provided for @requestFormZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get requestFormZone;

  /// No description provided for @requestFormZoneOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre zone'**
  String get requestFormZoneOther;

  /// No description provided for @requestFormNeededBy.
  ///
  /// In fr, this message translates to:
  /// **'Pour le'**
  String get requestFormNeededBy;

  /// No description provided for @requestFormTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get requestFormTomorrow;

  /// No description provided for @requestFormInDays.
  ///
  /// In fr, this message translates to:
  /// **'+ {days} jours'**
  String requestFormInDays(String days);

  /// No description provided for @requestFormNextWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine prochaine'**
  String get requestFormNextWeek;

  /// No description provided for @requestFormOtherDate.
  ///
  /// In fr, this message translates to:
  /// **'Autre date'**
  String get requestFormOtherDate;

  /// No description provided for @requestFormPriority.
  ///
  /// In fr, this message translates to:
  /// **'Urgence'**
  String get requestFormPriority;

  /// No description provided for @requestFormNote.
  ///
  /// In fr, this message translates to:
  /// **'Remarque (facultatif)'**
  String get requestFormNote;

  /// No description provided for @requestFormSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get requestFormSend;

  /// No description provided for @requestFormSendAnother.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer et ajouter un autre matériau'**
  String get requestFormSendAnother;

  /// No description provided for @requestFormPastDate.
  ///
  /// In fr, this message translates to:
  /// **'Cette date est déjà passée.'**
  String get requestFormPastDate;

  /// No description provided for @requestFormSendAnyway.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer quand même'**
  String get requestFormSendAnyway;

  /// No description provided for @requestFormDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'{number} est déjà ouverte pour ce matériau et cette zone.'**
  String requestFormDuplicate(String number);

  /// No description provided for @requestFormSeeDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Voir la demande'**
  String get requestFormSeeDuplicate;

  /// No description provided for @requestFormOtherRequest.
  ///
  /// In fr, this message translates to:
  /// **'C\'est une autre demande'**
  String get requestFormOtherRequest;

  /// No description provided for @requestSaved.
  ///
  /// In fr, this message translates to:
  /// **'Demande enregistrée. En attente d\'envoi.'**
  String get requestSaved;

  /// No description provided for @requestEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Corriger la demande'**
  String get requestEditTitle;

  /// No description provided for @requestEditSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get requestEditSave;

  /// No description provided for @requestEditNothing.
  ///
  /// In fr, this message translates to:
  /// **'Aucune modification.'**
  String get requestEditNothing;

  /// No description provided for @requestEditProductLocked.
  ///
  /// In fr, this message translates to:
  /// **'Le matériau ne se corrige pas : annulez la demande puis recréez-la.'**
  String get requestEditProductLocked;

  /// No description provided for @requestEditBusy.
  ///
  /// In fr, this message translates to:
  /// **'Cette saisie est en cours d\'envoi. Réessayez dans un instant.'**
  String get requestEditBusy;

  /// No description provided for @requestDetailHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get requestDetailHistory;

  /// No description provided for @requestDetailRequestedBy.
  ///
  /// In fr, this message translates to:
  /// **'Demandée par {name}'**
  String requestDetailRequestedBy(String name);

  /// No description provided for @requestDetailZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get requestDetailZone;

  /// No description provided for @requestDetailNote.
  ///
  /// In fr, this message translates to:
  /// **'Remarque'**
  String get requestDetailNote;

  /// No description provided for @requestDetailReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get requestDetailReason;

  /// No description provided for @requestDetailReceived.
  ///
  /// In fr, this message translates to:
  /// **'Reçu'**
  String get requestDetailReceived;

  /// No description provided for @requestDetailRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Reste'**
  String get requestDetailRemaining;

  /// No description provided for @requestDetailVariance.
  ///
  /// In fr, this message translates to:
  /// **'Écart'**
  String get requestDetailVariance;

  /// No description provided for @requestDetailDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Doublon possible de {number}'**
  String requestDetailDuplicate(String number);

  /// No description provided for @requestDetailNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande n\'est plus sur ce téléphone.'**
  String get requestDetailNotFound;

  /// No description provided for @requestDetailSavedAt.
  ///
  /// In fr, this message translates to:
  /// **'Saisie le {when}'**
  String requestDetailSavedAt(String when);

  /// No description provided for @requestZoneNone.
  ///
  /// In fr, this message translates to:
  /// **'Non précisée'**
  String get requestZoneNone;

  /// No description provided for @requestActionEdit.
  ///
  /// In fr, this message translates to:
  /// **'Corriger'**
  String get requestActionEdit;

  /// No description provided for @requestActionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la demande'**
  String get requestActionCancel;

  /// No description provided for @requestCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette demande ?'**
  String get requestCancelTitle;

  /// No description provided for @requestCancelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la demande'**
  String get requestCancelConfirm;

  /// No description provided for @requestCancelKeep.
  ///
  /// In fr, this message translates to:
  /// **'Garder la demande'**
  String get requestCancelKeep;

  /// No description provided for @requestReasonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get requestReasonTitle;

  /// No description provided for @requestReasonNoteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Précisez le motif'**
  String get requestReasonNoteLabel;

  /// No description provided for @requestReasonNoteRequired.
  ///
  /// In fr, this message translates to:
  /// **'Précisez le motif (Autre).'**
  String get requestReasonNoteRequired;

  /// No description provided for @requestReasonRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un motif.'**
  String get requestReasonRequired;

  /// No description provided for @requestActionQueued.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré. En attente d\'envoi.'**
  String get requestActionQueued;

  /// No description provided for @requestActionAlreadyQueued.
  ///
  /// In fr, this message translates to:
  /// **'Une action est déjà en attente d\'envoi pour cette demande.'**
  String get requestActionAlreadyQueued;

  /// No description provided for @approvalApprove.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get approvalApprove;

  /// No description provided for @approvalReject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get approvalReject;

  /// No description provided for @approvalAdjust.
  ///
  /// In fr, this message translates to:
  /// **'Autre quantité'**
  String get approvalAdjust;

  /// No description provided for @approvalAdjustTitle.
  ///
  /// In fr, this message translates to:
  /// **'Valider avec une autre quantité'**
  String get approvalAdjustTitle;

  /// No description provided for @approvalAdjustConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider cette quantité'**
  String get approvalAdjustConfirm;

  /// No description provided for @approvalPending.
  ///
  /// In fr, this message translates to:
  /// **'Validation en attente d\'envoi'**
  String get approvalPending;

  /// No description provided for @approvalRejectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Refuser la demande'**
  String get approvalRejectTitle;

  /// No description provided for @approvalRejectConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get approvalRejectConfirm;

  /// No description provided for @historyCreated.
  ///
  /// In fr, this message translates to:
  /// **'Demande créée'**
  String get historyCreated;

  /// No description provided for @historyEdited.
  ///
  /// In fr, this message translates to:
  /// **'Demande modifiée'**
  String get historyEdited;

  /// No description provided for @historyApproved.
  ///
  /// In fr, this message translates to:
  /// **'Validée'**
  String get historyApproved;

  /// No description provided for @historyQuantityAdjusted.
  ///
  /// In fr, this message translates to:
  /// **'Quantité ajustée'**
  String get historyQuantityAdjusted;

  /// No description provided for @historyRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get historyRejected;

  /// No description provided for @historyCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get historyCancelled;

  /// No description provided for @historyReceived.
  ///
  /// In fr, this message translates to:
  /// **'Réceptionnée'**
  String get historyReceived;

  /// No description provided for @historyStatusChange.
  ///
  /// In fr, this message translates to:
  /// **'{fromStatus} → {toStatus}'**
  String historyStatusChange(String fromStatus, String toStatus);

  /// No description provided for @historyBy.
  ///
  /// In fr, this message translates to:
  /// **'par {name}'**
  String historyBy(String name);

  /// No description provided for @fieldQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get fieldQuantity;

  /// No description provided for @fieldZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get fieldZone;

  /// No description provided for @fieldNeededBy.
  ///
  /// In fr, this message translates to:
  /// **'Pour le'**
  String get fieldNeededBy;

  /// No description provided for @fieldPriority.
  ///
  /// In fr, this message translates to:
  /// **'Urgence'**
  String get fieldPriority;

  /// No description provided for @fieldNote.
  ///
  /// In fr, this message translates to:
  /// **'Remarque'**
  String get fieldNote;

  /// No description provided for @fieldProduct.
  ///
  /// In fr, this message translates to:
  /// **'Matériau'**
  String get fieldProduct;

  /// No description provided for @fieldChange.
  ///
  /// In fr, this message translates to:
  /// **'{field} : {oldValue} → {newValue}'**
  String fieldChange(String field, String newValue, String oldValue);

  /// No description provided for @fieldEmpty.
  ///
  /// In fr, this message translates to:
  /// **'vide'**
  String get fieldEmpty;

  /// No description provided for @pendingEntityRequest.
  ///
  /// In fr, this message translates to:
  /// **'Demande de matériau'**
  String get pendingEntityRequest;

  /// No description provided for @pendingView.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get pendingView;

  /// No description provided for @conflictTitle.
  ///
  /// In fr, this message translates to:
  /// **'À vérifier'**
  String get conflictTitle;

  /// No description provided for @conflictIntro.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur garde sa version. Rien n\'est supprimé tant que vous n\'avez pas choisi.'**
  String get conflictIntro;

  /// No description provided for @conflictYourVersion.
  ///
  /// In fr, this message translates to:
  /// **'Votre version'**
  String get conflictYourVersion;

  /// No description provided for @conflictServerVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version du serveur'**
  String get conflictServerVersion;

  /// No description provided for @conflictFieldsInDisagreement.
  ///
  /// In fr, this message translates to:
  /// **'Champs en désaccord : {fields}'**
  String conflictFieldsInDisagreement(String fields);

  /// No description provided for @conflictYourAction.
  ///
  /// In fr, this message translates to:
  /// **'Votre action : {action}'**
  String conflictYourAction(String action);

  /// No description provided for @conflictActionApprove.
  ///
  /// In fr, this message translates to:
  /// **'valider'**
  String get conflictActionApprove;

  /// No description provided for @conflictActionReject.
  ///
  /// In fr, this message translates to:
  /// **'refuser'**
  String get conflictActionReject;

  /// No description provided for @conflictActionCancel.
  ///
  /// In fr, this message translates to:
  /// **'annuler'**
  String get conflictActionCancel;

  /// No description provided for @conflictActionReceive.
  ///
  /// In fr, this message translates to:
  /// **'réceptionner'**
  String get conflictActionReceive;

  /// No description provided for @conflictServerStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut sur le serveur : {status}'**
  String conflictServerStatus(String status);

  /// No description provided for @conflictKeepServer.
  ///
  /// In fr, this message translates to:
  /// **'Garder la version du serveur'**
  String get conflictKeepServer;

  /// No description provided for @conflictRedo.
  ///
  /// In fr, this message translates to:
  /// **'Refaire ma modification'**
  String get conflictRedo;

  /// No description provided for @conflictCreateNew.
  ///
  /// In fr, this message translates to:
  /// **'Créer une nouvelle demande avec mes valeurs'**
  String get conflictCreateNew;

  /// No description provided for @conflictCorrect.
  ///
  /// In fr, this message translates to:
  /// **'Corriger ma saisie'**
  String get conflictCorrect;

  /// No description provided for @conflictKeepServerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Garder la version du serveur ?'**
  String get conflictKeepServerTitle;

  /// No description provided for @conflictKeepServerBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre saisie sera supprimée de ce téléphone. Cette action est définitive.'**
  String get conflictKeepServerBody;

  /// No description provided for @conflictGone.
  ///
  /// In fr, this message translates to:
  /// **'Cette saisie n\'est plus à vérifier.'**
  String get conflictGone;

  /// No description provided for @deliveriesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livraisons'**
  String get deliveriesTitle;

  /// No description provided for @toReceiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'À recevoir'**
  String get toReceiveTitle;

  /// No description provided for @toReceptionTitle.
  ///
  /// In fr, this message translates to:
  /// **'À réceptionner'**
  String get toReceptionTitle;

  /// No description provided for @homeDeliveriesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livraisons et réception'**
  String get homeDeliveriesTitle;

  /// No description provided for @toReceiveEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande à recevoir.'**
  String get toReceiveEmpty;

  /// No description provided for @toReceiveSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher (fournisseur, matériau, DEM-014)'**
  String get toReceiveSearchHint;

  /// No description provided for @toReceiveExpectedOn.
  ///
  /// In fr, this message translates to:
  /// **'Prévue le {date}'**
  String toReceiveExpectedOn(String date);

  /// No description provided for @toReceiveNoDate.
  ///
  /// In fr, this message translates to:
  /// **'Date prévue non indiquée'**
  String get toReceiveNoDate;

  /// No description provided for @toReceiveRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Reste : {quantity}'**
  String toReceiveRemaining(String quantity);

  /// No description provided for @toReceiveWithoutRequest.
  ///
  /// In fr, this message translates to:
  /// **'Livraison sans demande'**
  String get toReceiveWithoutRequest;

  /// No description provided for @receiveFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get receiveFilterAll;

  /// No description provided for @receiveFilterToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get receiveFilterToday;

  /// No description provided for @receiveFilterWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get receiveFilterWeek;

  /// No description provided for @receiveFilterLate.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get receiveFilterLate;

  /// No description provided for @toReceptionEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande à réceptionner.'**
  String get toReceptionEmpty;

  /// No description provided for @toReceptionAction.
  ///
  /// In fr, this message translates to:
  /// **'Réceptionner'**
  String get toReceptionAction;

  /// No description provided for @receiveNowPrompt.
  ///
  /// In fr, this message translates to:
  /// **'{number} est livrée. Réceptionner maintenant ?'**
  String receiveNowPrompt(String number);

  /// No description provided for @receiveNowYes.
  ///
  /// In fr, this message translates to:
  /// **'Réceptionner'**
  String get receiveNowYes;

  /// No description provided for @receiveNowLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get receiveNowLater;

  /// No description provided for @deliveryNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir une livraison'**
  String get deliveryNewTitle;

  /// No description provided for @deliveryNoRequestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livraison sans demande'**
  String get deliveryNoRequestTitle;

  /// No description provided for @deliveryEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Corriger la livraison'**
  String get deliveryEditTitle;

  /// No description provided for @deliveryFormSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get deliveryFormSupplier;

  /// No description provided for @deliveryFormOtherSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Autre fournisseur'**
  String get deliveryFormOtherSupplier;

  /// No description provided for @deliveryFormSupplierName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du fournisseur'**
  String get deliveryFormSupplierName;

  /// No description provided for @deliveryFormSupplierInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Entrez 3 à 100 caractères.'**
  String get deliveryFormSupplierInvalid;

  /// No description provided for @deliveryFormQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité reçue'**
  String get deliveryFormQuantity;

  /// No description provided for @deliveryFormDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de livraison'**
  String get deliveryFormDate;

  /// No description provided for @deliveryFormToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get deliveryFormToday;

  /// No description provided for @deliveryFormYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get deliveryFormYesterday;

  /// No description provided for @deliveryFormOtherDate.
  ///
  /// In fr, this message translates to:
  /// **'Autre date'**
  String get deliveryFormOtherDate;

  /// No description provided for @deliveryFormNote.
  ///
  /// In fr, this message translates to:
  /// **'N° du bon de livraison (facultatif)'**
  String get deliveryFormNote;

  /// No description provided for @deliveryFormConformity.
  ///
  /// In fr, this message translates to:
  /// **'Conformité'**
  String get deliveryFormConformity;

  /// No description provided for @deliveryFormReserveReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif de la réserve'**
  String get deliveryFormReserveReason;

  /// No description provided for @deliveryFormReserveNote.
  ///
  /// In fr, this message translates to:
  /// **'Précisez la réserve'**
  String get deliveryFormReserveNote;

  /// No description provided for @deliveryFormReserveRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le motif de la réserve.'**
  String get deliveryFormReserveRequired;

  /// No description provided for @deliveryFormPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos du bon'**
  String get deliveryFormPhotos;

  /// No description provided for @deliveryFormSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer la livraison'**
  String get deliveryFormSave;

  /// No description provided for @deliveryFormBeforeRequest.
  ///
  /// In fr, this message translates to:
  /// **'Cette date est antérieure à la demande.'**
  String get deliveryFormBeforeRequest;

  /// No description provided for @deliveryAnnouncePartial.
  ///
  /// In fr, this message translates to:
  /// **'Livraison partielle : il restera {quantity}'**
  String deliveryAnnouncePartial(String quantity);

  /// No description provided for @deliveryAnnounceComplete.
  ///
  /// In fr, this message translates to:
  /// **'Livraison complète'**
  String get deliveryAnnounceComplete;

  /// No description provided for @deliveryAnnounceSurplus.
  ///
  /// In fr, this message translates to:
  /// **'Surplus de +{quantity} (+{percent} %)'**
  String deliveryAnnounceSurplus(String quantity, String percent);

  /// No description provided for @deliveryDuplicateNote.
  ///
  /// In fr, this message translates to:
  /// **'Ce bon est déjà saisi : {number}.'**
  String deliveryDuplicateNote(String number);

  /// No description provided for @deliveryDuplicateSee.
  ///
  /// In fr, this message translates to:
  /// **'Voir la livraison'**
  String get deliveryDuplicateSee;

  /// No description provided for @deliveryDuplicateOther.
  ///
  /// In fr, this message translates to:
  /// **'C\'est une autre livraison'**
  String get deliveryDuplicateOther;

  /// No description provided for @deliverySaved.
  ///
  /// In fr, this message translates to:
  /// **'Livraison enregistrée. En attente d\'envoi.'**
  String get deliverySaved;

  /// No description provided for @deliveryProductLocked.
  ///
  /// In fr, this message translates to:
  /// **'Le matériau est celui de la demande.'**
  String get deliveryProductLocked;

  /// No description provided for @deliveryProductNeeded.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le matériau.'**
  String get deliveryProductNeeded;

  /// No description provided for @photoAdd.
  ///
  /// In fr, this message translates to:
  /// **'Photographier le bon'**
  String get photoAdd;

  /// No description provided for @photoRetake.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get photoRetake;

  /// No description provided for @photoKeep.
  ///
  /// In fr, this message translates to:
  /// **'Garder'**
  String get photoKeep;

  /// No description provided for @photoMax.
  ///
  /// In fr, this message translates to:
  /// **'{max} photos au maximum.'**
  String photoMax(String max);

  /// No description provided for @photoCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photos : {count}'**
  String photoCountLabel(String count);

  /// No description provided for @photoErrorNotImage.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une image JPEG.'**
  String get photoErrorNotImage;

  /// No description provided for @photoErrorTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Cette photo est trop lourde. Reprenez-la.'**
  String get photoErrorTooLarge;

  /// No description provided for @photoErrorUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Photo illisible. Reprenez-la.'**
  String get photoErrorUnreadable;

  /// No description provided for @photoErrorNoCamera.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil photo disponible.'**
  String get photoErrorNoCamera;

  /// No description provided for @photoPendingSend.
  ///
  /// In fr, this message translates to:
  /// **'Photo en attente d\'envoi'**
  String get photoPendingSend;

  /// No description provided for @photoPendingSendCount.
  ///
  /// In fr, this message translates to:
  /// **'Photo en attente d\'envoi ({count})'**
  String photoPendingSendCount(String count);

  /// No description provided for @photoUploaded.
  ///
  /// In fr, this message translates to:
  /// **'Envoyée'**
  String get photoUploaded;

  /// No description provided for @photoShow.
  ///
  /// In fr, this message translates to:
  /// **'Afficher la photo'**
  String get photoShow;

  /// No description provided for @photoHide.
  ///
  /// In fr, this message translates to:
  /// **'Masquer'**
  String get photoHide;

  /// No description provided for @photoNeedsNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Réseau nécessaire pour afficher la photo.'**
  String get photoNeedsNetwork;

  /// No description provided for @photoNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Photo introuvable.'**
  String get photoNotFound;

  /// No description provided for @photoFileProblem.
  ///
  /// In fr, this message translates to:
  /// **'Fichier à vérifier : {reason}'**
  String photoFileProblem(String reason);

  /// No description provided for @photoAbandon.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner la photo'**
  String get photoAbandon;

  /// No description provided for @photoAbandonBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette photo sera supprimée de ce téléphone. Cette action est définitive.'**
  String get photoAbandonBody;

  /// No description provided for @deliveriesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune livraison ici.'**
  String get deliveriesEmpty;

  /// No description provided for @deliveriesSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher (LIV-006, ciment…)'**
  String get deliveriesSearchHint;

  /// No description provided for @deliveriesFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get deliveriesFilterAll;

  /// No description provided for @deliveriesFilterUnattached.
  ///
  /// In fr, this message translates to:
  /// **'Non rattachées'**
  String get deliveriesFilterUnattached;

  /// No description provided for @deliveriesFilterReserve.
  ///
  /// In fr, this message translates to:
  /// **'Avec réserve'**
  String get deliveriesFilterReserve;

  /// No description provided for @deliveriesFilterNoteMissing.
  ///
  /// In fr, this message translates to:
  /// **'BL manquant'**
  String get deliveriesFilterNoteMissing;

  /// No description provided for @deliveryUnattachedBadge.
  ///
  /// In fr, this message translates to:
  /// **'Non rattachée'**
  String get deliveryUnattachedBadge;

  /// No description provided for @deliveryNoteMissingBadge.
  ///
  /// In fr, this message translates to:
  /// **'BL manquant'**
  String get deliveryNoteMissingBadge;

  /// No description provided for @deliveryDetailNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette livraison n\'est plus sur ce téléphone.'**
  String get deliveryDetailNotFound;

  /// No description provided for @deliveryDetailQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get deliveryDetailQuantity;

  /// No description provided for @deliveryDetailInRequest.
  ///
  /// In fr, this message translates to:
  /// **'Équivalent dans la demande'**
  String get deliveryDetailInRequest;

  /// No description provided for @deliveryDetailSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get deliveryDetailSupplier;

  /// No description provided for @deliveryDetailRequest.
  ///
  /// In fr, this message translates to:
  /// **'Demande'**
  String get deliveryDetailRequest;

  /// No description provided for @deliveryDetailDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de livraison'**
  String get deliveryDetailDate;

  /// No description provided for @deliveryDetailNote.
  ///
  /// In fr, this message translates to:
  /// **'Bon n°'**
  String get deliveryDetailNote;

  /// No description provided for @deliveryDetailReserve.
  ///
  /// In fr, this message translates to:
  /// **'Réserve'**
  String get deliveryDetailReserve;

  /// No description provided for @deliveryDetailCancelReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif d\'annulation'**
  String get deliveryDetailCancelReason;

  /// No description provided for @deliveryDetailUnattachedReason.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi non rattachée'**
  String get deliveryDetailUnattachedReason;

  /// No description provided for @deliveryDetailPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos du bon'**
  String get deliveryDetailPhotos;

  /// No description provided for @deliveryDetailNoPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo.'**
  String get deliveryDetailNoPhotos;

  /// No description provided for @deliveryDetailSavedAt.
  ///
  /// In fr, this message translates to:
  /// **'Saisie le {when}'**
  String deliveryDetailSavedAt(String when);

  /// No description provided for @deliveryActionEdit.
  ///
  /// In fr, this message translates to:
  /// **'Corriger'**
  String get deliveryActionEdit;

  /// No description provided for @deliveryActionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la livraison'**
  String get deliveryActionCancel;

  /// No description provided for @deliveryCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette livraison ?'**
  String get deliveryCancelTitle;

  /// No description provided for @deliveryCancelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la livraison'**
  String get deliveryCancelConfirm;

  /// No description provided for @deliveryAttachInfo.
  ///
  /// In fr, this message translates to:
  /// **'Pour rattacher cette livraison à une demande, il faut du réseau : faites-le depuis le bureau ou une fois connecté.'**
  String get deliveryAttachInfo;

  /// No description provided for @unattachedNoRequestChosen.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande choisie'**
  String get unattachedNoRequestChosen;

  /// No description provided for @unattachedRequestNotOpen.
  ///
  /// In fr, this message translates to:
  /// **'La demande n\'était plus ouverte'**
  String get unattachedRequestNotOpen;

  /// No description provided for @unattachedRequestMissing.
  ///
  /// In fr, this message translates to:
  /// **'Demande introuvable'**
  String get unattachedRequestMissing;

  /// No description provided for @requestDetailDeliveries.
  ///
  /// In fr, this message translates to:
  /// **'Livraisons'**
  String get requestDetailDeliveries;

  /// No description provided for @requestDetailSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get requestDetailSupplier;

  /// No description provided for @requestDetailExpected.
  ///
  /// In fr, this message translates to:
  /// **'Livraison prévue le {date}'**
  String requestDetailExpected(String date);

  /// No description provided for @requestActionReceive.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir une livraison'**
  String get requestActionReceive;

  /// No description provided for @requestActionReception.
  ///
  /// In fr, this message translates to:
  /// **'Réceptionner'**
  String get requestActionReception;

  /// No description provided for @supplierCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler le fournisseur'**
  String get supplierCall;

  /// No description provided for @supplierCallNeedsNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Réseau nécessaire pour afficher le numéro.'**
  String get supplierCallNeedsNetwork;

  /// No description provided for @supplierCallNoNumber.
  ///
  /// In fr, this message translates to:
  /// **'Aucun numéro enregistré pour ce fournisseur.'**
  String get supplierCallNoNumber;

  /// No description provided for @supplierCallTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur : {name}'**
  String supplierCallTitle(String name);

  /// No description provided for @supplierCallDial.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get supplierCallDial;

  /// No description provided for @supplierCallClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get supplierCallClose;

  /// No description provided for @supplierCallNoApp.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir le téléphone.'**
  String get supplierCallNoApp;

  /// No description provided for @historyDeliveryRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Livraison enregistrée'**
  String get historyDeliveryRegistered;

  /// No description provided for @historyDeliveryEdited.
  ///
  /// In fr, this message translates to:
  /// **'Livraison corrigée'**
  String get historyDeliveryEdited;

  /// No description provided for @historyDeliveryCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Livraison annulée'**
  String get historyDeliveryCancelled;

  /// No description provided for @historyDeliveryAttached.
  ///
  /// In fr, this message translates to:
  /// **'Livraison rattachée'**
  String get historyDeliveryAttached;

  /// No description provided for @historyStatusRecomputed.
  ///
  /// In fr, this message translates to:
  /// **'Statut recalculé'**
  String get historyStatusRecomputed;

  /// No description provided for @historyPhotoAdded.
  ///
  /// In fr, this message translates to:
  /// **'Photo ajoutée'**
  String get historyPhotoAdded;

  /// No description provided for @historyOrdered.
  ///
  /// In fr, this message translates to:
  /// **'Commandée'**
  String get historyOrdered;

  /// No description provided for @fieldDeliveryDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de livraison'**
  String get fieldDeliveryDate;

  /// No description provided for @fieldDeliveryNote.
  ///
  /// In fr, this message translates to:
  /// **'Bon n°'**
  String get fieldDeliveryNote;

  /// No description provided for @fieldConformity.
  ///
  /// In fr, this message translates to:
  /// **'Conformité'**
  String get fieldConformity;

  /// No description provided for @fieldReserveReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif de la réserve'**
  String get fieldReserveReason;

  /// No description provided for @fieldReserveNote.
  ///
  /// In fr, this message translates to:
  /// **'Remarque de réserve'**
  String get fieldReserveNote;

  /// No description provided for @pendingEntityDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get pendingEntityDelivery;

  /// No description provided for @pendingEntityPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo du bon'**
  String get pendingEntityPhoto;

  /// No description provided for @conflictRequestNotComplete.
  ///
  /// In fr, this message translates to:
  /// **'La demande n\'est plus complète : votre réception n\'a pas été enregistrée.'**
  String get conflictRequestNotComplete;

  /// No description provided for @conflictDeliveryCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Cette livraison a été annulée entre-temps.'**
  String get conflictDeliveryCancelled;

  /// No description provided for @conflictDeliveryRequestClosed.
  ///
  /// In fr, this message translates to:
  /// **'La demande est déjà réceptionnée : ses livraisons ne se modifient plus.'**
  String get conflictDeliveryRequestClosed;

  /// No description provided for @conflictServerDeliveryStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut de la livraison sur le serveur : {status}'**
  String conflictServerDeliveryStatus(String status);

  /// No description provided for @conflictYourPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo du bon prise le {when}'**
  String conflictYourPhoto(String when);

  /// No description provided for @pendingPhotosTitle.
  ///
  /// In fr, this message translates to:
  /// **'Photos à envoyer'**
  String get pendingPhotosTitle;

  /// No description provided for @pendingPhotosRefused.
  ///
  /// In fr, this message translates to:
  /// **'Photo refusée par le serveur'**
  String get pendingPhotosRefused;

  /// No description provided for @errorErreurTemporaire.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur est occupé un instant. Rien n\'a été enregistré : réessayez.'**
  String get errorErreurTemporaire;

  /// No description provided for @historyUnavailableOffline.
  ///
  /// In fr, this message translates to:
  /// **'Historique indisponible hors ligne.'**
  String get historyUnavailableOffline;
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
