// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_response.freezed.dart';
part 'supplier_response.g.dart';

/// Fournisseur. `phone` est <b>absent</b> (clé non écrite) sans la permission `SupplierPhone.View` et n'existe jamais dans les données de.
/// synchronisation ni dans un journal (ADR 0012).
@Freezed()
abstract class SupplierResponse with _$SupplierResponse {
  const factory SupplierResponse({
    required String id,
    required String name,

    /// Produits fournis (liste indicative).
    required List<String> productIds,
    required bool isActive,
    required DateTime? deactivatedAt,
    required String version,
    required DateTime createdAt,
    required String? createdByName,
    required DateTime? updatedAt,
    required String? updatedByName,

    /// Téléphone au format algérien (`0550 00 00 21`) ; donnée sensible.
    String? phone,
  }) = _SupplierResponse;

  factory SupplierResponse.fromJson(Map<String, Object?> json) =>
      _$SupplierResponseFromJson(json);
}
