// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SiteResponse _$SiteResponseFromJson(Map<String, dynamic> json) =>
    _SiteResponse(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      type: SiteType.fromJson(json['type'] as String),
      wilaya: json['wilaya'] as String,
      commune: json['commune'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      owner: json['owner'] as String,
      contractNumber: json['contractNumber'] as String?,
      delayDays: (json['delayDays'] as num?)?.toInt(),
      odsDate: json['odsDate'] == null
          ? null
          : DateTime.parse(json['odsDate'] as String),
      contractualEndDate: json['contractualEndDate'] == null
          ? null
          : DateTime.parse(json['contractualEndDate'] as String),
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      archivedByName: json['archivedByName'] as String?,
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdByName: json['createdByName'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedByName: json['updatedByName'] as String?,
      contractAmount: (json['contractAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SiteResponseToJson(_SiteResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'type': instance.type,
      'wilaya': instance.wilaya,
      'commune': instance.commune,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'owner': instance.owner,
      'contractNumber': instance.contractNumber,
      'delayDays': instance.delayDays,
      'odsDate': instance.odsDate?.toIso8601String(),
      'contractualEndDate': instance.contractualEndDate?.toIso8601String(),
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'archivedByName': instance.archivedByName,
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdByName': instance.createdByName,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedByName': instance.updatedByName,
      'contractAmount': instance.contractAmount,
    };
