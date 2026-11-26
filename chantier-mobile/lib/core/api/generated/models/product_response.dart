// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_response_allowed_units.dart';
import 'product_response_category.dart';
import 'product_response_default_unit.dart';

part 'product_response.freezed.dart';
part 'product_response.g.dart';

/// Produit du catalogue tel que renvoye par l'API et par la synchronisation (meme JSON, globale : sans chantier).
@Freezed()
abstract class ProductResponse with _$ProductResponse {
  const factory ProductResponse({
    required String id,

    /// Nom en français.
    required String nameFr,

    /// Nom en arabe, s'il existe (sinon le nom français est affiché).
    required String? nameAr,
    required ProductResponseCategory category,

    /// Unités autorisées (codes du référentiel : `sac`, `t`, `kg`...), jamais du texte libre.
    required List<ProductResponseAllowedUnits> allowedUnits,

    /// Unites du referentiel (skill `metier-chantier`), identifiees par leur <b>code stable</b> dans le JSON, la base et les vecteurs de calcul :.
    /// `u ml m2 m3 kg t sac l h j pj ft`. Une quantite n'existe jamais sans unite (regle 1).
    required ProductResponseDefaultUnit defaultUnit,

    /// Masse d'un sac en kg (50 pour le ciment) ; obligatoire si l'unité `sac` est autorisée. Sert aux conversions sac, kg, T.
    required double? bagMassKg,

    /// Un produit désactivé reste affiché dans l'historique mais ne peut plus être demandé ni livré.
    required bool isActive,
    required DateTime? deactivatedAt,

    /// Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.
    required String version,
    required DateTime createdAt,
    required String? createdByName,
    required DateTime? updatedAt,
    required String? updatedByName,
  }) = _ProductResponse;

  factory ProductResponse.fromJson(Map<String, Object?> json) =>
      _$ProductResponseFromJson(json);
}
