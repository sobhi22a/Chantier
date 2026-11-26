// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateOrderRequest _$CreateOrderRequestFromJson(Map<String, dynamic> json) =>
    _CreateOrderRequest(
      supplierId: json['supplierId'] as String,
      clientId: json['clientId'] as String?,
      orderDate: json['orderDate'] == null
          ? null
          : DateTime.parse(json['orderDate'] as String),
      expectedDeliveryDate: json['expectedDeliveryDate'] == null
          ? null
          : DateTime.parse(json['expectedDeliveryDate'] as String),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      purchaseOrderNumber: json['purchaseOrderNumber'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CreateOrderRequestToJson(_CreateOrderRequest instance) =>
    <String, dynamic>{
      'supplierId': instance.supplierId,
      'clientId': instance.clientId,
      'orderDate': instance.orderDate?.toIso8601String(),
      'expectedDeliveryDate': instance.expectedDeliveryDate?.toIso8601String(),
      'unitPrice': instance.unitPrice,
      'purchaseOrderNumber': instance.purchaseOrderNumber,
      'note': instance.note,
    };
