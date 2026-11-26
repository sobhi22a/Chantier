// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_supplier_request.freezed.dart';
part 'update_supplier_request.g.dart';

@Freezed()
abstract class UpdateSupplierRequest with _$UpdateSupplierRequest {
  const factory UpdateSupplierRequest({
    /// Version lue avec le fournisseur ; une version périmée donne 409 `CONFLIT_VERSION`.
    required String version,

    /// Nom du fournisseur (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus).
    required String name,

    /// Téléphone au format algérien (05, 06 ou 07 suivi de 8 chiffres, espaces facultatifs).
    String? phone,

    /// Produits fournis (identifiants du catalogue), liste indicative.
    List<String>? productIds,
  }) = _UpdateSupplierRequest;

  factory UpdateSupplierRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateSupplierRequestFromJson(json);
}
