// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateOrderRequest _$UpdateOrderRequestFromJson(Map<String, dynamic> json) =>
    _UpdateOrderRequest(
      version: json['version'] as String,
      supplierId: json['supplierId'] as String?,
      expectedDeliveryDate: json['expectedDeliveryDate'] == null
          ? null
          : DateTime.parse(json['expectedDeliveryDate'] as String),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      purchaseOrderNumber: json['purchaseOrderNumber'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$UpdateOrderRequestToJson(_UpdateOrderRequest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'supplierId': instance.supplierId,
      'expectedDeliveryDate': instance.expectedDeliveryDate?.toIso8601String(),
      'unitPrice': instance.unitPrice,
      'purchaseOrderNumber': instance.purchaseOrderNumber,
      'note': instance.note,
    };
