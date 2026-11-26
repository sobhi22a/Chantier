// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Photos _$PhotosFromJson(Map<String, dynamic> json) => _Photos(
  id: json['id'] as String,
  contentStatus: ContentStatus.fromJson(json['contentStatus'] as String),
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  takenAt: DateTime.parse(json['takenAt'] as String),
);

Map<String, dynamic> _$PhotosToJson(_Photos instance) => <String, dynamic>{
  'id': instance.id,
  'contentStatus': instance.contentStatus,
  'sizeBytes': instance.sizeBytes,
  'takenAt': instance.takenAt.toIso8601String(),
};
