import 'package:chantier_mobile/l10n/generated/app_localizations.dart';

/// Libelles traduits des valeurs stables du contrat (roles, types de local, types d'ouvrage).
/// Une valeur inconnue (ajoutee cote serveur apres cette version) est affichee **telle que recue**
/// plutot que de faire echouer l'ecran.

/// Valeurs `roomType` du contrat, dans l'ordre propose a la saisie (CA-011.1).
const List<String> roomTypeValues = [
  'Classroom',
  'Corridor',
  'Canteen',
  'Refectory',
  'Kitchen',
  'Office',
  'Sanitary',
  'TechnicalRoom',
  'Facade',
  'Other',
];

String roomTypeLabel(AppLocalizations l10n, String value) => switch (value) {
  'Classroom' => l10n.roomTypeClassroom,
  'Corridor' => l10n.roomTypeCorridor,
  'Canteen' => l10n.roomTypeCanteen,
  'Refectory' => l10n.roomTypeRefectory,
  'Kitchen' => l10n.roomTypeKitchen,
  'Office' => l10n.roomTypeOffice,
  'Sanitary' => l10n.roomTypeSanitary,
  'TechnicalRoom' => l10n.roomTypeTechnicalRoom,
  'Facade' => l10n.roomTypeFacade,
  'Other' => l10n.roomTypeOther,
  _ => value,
};

String roleLabel(AppLocalizations l10n, String value) => switch (value) {
  'Admin' => l10n.roleAdmin,
  'Direction' => l10n.roleDirection,
  'ConducteurTravaux' => l10n.roleConducteurTravaux,
  'Achats' => l10n.roleAchats,
  'ChefChantier' => l10n.roleChefChantier,
  'ChefEquipe' => l10n.roleChefEquipe,
  _ => value,
};

String siteTypeLabel(AppLocalizations l10n, String value) => switch (value) {
  'School' => l10n.siteTypeSchool,
  'Housing' => l10n.siteTypeHousing,
  'PublicFacility' => l10n.siteTypePublicFacility,
  'Other' => l10n.siteTypeOther,
  _ => value,
};

// --- Demandes de materiaux et livraisons ----------------------------------------------------
// Les valeurs sont les chaines stables du contrat ; une valeur inconnue (ajoutee cote serveur
// apres cette version) est affichee telle que recue.

String requestStatusLabel(AppLocalizations l10n, String value) =>
    switch (value) {
      'Requested' => l10n.requestStatusRequested,
      'Validated' => l10n.requestStatusValidated,
      'Rejected' => l10n.requestStatusRejected,
      'Ordered' => l10n.requestStatusOrdered,
      'PartiallyDelivered' => l10n.requestStatusPartiallyDelivered,
      'Delivered' => l10n.requestStatusDelivered,
      'Received' => l10n.requestStatusReceived,
      'Cancelled' => l10n.requestStatusCancelled,
      _ => value,
    };

String priorityLabel(AppLocalizations l10n, String value) => switch (value) {
  'Normal' => l10n.priorityNormal,
  'Urgent' => l10n.priorityUrgent,
  'Blocking' => l10n.priorityBlocking,
  _ => value,
};

String deliveryStatusLabel(AppLocalizations l10n, String value) =>
    switch (value) {
      'Recorded' => l10n.deliveryStatusRecorded,
      'Cancelled' => l10n.deliveryStatusCancelled,
      _ => value,
    };

String conformityLabel(AppLocalizations l10n, String value) => switch (value) {
  'Conform' => l10n.conformityConform,
  'WithReserve' => l10n.conformityWithReserve,
  _ => value,
};

/// Libelle court d'une unite du referentiel (`sac`, `t`, `m2`...) ; code inconnu : tel que recu.
String unitLabel(AppLocalizations l10n, String code) => switch (code) {
  'u' => l10n.unitPiece,
  'ml' => l10n.unitLinearMeter,
  'm2' => l10n.unitSquareMeter,
  'm3' => l10n.unitCubicMeter,
  'kg' => l10n.unitKilogram,
  't' => l10n.unitTonne,
  'sac' => l10n.unitBag,
  'l' => l10n.unitLiter,
  'h' => l10n.unitHour,
  'j' => l10n.unitDay,
  'pj' => l10n.unitManDay,
  'ft' => l10n.unitLumpSum,
  _ => code,
};

