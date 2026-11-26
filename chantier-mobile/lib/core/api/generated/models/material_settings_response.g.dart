// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_settings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaterialSettingsResponse _$MaterialSettingsResponseFromJson(
  Map<String, dynamic> json,
) => _MaterialSettingsResponse(
  defaultNeededByDays: (json['defaultNeededByDays'] as num).toInt(),
  deliveryTolerancePercent: (json['deliveryTolerancePercent'] as num)
      .toDouble(),
  maxPhotosPerDelivery: (json['maxPhotosPerDelivery'] as num).toInt(),
  maxPhotoBytes: (json['maxPhotoBytes'] as num).toInt(),
  noteMaxLength: (json['noteMaxLength'] as num).toInt(),
  reasons: MaterialReasonsResponse.fromJson(
    json['reasons'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$MaterialSettingsResponseToJson(
  _MaterialSettingsResponse instance,
) => <String, dynamic>{
  'defaultNeededByDays': instance.defaultNeededByDays,
  'deliveryTolerancePercent': instance.deliveryTolerancePercent,
  'maxPhotosPerDelivery': instance.maxPhotosPerDelivery,
  'maxPhotoBytes': instance.maxPhotoBytes,
  'noteMaxLength': instance.noteMaxLength,
  'reasons': instance.reasons,
};
