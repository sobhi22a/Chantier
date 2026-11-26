// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_ref_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductRefResponse _$ProductRefResponseFromJson(Map<String, dynamic> json) =>
    _ProductRefResponse(
      productId: json['productId'] as String?,
      name: json['name'] as String?,
      nameAr: json['nameAr'] as String?,
      freeName: json['freeName'] as String?,
    );

Map<String, dynamic> _$ProductRefResponseToJson(_ProductRefResponse instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'freeName': instance.freeName,
    };
