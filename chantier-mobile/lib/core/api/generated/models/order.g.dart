// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
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
      : Commercial2.fromJson(json['commercial'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
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
