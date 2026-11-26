import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/product_search.dart';

/// Filtres de la liste des livraisons (CA-MAT-011.8, CA-MAT-012.2, CA-MAT-007.7).
enum DeliveryListFilter {
  all,

  /// « Non rattachees » : fait de chantier sans demande, a traiter.
  unattached,

  /// « Avec reserve ».
  withReserve,

  /// « BL manquant » : ni n° de BL ni photo.
  noteMissing,
}

/// Nom du produit d'une livraison a afficher : nom arabe en interface arabe quand il existe, sinon
/// le nom francais du catalogue, sinon le nom libre.
String deliveryProductName(DeliveryView view, String languageCode) {
  final row = view.row;
  final arabic = row.productNameAr;
  if (languageCode == 'ar' && arabic != null && arabic.isNotEmpty) {
    return arabic;
  }
  return row.productName ?? row.freeProductName ?? '—';
}

/// Fournisseur d'une livraison : nom du catalogue ou nom libre.
String? deliverySupplierName(DeliveryView view) =>
    view.row.supplierName ?? view.row.freeSupplierName;

/// Filtre, recherche et tri de la liste des livraisons (fonction pure, testee) :
/// * [unattachedRequestIds] : identifiants des demandes **connues** du telephone ; une livraison
///   dont la demande a disparu (saisie abandonnee) est traitee comme non rattachee ;
/// * [query] : numero, produit, fournisseur ou n° de BL, sans accents ni casse ;
/// * tri : la plus recente d'abord (date de livraison puis saisie).
List<DeliveryView> filterDeliveries(
  Iterable<DeliveryView> all, {
  required DeliveryListFilter filter,
  required String languageCode,
  Set<String>? knownRequestIds,
  String query = '',
}) {
  final tokens = normalizeSearchText(
    query,
  ).split(' ').where((token) => token.isNotEmpty).toList(growable: false);

  bool isUnattached(DeliveryView view) {
    final requestId = view.row.requestId;
    if (requestId == null) return true;
    return knownRequestIds != null && !knownRequestIds.contains(requestId);
  }

  bool inFilter(DeliveryView view) => switch (filter) {
    DeliveryListFilter.all => true,
    DeliveryListFilter.unattached => isUnattached(view),
    DeliveryListFilter.withReserve => view.row.conformity == 'WithReserve',
    DeliveryListFilter.noteMissing =>
      view.isNoteMissing && !view.row.isCancelled,
  };

  bool matches(DeliveryView view) {
    if (tokens.isEmpty) return true;
    final row = view.row;
    final haystack = normalizeSearchText(
      [
        row.number ?? '',
        row.productName ?? '',
        row.productNameAr ?? '',
        row.freeProductName ?? '',
        row.supplierName ?? '',
        row.freeSupplierName ?? '',
        row.deliveryNoteNumber ?? '',
      ].join(' '),
    );
    return tokens.every(haystack.contains);
  }

  final selected = [
    for (final view in all)
      if (inFilter(view) && matches(view)) view,
  ];
  selected.sort((a, b) {
    final byDate = b.row.deliveryDate.compareTo(a.row.deliveryDate);
    return byDate != 0 ? byDate : b.row.createdAt.compareTo(a.row.createdAt);
  });
  return selected;
}
