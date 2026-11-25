// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      userName: json['userName'] as String,
      password: json['password'] as String,
      isAppMobile: json['isAppMobile'] as bool?,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'password': instance.password,
      'isAppMobile': instance.isAppMobile,
    };
