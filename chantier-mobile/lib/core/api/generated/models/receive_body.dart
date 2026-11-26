// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'receive_body.freezed.dart';
part 'receive_body.g.dart';

/// Réception d'une demande livrée.
@Freezed()
abstract class ReceiveBody with _$ReceiveBody {
  const factory ReceiveBody({
    /// Remarque facultative (200 caractères au plus).
    String? note,
  }) = _ReceiveBody;

  factory ReceiveBody.fromJson(Map<String, Object?> json) =>
      _$ReceiveBodyFromJson(json);
}
