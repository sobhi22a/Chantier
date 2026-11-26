// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_deletion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncDeletion _$SyncDeletionFromJson(Map<String, dynamic> json) =>
    _SyncDeletion(
      entity: json['entity'] as String,
      id: json['id'] as String,
      siteId: json['siteId'] as String?,
      version: json['version'] as String,
    );

Map<String, dynamic> _$SyncDeletionToJson(_SyncDeletion instance) =>
    <String, dynamic>{
      'entity': instance.entity,
      'id': instance.id,
      'siteId': instance.siteId,
      'version': instance.version,
    };
