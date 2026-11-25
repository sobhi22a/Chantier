// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_push_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncPushOperation _$SyncPushOperationFromJson(Map<String, dynamic> json) =>
    _SyncPushOperation(
      clientId: json['clientId'] as String,
      entity: json['entity'] as String,
      operation: json['operation'] as String,
      siteId: json['siteId'] as String?,
      payload: json['payload'],
      baseVersion: json['baseVersion'] as String?,
    );

Map<String, dynamic> _$SyncPushOperationToJson(_SyncPushOperation instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'entity': instance.entity,
      'operation': instance.operation,
      'siteId': instance.siteId,
      'payload': instance.payload,
      'baseVersion': instance.baseVersion,
    };
