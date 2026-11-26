// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_supplier_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateSupplierRequest _$UpdateSupplierRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateSupplierRequest(
  version: json['version'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  productIds: (json['productIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UpdateSupplierRequestToJson(
  _UpdateSupplierRequest instance,
) => <String, dynamic>{
  'version': instance.version,
  'name': instance.name,
  'phone': instance.phone,
  'productIds': instance.productIds,
};
