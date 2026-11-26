// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'batch_item_result.freezed.dart';
part 'batch_item_result.g.dart';

/// Issue d'une demande d'un lot : `applied`, `duplicate` (deja dans l'etat vise) ou `rejected` (avec `code`).
@Freezed()
abstract class BatchItemResult with _$BatchItemResult {
  const factory BatchItemResult({
    required String requestId,
    required String outcome,
    String? code,
  }) = _BatchItemResult;

  factory BatchItemResult.fromJson(Map<String, Object?> json) =>
      _$BatchItemResultFromJson(json);
}
