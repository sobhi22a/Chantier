import 'package:chantier_mobile/core/l10n/quantity_format.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';

/// Libelle d'une saisie pour « Envois en attente » : `DEM-014 · Ciment CPJ 42,5 · 300 sac`
/// (texte brut, les parties sont separees par « · » et isolees a l'affichage). Une demande
/// jamais envoyee n'a pas encore de numero : il est omis.
String requestOperationLabel(
  AppLocalizations l10n,
  MaterialRequestRow row, {
  Quantity? quantity,
}) {
  final shown = quantity ?? row.quantity;
  return [
    if (row.number != null) row.number!,
    requestProductName(row, 'fr'),
    if (shown != null)
      formatQuantity(l10n, shown)
    else
      '${row.quantityValue} ${row.quantityUnit}',
  ].join(' · ');
}
