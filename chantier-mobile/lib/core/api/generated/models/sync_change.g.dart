// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncChange _$SyncChangeFromJson(Map<String, dynamic> json) => _SyncChange(
  entity: json['entity'] as String,
  id: json['id'] as String,
  siteId: json['siteId'] as String,
  version: json['version'] as String,
  data: json['data'],
);

Map<String, dynamic> _$SyncChangeToJson(_SyncChange instance) =>
    <String, dynamic>{
      'entity': instance.entity,
      'id': instance.id,
      'siteId': instance.siteId,
      'version': instance.version,
      'data': instance.data,
    };
