// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'to_order_total_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ToOrderTotalLine _$ToOrderTotalLineFromJson(Map<String, dynamic> json) =>
    _ToOrderTotalLine(
      productId: json['productId'] as String?,
      name: json['name'] as String,
      total: Quantity.fromJson(json['total'] as Map<String, dynamic>),
      requestCount: (json['requestCount'] as num).toInt(),
      massEquivalent: json['massEquivalent'] == null
          ? null
          : Quantity.fromJson(json['massEquivalent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ToOrderTotalLineToJson(_ToOrderTotalLine instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'total': instance.total,
      'requestCount': instance.requestCount,
      'massEquivalent': instance.massEquivalent,
    };