String productCategoryLabel(AppLocalizations l10n, String value) =>
    switch (value) {
      'Binders' => l10n.productCategoryBinders,
      'Steel' => l10n.productCategorySteel,
      'Masonry' => l10n.productCategoryMasonry,
      'Aggregates' => l10n.productCategoryAggregates,
      'Admixtures' => l10n.productCategoryAdmixtures,
      'FinishingWorks' => l10n.productCategoryFinishingWorks,
      'Other' => l10n.productCategoryOther,
      _ => value,
    };

/// Motif d'un refus, d'une annulation, d'un solde ou d'une reserve (codes ouverts : les listes
/// viennent de `GET /settings/materials`). Un code inconnu est affiche tel que recu.
String reasonLabel(AppLocalizations l10n, String code) => switch (code) {
  'AlreadyOrdered' => l10n.reasonAlreadyOrdered,
  'StockSufficient' => l10n.reasonStockSufficient,
  'QuantityToReview' => l10n.reasonQuantityToReview,
  'OverBudget' => l10n.reasonOverBudget,
  'EntryError' => l10n.reasonEntryError,
  'NoLongerNeeded' => l10n.reasonNoLongerNeeded,
  'Duplicate' => l10n.reasonDuplicate,
  'SupplierUnavailable' => l10n.reasonSupplierUnavailable,
  'PriceRefused' => l10n.reasonPriceRefused,
  'SupplierWillNotDeliver' => l10n.reasonSupplierWillNotDeliver,
  'QuantitySufficient' => l10n.reasonQuantitySufficient,
  'DoubleEntry' => l10n.reasonDoubleEntry,
  'QuantityError' => l10n.reasonQuantityError,
  'RefusedAtReception' => l10n.reasonRefusedAtReception,
  'QuantityMissing' => l10n.reasonQuantityMissing,
  'DamagedProduct' => l10n.reasonDamagedProduct,
  'WrongProduct' => l10n.reasonWrongProduct,
  'Other' => l10n.reasonOther,
  _ => code,
};

/// Evenement de l'historique d'une demande (`Created`, `Approved`...) ; type inconnu : tel que recu.
String requestEventLabel(AppLocalizations l10n, String type) => switch (type) {
  'Created' => l10n.historyCreated,
  'Edited' => l10n.historyEdited,
  'Approved' => l10n.historyApproved,
  'QuantityAdjusted' => l10n.historyQuantityAdjusted,
  'Rejected' => l10n.historyRejected,
  'Cancelled' => l10n.historyCancelled,
  'Received' => l10n.historyReceived,
  'Ordered' => l10n.historyOrdered,
  'DeliveryRegistered' => l10n.historyDeliveryRegistered,
  'DeliveryEdited' => l10n.historyDeliveryEdited,
  'DeliveryCancelled' => l10n.historyDeliveryCancelled,
  'DeliveryAttached' => l10n.historyDeliveryAttached,
  'StatusRecomputed' => l10n.historyStatusRecomputed,
  'PhotoAdded' => l10n.historyPhotoAdded,
  _ => type,
};

/// Champ modifiable d'une demande, tel que nomme dans `changes` : champ inconnu : tel que recu.
String requestFieldLabel(AppLocalizations l10n, String field) =>
    switch (field) {
      'quantity' => l10n.fieldQuantity,
      'zoneId' || 'zone' => l10n.fieldZone,
      'neededBy' => l10n.fieldNeededBy,
      'priority' => l10n.fieldPriority,
      'note' => l10n.fieldNote,
      'productId' || 'freeProductName' || 'product' => l10n.fieldProduct,
      'deliveryDate' => l10n.fieldDeliveryDate,
      'deliveryNoteNumber' => l10n.fieldDeliveryNote,
      'conformity' => l10n.fieldConformity,
      'reserveReasonCode' => l10n.fieldReserveReason,
      'reserveNote' => l10n.fieldReserveNote,
      _ => field,
    };

/// Pourquoi une livraison n'est pas rattachee a une demande (`unattachedReason`) ; valeur
/// inconnue : telle que recue.
String unattachedReasonLabel(AppLocalizations l10n, String value) =>
    switch (value) {
      'NoRequestChosen' => l10n.unattachedNoRequestChosen,
      'RequestNotOpen' => l10n.unattachedRequestNotOpen,
      'RequestMissing' => l10n.unattachedRequestMissing,
      _ => value,
    };
