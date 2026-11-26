// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  productId: json['productId'] as String?,
  name: json['name'] as String?,
  nameAr: json['nameAr'] as String?,
  freeName: json['freeName'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'productId': instance.productId,
  'name': instance.name,
  'nameAr': instance.nameAr,
  'freeName': instance.freeName,
};
