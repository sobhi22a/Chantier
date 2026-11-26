// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_request_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateRequestRequest _$CreateRequestRequestFromJson(
  Map<String, dynamic> json,
) => _CreateRequestRequest(
  quantity: json['quantity'] == null
      ? null
      : QuantityBody.fromJson(json['quantity'] as Map<String, dynamic>),
  clientId: json['clientId'] as String?,
  clientCreatedAt: json['clientCreatedAt'] == null
      ? null
      : DateTime.parse(json['clientCreatedAt'] as String),
  productId: json['productId'] as String?,
  freeProductName: json['freeProductName'] as String?,
  zoneId: json['zoneId'] as String?,
  neededBy: json['neededBy'] == null
      ? null
      : DateTime.parse(json['neededBy'] as String),
  priority: json['priority'] == null
      ? null
      : Priority.fromJson(json['priority'] as String),
  note: json['note'] as String?,
);

Map<String, dynamic> _$CreateRequestRequestToJson(
  _CreateRequestRequest instance,
) => <String, dynamic>{
  'quantity': instance.quantity,
  'clientId': instance.clientId,
  'clientCreatedAt': instance.clientCreatedAt?.toIso8601String(),
  'productId': instance.productId,
  'freeProductName': instance.freeProductName,
  'zoneId': instance.zoneId,
  'neededBy': instance.neededBy?.toIso8601String(),
  'priority': instance.priority,
  'note': instance.note,
};
