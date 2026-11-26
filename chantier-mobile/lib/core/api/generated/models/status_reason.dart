// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_reason.freezed.dart';
part 'status_reason.g.dart';

@Freezed()
abstract class StatusReason with _$StatusReason {
  const factory StatusReason({required String code, required String? note}) =
      _StatusReason;

  factory StatusReason.fromJson(Map<String, Object?> json) =>
      _$StatusReasonFromJson(json);
}
