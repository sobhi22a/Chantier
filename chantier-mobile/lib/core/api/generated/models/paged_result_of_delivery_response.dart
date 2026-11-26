// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'delivery_response.dart';

part 'paged_result_of_delivery_response.freezed.dart';
part 'paged_result_of_delivery_response.g.dart';

/// Liste paginee par numero de page avec total (back-office seulement).
@Freezed()
abstract class PagedResultOfDeliveryResponse
    with _$PagedResultOfDeliveryResponse {
  const factory PagedResultOfDeliveryResponse({
    required List<DeliveryResponse> items,
    required int page,
    required int pageSize,
    required int totalCount,
  }) = _PagedResultOfDeliveryResponse;

  factory PagedResultOfDeliveryResponse.fromJson(Map<String, Object?> json) =>
      _$PagedResultOfDeliveryResponseFromJson(json);
}
