// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_sync_data.freezed.dart';
part 'supplier_sync_data.g.dart';

/// Ligne `supplier` de la synchronisation : le fournisseur <b>sans téléphone</b>. Le champ n'existe pas dans ce type : un téléphone ne peut pas.
/// atteindre un téléphone mobile par la synchronisation, quel que soit le rôle (ADR 0012).
@Freezed()
abstract class SupplierSyncData with _$SupplierSyncData {
  const factory SupplierSyncData({
    required String id,
    required String name,
    required List<String> productIds,
    required bool isActive,
    required DateTime? deactivatedAt,
    required String version,
    required DateTime createdAt,
    required String? createdByName,
    required DateTime? updatedAt,
    required String? updatedByName,
  }) = _SupplierSyncData;

  factory SupplierSyncData.fromJson(Map<String, Object?> json) =>
      _$SupplierSyncDataFromJson(json);
}
