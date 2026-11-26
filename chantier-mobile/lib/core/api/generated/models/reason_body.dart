// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reason_body.freezed.dart';
part 'reason_body.g.dart';

/// Motif d'un refus, d'une annulation ou d'un solde : une valeur de la liste du cas (`GET /settings/materials`) ; `Other` impose une remarque.
@Freezed()
abstract class ReasonBody with _$ReasonBody {
  const factory ReasonBody({
    String? reasonCode,

    /// Remarque (200 caractères au plus), obligatoire pour `Other`.
    String? reasonNote,
  }) = _ReasonBody;

  factory ReasonBody.fromJson(Map<String, Object?> json) =>
      _$ReasonBodyFromJson(json);
}
