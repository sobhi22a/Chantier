// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_result_of_supplier_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PagedResultOfSupplierResponse _$PagedResultOfSupplierResponseFromJson(
  Map<String, dynamic> json,
) => _PagedResultOfSupplierResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => SupplierResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalCount: (json['totalCount'] as num).toInt(),
);

Map<String, dynamic> _$PagedResultOfSupplierResponseToJson(
  _PagedResultOfSupplierResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
};
