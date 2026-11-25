// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_site_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateSiteRequest _$CreateSiteRequestFromJson(Map<String, dynamic> json) =>
    _CreateSiteRequest(
      code: json['code'] as String,
      name: json['name'] as String,
      type: json['type'] == null
          ? null
          : SiteType.fromJson(json['type'] as String),
      wilaya: json['wilaya'] as String,
      commune: json['commune'] as String,
      owner: json['owner'] as String,
      nameAr: json['nameAr'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contractNumber: json['contractNumber'] as String?,
      contractAmount: (json['contractAmount'] as num?)?.toDouble(),
      delayDays: (json['delayDays'] as num?)?.toInt(),
      odsDate: json['odsDate'] == null
          ? null
          : DateTime.parse(json['odsDate'] as String),
    );

Map<String, dynamic> _$CreateSiteRequestToJson(_CreateSiteRequest instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'type': instance.type,
      'wilaya': instance.wilaya,
      'commune': instance.commune,
      'owner': instance.owner,
      'nameAr': instance.nameAr,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'contractNumber': instance.contractNumber,
      'contractAmount': instance.contractAmount,
      'delayDays': instance.delayDays,
      'odsDate': instance.odsDate?.toIso8601String(),
    };
