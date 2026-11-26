// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_supplier_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateSupplierRequest _$CreateSupplierRequestFromJson(
  Map<String, dynamic> json,
) => _CreateSupplierRequest(
  name: json['name'] as String,
  phone: json['phone'] as String?,
  productIds: (json['productIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CreateSupplierRequestToJson(
  _CreateSupplierRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone': instance.phone,
  'productIds': instance.productIds,
};
