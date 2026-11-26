// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_ids_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RequestIdsBody _$RequestIdsBodyFromJson(Map<String, dynamic> json) =>
    _RequestIdsBody(
      requestIds: (json['requestIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RequestIdsBodyToJson(_RequestIdsBody instance) =>
    <String, dynamic>{'requestIds': instance.requestIds};
