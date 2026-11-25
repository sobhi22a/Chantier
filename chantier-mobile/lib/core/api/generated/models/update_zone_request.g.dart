// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_zone_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateZoneRequest _$UpdateZoneRequestFromJson(Map<String, dynamic> json) =>
    _UpdateZoneRequest(
      version: json['version'] as String,
      block: json['block'] as String,
      elevation: (json['elevation'] as num?)?.toDouble(),
      roomType: json['roomType'] == null
          ? null
          : RoomType.fromJson(json['roomType'] as String),
      roomNumber: (json['roomNumber'] as num?)?.toInt(),
      roomLabel: json['roomLabel'] as String?,
    );

Map<String, dynamic> _$UpdateZoneRequestToJson(_UpdateZoneRequest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'block': instance.block,
      'elevation': instance.elevation,
      'roomType': instance.roomType,
      'roomNumber': instance.roomNumber,
      'roomLabel': instance.roomLabel,
    };
