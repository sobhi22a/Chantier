// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Quantity _$QuantityFromJson(Map<String, dynamic> json) => _Quantity(
  value: (json['value'] as num).toDouble(),
  unit: MeasureUnit.fromJson(json['unit'] as String),
);

Map<String, dynamic> _$QuantityToJson(_Quantity instance) => <String, dynamic>{
  'value': instance.value,
  'unit': instance.unit,
};
