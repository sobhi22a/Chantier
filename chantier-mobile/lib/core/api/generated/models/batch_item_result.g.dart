// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_item_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BatchItemResult _$BatchItemResultFromJson(Map<String, dynamic> json) =>
    _BatchItemResult(
      requestId: json['requestId'] as String,
      outcome: json['outcome'] as String,
      code: json['code'] as String?,
    );

Map<String, dynamic> _$BatchItemResultToJson(_BatchItemResult instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'outcome': instance.outcome,
      'code': instance.code,
    };
