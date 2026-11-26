// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_delivery_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RequestDeliveryItem _$RequestDeliveryItemFromJson(Map<String, dynamic> json) =>
    _RequestDeliveryItem(
      id: json['id'] as String,
      number: json['number'] as String,
      deliveryDate: DateTime.parse(json['deliveryDate'] as String),
      quantity: Quantity.fromJson(json['quantity'] as Map<String, dynamic>),
      status: DeliveryStatus.fromJson(json['status'] as String),
      deliveryNoteNumber: json['deliveryNoteNumber'] as String?,
      conformity: Conformity.fromJson(json['conformity'] as String),
      photoCount: (json['photoCount'] as num).toInt(),
      quantityInRequestUnit: json['quantityInRequestUnit'] == null
          ? null
          : Quantity.fromJson(
              json['quantityInRequestUnit'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$RequestDeliveryItemToJson(
  _RequestDeliveryItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'deliveryDate': instance.deliveryDate.toIso8601String(),
  'quantity': instance.quantity,
  'status': instance.status,
  'deliveryNoteNumber': instance.deliveryNoteNumber,
  'conformity': instance.conformity,
  'photoCount': instance.photoCount,
  'quantityInRequestUnit': instance.quantityInRequestUnit,
};
