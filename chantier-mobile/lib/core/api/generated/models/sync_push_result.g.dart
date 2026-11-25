// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_push_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncPushResult _$SyncPushResultFromJson(Map<String, dynamic> json) =>
    _SyncPushResult(
      clientId: json['clientId'] as String,
      status: json['status'] as String,
      resource: json['resource'],
      current: json['current'],
      code: json['code'] as String?,
      merged: json['merged'] as bool?,
      errors: (json['errors'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$SyncPushResultToJson(_SyncPushResult instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'status': instance.status,
      'resource': instance.resource,
      'current': instance.current,
      'code': instance.code,
      'merged': instance.merged,
      'errors': instance.errors,
    };
