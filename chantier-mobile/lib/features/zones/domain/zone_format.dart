import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:decimal/decimal.dart';

/// Affichage d'une zone : « Bloc 01 · +3,40 m · Classe 02 » (CA-009.2).
///
/// Les cotes sont **signees** (`+3,40`, `−1,90`) et `±0,00` pour zero, avec deux decimales et la
/// virgule en francais comme en arabe. Mise en forme seulement : aucune arithmetique.

/// Signe moins typographique (U+2212), comme dans `−1,90` du contrat d'affichage.
const String minusSign = '−';

/// `3.40` -> `+3,40` ; `-1.90` -> `−1,90` ; `0.00` -> `±0,00`.
String signedElevation(Decimal elevation) {
  final text = Formatters.decimal(elevation.abs().toStringAsFixed(2));
  if (elevation == Decimal.zero) return '±0,00';
  return elevation < Decimal.zero ? '$minusSign$text' : '+$text';
}

/// Cote avec son unite (toujours le metre) : `+3,40 m`. A afficher dans un `LtrText`.
String elevationWithUnit(Decimal elevation) =>
    '${signedElevation(elevation)} m';

/// Local : `Classe 02`, `Cantine`, ou le libelle libre si le type est `Autre`.
String? roomLabelText(AppLocalizations l10n, ZoneRow zone) {
  final type = zone.roomType;
  if (type == null) return null;
  if (type == 'Other' && (zone.roomLabel ?? '').isNotEmpty) {
    return zone.roomLabel;
  }
  final name = roomTypeLabel(l10n, type);
  final number = zone.roomNumber;
  return number == null ? name : '$name ${number.toString().padLeft(2, '0')}';
}

/// `Bloc 01 · +3,40 m · Classe 02` (les parties absentes sont omises). Texte brut : pour
/// l'enregistrer (libelle de la file d'envoi) ou le comparer.
String zoneLabel(AppLocalizations l10n, ZoneRow zone) =>
    _zoneLabel(l10n, zone, isolate: false);

/// Meme libelle pour l'**affichage** : bloc et cote isoles en gauche-a-droite, le local suit le
/// sens de la langue.
String zoneLabelForDisplay(AppLocalizations l10n, ZoneRow zone) =>
    _zoneLabel(l10n, zone, isolate: true);

String _zoneLabel(
  AppLocalizations l10n,
  ZoneRow zone, {
  required bool isolate,
}) {
  String ltr(String text) => isolate ? Formatters.isolateLtr(text) : text;
  final elevation = zone.elevation;
  return [
    ltr(zone.block),
    if (elevation != null) ltr(elevationWithUnit(elevation)),
    ?roomLabelText(l10n, zone),
  ].join(' · ');
}
