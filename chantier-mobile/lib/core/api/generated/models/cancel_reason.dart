// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'cancel_reason.freezed.dart';
part 'cancel_reason.g.dart';

@Freezed()
abstract class CancelReason with _$CancelReason {
  const factory CancelReason({required String code, required String? note}) =
      _CancelReason;

  factory CancelReason.fromJson(Map<String, Object?> json) =>
      _$CancelReasonFromJson(json);
}
