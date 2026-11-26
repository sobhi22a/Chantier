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
  String get errorDemandeVerrouillee =>
      'Demande validée : la quantité et le produit ne se modifient plus. Annulez-la et créez-en une nouvelle.';

  @override
  String get errorDemandeNonOuverte =>
      'Cette demande n\'accepte plus de livraison.';

  @override
  String get errorCommandeExistante => 'Cette demande est déjà commandée.';

  @override
  String get errorProduitDifferent =>
      'Le produit de la livraison n\'est pas celui de la demande.';

  @override
  String get errorQuantiteEntiereRequise => 'Nombre entier requis.';

  @override
  String get errorUniteNonAutorisee =>
      'Cette unité n\'est pas autorisée pour ce produit.';

  @override
  String get errorMasseSacObligatoire =>
      'Indiquez la masse d\'un sac pour ce produit.';

  @override
  String get errorProduitExistant => 'Ce produit existe déjà.';

  @override
  String get errorFournisseurExistant => 'Ce fournisseur existe déjà.';

  @override
  String get errorProduitInactif =>
      'Ce produit est désactivé : choisissez-en un autre.';

  @override
  String get errorFournisseurInactif => 'Ce fournisseur est désactivé.';

  @override
  String get errorZoneHorsChantier =>
      'Cette zone n\'appartient pas à ce chantier.';

  @override
  String get errorLivraisonDejaRattachee =>
      'Cette livraison est déjà rattachée à une autre demande.';

  @override
  String get errorPhotosTropNombreuses =>
      'Nombre maximal de photos atteint pour cette livraison.';

  @override
  String get errorPhotoDejaEnvoyee => 'Cette photo a déjà été envoyée.';

  @override
  String get errorFichierTropGros => 'Image trop volumineuse.';

  @override
  String get errorTypeFichierRefuse => 'Seules les images JPEG sont acceptées.';

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

  @override
  String get requestStatusRequested => 'Demandée';

  @override
  String get requestStatusValidated => 'Validée';

  @override
  String get requestStatusRejected => 'Refusée';

  @override
  String get requestStatusOrdered => 'Commandée';

  @override
  String get requestStatusPartiallyDelivered => 'Livrée partiellement';

  @override
  String get requestStatusDelivered => 'Livrée';

  @override
  String get requestStatusReceived => 'Réceptionnée';

  @override
  String get requestStatusCancelled => 'Annulée';

  @override
  String get priorityNormal => 'Normale';

  @override
  String get priorityUrgent => 'Urgente';

  @override
  String get priorityBlocking => 'Bloquante';

  @override
  String get deliveryStatusRecorded => 'Enregistrée';

  @override
  String get deliveryStatusCancelled => 'Annulée';

  @override
  String get conformityConform => 'Conforme';

  @override
  String get conformityWithReserve => 'Avec réserve';

  @override
  String get unitPiece => 'u';

  @override
  String get unitLinearMeter => 'ml';

  @override
  String get unitSquareMeter => 'm²';

  @override
  String get unitCubicMeter => 'm³';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitTonne => 'T';

  @override
  String get unitBag => 'sac';

  @override
  String get unitLiter => 'L';

  @override
  String get unitHour => 'h';

  @override
  String get unitDay => 'j';

  @override
  String get unitManDay => 'pers·j';

  @override
  String get unitLumpSum => 'forfait';

  @override
  String get productCategoryBinders => 'Liants';

  @override
  String get productCategorySteel => 'Acier';

  @override
  String get productCategoryMasonry => 'Maçonnerie';

  @override
  String get productCategoryAggregates => 'Granulats';

  @override
  String get productCategoryAdmixtures => 'Adjuvants';

  @override
  String get productCategoryFinishingWorks => 'Second œuvre';

  @override
  String get productCategoryOther => 'Autre';

  @override
  String get reasonAlreadyOrdered => 'Déjà commandé';

  @override
  String get reasonStockSufficient => 'Stock suffisant sur le chantier';

  @override
  String get reasonQuantityToReview => 'Quantité à revoir';

  @override
  String get reasonOverBudget => 'Hors budget';

  @override
  String get reasonEntryError => 'Erreur de saisie';

  @override
  String get reasonNoLongerNeeded => 'Plus besoin';

  @override
  String get reasonDuplicate => 'Doublon';

  @override
  String get reasonSupplierUnavailable => 'Fournisseur indisponible';

  @override
  String get reasonPriceRefused => 'Prix refusé';

  @override
  String get reasonSupplierWillNotDeliver =>
      'Le fournisseur ne livrera pas le reste';

  @override
  String get reasonQuantitySufficient => 'Quantité suffisante';

  @override
  String get reasonDoubleEntry => 'Saisie en double';

  @override
  String get reasonQuantityError => 'Erreur de quantité';

  @override
  String get reasonRefusedAtReception => 'Refusée à la réception';

  @override
  String get reasonQuantityMissing => 'Quantité manquante';

  @override
  String get reasonDamagedProduct => 'Produit abîmé';

  @override
  String get reasonWrongProduct => 'Mauvais produit';

  @override
  String get reasonOther => 'Autre';

  @override
  String get materialNumberPending => 'Numéro en attente';

  @override
  String get materialToConfirm => 'À confirmer';

  @override
  String materialOverdueDays(String days) {
    return 'En retard de $days j';
  }

  @override
  String get requestsTitle => 'Demandes de matériaux';

  @override
  String get requestNew => 'Nouvelle demande';

  @override
  String get requestNewShort => '+ Demande';

  @override
  String get requestsOpen => 'Demandes';

  @override
  String get approvalsTitle => 'À valider';

  @override
  String get approvalsEmpty => 'Aucune demande à valider.';

  @override
  String get requestsViewToFollow => 'À suivre';

  @override
  String get requestsViewReceived => 'Terminées';

  @override
  String get requestsViewClosed => 'Refusées et annulées';

  @override
  String get requestsViewArchived => 'Archivées';

  @override
  String get requestsMine => 'Mes demandes';

  @override
  String get requestsAll => 'Toutes';

  @override
  String get requestsEmpty => 'Aucune demande ici.';

  @override
  String get requestsSearchHint => 'Rechercher (DEM-014, ciment…)';

  @override
  String get requestPendingSend => 'En attente d\'envoi';

  @override
  String get requestNeedsCheck => 'À vérifier';

  @override
  String requestNeededBy(String date) {
    return 'Pour le $date';
  }

  @override
  String get requestFormProduct => 'Matériau';

  @override
  String get requestFormSearchHint => 'Chercher un matériau';

  @override
  String get requestFormNoProduct => 'Aucun matériau trouvé.';

  @override
  String get requestFormTopProducts => 'Les plus demandés';

  @override
  String get requestFormOtherProduct => 'Autre produit';

  @override
  String get requestFormFreeName => 'Nom du matériau';

  @override
  String get requestFormFreeNameInvalid => 'Entrez 3 à 100 caractères.';

  @override
  String get requestFormQuantity => 'Quantité';

  @override
  String get requestFormUnit => 'Unité';

  @override
  String get requestFormZone => 'Zone';

  @override
  String get requestFormZoneOther => 'Autre zone';

  @override
  String get requestFormNeededBy => 'Pour le';

  @override
  String get requestFormTomorrow => 'Demain';

  @override
  String requestFormInDays(String days) {
    return '+ $days jours';
  }

  @override
  String get requestFormNextWeek => 'Semaine prochaine';

  @override
  String get requestFormOtherDate => 'Autre date';

  @override
  String get requestFormPriority => 'Urgence';

  @override
  String get requestFormNote => 'Remarque (facultatif)';

  @override
  String get requestFormSend => 'Envoyer';

  @override
  String get requestFormSendAnother => 'Envoyer et ajouter un autre matériau';

  @override
  String get requestFormPastDate => 'Cette date est déjà passée.';

  @override
  String get requestFormSendAnyway => 'Envoyer quand même';

  @override
  String requestFormDuplicate(String number) {
    return '$number est déjà ouverte pour ce matériau et cette zone.';
  }

  @override
  String get requestFormSeeDuplicate => 'Voir la demande';

  @override
  String get requestFormOtherRequest => 'C\'est une autre demande';

  @override
  String get requestSaved => 'Demande enregistrée. En attente d\'envoi.';

  @override
  String get requestEditTitle => 'Corriger la demande';

  @override
  String get requestEditSave => 'Enregistrer';

  @override
  String get requestEditNothing => 'Aucune modification.';

  @override
  String get requestEditProductLocked =>
      'Le matériau ne se corrige pas : annulez la demande puis recréez-la.';

  @override
  String get requestEditBusy =>
      'Cette saisie est en cours d\'envoi. Réessayez dans un instant.';

  @override
  String get requestDetailHistory => 'Historique';

  @override
  String requestDetailRequestedBy(String name) {
    return 'Demandée par $name';
  }

  @override
  String get requestDetailZone => 'Zone';

  @override
  String get requestDetailNote => 'Remarque';

  @override
  String get requestDetailReason => 'Motif';

  @override
  String get requestDetailReceived => 'Reçu';

  @override
  String get requestDetailRemaining => 'Reste';

  @override
  String get requestDetailVariance => 'Écart';

  @override
  String requestDetailDuplicate(String number) {
    return 'Doublon possible de $number';
  }

  @override
  String get requestDetailNotFound =>
      'Cette demande n\'est plus sur ce téléphone.';

  @override
  String requestDetailSavedAt(String when) {
    return 'Saisie le $when';
  }

  @override
  String get requestZoneNone => 'Non précisée';

  @override
  String get requestActionEdit => 'Corriger';

  @override
  String get requestActionCancel => 'Annuler la demande';

  @override
  String get requestCancelTitle => 'Annuler cette demande ?';

  @override
  String get requestCancelConfirm => 'Annuler la demande';

  @override
  String get requestCancelKeep => 'Garder la demande';

  @override
  String get requestReasonTitle => 'Motif';

  @override
  String get requestReasonNoteLabel => 'Précisez le motif';

  @override
  String get requestReasonNoteRequired => 'Précisez le motif (Autre).';

  @override
  String get requestReasonRequired => 'Choisissez un motif.';

  @override
  String get requestActionQueued => 'Enregistré. En attente d\'envoi.';

  @override
  String get requestActionAlreadyQueued =>
      'Une action est déjà en attente d\'envoi pour cette demande.';

  @override
  String get approvalApprove => 'Valider';

  @override
  String get approvalReject => 'Refuser';

  @override
  String get approvalAdjust => 'Autre quantité';

  @override
  String get approvalAdjustTitle => 'Valider avec une autre quantité';

  @override
  String get approvalAdjustConfirm => 'Valider cette quantité';

  @override
  String get approvalPending => 'Validation en attente d\'envoi';

  @override
  String get approvalRejectTitle => 'Refuser la demande';

  @override
  String get approvalRejectConfirm => 'Refuser';

  @override
  String get historyCreated => 'Demande créée';

  @override
  String get historyEdited => 'Demande modifiée';

  @override
  String get historyApproved => 'Validée';

  @override
  String get historyQuantityAdjusted => 'Quantité ajustée';

  @override
  String get historyRejected => 'Refusée';

  @override
  String get historyCancelled => 'Annulée';

  @override
  String get historyReceived => 'Réceptionnée';

  @override
  String historyStatusChange(String fromStatus, String toStatus) {
    return '$fromStatus → $toStatus';
  }

  @override
  String historyBy(String name) {
    return 'par $name';
  }

  @override
  String get fieldQuantity => 'Quantité';

  @override
  String get fieldZone => 'Zone';

  @override
  String get fieldNeededBy => 'Pour le';

  @override
  String get fieldPriority => 'Urgence';

  @override
  String get fieldNote => 'Remarque';

  @override
  String get fieldProduct => 'Matériau';

  @override
  String fieldChange(String field, String newValue, String oldValue) {
    return '$field : $oldValue → $newValue';
  }

  @override
  String get fieldEmpty => 'vide';

  @override
  String get pendingEntityRequest => 'Demande de matériau';

  @override
  String get pendingView => 'Voir';

  @override
  String get conflictTitle => 'À vérifier';

  @override
  String get conflictIntro =>
      'Le serveur garde sa version. Rien n\'est supprimé tant que vous n\'avez pas choisi.';

  @override
  String get conflictYourVersion => 'Votre version';

  @override
  String get conflictServerVersion => 'Version du serveur';

  @override
  String conflictFieldsInDisagreement(String fields) {
    return 'Champs en désaccord : $fields';
  }

  @override
  String conflictYourAction(String action) {
    return 'Votre action : $action';
  }

  @override
  String get conflictActionApprove => 'valider';

  @override
  String get conflictActionReject => 'refuser';

  @override
  String get conflictActionCancel => 'annuler';

  @override
  String get conflictActionReceive => 'réceptionner';

  @override
  String conflictServerStatus(String status) {
    return 'Statut sur le serveur : $status';
  }

  @override
  String get conflictKeepServer => 'Garder la version du serveur';

  @override
  String get conflictRedo => 'Refaire ma modification';

  @override
  String get conflictCreateNew => 'Créer une nouvelle demande avec mes valeurs';

  @override
  String get conflictCorrect => 'Corriger ma saisie';

  @override
  String get conflictKeepServerTitle => 'Garder la version du serveur ?';

  @override
  String get conflictKeepServerBody =>
      'Votre saisie sera supprimée de ce téléphone. Cette action est définitive.';

  @override
  String get conflictGone => 'Cette saisie n\'est plus à vérifier.';

  @override
  String get deliveriesTitle => 'Livraisons';

  @override
  String get toReceiveTitle => 'À recevoir';

  @override
  String get toReceptionTitle => 'À réceptionner';

  @override
  String get homeDeliveriesTitle => 'Livraisons et réception';

  @override
  String get toReceiveEmpty => 'Aucune commande à recevoir.';

  @override
  String get toReceiveSearchHint =>
      'Rechercher (fournisseur, matériau, DEM-014)';

  @override
  String toReceiveExpectedOn(String date) {
    return 'Prévue le $date';
  }

  @override
  String get toReceiveNoDate => 'Date prévue non indiquée';

  @override
  String toReceiveRemaining(String quantity) {
    return 'Reste : $quantity';
  }

  @override
  String get toReceiveWithoutRequest => 'Livraison sans demande';

  @override
  String get receiveFilterAll => 'Toutes';

  @override
  String get receiveFilterToday => 'Aujourd\'hui';

  @override
  String get receiveFilterWeek => 'Cette semaine';

  @override
  String get receiveFilterLate => 'En retard';

  @override
  String get toReceptionEmpty => 'Aucune demande à réceptionner.';

  @override
  String get toReceptionAction => 'Réceptionner';

  @override
  String receiveNowPrompt(String number) {
    return '$number est livrée. Réceptionner maintenant ?';
  }

  @override
  String get receiveNowYes => 'Réceptionner';

  @override
  String get receiveNowLater => 'Plus tard';

  @override
  String get deliveryNewTitle => 'Recevoir une livraison';

  @override
  String get deliveryNoRequestTitle => 'Livraison sans demande';

  @override
  String get deliveryEditTitle => 'Corriger la livraison';

  @override
  String get deliveryFormSupplier => 'Fournisseur';

  @override
  String get deliveryFormOtherSupplier => 'Autre fournisseur';

  @override
  String get deliveryFormSupplierName => 'Nom du fournisseur';

  @override
  String get deliveryFormSupplierInvalid => 'Entrez 3 à 100 caractères.';

  @override
  String get deliveryFormQuantity => 'Quantité reçue';

  @override
  String get deliveryFormDate => 'Date de livraison';

  @override
  String get deliveryFormToday => 'Aujourd\'hui';

  @override
  String get deliveryFormYesterday => 'Hier';

  @override
  String get deliveryFormOtherDate => 'Autre date';

  @override
  String get deliveryFormNote => 'N° du bon de livraison (facultatif)';

  @override
  String get deliveryFormConformity => 'Conformité';

  @override
  String get deliveryFormReserveReason => 'Motif de la réserve';

  @override
  String get deliveryFormReserveNote => 'Précisez la réserve';

  @override
  String get deliveryFormReserveRequired =>
      'Choisissez le motif de la réserve.';

  @override
  String get deliveryFormPhotos => 'Photos du bon';

  @override
  String get deliveryFormSave => 'Enregistrer la livraison';

  @override
  String get deliveryFormBeforeRequest =>
      'Cette date est antérieure à la demande.';

  @override
  String deliveryAnnouncePartial(String quantity) {
    return 'Livraison partielle : il restera $quantity';
  }

  @override
  String get deliveryAnnounceComplete => 'Livraison complète';

  @override
  String deliveryAnnounceSurplus(String quantity, String percent) {
    return 'Surplus de +$quantity (+$percent %)';
  }

  @override
  String deliveryDuplicateNote(String number) {
    return 'Ce bon est déjà saisi : $number.';
  }

  @override
  String get deliveryDuplicateSee => 'Voir la livraison';

  @override
  String get deliveryDuplicateOther => 'C\'est une autre livraison';

  @override
  String get deliverySaved => 'Livraison enregistrée. En attente d\'envoi.';

  @override
  String get deliveryProductLocked => 'Le matériau est celui de la demande.';

  @override
  String get deliveryProductNeeded => 'Choisissez le matériau.';

  @override
  String get photoAdd => 'Photographier le bon';

  @override
  String get photoRetake => 'Reprendre';

  @override
  String get photoKeep => 'Garder';

  @override
  String photoMax(String max) {
    return '$max photos au maximum.';
  }

  @override
  String photoCountLabel(String count) {
    return 'Photos : $count';
  }

  @override
  String get photoErrorNotImage => 'Ce fichier n\'est pas une image JPEG.';

  @override
  String get photoErrorTooLarge => 'Cette photo est trop lourde. Reprenez-la.';

  @override
  String get photoErrorUnreadable => 'Photo illisible. Reprenez-la.';

  @override
  String get photoErrorNoCamera => 'Aucun appareil photo disponible.';

  @override
  String get photoPendingSend => 'Photo en attente d\'envoi';

  @override
  String photoPendingSendCount(String count) {
    return 'Photo en attente d\'envoi ($count)';
  }

  @override
  String get photoUploaded => 'Envoyée';

  @override
  String get photoShow => 'Afficher la photo';

  @override
  String get photoHide => 'Masquer';

  @override
  String get photoNeedsNetwork => 'Réseau nécessaire pour afficher la photo.';

  @override
  String get photoNotFound => 'Photo introuvable.';

  @override
  String photoFileProblem(String reason) {
    return 'Fichier à vérifier : $reason';
  }

  @override
  String get photoAbandon => 'Abandonner la photo';

  @override
  String get photoAbandonBody =>
      'Cette photo sera supprimée de ce téléphone. Cette action est définitive.';

  @override
  String get deliveriesEmpty => 'Aucune livraison ici.';

  @override
  String get deliveriesSearchHint => 'Rechercher (LIV-006, ciment…)';

  @override
  String get deliveriesFilterAll => 'Toutes';

  @override
  String get deliveriesFilterUnattached => 'Non rattachées';

  @override
  String get deliveriesFilterReserve => 'Avec réserve';

  @override
  String get deliveriesFilterNoteMissing => 'BL manquant';

  @override
  String get deliveryUnattachedBadge => 'Non rattachée';

  @override
  String get deliveryNoteMissingBadge => 'BL manquant';

  @override
  String get deliveryDetailNotFound =>
      'Cette livraison n\'est plus sur ce téléphone.';

  @override
  String get deliveryDetailQuantity => 'Quantité';

  @override
  String get deliveryDetailInRequest => 'Équivalent dans la demande';

  @override
  String get deliveryDetailSupplier => 'Fournisseur';

  @override
  String get deliveryDetailRequest => 'Demande';

  @override
  String get deliveryDetailDate => 'Date de livraison';

  @override
  String get deliveryDetailNote => 'Bon n°';

  @override
  String get deliveryDetailReserve => 'Réserve';

  @override
  String get deliveryDetailCancelReason => 'Motif d\'annulation';

  @override
  String get deliveryDetailUnattachedReason => 'Pourquoi non rattachée';

  @override
  String get deliveryDetailPhotos => 'Photos du bon';

  @override
  String get deliveryDetailNoPhotos => 'Aucune photo.';

  @override
  String deliveryDetailSavedAt(String when) {
    return 'Saisie le $when';
  }

  @override
  String get deliveryActionEdit => 'Corriger';

  @override
  String get deliveryActionCancel => 'Annuler la livraison';

  @override
  String get deliveryCancelTitle => 'Annuler cette livraison ?';

  @override
  String get deliveryCancelConfirm => 'Annuler la livraison';

  @override
  String get deliveryAttachInfo =>
      'Pour rattacher cette livraison à une demande, il faut du réseau : faites-le depuis le bureau ou une fois connecté.';

  @override
  String get unattachedNoRequestChosen => 'Aucune demande choisie';

  @override
  String get unattachedRequestNotOpen => 'La demande n\'était plus ouverte';

  @override
  String get unattachedRequestMissing => 'Demande introuvable';

  @override
  String get requestDetailDeliveries => 'Livraisons';

  @override
  String get requestDetailSupplier => 'Fournisseur';

  @override
  String requestDetailExpected(String date) {
    return 'Livraison prévue le $date';
  }

  @override
  String get requestActionReceive => 'Recevoir une livraison';

  @override
  String get requestActionReception => 'Réceptionner';

  @override
  String get supplierCall => 'Appeler le fournisseur';

  @override
  String get supplierCallNeedsNetwork =>
      'Réseau nécessaire pour afficher le numéro.';

  @override
  String get supplierCallNoNumber =>
      'Aucun numéro enregistré pour ce fournisseur.';

  @override
  String supplierCallTitle(String name) {
    return 'Fournisseur : $name';
  }

  @override
  String get supplierCallDial => 'Appeler';

  @override
  String get supplierCallClose => 'Fermer';

  @override
  String get supplierCallNoApp => 'Impossible d\'ouvrir le téléphone.';

  @override
  String get historyDeliveryRegistered => 'Livraison enregistrée';

  @override
  String get historyDeliveryEdited => 'Livraison corrigée';

  @override
  String get historyDeliveryCancelled => 'Livraison annulée';

  @override
  String get historyDeliveryAttached => 'Livraison rattachée';

  @override
  String get historyStatusRecomputed => 'Statut recalculé';

  @override
  String get historyPhotoAdded => 'Photo ajoutée';

  @override
  String get historyOrdered => 'Commandée';

  @override
  String get fieldDeliveryDate => 'Date de livraison';

  @override
  String get fieldDeliveryNote => 'Bon n°';

  @override
  String get fieldConformity => 'Conformité';

  @override
  String get fieldReserveReason => 'Motif de la réserve';

  @override
  String get fieldReserveNote => 'Remarque de réserve';

  @override
  String get pendingEntityDelivery => 'Livraison';

  @override
  String get pendingEntityPhoto => 'Photo du bon';

  @override
  String get conflictRequestNotComplete =>
      'La demande n\'est plus complète : votre réception n\'a pas été enregistrée.';

  @override
  String get conflictDeliveryCancelled =>
      'Cette livraison a été annulée entre-temps.';

  @override
  String get conflictDeliveryRequestClosed =>
      'La demande est déjà réceptionnée : ses livraisons ne se modifient plus.';

  @override
  String conflictServerDeliveryStatus(String status) {
    return 'Statut de la livraison sur le serveur : $status';
  }

  @override
  String conflictYourPhoto(String when) {
    return 'Photo du bon prise le $when';
  }

  @override
  String get pendingPhotosTitle => 'Photos à envoyer';

  @override
  String get pendingPhotosRefused => 'Photo refusée par le serveur';

  @override
  String get errorErreurTemporaire =>
      'Le serveur est occupé un instant. Rien n\'a été enregistré : réessayez.';

  @override
  String get historyUnavailableOffline => 'Historique indisponible hors ligne.';
}
