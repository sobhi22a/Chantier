import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:decimal/decimal.dart';

/// Nom du chantier dans la langue de l'interface : le nom arabe s'il existe, sinon le nom
/// francais (CA-014.6, H-20).
String siteDisplayName(SiteRow site, String languageCode) {
  final arabic = site.nameAr;
  return languageCode == 'ar' && arabic != null && arabic.trim().isNotEmpty
      ? arabic
      : site.name;
}

/// Montant du marche : `185 000 000,00 DZD` (CA-007.8). Texte decimal, aucune arithmetique.
String contractAmountText(Decimal amount) =>
    '${Formatters.decimal(amount.toStringAsFixed(2))} DZD';

/// Coordonnees ecrites a la place de la carte (hors ligne, CA-007.5) : `36,575000 ; 2,912000`.
String? coordinatesText(SiteRow site) {
  final latitude = site.latitude;
  final longitude = site.longitude;
  if (latitude == null || longitude == null) return null;
  return '${Formatters.decimal(latitude.toStringAsFixed(6))} ; '
      '${Formatters.decimal(longitude.toStringAsFixed(6))}';
}
