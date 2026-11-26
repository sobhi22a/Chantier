// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'quantity_body.dart';

part 'approve_body.freezed.dart';
part 'approve_body.g.dart';

/// Validation d'une demande, avec une quantité ajustée facultative (même unité).
@Freezed()
abstract class ApproveBody with _$ApproveBody {
  const factory ApproveBody({
    /// Quantité validée si elle diffère de la demande (ancienne et nouvelle valeurs sont tracées dans l'historique).
    QuantityBody? quantity,
  }) = _ApproveBody;

  factory ApproveBody.fromJson(Map<String, Object?> json) =>
      _$ApproveBodyFromJson(json);
}
