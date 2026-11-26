// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_supplier_request.freezed.dart';
part 'create_supplier_request.g.dart';

@Freezed()
abstract class CreateSupplierRequest with _$CreateSupplierRequest {
  const factory CreateSupplierRequest({
    /// Nom du fournisseur (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus).
    required String name,

    /// Téléphone au format algérien (05, 06 ou 07 suivi de 8 chiffres, espaces facultatifs).
    String? phone,

    /// Produits fournis (identifiants du catalogue), liste indicative.
    List<String>? productIds,
  }) = _CreateSupplierRequest;

  factory CreateSupplierRequest.fromJson(Map<String, Object?> json) =>
      _$CreateSupplierRequestFromJson(json);
}
