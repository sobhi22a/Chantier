// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'type.dart';
import 'from_status.dart';
import 'to_status.dart';
import 'changes2.dart';
import 'source.dart';

part 'history2.freezed.dart';
part 'history2.g.dart';

@Freezed()
abstract class History2 with _$History2 {
  const factory History2({
    required String id,

    /// Type d'evenement de l'historique. `OrderCommercialEdited` est sensible : rendu seulement avec `Prices.View`, jamais synchronise.
    required Type type,
    required FromStatus fromStatus,
    required ToStatus toStatus,
    required String? reasonCode,
    required String? reasonNote,
    required List<Changes2>? changes,
    required String? actorName,
    required DateTime occurredAt,

    /// « Saisi le » du telephone pour une saisie hors ligne : information seulement.
    required DateTime? deviceAt,

    /// Origine d'un evenement : API directe, push de synchronisation, ou systeme (recalcul).
    required Source source,
  }) = _History2;

  factory History2.fromJson(Map<String, Object?> json) =>
      _$History2FromJson(json);
}
