// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'conformity.dart';
import 'delivery_status.dart';
import 'quantity.dart';

part 'request_delivery_item.freezed.dart';
part 'request_delivery_item.g.dart';

/// Livraison d'une demande, resumee dans son detail : toutes, annulees comprises (une livraison annulee reste visible, barree).
@Freezed()
abstract class RequestDeliveryItem with _$RequestDeliveryItem {
  const factory RequestDeliveryItem({
    required String id,
    required String number,
    required DateTime deliveryDate,
    required Quantity quantity,
    required DeliveryStatus status,
    required String? deliveryNoteNumber,
    required Conformity conformity,
    required int photoCount,

    /// Quantite convertie dans l'unite de la demande ; absente d'une livraison annulee.
    Quantity? quantityInRequestUnit,
  }) = _RequestDeliveryItem;

  factory RequestDeliveryItem.fromJson(Map<String, Object?> json) =>
      _$RequestDeliveryItemFromJson(json);
}
