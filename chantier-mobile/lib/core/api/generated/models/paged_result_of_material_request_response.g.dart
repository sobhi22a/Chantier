// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_result_of_material_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PagedResultOfMaterialRequestResponse
_$PagedResultOfMaterialRequestResponseFromJson(Map<String, dynamic> json) =>
    _PagedResultOfMaterialRequestResponse(
      items: (json['items'] as List<dynamic>)
          .map(
            (e) => MaterialRequestResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$PagedResultOfMaterialRequestResponseToJson(
  _PagedResultOfMaterialRequestResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
};
