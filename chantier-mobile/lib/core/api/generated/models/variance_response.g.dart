// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variance_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VarianceResponse _$VarianceResponseFromJson(Map<String, dynamic> json) =>
    _VarianceResponse(
      value: (json['value'] as num).toDouble(),
      unit: MeasureUnit.fromJson(json['unit'] as String),
      percent: (json['percent'] as num).toDouble(),
    );

Map<String, dynamic> _$VarianceResponseToJson(_VarianceResponse instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unit': instance.unit,
      'percent': instance.percent,
    };
