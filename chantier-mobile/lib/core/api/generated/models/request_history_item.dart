// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'field_change.dart';
import 'material_event_source.dart';
import 'material_event_type.dart';
import 'request_status.dart';

part 'request_history_item.freezed.dart';
part 'request_history_item.g.dart';

/// Evenement de l'historique : qui, quand (heure du serveur), ancien et nouveau statut, motif, champs modifies.
@Freezed()
abstract class RequestHistoryItem with _$RequestHistoryItem {
  const factory RequestHistoryItem({
    required String id,
    required MaterialEventType type,
    required RequestStatus? fromStatus,
    required RequestStatus? toStatus,
    required String? reasonCode,
    required String? reasonNote,
    required List<FieldChange>? changes,
    required String? actorName,
    required DateTime occurredAt,

    /// « Saisi le » du telephone pour une saisie hors ligne : information seulement.
    required DateTime? deviceAt,
    required MaterialEventSource source,
  }) = _RequestHistoryItem;

  factory RequestHistoryItem.fromJson(Map<String, Object?> json) =>
      _$RequestHistoryItemFromJson(json);
}
