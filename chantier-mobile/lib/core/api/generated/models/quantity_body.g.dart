// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuantityBody _$QuantityBodyFromJson(Map<String, dynamic> json) =>
    _QuantityBody(
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] == null
          ? null
          : MeasureUnit.fromJson(json['unit'] as String),
    );

Map<String, dynamic> _$QuantityBodyToJson(_QuantityBody instance) =>
    <String, dynamic>{'value': instance.value, 'unit': instance.unit};
