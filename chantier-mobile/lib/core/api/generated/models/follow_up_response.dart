// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'follow_up_commercial_response.dart';
import 'follow_up_counters.dart';
import 'to_order_total_line.dart';

part 'follow_up_response.freezed.dart';
part 'follow_up_response.g.dart';

@Freezed()
abstract class FollowUpResponse with _$FollowUpResponse {
  const factory FollowUpResponse({
    required FollowUpCounters counters,
    required List<ToOrderTotalLine> toOrderTotals,
    FollowUpCommercialResponse? commercial,
  }) = _FollowUpResponse;

  factory FollowUpResponse.fromJson(Map<String, Object?> json) =>
      _$FollowUpResponseFromJson(json);
}
