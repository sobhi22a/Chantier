// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_up_commercial_response.freezed.dart';
part 'follow_up_commercial_response.g.dart';

/// Montants du chantier en DZD hors taxes : commandes non annulees et valeur recue (somme des montants arrondis des livraisons). Absent sans `Prices.View`.
@Freezed()
abstract class FollowUpCommercialResponse with _$FollowUpCommercialResponse {
  const factory FollowUpCommercialResponse({
    required double orderedAmount,
    required double receivedValue,
  }) = _FollowUpCommercialResponse;

  factory FollowUpCommercialResponse.fromJson(Map<String, Object?> json) =>
      _$FollowUpCommercialResponseFromJson(json);
}
