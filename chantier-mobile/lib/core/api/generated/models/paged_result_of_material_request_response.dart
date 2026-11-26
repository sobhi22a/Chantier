// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'material_request_response.dart';

part 'paged_result_of_material_request_response.freezed.dart';
part 'paged_result_of_material_request_response.g.dart';

/// Liste paginee par numero de page avec total (back-office seulement).
@Freezed()
abstract class PagedResultOfMaterialRequestResponse
    with _$PagedResultOfMaterialRequestResponse {
  const factory PagedResultOfMaterialRequestResponse({
    required List<MaterialRequestResponse> items,
    required int page,
    required int pageSize,
    required int totalCount,
  }) = _PagedResultOfMaterialRequestResponse;

  factory PagedResultOfMaterialRequestResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PagedResultOfMaterialRequestResponseFromJson(json);
}
