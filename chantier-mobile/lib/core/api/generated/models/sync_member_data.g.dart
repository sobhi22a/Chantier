// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_member_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncMemberData _$SyncMemberDataFromJson(Map<String, dynamic> json) =>
    _SyncMemberData(
      id: json['id'] as String,
      siteId: json['siteId'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );

Map<String, dynamic> _$SyncMemberDataToJson(_SyncMemberData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'role': instance.role,
      'assignedAt': instance.assignedAt.toIso8601String(),
    };
