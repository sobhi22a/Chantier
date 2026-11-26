// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commercial2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Commercial2 _$Commercial2FromJson(Map<String, dynamic> json) => _Commercial2(
  unitPrice: (json['unitPrice'] as num?)?.toDouble(),
  amount: (json['amount'] as num?)?.toDouble(),
  receivedValue: (json['receivedValue'] as num?)?.toDouble(),
  purchaseOrderNumber: json['purchaseOrderNumber'] as String?,
);

Map<String, dynamic> _$Commercial2ToJson(_Commercial2 instance) =>
    <String, dynamic>{
      'unitPrice': instance.unitPrice,
      'amount': instance.amount,
      'receivedValue': instance.receivedValue,
      'purchaseOrderNumber': instance.purchaseOrderNumber,
    };
