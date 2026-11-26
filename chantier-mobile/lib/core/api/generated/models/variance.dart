// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'unit.dart';

part 'variance.freezed.dart';
part 'variance.g.dart';

@Freezed()
abstract class Variance with _$Variance {
  const factory Variance({
    required double value,

    /// Unites du referentiel (skill `metier-chantier`), identifiees par leur <b>code stable</b> dans le JSON, la base et les vecteurs de calcul :.
    /// `u ml m2 m3 kg t sac l h j pj ft`. Une quantite n'existe jamais sans unite (regle 1).
    required Unit unit,
    required double percent,
  }) = _Variance;

  factory Variance.fromJson(Map<String, Object?> json) =>
      _$VarianceFromJson(json);
}
