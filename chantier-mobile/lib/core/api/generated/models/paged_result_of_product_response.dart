// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_response.dart';

part 'paged_result_of_product_response.freezed.dart';
part 'paged_result_of_product_response.g.dart';

/// Liste paginee par numero de page avec total (back-office seulement).
@Freezed()
abstract class PagedResultOfProductResponse
    with _$PagedResultOfProductResponse {
  const factory PagedResultOfProductResponse({
    required List<ProductResponse> items,
    required int page,
    required int pageSize,
    required int totalCount,
  }) = _PagedResultOfProductResponse;

  factory PagedResultOfProductResponse.fromJson(Map<String, Object?> json) =>
      _$PagedResultOfProductResponseFromJson(json);
}
