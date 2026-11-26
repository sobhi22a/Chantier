import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity_mirror.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:equatable/equatable.dart';

/// Une livraison **telle que l'utilisateur doit la voir** : l'etat du serveur (ligne locale) plus
/// ses saisies en attente d'envoi (correction, annulation), comme `RequestView` pour une demande.
///
/// * [row] : ligne a afficher (corrections et annulation provisoires deja appliquees) ;
/// * [isProvisional] : l'annulation affichee vient d'une saisie en attente (« a confirmer ») ;
/// * [hasPendingChanges] : une correction attend son envoi ;
/// * [needsCheck] : une saisie de cette livraison est refusee ou en conflit (« A verifier »).
class DeliveryView extends Equatable {
  const DeliveryView({
    required this.row,
    required this.stored,
    this.pendingOperations = const [],
    this.isProvisional = false,
    this.hasPendingChanges = false,
    this.needsCheck = false,
    this.photoCount = 0,
  });

  factory DeliveryView.plain(DeliveryRow row) =>
      DeliveryView(row: row, stored: row);

  final DeliveryRow row;

  /// Ligne stockee, sans surcouche (valeurs de depart d'une correction).
  final DeliveryRow stored;
  final List<OutboxRow> pendingOperations;
  final bool isProvisional;
  final bool hasPendingChanges;
  final bool needsCheck;

  /// Photos du bon (envoyees ou en attente d'envoi) ; sert au badge « BL manquant ».
  final int photoCount;

  String get id => row.id;

  /// Ni n° de BL ni photo : « BL manquant » (CA-MAT-007.7).
  bool get isNoteMissing => row.deliveryNoteNumber == null && photoCount == 0;

  DeliveryView withPhotoCount(int count) => DeliveryView(
    row: row,
    stored: stored,
    pendingOperations: pendingOperations,
    isProvisional: isProvisional,
    hasPendingChanges: hasPendingChanges,
    needsCheck: needsCheck,
    photoCount: count,
  );

  /// Creation jamais confirmee par le serveur : pas de numero.
  bool get isNotYetSent => row.isPending;

  /// Une saisie quelconque de cette livraison attend encore son envoi.
  bool get hasPendingOperation => pendingOperations.isNotEmpty || row.isPending;

  @override
  List<Object?> get props => [
    row,
    stored,
    pendingOperations,
    isProvisional,
    hasPendingChanges,
    needsCheck,
    photoCount,
  ];
}

/// Applique les saisies en attente [operations] (dans l'ordre de creation) a la ligne [stored].
/// Fonction **pure** : une operation refusee ou en conflit n'est jamais appliquee (le serveur fait
/// foi) ; une livraison deja annulee ne change plus.
DeliveryView overlayDelivery(
  DeliveryRow stored,
  Iterable<OutboxRow> operations,
) {
  var row = stored;
  var provisional = false;
  var pendingChanges = false;
  var needsCheck = false;
  final pending = <OutboxRow>[];

  for (final op in operations) {
    if (!op.isDeliveryOperation || !op.targetsDelivery(stored)) continue;
    if (op.status == OutboxStatus.conflict ||
        op.status == OutboxStatus.rejected) {
      needsCheck = true;
      continue;
    }
    if (op.operation == DeliveryEntity.create) continue;
    pending.add(op);
    if (row.isCancelled) continue;

    if (op.operation == DeliveryEntity.update) {
      final changed = _applyChanges(row, op.payload['changes']);
      if (changed != null) {
        row = changed;
        pendingChanges = true;
      }
    } else if (op.deliveryAction == DeliveryEntity.cancel) {
      final payload = op.payload;
      row = row.copyWith(
        status: DeliveryStatus.cancelled.code,
        cancelReasonCode: Value(payload['reasonCode'] as String?),
        cancelReasonNote: Value(payload['reasonNote'] as String?),
      );
      provisional = true;
    }
  }

  return DeliveryView(
    row: row,
    stored: stored,
    pendingOperations: pending,
    isProvisional: provisional,
    hasPendingChanges: pendingChanges,
    needsCheck: needsCheck,
  );
}

