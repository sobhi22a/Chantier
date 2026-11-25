// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUserResponse _$AuthUserResponseFromJson(Map<String, dynamic> json) =>
    _AuthUserResponse(
      id: json['id'] as String,
      userName: json['userName'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      language: json['language'] as String,
      mustChangePassword: json['mustChangePassword'] as bool,
    );

Map<String, dynamic> _$AuthUserResponseToJson(_AuthUserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'fullName': instance.fullName,
      'role': instance.role,
      'language': instance.language,
      'mustChangePassword': instance.mustChangePassword,
    };
