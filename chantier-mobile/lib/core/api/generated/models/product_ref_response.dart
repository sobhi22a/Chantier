// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_ref_response.freezed.dart';
part 'product_ref_response.g.dart';

/// Produit d'une demande : du catalogue (`productId`, `name`) et/ou le nom libre saisi (`freeName`, conserve apres un rattachement).
@Freezed()
abstract class ProductRefResponse with _$ProductRefResponse {
  const factory ProductRefResponse({
    required String? productId,
    required String? name,
    required String? nameAr,
    required String? freeName,
  }) = _ProductRefResponse;

  factory ProductRefResponse.fromJson(Map<String, Object?> json) =>
      _$ProductRefResponseFromJson(json);
}
