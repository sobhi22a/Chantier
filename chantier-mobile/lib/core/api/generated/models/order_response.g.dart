// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    _OrderResponse(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      orderDate: DateTime.parse(json['orderDate'] as String),
      expectedDeliveryDate: json['expectedDeliveryDate'] == null
          ? null
          : DateTime.parse(json['expectedDeliveryDate'] as String),
      plannedAfterNeedDays: (json['plannedAfterNeedDays'] as num).toInt(),
      note: json['note'] as String?,
      version: json['version'] as String,
      commercial: json['commercial'] == null
          ? null
          : OrderCommercialResponse.fromJson(
              json['commercial'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$OrderResponseToJson(_OrderResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'orderDate': instance.orderDate.toIso8601String(),
      'expectedDeliveryDate': instance.expectedDeliveryDate?.toIso8601String(),
      'plannedAfterNeedDays': instance.plannedAfterNeedDays,
      'note': instance.note,
      'version': instance.version,
      'commercial': instance.commercial,
    };
