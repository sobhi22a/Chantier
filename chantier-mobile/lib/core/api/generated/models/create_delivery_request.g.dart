// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_delivery_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateDeliveryRequest _$CreateDeliveryRequestFromJson(
  Map<String, dynamic> json,
) => _CreateDeliveryRequest(
  quantity: json['quantity'] == null
      ? null
      : QuantityBody.fromJson(json['quantity'] as Map<String, dynamic>),
  clientId: json['clientId'] as String?,
  clientCreatedAt: json['clientCreatedAt'] == null
      ? null
      : DateTime.parse(json['clientCreatedAt'] as String),
  requestId: json['requestId'] as String?,
  supplierId: json['supplierId'] as String?,
  freeSupplierName: json['freeSupplierName'] as String?,
  productId: json['productId'] as String?,
  freeProductName: json['freeProductName'] as String?,
  deliveryDate: json['deliveryDate'] == null
      ? null
      : DateTime.parse(json['deliveryDate'] as String),
  deliveryNoteNumber: json['deliveryNoteNumber'] as String?,
  conformity: json['conformity'] == null
      ? null
      : Conformity.fromJson(json['conformity'] as String),
  reserveReasonCode: json['reserveReasonCode'] as String?,
  reserveNote: json['reserveNote'] as String?,
);

Map<String, dynamic> _$CreateDeliveryRequestToJson(
  _CreateDeliveryRequest instance,
) => <String, dynamic>{
  'quantity': instance.quantity,
  'clientId': instance.clientId,
  'clientCreatedAt': instance.clientCreatedAt?.toIso8601String(),
  'requestId': instance.requestId,
  'supplierId': instance.supplierId,
  'freeSupplierName': instance.freeSupplierName,
  'productId': instance.productId,
  'freeProductName': instance.freeProductName,
  'deliveryDate': instance.deliveryDate?.toIso8601String(),
  'deliveryNoteNumber': instance.deliveryNoteNumber,
  'conformity': instance.conformity,
  'reserveReasonCode': instance.reserveReasonCode,
  'reserveNote': instance.reserveNote,
};
