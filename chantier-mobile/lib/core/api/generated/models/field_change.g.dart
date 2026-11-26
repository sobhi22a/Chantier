// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FieldChange _$FieldChangeFromJson(Map<String, dynamic> json) => _FieldChange(
  field: json['field'] as String,
  old: json['old'] as String?,
  newValue: json['new'] as String?,
);

Map<String, dynamic> _$FieldChangeToJson(_FieldChange instance) =>
    <String, dynamic>{
      'field': instance.field,
      'old': instance.old,
      'new': instance.newValue,
    };
