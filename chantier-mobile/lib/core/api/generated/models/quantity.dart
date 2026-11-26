// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'measure_unit.dart';

part 'quantity.freezed.dart';
part 'quantity.g.dart';

/// Une quantite et son unite : les deux voyagent toujours ensemble (`{ "value": 300, "unit": "sac" }`).
@Freezed()
abstract class Quantity with _$Quantity {
  const factory Quantity({
    /// Valeur, 3 decimales au plus.
    required double value,

    /// Code de l'unite : `u ml m2 m3 kg t sac l h j pj ft`.
    required MeasureUnit unit,
  }) = _Quantity;

  factory Quantity.fromJson(Map<String, Object?> json) =>
      _$QuantityFromJson(json);
}
