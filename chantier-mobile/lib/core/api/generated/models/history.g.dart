// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_History _$HistoryFromJson(Map<String, dynamic> json) => _History(
  id: json['id'] as String,
  type: Type.fromJson(json['type'] as String),
  fromStatus: FromStatus.fromJson(json['fromStatus'] as String),
  toStatus: ToStatus.fromJson(json['toStatus'] as String),
  reasonCode: json['reasonCode'] as String?,
  reasonNote: json['reasonNote'] as String?,
  changes: (json['changes'] as List<dynamic>?)
      ?.map((e) => Changes.fromJson(e as Map<String, dynamic>))
      .toList(),
  actorName: json['actorName'] as String?,
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  deviceAt: json['deviceAt'] == null
      ? null
      : DateTime.parse(json['deviceAt'] as String),
  source: Source.fromJson(json['source'] as String),
);

Map<String, dynamic> _$HistoryToJson(_History instance) => <String, dynamic>{
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
