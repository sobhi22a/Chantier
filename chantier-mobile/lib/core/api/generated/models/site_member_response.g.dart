// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_member_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SiteMemberResponse _$SiteMemberResponseFromJson(Map<String, dynamic> json) =>
    _SiteMemberResponse(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );

Map<String, dynamic> _$SiteMemberResponseToJson(_SiteMemberResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'fullName': instance.fullName,
      'role': instance.role,
      'assignedAt': instance.assignedAt.toIso8601String(),
    };
