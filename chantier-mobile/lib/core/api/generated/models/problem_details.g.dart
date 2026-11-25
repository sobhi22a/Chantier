// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProblemDetails _$ProblemDetailsFromJson(Map<String, dynamic> json) =>
    _ProblemDetails(
      type: json['type'] as String,
      title: json['title'] as String,
      status: (json['status'] as num).toInt(),
      code: json['code'] as String,
      traceId: json['traceId'] as String,
      detail: json['detail'] as String?,
      instance: json['instance'] as String?,
      errors: (json['errors'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      current: json['current'],
    );

Map<String, dynamic> _$ProblemDetailsToJson(_ProblemDetails instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'status': instance.status,
      'code': instance.code,
      'traceId': instance.traceId,
      'detail': instance.detail,
      'instance': instance.instance,
      'errors': instance.errors,
      'current': instance.current,
    };
