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
