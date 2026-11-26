// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryResponse _$DeliveryResponseFromJson(Map<String, dynamic> json) =>
    _DeliveryResponse(
      id: json['id'] as String,
      siteId: json['siteId'] as String,
      number: json['number'] as String,
      product: ProductRefResponse.fromJson(
        json['product'] as Map<String, dynamic>,
      ),
      quantity: Quantity.fromJson(json['quantity'] as Map<String, dynamic>),
      deliveryDate: DateTime.parse(json['deliveryDate'] as String),
      conformity: Conformity.fromJson(json['conformity'] as String),
      status: DeliveryStatus.fromJson(json['status'] as String),
      photoCount: (json['photoCount'] as num).toInt(),
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      clientId: json['clientId'] as String?,
      clientCreatedAt: json['clientCreatedAt'] == null
          ? null
          : DateTime.parse(json['clientCreatedAt'] as String),
      requestId: json['requestId'] as String?,
      requestNumber: json['requestNumber'] as String?,
      unattachedReason: json['unattachedReason'] == null
          ? null
          : UnattachedReason.fromJson(json['unattachedReason'] as String),
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      freeSupplierName: json['freeSupplierName'] as String?,
      quantityInRequestUnit: json['quantityInRequestUnit'] == null
          ? null
          : Quantity.fromJson(
              json['quantityInRequestUnit'] as Map<String, dynamic>,
            ),
      deliveryNoteNumber: json['deliveryNoteNumber'] as String?,
      missingNote: json['missingNote'] as bool?,
      reserve: json['reserve'] == null
          ? null
          : ReserveResponse.fromJson(json['reserve'] as Map<String, dynamic>),
      cancelReason: json['cancelReason'] == null
          ? null
          : StatusReasonResponse.fromJson(
              json['cancelReason'] as Map<String, dynamic>,
            ),
      possibleDuplicateOf: json['possibleDuplicateOf'] == null
          ? null
          : DuplicateRefResponse.fromJson(
              json['possibleDuplicateOf'] as Map<String, dynamic>,
            ),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => DeliveryPhotoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      commercial: json['commercial'] == null
          ? null
          : DeliveryCommercialResponse.fromJson(
              json['commercial'] as Map<String, dynamic>,
            ),
      createdByName: json['createdByName'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedByName: json['updatedByName'] as String?,
    );

Map<String, dynamic> _$DeliveryResponseToJson(_DeliveryResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'number': instance.number,
      'product': instance.product,
      'quantity': instance.quantity,
      'deliveryDate': instance.deliveryDate.toIso8601String(),
      'conformity': instance.conformity,
      'status': instance.status,
      'photoCount': instance.photoCount,
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'clientId': instance.clientId,
      'clientCreatedAt': instance.clientCreatedAt?.toIso8601String(),
      'requestId': instance.requestId,
      'requestNumber': instance.requestNumber,
      'unattachedReason': instance.unattachedReason,
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'freeSupplierName': instance.freeSupplierName,
      'quantityInRequestUnit': instance.quantityInRequestUnit,
      'deliveryNoteNumber': instance.deliveryNoteNumber,
      'missingNote': instance.missingNote,
      'reserve': instance.reserve,
      'cancelReason': instance.cancelReason,
      'possibleDuplicateOf': instance.possibleDuplicateOf,
      'photos': instance.photos,
      'commercial': instance.commercial,
      'createdByName': instance.createdByName,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedByName': instance.updatedByName,
    };
