// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cursor_page_of_zone_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CursorPageOfZoneResponse _$CursorPageOfZoneResponseFromJson(
  Map<String, dynamic> json,
) => _CursorPageOfZoneResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => ZoneResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$CursorPageOfZoneResponseToJson(
  _CursorPageOfZoneResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'nextCursor': instance.nextCursor,
};
