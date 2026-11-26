// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_delivery_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateDeliveryRequest _$UpdateDeliveryRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateDeliveryRequest(
  version: json['version'] as String,
  quantity: json['quantity'] == null
      ? null
      : QuantityBody.fromJson(json['quantity'] as Map<String, dynamic>),
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

Map<String, dynamic> _$UpdateDeliveryRequestToJson(
  _UpdateDeliveryRequest instance,
) => <String, dynamic>{
  'version': instance.version,
  'quantity': instance.quantity,
  'deliveryDate': instance.deliveryDate?.toIso8601String(),
  'deliveryNoteNumber': instance.deliveryNoteNumber,
  'conformity': instance.conformity,
  'reserveReasonCode': instance.reserveReasonCode,
  'reserveNote': instance.reserveNote,
};
