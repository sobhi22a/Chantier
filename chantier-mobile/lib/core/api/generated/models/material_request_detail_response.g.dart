// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_request_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaterialRequestDetailResponse _$MaterialRequestDetailResponseFromJson(
  Map<String, dynamic> json,
) => _MaterialRequestDetailResponse(
  history: (json['history'] as List<dynamic>?)
      ?.map((e) => RequestHistoryItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveries: (json['deliveries'] as List<dynamic>?)
      ?.map((e) => RequestDeliveryItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  id: json['id'] as String?,
  siteId: json['siteId'] as String?,
  siteCode: json['siteCode'] as String?,
  clientId: json['clientId'] as String?,
  clientCreatedAt: json['clientCreatedAt'] == null
      ? null
      : DateTime.parse(json['clientCreatedAt'] as String),
  number: json['number'] as String?,
  product: json['product'] == null
      ? null
      : ProductRefResponse.fromJson(json['product'] as Map<String, dynamic>),
  quantity: json['quantity'] == null
      ? null
      : Quantity.fromJson(json['quantity'] as Map<String, dynamic>),
  zoneId: json['zoneId'] as String?,
  neededBy: json['neededBy'] == null
      ? null
      : DateTime.parse(json['neededBy'] as String),
  priority: json['priority'] == null
      ? null
      : Priority.fromJson(json['priority'] as String),
  note: json['note'] as String?,
  status: json['status'] == null
      ? null
      : RequestStatus.fromJson(json['status'] as String),
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
  isSettled: json['isSettled'] as bool?,
  overdueDays: (json['overdueDays'] as num?)?.toInt(),
  possibleDuplicateOf: json['possibleDuplicateOf'] == null
      ? null
      : DuplicateRefResponse.fromJson(
          json['possibleDuplicateOf'] as Map<String, dynamic>,
        ),
  order: json['order'] == null
      ? null
      : OrderResponse.fromJson(json['order'] as Map<String, dynamic>),
  hasDeliveryWithoutOrder: json['hasDeliveryWithoutOrder'] as bool?,
  requestedById: json['requestedById'] as String?,
  requestedByName: json['requestedByName'] as String?,
  archivedAt: json['archivedAt'] == null
      ? null
      : DateTime.parse(json['archivedAt'] as String),
  archivedByName: json['archivedByName'] as String?,
  version: json['version'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  createdByName: json['createdByName'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  updatedByName: json['updatedByName'] as String?,
);

Map<String, dynamic> _$MaterialRequestDetailResponseToJson(
  _MaterialRequestDetailResponse instance,
) => <String, dynamic>{
  'history': instance.history,
  'deliveries': instance.deliveries,
  'id': instance.id,
  'siteId': instance.siteId,
  'siteCode': instance.siteCode,
  'clientId': instance.clientId,
  'clientCreatedAt': instance.clientCreatedAt?.toIso8601String(),
  'number': instance.number,
  'product': instance.product,
  'quantity': instance.quantity,
  'zoneId': instance.zoneId,
  'neededBy': instance.neededBy?.toIso8601String(),
  'priority': instance.priority,
  'note': instance.note,
  'status': instance.status,
  'statusReason': instance.statusReason,
  'receivedQuantity': instance.receivedQuantity,
  'remainingQuantity': instance.remainingQuantity,
  'variance': instance.variance,
  'isSettled': instance.isSettled,
  'overdueDays': instance.overdueDays,
  'possibleDuplicateOf': instance.possibleDuplicateOf,
  'order': instance.order,
  'hasDeliveryWithoutOrder': instance.hasDeliveryWithoutOrder,
  'requestedById': instance.requestedById,
  'requestedByName': instance.requestedByName,
  'archivedAt': instance.archivedAt?.toIso8601String(),
  'archivedByName': instance.archivedByName,
  'version': instance.version,
  'createdAt': instance.createdAt?.toIso8601String(),
  'createdByName': instance.createdByName,
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'updatedByName': instance.updatedByName,
};
