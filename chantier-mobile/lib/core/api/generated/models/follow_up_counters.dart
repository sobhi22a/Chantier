// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_up_counters.freezed.dart';
part 'follow_up_counters.g.dart';

/// Compteurs des cinq vues du suivi d'un chantier (demandes non archivees).
@Freezed()
abstract class FollowUpCounters with _$FollowUpCounters {
  const factory FollowUpCounters({
    /// A valider : demandees.
    required int toApprove,

    /// A commander : validees.
    required int toOrder,

    /// Attendues : commandees et livrees partiellement.
    required int expected,

    /// En retard : date de besoin depassee, ou commande attendue dont la date prevue est depassee.
    /// The name has been replaced because it contains a keyword. Original name: `late`.
    @JsonKey(name: 'late') required int lateValue,

    /// A receptionner : livrees.
    required int toReceive,
  }) = _FollowUpCounters;

  factory FollowUpCounters.fromJson(Map<String, Object?> json) =>
      _$FollowUpCountersFromJson(json);
}
