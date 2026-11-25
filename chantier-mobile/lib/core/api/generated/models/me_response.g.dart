// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeResponse _$MeResponseFromJson(Map<String, dynamic> json) => _MeResponse(
  id: json['id'] as String,
  userName: json['userName'] as String,
  fullName: json['fullName'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  role: json['role'] as String,
  language: json['language'] as String,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  permissionsVersion: json['permissionsVersion'] as String,
  mustChangePassword: json['mustChangePassword'] as bool,
);

Map<String, dynamic> _$MeResponseToJson(_MeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'role': instance.role,
      'language': instance.language,
      'permissions': instance.permissions,
      'permissionsVersion': instance.permissionsVersion,
      'mustChangePassword': instance.mustChangePassword,
    };
