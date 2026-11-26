// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_sync_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliverySyncData _$DeliverySyncDataFromJson(Map<String, dynamic> json) =>
    _DeliverySyncData(
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => History.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String?,
      siteId: json['siteId'] as String?,
      clientId: json['clientId'] as String?,
      clientCreatedAt: json['clientCreatedAt'] == null
          ? null
          : DateTime.parse(json['clientCreatedAt'] as String),
      number: json['number'] as String?,
      requestId: json['requestId'] as String?,
      requestNumber: json['requestNumber'] as String?,
      unattachedReason: json['unattachedReason'] == null
          ? null
          : DeliverySyncDataUnattachedReason.fromJson(
              json['unattachedReason'] as String,
            ),
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      freeSupplierName: json['freeSupplierName'] as String?,
      product: json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] == null
          ? null
          : Quantity.fromJson(json['quantity'] as Map<String, dynamic>),
      quantityInRequestUnit: json['quantityInRequestUnit'] == null
          ? null
          : Quantity.fromJson(
              json['quantityInRequestUnit'] as Map<String, dynamic>,
            ),
      deliveryDate: json['deliveryDate'] == null
          ? null
          : DateTime.parse(json['deliveryDate'] as String),
      deliveryNoteNumber: json['deliveryNoteNumber'] as String?,
      missingNote: json['missingNote'] as bool?,
      conformity: json['conformity'] == null
          ? null
          : DeliverySyncDataConformity.fromJson(json['conformity'] as String),
      reserve: json['reserve'] == null
          ? null
          : Reserve.fromJson(json['reserve'] as Map<String, dynamic>),
      status: json['status'] == null
          ? null
          : DeliverySyncDataStatus.fromJson(json['status'] as String),
      cancelReason: json['cancelReason'] == null
          ? null
          : CancelReason.fromJson(json['cancelReason'] as Map<String, dynamic>),
      possibleDuplicateOf: json['possibleDuplicateOf'] == null
          ? null
          : PossibleDuplicateOf.fromJson(
              json['possibleDuplicateOf'] as Map<String, dynamic>,
            ),
      photoCount: (json['photoCount'] as num?)?.toInt(),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => Photos.fromJson(e as Map<String, dynamic>))
          .toList(),
      commercial: json['commercial'] == null
          ? null
          : Commercial.fromJson(json['commercial'] as Map<String, dynamic>),
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

Map<String, dynamic> _$DeliverySyncDataToJson(_DeliverySyncData instance) =>
    <String, dynamic>{
      'history': instance.history,
      'id': instance.id,
      'siteId': instance.siteId,
      'clientId': instance.clientId,
      'clientCreatedAt': instance.clientCreatedAt?.toIso8601String(),
      'number': instance.number,
      'requestId': instance.requestId,
      'requestNumber': instance.requestNumber,
      'unattachedReason': instance.unattachedReason,
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'freeSupplierName': instance.freeSupplierName,
      'product': instance.product,
      'quantity': instance.quantity,
      'quantityInRequestUnit': instance.quantityInRequestUnit,
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'deliveryNoteNumber': instance.deliveryNoteNumber,
      'missingNote': instance.missingNote,
      'conformity': instance.conformity,
      'reserve': instance.reserve,
      'status': instance.status,
      'cancelReason': instance.cancelReason,
      'possibleDuplicateOf': instance.possibleDuplicateOf,
      'photoCount': instance.photoCount,
      'photos': instance.photos,
      'commercial': instance.commercial,
      'version': instance.version,
      'createdAt': instance.createdAt?.toIso8601String(),
      'createdByName': instance.createdByName,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedByName': instance.updatedByName,
    };
