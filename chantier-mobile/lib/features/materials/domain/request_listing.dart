import 'dart:convert';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/product_search.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:equatable/equatable.dart';

/// Nom du produit d'une demande a afficher : nom arabe en interface arabe quand il existe, sinon
/// le nom francais du catalogue, sinon le nom libre (« Autre produit »).
String requestProductName(MaterialRequestRow row, String languageCode) {
  final arabic = row.productNameAr;
  if (languageCode == 'ar' && arabic != null && arabic.isNotEmpty) {
    return arabic;
  }
  return row.productName ?? row.freeProductName ?? '—';
}

/// Vue de la liste des demandes : filtre, recherche et tri (fonction pure, testee).
///
/// * l'appartenance a une vue suit le statut **affiche** (surcouche des saisies en attente) : une
///   demande annulee hors ligne passe tout de suite dans « Refusees et annulees » ;
/// * « A valider » suit le statut **stocke** : une demande dont la validation attend son envoi
///   reste dans la file, marquee « Validation en attente d'envoi » ;
/// * [mineUserId] : « Mes demandes » ;
/// * [query] : numero, produit ou remarque, sans accents ni casse, chaque mot doit se retrouver.
List<RequestView> filterRequests(
  Iterable<RequestView> all, {
  required RequestListView view,
  required String languageCode,
  String? mineUserId,
  String query = '',
}) {
  final tokens = normalizeSearchText(
    query,
  ).split(' ').where((token) => token.isNotEmpty).toList(growable: false);

  bool inView(RequestView item) {
    final row = view == RequestListView.toApprove ? item.stored : item.row;
    if (view == RequestListView.archived) return row.archivedAt != null;
    if (row.archivedAt != null) return false;
    final status = row.statusValue;
    return status != null && view.statuses.contains(status);
  }

  bool matches(RequestView item) {
    if (tokens.isEmpty) return true;
    final row = item.row;
    final haystack = normalizeSearchText(
      [
        row.number ?? '',
        row.productName ?? '',
        row.productNameAr ?? '',
        row.freeProductName ?? '',
        row.note ?? '',
      ].join(' '),
    );
    return tokens.every(haystack.contains);
  }

  final selected = [
    for (final item in all)
      if (inView(item) &&
          (mineUserId == null || item.row.requestedById == mineUserId) &&
          matches(item))
        item,
  ];

  final byUrgency =
      view == RequestListView.toFollow ||
      view == RequestListView.toApprove ||
      view == RequestListView.expected ||
      view == RequestListView.toReception;
  selected.sort((a, b) {
    if (byUrgency) {
      final byPriority = _rank(a.row).compareTo(_rank(b.row));
      if (byPriority != 0) return byPriority;
      final byDate = a.row.neededBy.compareTo(b.row.neededBy);
      if (byDate != 0) return byDate;
      return a.row.createdAt.compareTo(b.row.createdAt);
    }
    return b.row.createdAt.compareTo(a.row.createdAt);
  });
  return selected;
}

int _rank(MaterialRequestRow row) => row.priorityValue?.rank ?? 2;

/// Une demande ouverte (`Requested` ou `Validated`) du meme chantier, meme produit du catalogue
/// et meme zone (ou aucune) : « possible doublon », jamais un blocage (CA-MAT-001.9). Le calcul
/// definitif est celui du serveur ; celui-ci n'avertit que pendant la saisie, hors ligne.
MaterialRequestRow? findPossibleDuplicate(
  Iterable<MaterialRequestRow> rows, {
  required String? productId,
  required String? zoneId,
  String? ignoringId,
}) {
  if (productId == null) return null;
  for (final row in rows) {
    if (row.id == ignoringId || row.archivedAt != null) continue;
    final status = row.statusValue;
    if (status != RequestStatus.requested &&
        status != RequestStatus.validated) {
      continue;
    }
    if (row.productId == productId && row.zoneId == zoneId) return row;
  }
  return null;
}

/// Evenement de l'historique d'une demande (`history[]` de `RequestSyncData`), jamais sensible.
class RequestHistoryEvent extends Equatable {
  const RequestHistoryEvent({
    required this.type,
    required this.occurredAt,
    this.fromStatus,
    this.toStatus,
    this.reasonCode,
    this.reasonNote,
    this.changes = const [],
    this.actorName,
    this.deviceAt,
  });

  /// `Created`, `Approved`, `QuantityAdjusted`... (texte recu : un type inconnu est affiche tel quel).
  final String type;
  final DateTime occurredAt;
  final String? fromStatus;
  final String? toStatus;
  final String? reasonCode;
  final String? reasonNote;
  final List<RequestFieldChange> changes;
  final String? actorName;

  /// « Saisi le » du telephone (information seulement).
  final DateTime? deviceAt;

  @override
  List<Object?> get props => [
    type,
    occurredAt,
    fromStatus,
    toStatus,
    reasonCode,
    reasonNote,
    changes,
    actorName,
    deviceAt,
  ];
}

class RequestFieldChange extends Equatable {
  const RequestFieldChange({required this.field, this.oldValue, this.newValue});

  final String field;
  final String? oldValue;
  final String? newValue;

  @override
  List<Object?> get props => [field, oldValue, newValue];
}

/// Historique lu dans `history_json`, du plus ancien au plus recent. Un evenement illisible est
/// ignore (jamais d'erreur a l'ecran pour un historique).
List<RequestHistoryEvent> parseHistory(String? historyJson) {
  if (historyJson == null) return const [];
  final Object? decoded;
  try {
    decoded = jsonDecode(historyJson);
  } on FormatException {
    return const [];
  }
  if (decoded is! List) return const [];
  final events = <RequestHistoryEvent>[];
  for (final item in decoded) {
    if (item is! Map) continue;
    final occurredAt = DateTime.tryParse('${item['occurredAt']}');
    final type = item['type'];
    if (occurredAt == null || type is! String) continue;
    final rawChanges = item['changes'];
    events.add(
      RequestHistoryEvent(
        type: type,
        occurredAt: occurredAt.toUtc(),
        fromStatus: item['fromStatus'] as String?,
        toStatus: item['toStatus'] as String?,
        reasonCode: item['reasonCode'] as String?,
        reasonNote: item['reasonNote'] as String?,
        changes: [
          if (rawChanges is List)
            for (final change in rawChanges)
              if (change is Map && change['field'] is String)
                RequestFieldChange(
                  field: change['field']! as String,
                  oldValue: change['old'] as String?,
                  newValue: change['new'] as String?,
                ),
        ],
        actorName: item['actorName'] as String?,
        deviceAt: DateTime.tryParse('${item['deviceAt']}')?.toUtc(),
      ),
    );
  }
  events.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  return events;
}
