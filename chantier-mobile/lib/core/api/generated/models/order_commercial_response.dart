// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_commercial_response.freezed.dart';
part 'order_commercial_response.g.dart';

/// Donnees commerciales d'une commande : prix unitaire HT (par unite de commande), montant (quantite x prix, arrondi au centime), valeur recue (somme des montants.
/// arrondis des livraisons) et n° de bon de commande, en DZD. <b>Absent sans `Prices.View`</b> et de toute synchronisation (ADR 0012).
@Freezed()
abstract class OrderCommercialResponse with _$OrderCommercialResponse {
  const factory OrderCommercialResponse({
    required double? unitPrice,
    required double? amount,
    required double? receivedValue,
    required String? purchaseOrderNumber,
  }) = _OrderCommercialResponse;

  factory OrderCommercialResponse.fromJson(Map<String, Object?> json) =>
      _$OrderCommercialResponseFromJson(json);
}
