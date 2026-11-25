// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'site_response.dart';

part 'paged_result_of_site_response.freezed.dart';
part 'paged_result_of_site_response.g.dart';

/// Liste paginee par numero de page avec total (back-office seulement).
@Freezed()
abstract class PagedResultOfSiteResponse with _$PagedResultOfSiteResponse {
  const factory PagedResultOfSiteResponse({
    required List<SiteResponse> items,
    required int page,
    required int pageSize,
    required int totalCount,
  }) = _PagedResultOfSiteResponse;

  factory PagedResultOfSiteResponse.fromJson(Map<String, Object?> json) =>
      _$PagedResultOfSiteResponseFromJson(json);
}
