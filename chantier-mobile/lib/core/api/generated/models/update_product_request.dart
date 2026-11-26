// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'measure_unit.dart';
import 'product_category.dart';

part 'update_product_request.freezed.dart';
part 'update_product_request.g.dart';

@Freezed()
abstract class UpdateProductRequest with _$UpdateProductRequest {
  const factory UpdateProductRequest({
    /// Version lue avec le produit ; une version périmée donne 409 `CONFLIT_VERSION`.
    required String version,

    /// Nom en français (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus).
    required String nameFr,

    /// Catégorie du catalogue.
    required ProductCategory? category,

    /// Unités autorisées (au moins une), parmi le référentiel : jamais de texte libre.
    required List<MeasureUnit> allowedUnits,

    /// Unité proposée par défaut ; doit faire partie des unités autorisées (422 `UNITE_NON_AUTORISEE` sinon).
    required MeasureUnit? defaultUnit,

    /// Nom en arabe (facultatif : le nom français est affiché à défaut).
    String? nameAr,

    /// Masse d'un sac en kg ; obligatoire si l'unité `sac` est autorisée (422 `MASSE_SAC_OBLIGATOIRE`).
    double? bagMassKg,
  }) = _UpdateProductRequest;

  factory UpdateProductRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateProductRequestFromJson(json);
}
