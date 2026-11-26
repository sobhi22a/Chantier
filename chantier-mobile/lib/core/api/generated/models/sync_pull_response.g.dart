// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_pull_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncPullResponse _$SyncPullResponseFromJson(Map<String, dynamic> json) =>
    _SyncPullResponse(
      changes: (json['changes'] as List<dynamic>)
          .map((e) => SyncChange.fromJson(e as Map<String, dynamic>))
          .toList(),
      deleted: (json['deleted'] as List<dynamic>)
          .map((e) => SyncDeletion.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String,
      hasMore: json['hasMore'] as bool,
      resetRequired: json['resetRequired'] as bool? ?? false,
    );

Map<String, dynamic> _$SyncPullResponseToJson(_SyncPullResponse instance) =>
    <String, dynamic>{
      'changes': instance.changes,
      'deleted': instance.deleted,
      'cursor': instance.cursor,
      'hasMore': instance.hasMore,
      'resetRequired': instance.resetRequired,
    };
