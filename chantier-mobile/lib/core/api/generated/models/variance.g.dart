// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Variance _$VarianceFromJson(Map<String, dynamic> json) => _Variance(
  value: (json['value'] as num).toDouble(),
  unit: Unit.fromJson(json['unit'] as String),
  percent: (json['percent'] as num).toDouble(),
);

Map<String, dynamic> _$VarianceToJson(_Variance instance) => <String, dynamic>{
  'value': instance.value,
  'unit': instance.unit,
  'percent': instance.percent,
};
