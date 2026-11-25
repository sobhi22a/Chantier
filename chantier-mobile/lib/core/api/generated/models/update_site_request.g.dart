// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_site_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateSiteRequest _$UpdateSiteRequestFromJson(Map<String, dynamic> json) =>
    _UpdateSiteRequest(
      version: json['version'] as String,
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

Map<String, dynamic> _$UpdateSiteRequestToJson(_UpdateSiteRequest instance) =>
    <String, dynamic>{
      'version': instance.version,
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
