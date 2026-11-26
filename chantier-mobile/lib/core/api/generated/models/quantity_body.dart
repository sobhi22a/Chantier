// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'measure_unit.dart';

part 'quantity_body.freezed.dart';
part 'quantity_body.g.dart';

/// Quantité saisie : valeur et unité. L'unité est toujours obligatoire (422 `UNITE_OBLIGATOIRE` sinon, jamais une quantité sans unité).
@Freezed()
abstract class QuantityBody with _$QuantityBody {
  const factory QuantityBody({
    /// Valeur strictement positive, 3 décimales au plus ; entier pour `sac` et `u` (422 `QUANTITE_INVALIDE`, `QUANTITE_ENTIERE_REQUISE`).
    double? value,

    /// Unité du référentiel : `u ml m2 m3 kg t sac l h j pj ft`.
    MeasureUnit? unit,
  }) = _QuantityBody;

  factory QuantityBody.fromJson(Map<String, Object?> json) =>
      _$QuantityBodyFromJson(json);
}
