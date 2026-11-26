// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_photo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryPhotoItem _$DeliveryPhotoItemFromJson(Map<String, dynamic> json) =>
    _DeliveryPhotoItem(
      id: json['id'] as String,
      contentStatus: PhotoContentStatus.fromJson(
        json['contentStatus'] as String,
      ),
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      takenAt: DateTime.parse(json['takenAt'] as String),
    );

Map<String, dynamic> _$DeliveryPhotoItemToJson(_DeliveryPhotoItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentStatus': instance.contentStatus,
      'sizeBytes': instance.sizeBytes,
      'takenAt': instance.takenAt.toIso8601String(),
    };