DeliveryRow? _applyChanges(DeliveryRow row, Object? raw) {
  if (raw is! Map) return null;
  final changes = Map<String, Object?>.from(raw);
  var next = row;
  var touched = false;

  final quantity = changes[DeliveryFieldKeys.quantity];
  if (quantity is Map && quantity['unit'] is String) {
    final value = Decimal.tryParse('${quantity['value']}');
    if (value != null) {
      next = next.copyWith(
        quantityValue: value,
        quantityUnit: quantity['unit']! as String,
      );
      touched = true;
    }
  }
  final date = changes[DeliveryFieldKeys.deliveryDate];
  if (date is String) {
    next = next.copyWith(deliveryDate: DateOnlyTextConverter.parse(date));
    touched = true;
  }
  final note = changes[DeliveryFieldKeys.deliveryNoteNumber];
  if (note is String && note.isNotEmpty) {
    next = next.copyWith(deliveryNoteNumber: Value(note));
    touched = true;
  }
  final conformity = changes[DeliveryFieldKeys.conformity];
  if (conformity is String) {
    next = next.copyWith(conformity: conformity);
    touched = true;
  }
  final reasonCode = changes[DeliveryFieldKeys.reserveReasonCode];
  if (reasonCode is String && reasonCode.isNotEmpty) {
    next = next.copyWith(reserveReasonCode: Value(reasonCode));
    touched = true;
  }
  final reserveNote = changes[DeliveryFieldKeys.reserveNote];
  if (reserveNote is String && reserveNote.isNotEmpty) {
    next = next.copyWith(reserveNote: Value(reserveNote));
    touched = true;
  }
  return touched ? next : null;
}

/// Livraisons regroupees par demande (identifiant de la demande, ou `clientId` de sa creation tant
/// qu'elle n'est pas confirmee) : un seul passage, quel que soit le nombre de demandes.
Map<String, List<DeliveryView>> groupByRequest(
  Iterable<DeliveryView> deliveries,
) {
  final groups = <String, List<DeliveryView>>{};
  for (final delivery in deliveries) {
    final requestId = delivery.row.requestId;
    if (requestId != null) {
      (groups[requestId] ??= <DeliveryView>[]).add(delivery);
    }
  }
  return groups;
}

/// Livraisons d'une demande dans [groups] (voir [groupByRequest]).
List<DeliveryView> deliveriesOfRequest(
  Map<String, List<DeliveryView>> groups,
  RequestView request,
) {
  final stored = request.stored;
  final clientId = stored.clientId;
  // Toujours une **nouvelle** liste modifiable (l'appelant peut la trier).
  return [
    ...?groups[stored.id],
    if (clientId != null && clientId != stored.id) ...?groups[clientId],
  ];
}

/// Recu, reste, ecart et statut **provisoires** d'une demande dont des livraisons attendent leur
/// envoi (saisies hors ligne, corrigees ou annulees : « a confirmer », CA-MAT-006.7,
/// CA-MAT-010.11). Sans saisie en attente, ou quand le calcul est impossible (statut sans recalcul,
/// unite non convertible), la demande est rendue **telle quelle** : le serveur fait foi.
///
/// [mine] : les livraisons de cette demande ([deliveriesOfRequest]). Meme regle que
/// `RequestStatusCalculator` du serveur (`QuantityMirror.provisionalReception`).
RequestView applyDeliveries(
  RequestView view,
  List<DeliveryView> mine, {
  Decimal? bagMassKg,
  Decimal? tolerancePercent,
}) {
  final anyPending = mine.any(
    (d) => d.isNotYetSent || d.hasPendingChanges || d.isProvisional,
  );
  final row = view.row;
  final ordered = row.quantity;
  final status = row.statusValue;
  if (!anyPending || ordered == null || status == null) return view;

  final facts = <DeliveryFact>[];
  for (final delivery in mine) {
    final quantity = delivery.row.quantity;
    if (quantity == null) return view;
    facts.add(
      DeliveryFact(
        quantity: quantity,
        isCancelled: delivery.row.isCancelled,
        isPending: delivery.isNotYetSent,
      ),
    );
  }
  final state = QuantityMirror.provisionalReception(
    status: status,
    ordered: ordered,
    deliveries: facts,
    bagMassKg: bagMassKg,
    tolerancePercent: tolerancePercent,
    isSettled: row.isSettled,
  );
  if (state == null) return view;

  return RequestView(
    row: row.copyWith(
      status: state.status.code,
      receivedValue: Value(state.received),
      remainingValue: Value(state.remaining),
      varianceValue: Value(state.variance),
      variancePercent: Value(state.variancePercent),
    ),
    stored: view.stored,
    pendingOperations: view.pendingOperations,
    isStatusProvisional: true,
    hasPendingChanges: view.hasPendingChanges,
    needsCheck: view.needsCheck,
  );
}

/// Livraisons d'un chantier et leurs photos : surcouche des saisies en attente et nombre de
/// photos (fonction pure, partagee par les depots de livraisons et de demandes).
List<DeliveryView> deliveryViews(
  List<DeliveryRow> rows,
  List<OutboxRow> operations,
  List<DeliveryPhotoRow> photos,
) {
  final deliveryOperations = [
    for (final op in operations)
      if (op.isDeliveryOperation) op,
  ];
  final photoCounts = <String, int>{};
  for (final photo in photos) {
    photoCounts[photo.deliveryId] = (photoCounts[photo.deliveryId] ?? 0) + 1;
  }
  return [
    for (final row in rows)
      overlayDelivery(
        row,
        deliveryOperations,
      ).withPhotoCount(photoCounts[row.id] ?? photoCounts[row.clientId] ?? 0),
  ];
}
