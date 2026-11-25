// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_zone_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateZoneRequest _$CreateZoneRequestFromJson(Map<String, dynamic> json) =>
    _CreateZoneRequest(
      block: json['block'] as String,
      clientId: json['clientId'] as String?,
      clientCreatedAt: json['clientCreatedAt'] == null
          ? null
          : DateTime.parse(json['clientCreatedAt'] as String),
      elevation: (json['elevation'] as num?)?.toDouble(),
      roomType: json['roomType'] == null
          ? null
          : RoomType.fromJson(json['roomType'] as String),
      roomNumber: (json['roomNumber'] as num?)?.toInt(),
      roomLabel: json['roomLabel'] as String?,
    );

Map<String, dynamic> _$CreateZoneRequestToJson(_CreateZoneRequest instance) =>
    <String, dynamic>{
      'block': instance.block,
      'clientId': instance.clientId,
      'clientCreatedAt': instance.clientCreatedAt?.toIso8601String(),
      'elevation': instance.elevation,
      'roomType': instance.roomType,
      'roomNumber': instance.roomNumber,
      'roomLabel': instance.roomLabel,
    };
