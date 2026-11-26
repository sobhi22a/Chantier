// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_commercial_response.freezed.dart';
part 'delivery_commercial_response.g.dart';

/// Montant d'une livraison : prix de la commande x quantite convertie, arrondi au centime (DZD). Absent sans `Prices.View`.
@Freezed()
abstract class DeliveryCommercialResponse with _$DeliveryCommercialResponse {
  const factory DeliveryCommercialResponse({required double amount}) =
      _DeliveryCommercialResponse;

  factory DeliveryCommercialResponse.fromJson(Map<String, Object?> json) =>
      _$DeliveryCommercialResponseFromJson(json);
}
