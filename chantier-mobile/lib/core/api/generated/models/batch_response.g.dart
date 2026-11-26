// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BatchResponse _$BatchResponseFromJson(Map<String, dynamic> json) =>
    _BatchResponse(
      results: (json['results'] as List<dynamic>)
          .map((e) => BatchItemResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BatchResponseToJson(_BatchResponse instance) =>
    <String, dynamic>{'results': instance.results};
