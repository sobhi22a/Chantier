import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/order_info.dart';
import 'package:chantier_mobile/features/materials/domain/product_search.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';

/// Filtres de « A recevoir » (CA-MAT-006.12).
enum ReceiveFilter { all, today, week, late }

/// Date de livraison prevue d'une demande commandee : celle de la commande, sinon la date de
/// besoin (jamais une date inventee : l'ecran dit « date prevue non indiquee » dans ce cas).
DateTime? expectedDateOf(RequestView view) =>
    view.row.order?.expectedDeliveryDate;

/// Commandes attendues (« A recevoir ») : demandes **commandees ou livrees partiellement** (statut
/// affiche, surcouche comprise), non archivees, la date prevue la plus proche en premier
/// (CA-MAT-006.1). Fonction pure, testee.
///
/// * [today] : jour d'Algerie ; « Aujourd'hui » = date prevue du jour, « Cette semaine » = les 7
///   prochains jours, « En retard » = date prevue depassee (a defaut de date prevue, date de besoin) ;
/// * [query] : numero, materiau, fournisseur, sans accents ni casse.
List<RequestView> filterToReceive(
  Iterable<RequestView> all, {
  required ReceiveFilter filter,
  required DateTime today,
  required String languageCode,
  String query = '',
}) {
  final tokens = normalizeSearchText(
    query,
  ).split(' ').where((token) => token.isNotEmpty).toList(growable: false);
  final weekEnd = DateTime.utc(today.year, today.month, today.day + 6);

  bool inFilter(RequestView view) {
    final date = expectedDateOf(view) ?? view.row.neededBy;
    return switch (filter) {
      ReceiveFilter.all => true,
      ReceiveFilter.today => date == today,
      ReceiveFilter.week => !date.isBefore(today) && !date.isAfter(weekEnd),
      ReceiveFilter.late => date.isBefore(today),
    };
  }

  bool matches(RequestView view) {
    if (tokens.isEmpty) return true;
    final row = view.row;
    final haystack = normalizeSearchText(
      [
        row.number ?? '',
        requestProductName(row, languageCode),
        row.productName ?? '',
        row.freeProductName ?? '',
        row.order?.supplierName ?? '',
      ].join(' '),
    );
    return tokens.every(haystack.contains);
  }

  final selected = [
    for (final view in all)
      if (view.row.archivedAt == null &&
          const {
            RequestStatus.ordered,
            RequestStatus.partiallyDelivered,
          }.contains(view.row.statusValue) &&
          inFilter(view) &&
          matches(view))
        view,
  ];
  selected.sort((a, b) {
    final left = expectedDateOf(a) ?? a.row.neededBy;
    final right = expectedDateOf(b) ?? b.row.neededBy;
    final byDate = left.compareTo(right);
    return byDate != 0 ? byDate : a.row.createdAt.compareTo(b.row.createdAt);
  });
  return selected;
}
