// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_sync_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SupplierSyncData _$SupplierSyncDataFromJson(Map<String, dynamic> json) =>
    _SupplierSyncData(
      id: json['id'] as String,
      name: json['name'] as String,
      productIds: (json['productIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool,
      deactivatedAt: json['deactivatedAt'] == null
          ? null
          : DateTime.parse(json['deactivatedAt'] as String),
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdByName: json['createdByName'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedByName: json['updatedByName'] as String?,
    );

Map<String, dynamic> _$SupplierSyncDataToJson(_SupplierSyncData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'productIds': instance.productIds,
      'isActive': instance.isActive,
      'deactivatedAt': instance.deactivatedAt?.toIso8601String(),
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdByName': instance.createdByName,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedByName': instance.updatedByName,
    };
