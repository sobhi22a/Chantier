// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

/// Type d'evenement de l'historique. `OrderCommercialEdited` est sensible : rendu seulement avec `Prices.View`, jamais synchronise.
@JsonEnum()
enum MaterialEventType {
  @JsonValue('Created')
  created('Created'),
  @JsonValue('Edited')
  edited('Edited'),
  @JsonValue('Approved')
  approved('Approved'),
  @JsonValue('QuantityAdjusted')
  quantityAdjusted('QuantityAdjusted'),
  @JsonValue('Rejected')
  rejected('Rejected'),
  @JsonValue('Cancelled')
  cancelled('Cancelled'),
  @JsonValue('Ordered')
  ordered('Ordered'),
  @JsonValue('OrderEdited')
  orderEdited('OrderEdited'),
  @JsonValue('OrderCommercialEdited')
  orderCommercialEdited('OrderCommercialEdited'),
  @JsonValue('OrderCancelled')
  orderCancelled('OrderCancelled'),
  @JsonValue('DeliveryRegistered')
  deliveryRegistered('DeliveryRegistered'),
  @JsonValue('DeliveryEdited')
  deliveryEdited('DeliveryEdited'),
  @JsonValue('DeliveryCancelled')
  deliveryCancelled('DeliveryCancelled'),
  @JsonValue('DeliveryAttached')
  deliveryAttached('DeliveryAttached'),
  @JsonValue('StatusRecomputed')
  statusRecomputed('StatusRecomputed'),
  @JsonValue('Settled')
  settled('Settled'),
  @JsonValue('Received')
  received('Received'),
  @JsonValue('Archived')
  archived('Archived'),
  @JsonValue('Restored')
  restored('Restored'),
  @JsonValue('ProductLinked')
  productLinked('ProductLinked'),
  @JsonValue('PhotoAdded')
  photoAdded('PhotoAdded'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const MaterialEventType(this.json);

  factory MaterialEventType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError(
        'Cannot convert enum value with null JSON representation to String. '
        'This usually happens for \$unknown or @JsonValue(null) entries.',
      );
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<MaterialEventType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
