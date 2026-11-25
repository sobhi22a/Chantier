// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'zone_response.dart';

part 'cursor_page_of_zone_response.freezed.dart';
part 'cursor_page_of_zone_response.g.dart';

/// Liste paginee par curseur (listes de terrain) : `nextCursor` absent = derniere page.
@Freezed()
abstract class CursorPageOfZoneResponse with _$CursorPageOfZoneResponse {
  const factory CursorPageOfZoneResponse({
    required List<ZoneResponse> items,
    required String? nextCursor,
  }) = _CursorPageOfZoneResponse;

  factory CursorPageOfZoneResponse.fromJson(Map<String, Object?> json) =>
      _$CursorPageOfZoneResponseFromJson(json);
}
