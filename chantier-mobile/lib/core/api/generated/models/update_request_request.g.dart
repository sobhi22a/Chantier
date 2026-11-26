// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_request_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateRequestRequest _$UpdateRequestRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateRequestRequest(
  version: json['version'] as String,
  productId: json['productId'] as String?,
  freeProductName: json['freeProductName'] as String?,
  quantity: json['quantity'] == null
      ? null
      : QuantityBody.fromJson(json['quantity'] as Map<String, dynamic>),
  zoneId: json['zoneId'] as String?,
  neededBy: json['neededBy'] == null
      ? null
      : DateTime.parse(json['neededBy'] as String),
  priority: json['priority'] == null
      ? null
      : Priority.fromJson(json['priority'] as String),
  note: json['note'] as String?,
);

Map<String, dynamic> _$UpdateRequestRequestToJson(
  _UpdateRequestRequest instance,
) => <String, dynamic>{
  'version': instance.version,
  'productId': instance.productId,
  'freeProductName': instance.freeProductName,
  'quantity': instance.quantity,
  'zoneId': instance.zoneId,
  'neededBy': instance.neededBy?.toIso8601String(),
  'priority': instance.priority,
  'note': instance.note,
};
