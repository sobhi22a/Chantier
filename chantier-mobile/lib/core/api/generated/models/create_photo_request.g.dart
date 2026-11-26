// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_photo_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatePhotoRequest _$CreatePhotoRequestFromJson(Map<String, dynamic> json) =>
    _CreatePhotoRequest(
      clientId: json['clientId'] as String?,
      clientCreatedAt: json['clientCreatedAt'] == null
          ? null
          : DateTime.parse(json['clientCreatedAt'] as String),
      takenAt: json['takenAt'] == null
          ? null
          : DateTime.parse(json['takenAt'] as String),
      contentType: json['contentType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      sha256: json['sha256'] as String?,
    );

Map<String, dynamic> _$CreatePhotoRequestToJson(_CreatePhotoRequest instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'clientCreatedAt': instance.clientCreatedAt?.toIso8601String(),
      'takenAt': instance.takenAt?.toIso8601String(),
      'contentType': instance.contentType,
      'sizeBytes': instance.sizeBytes,
      'sha256': instance.sha256,
    };
