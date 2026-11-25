// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_result_of_site_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PagedResultOfSiteResponse _$PagedResultOfSiteResponseFromJson(
  Map<String, dynamic> json,
) => _PagedResultOfSiteResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => SiteResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalCount: (json['totalCount'] as num).toInt(),
);

Map<String, dynamic> _$PagedResultOfSiteResponseToJson(
  _PagedResultOfSiteResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
};
