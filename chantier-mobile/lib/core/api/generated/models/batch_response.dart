// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'batch_item_result.dart';

part 'batch_response.freezed.dart';
part 'batch_response.g.dart';

@Freezed()
abstract class BatchResponse with _$BatchResponse {
  const factory BatchResponse({required List<BatchItemResult> results}) =
      _BatchResponse;

  factory BatchResponse.fromJson(Map<String, Object?> json) =>
      _$BatchResponseFromJson(json);
}
