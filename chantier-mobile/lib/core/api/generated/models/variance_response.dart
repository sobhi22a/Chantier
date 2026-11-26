// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'measure_unit.dart';

part 'variance_response.freezed.dart';
part 'variance_response.g.dart';

/// Ecart entre le recu et le demande dans l'unite de la demande : negatif = manque, positif = surplus.
@Freezed()
abstract class VarianceResponse with _$VarianceResponse {
  const factory VarianceResponse({
    required double value,
    required MeasureUnit unit,
    required double percent,
  }) = _VarianceResponse;

  factory VarianceResponse.fromJson(Map<String, Object?> json) =>
      _$VarianceResponseFromJson(json);
}
