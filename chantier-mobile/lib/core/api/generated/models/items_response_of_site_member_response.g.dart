// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_response_of_site_member_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemsResponseOfSiteMemberResponse _$ItemsResponseOfSiteMemberResponseFromJson(
  Map<String, dynamic> json,
) => _ItemsResponseOfSiteMemberResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => SiteMemberResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ItemsResponseOfSiteMemberResponseToJson(
  _ItemsResponseOfSiteMemberResponse instance,
) => <String, dynamic>{'items': instance.items};
