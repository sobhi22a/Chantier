import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:equatable/equatable.dart';

/// Une demande **telle que l'utilisateur doit la voir** : l'etat du serveur (ligne locale) plus ses
/// saisies en attente d'envoi (surcouche provisoire, plan M3).
///
/// * [row] : ligne a afficher (champs modifies et statut provisoires deja appliques) ;
/// * [isStatusProvisional] : le statut affiche vient d'une saisie en attente, il est marque
///   « a confirmer » jusqu'a la reponse du serveur (CA-MAT-006.7, CA-MAT-010.11) ;
/// * [hasPendingChanges] : une correction attend son envoi ;
/// * [needsCheck] : une saisie de cette demande est refusee ou en conflit (« A verifier »).
///
/// La surcouche disparait d'elle-meme quand l'operation quitte la file : le serveur remplace
/// toujours la valeur provisoire.
class RequestView extends Equatable {
  const RequestView({
    required this.row,
    required this.stored,
    this.pendingOperations = const [],
    this.isStatusProvisional = false,
    this.hasPendingChanges = false,
    this.needsCheck = false,
  });

  /// Aucune saisie en attente : la ligne est celle du serveur (ou une creation jamais envoyee).
  factory RequestView.plain(MaterialRequestRow row) =>
      RequestView(row: row, stored: row);

  final MaterialRequestRow row;

  /// Ligne stockee, sans surcouche (valeurs de depart d'une modification).
  final MaterialRequestRow stored;
  final List<OutboxRow> pendingOperations;
  final bool isStatusProvisional;
  final bool hasPendingChanges;
  final bool needsCheck;

  String get id => row.id;

  /// Creation jamais confirmee par le serveur : pas de numero, pas encore sur le serveur.
  bool get isNotYetSent => row.isPending;

  /// Une transition `approve` attend son envoi (« Validation en attente d'envoi »).
  bool get hasPendingApproval => pendingOperations.any(
    (op) => op.transitionAction == RequestEntity.approve,
  );

  /// Une saisie quelconque de cette demande attend encore son envoi.
  bool get hasPendingOperation => pendingOperations.isNotEmpty || row.isPending;

  @override
  List<Object?> get props => [
    row,
    stored,
    pendingOperations,
    isStatusProvisional,
    hasPendingChanges,
    needsCheck,
  ];
}

/// Applique les saisies en attente [operations] (dans l'ordre de creation) a la ligne [stored].
///
/// Fonction **pure** : seules les operations `pending` ou `sending` de la demande modifient
/// l'affichage ; une operation refusee ou en conflit n'est jamais appliquee (elle est signalee par
/// `needsCheck` et le serveur fait foi). Une transition n'est appliquee que depuis un statut ou
/// elle a un sens (valider une demande deja validee n'invente rien).
RequestView overlayRequest(
  MaterialRequestRow stored,
  Iterable<OutboxRow> operations,
) {
  var row = stored;
  var provisionalStatus = false;
  var pendingChanges = false;
  var needsCheck = false;
  final pending = <OutboxRow>[];

  for (final op in operations) {
    if (!op.targets(stored)) continue;
    if (op.status == OutboxStatus.conflict ||
        op.status == OutboxStatus.rejected) {
      needsCheck = true;
      continue;
    }
    if (op.operation == RequestEntity.create) continue;
    pending.add(op);

    if (op.operation == RequestEntity.update) {
      final changed = _applyChanges(row, op.payload['changes']);
      if (changed != null) {
        row = changed;
        pendingChanges = true;
      }
    } else if (op.operation == RequestEntity.transition) {
      final next = _applyTransition(row, op);
      if (next != null) {
        row = next;
        provisionalStatus = true;
      }
    }
  }

  return RequestView(
    row: row,
    stored: stored,
    pendingOperations: pending,
    isStatusProvisional: provisionalStatus,
    hasPendingChanges: pendingChanges,
    needsCheck: needsCheck,
  );
}

MaterialRequestRow? _applyChanges(MaterialRequestRow row, Object? raw) {
  if (raw is! Map) return null;
  final changes = Map<String, Object?>.from(raw);
  var next = row;
  var touched = false;

  final quantity = changes[RequestFieldKeys.quantity];
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
  if (changes.containsKey(RequestFieldKeys.zoneId)) {
    next = next.copyWith(
      zoneId: _nullableText(changes[RequestFieldKeys.zoneId]),
    );
    touched = true;
  }
  final neededBy = changes[RequestFieldKeys.neededBy];
  if (neededBy is String) {
    next = next.copyWith(neededBy: DateOnlyTextConverter.parse(neededBy));
    touched = true;
  }
  final priority = changes[RequestFieldKeys.priority];
  if (priority is String) {
    next = next.copyWith(priority: priority);
    touched = true;
  }
  if (changes.containsKey(RequestFieldKeys.note)) {
    next = next.copyWith(note: _nullableText(changes[RequestFieldKeys.note]));
    touched = true;
  }
  return touched ? next : null;
}

/// `null` du JSON = champ efface (zone retiree, remarque vide) ; `copyWith` de Drift veut un `Value`.
Value<String?> _nullableText(Object? raw) => Value(raw is String ? raw : null);

MaterialRequestRow? _applyTransition(MaterialRequestRow row, OutboxRow op) {
  final status = row.statusValue;
  final payload = op.payload;
  switch (op.transitionAction) {
    case RequestEntity.approve:
      if (status != RequestStatus.requested) return null;
      final quantity = payload['quantity'];
      var next = row.copyWith(status: RequestStatus.validated.code);
      if (quantity is Map && quantity['unit'] is String) {
        final value = Decimal.tryParse('${quantity['value']}');
        if (value != null) {
          next = next.copyWith(
            quantityValue: value,
            quantityUnit: quantity['unit']! as String,
          );
        }
      }
      return next;
    case RequestEntity.reject:
      if (status != RequestStatus.requested) return null;
      return row.copyWith(
        status: RequestStatus.rejected.code,
        statusReasonCode: Value(payload['reasonCode'] as String?),
        statusReasonNote: Value(payload['reasonNote'] as String?),
      );
    case RequestEntity.cancel:
      if (status != RequestStatus.requested &&
          status != RequestStatus.validated) {
        return null;
      }
      return row.copyWith(
        status: RequestStatus.cancelled.code,
        statusReasonCode: Value(payload['reasonCode'] as String?),
        statusReasonNote: Value(payload['reasonNote'] as String?),
      );
    case RequestEntity.receive:
      if (status != RequestStatus.delivered) return null;
      return row.copyWith(status: RequestStatus.received.code);
    default:
      return null;
  }
}
