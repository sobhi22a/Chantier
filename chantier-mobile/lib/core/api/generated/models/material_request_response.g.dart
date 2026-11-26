// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaterialRequestResponse _$MaterialRequestResponseFromJson(
  Map<String, dynamic> json,
) => _MaterialRequestResponse(
  id: json['id'] as String,
  siteId: json['siteId'] as String,
  number: json['number'] as String,
  product: ProductRefResponse.fromJson(json['product'] as Map<String, dynamic>),
  quantity: Quantity.fromJson(json['quantity'] as Map<String, dynamic>),
  neededBy: DateTime.parse(json['neededBy'] as String),
  priority: Priority.fromJson(json['priority'] as String),
  status: RequestStatus.fromJson(json['status'] as String),
  isSettled: json['isSettled'] as bool,
  overdueDays: (json['overdueDays'] as num).toInt(),
  requestedById: json['requestedById'] as String,
  version: json['version'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  siteCode: json['siteCode'] as String?,
  clientId: json['clientId'] as String?,
  clientCreatedAt: json['clientCreatedAt'] == null
      ? null
      : DateTime.parse(json['clientCreatedAt'] as String),
  zoneId: json['zoneId'] as String?,
  note: json['note'] as String?,
  statusReason: json['statusReason'] == null
      ? null
      : StatusReasonResponse.fromJson(
          json['statusReason'] as Map<String, dynamic>,
        ),
  receivedQuantity: json['receivedQuantity'] == null
      ? null
      : Quantity.fromJson(json['receivedQuantity'] as Map<String, dynamic>),
  remainingQuantity: json['remainingQuantity'] == null
      ? null
      : Quantity.fromJson(json['remainingQuantity'] as Map<String, dynamic>),
  variance: json['variance'] == null
      ? null
      : VarianceResponse.fromJson(json['variance'] as Map<String, dynamic>),
  possibleDuplicateOf: json['possibleDuplicateOf'] == null
      ? null
      : DuplicateRefResponse.fromJson(
          json['possibleDuplicateOf'] as Map<String, dynamic>,
        ),
  order: json['order'] == null
      ? null
      : OrderResponse.fromJson(json['order'] as Map<String, dynamic>),
  hasDeliveryWithoutOrder: json['hasDeliveryWithoutOrder'] as bool?,
  requestedByName: json['requestedByName'] as String?,
  archivedAt: json['archivedAt'] == null
      ? null
      : DateTime.parse(json['archivedAt'] as String),
  archivedByName: json['archivedByName'] as String?,
  createdByName: json['createdByName'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  updatedByName: json['updatedByName'] as String?,
);

Map<String, dynamic> _$MaterialRequestResponseToJson(
  _MaterialRequestResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'siteId': instance.siteId,
  'number': instance.number,
  'product': instance.product,
  'quantity': instance.quantity,
  'neededBy': instance.neededBy.toIso8601String(),
  'priority': instance.priority,
  'status': instance.status,
  'isSettled': instance.isSettled,
  'overdueDays': instance.overdueDays,
  'requestedById': instance.requestedById,
  'version': instance.version,
  'createdAt': instance.createdAt.toIso8601String(),
  'siteCode': instance.siteCode,
  'clientId': instance.clientId,
  'clientCreatedAt': instance.clientCreatedAt?.toIso8601String(),
  'zoneId': instance.zoneId,
  'note': instance.note,
  'statusReason': instance.statusReason,
  'receivedQuantity': instance.receivedQuantity,
  'remainingQuantity': instance.remainingQuantity,
  'variance': instance.variance,
  'possibleDuplicateOf': instance.possibleDuplicateOf,
  'order': instance.order,
  'hasDeliveryWithoutOrder': instance.hasDeliveryWithoutOrder,
  'requestedByName': instance.requestedByName,
  'archivedAt': instance.archivedAt?.toIso8601String(),
  'archivedByName': instance.archivedByName,
  'createdByName': instance.createdByName,
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'updatedByName': instance.updatedByName,
};
