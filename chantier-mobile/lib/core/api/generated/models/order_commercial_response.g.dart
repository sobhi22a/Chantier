// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_commercial_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderCommercialResponse _$OrderCommercialResponseFromJson(
  Map<String, dynamic> json,
) => _OrderCommercialResponse(
  unitPrice: (json['unitPrice'] as num?)?.toDouble(),
  amount: (json['amount'] as num?)?.toDouble(),
  receivedValue: (json['receivedValue'] as num?)?.toDouble(),
  purchaseOrderNumber: json['purchaseOrderNumber'] as String?,
);

Map<String, dynamic> _$OrderCommercialResponseToJson(
  _OrderCommercialResponse instance,
) => <String, dynamic>{
  'unitPrice': instance.unitPrice,
  'amount': instance.amount,
  'receivedValue': instance.receivedValue,
  'purchaseOrderNumber': instance.purchaseOrderNumber,
};
