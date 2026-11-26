// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhotoResponse _$PhotoResponseFromJson(Map<String, dynamic> json) =>
    _PhotoResponse(
      id: json['id'] as String,
      siteId: json['siteId'] as String,
      deliveryId: json['deliveryId'] as String,
      clientId: json['clientId'] as String?,
      takenAt: DateTime.parse(json['takenAt'] as String),
      contentType: json['contentType'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      contentStatus: PhotoResponseContentStatus.fromJson(
        json['contentStatus'] as String,
      ),
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PhotoResponseToJson(_PhotoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'deliveryId': instance.deliveryId,
      'clientId': instance.clientId,
      'takenAt': instance.takenAt.toIso8601String(),
      'contentType': instance.contentType,
      'sizeBytes': instance.sizeBytes,
      'contentStatus': instance.contentStatus,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
    };
