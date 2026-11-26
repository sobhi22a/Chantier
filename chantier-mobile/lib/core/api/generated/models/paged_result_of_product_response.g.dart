// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_result_of_product_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PagedResultOfProductResponse _$PagedResultOfProductResponseFromJson(
  Map<String, dynamic> json,
) => _PagedResultOfProductResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => ProductResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalCount: (json['totalCount'] as num).toInt(),
);

Map<String, dynamic> _$PagedResultOfProductResponseToJson(
  _PagedResultOfProductResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
};
