// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'supplier_response.dart';

part 'paged_result_of_supplier_response.freezed.dart';
part 'paged_result_of_supplier_response.g.dart';

/// Liste paginee par numero de page avec total (back-office seulement).
@Freezed()
abstract class PagedResultOfSupplierResponse
    with _$PagedResultOfSupplierResponse {
  const factory PagedResultOfSupplierResponse({
    required List<SupplierResponse> items,
    required int page,
    required int pageSize,
    required int totalCount,
  }) = _PagedResultOfSupplierResponse;

  factory PagedResultOfSupplierResponse.fromJson(Map<String, Object?> json) =>
      _$PagedResultOfSupplierResponseFromJson(json);
}
