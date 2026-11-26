// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_result_of_delivery_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PagedResultOfDeliveryResponse _$PagedResultOfDeliveryResponseFromJson(
  Map<String, dynamic> json,
) => _PagedResultOfDeliveryResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => DeliveryResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalCount: (json['totalCount'] as num).toInt(),
);

Map<String, dynamic> _$PagedResultOfDeliveryResponseToJson(
  _PagedResultOfDeliveryResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
};
