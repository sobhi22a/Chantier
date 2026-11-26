// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RequestHistoryItem _$RequestHistoryItemFromJson(Map<String, dynamic> json) =>
    _RequestHistoryItem(
      id: json['id'] as String,
      type: MaterialEventType.fromJson(json['type'] as String),
      fromStatus: json['fromStatus'] == null
          ? null
          : RequestStatus.fromJson(json['fromStatus'] as String),
      toStatus: json['toStatus'] == null
          ? null
          : RequestStatus.fromJson(json['toStatus'] as String),
      reasonCode: json['reasonCode'] as String?,
      reasonNote: json['reasonNote'] as String?,
      changes: (json['changes'] as List<dynamic>?)
          ?.map((e) => FieldChange.fromJson(e as Map<String, dynamic>))
          .toList(),
      actorName: json['actorName'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      deviceAt: json['deviceAt'] == null
          ? null
          : DateTime.parse(json['deviceAt'] as String),
      source: MaterialEventSource.fromJson(json['source'] as String),
    );

Map<String, dynamic> _$RequestHistoryItemToJson(_RequestHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'fromStatus': instance.fromStatus,
      'toStatus': instance.toStatus,
      'reasonCode': instance.reasonCode,
      'reasonNote': instance.reasonNote,
      'changes': instance.changes,
      'actorName': instance.actorName,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'deviceAt': instance.deviceAt?.toIso8601String(),
      'source': instance.source,
    };
