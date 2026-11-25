// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'site_member_response.dart';

part 'items_response_of_site_member_response.freezed.dart';
part 'items_response_of_site_member_response.g.dart';

/// Liste sans pagination (petite liste bornee, par exemple les personnes affectees a un chantier).
@Freezed()
abstract class ItemsResponseOfSiteMemberResponse
    with _$ItemsResponseOfSiteMemberResponse {
  const factory ItemsResponseOfSiteMemberResponse({
    required List<SiteMemberResponse> items,
  }) = _ItemsResponseOfSiteMemberResponse;

  factory ItemsResponseOfSiteMemberResponse.fromJson(
    Map<String, Object?> json,
  ) => _$ItemsResponseOfSiteMemberResponseFromJson(json);
}
