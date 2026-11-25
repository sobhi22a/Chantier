// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ZoneResponse _$ZoneResponseFromJson(Map<String, dynamic> json) =>
    _ZoneResponse(
      id: json['id'] as String,
      siteId: json['siteId'] as String,
      clientId: json['clientId'] as String?,
      clientCreatedAt: json['clientCreatedAt'] == null
          ? null
          : DateTime.parse(json['clientCreatedAt'] as String),
      block: json['block'] as String,
      elevation: (json['elevation'] as num?)?.toDouble(),
      roomType: json['roomType'] == null
          ? null
          : RoomType.fromJson(json['roomType'] as String),
      roomNumber: (json['roomNumber'] as num?)?.toInt(),
      roomLabel: json['roomLabel'] as String?,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      archivedByName: json['archivedByName'] as String?,
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdByName: json['createdByName'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedByName: json['updatedByName'] as String?,
    );

Map<String, dynamic> _$ZoneResponseToJson(_ZoneResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'clientId': instance.clientId,
      'clientCreatedAt': instance.clientCreatedAt?.toIso8601String(),
      'block': instance.block,
      'elevation': instance.elevation,
      'roomType': instance.roomType,
      'roomNumber': instance.roomNumber,
      'roomLabel': instance.roomLabel,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'archivedByName': instance.archivedByName,
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdByName': instance.createdByName,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedByName': instance.updatedByName,
    };
