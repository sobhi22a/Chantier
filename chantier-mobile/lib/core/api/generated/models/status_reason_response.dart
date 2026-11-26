// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_reason_response.freezed.dart';
part 'status_reason_response.g.dart';

/// Motif d'un refus ou d'une annulation.
@Freezed()
abstract class StatusReasonResponse with _$StatusReasonResponse {
  const factory StatusReasonResponse({
    required String code,
    required String? note,
  }) = _StatusReasonResponse;

  factory StatusReasonResponse.fromJson(Map<String, Object?> json) =>
      _$StatusReasonResponseFromJson(json);
}
