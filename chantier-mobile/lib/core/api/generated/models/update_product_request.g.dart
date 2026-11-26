// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_product_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateProductRequest _$UpdateProductRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateProductRequest(
  version: json['version'] as String,
  nameFr: json['nameFr'] as String,
  category: json['category'] == null
      ? null
      : ProductCategory.fromJson(json['category'] as String),
  allowedUnits: (json['allowedUnits'] as List<dynamic>)
      .map((e) => MeasureUnit.fromJson(e as String))
      .toList(),
  defaultUnit: json['defaultUnit'] == null
      ? null
      : MeasureUnit.fromJson(json['defaultUnit'] as String),
  nameAr: json['nameAr'] as String?,
  bagMassKg: (json['bagMassKg'] as num?)?.toDouble(),
);

Map<String, dynamic> _$UpdateProductRequestToJson(
  _UpdateProductRequest instance,
) => <String, dynamic>{
  'version': instance.version,
  'nameFr': instance.nameFr,
  'category': instance.category,
  'allowedUnits': instance.allowedUnits,
  'defaultUnit': instance.defaultUnit,
  'nameAr': instance.nameAr,
  'bagMassKg': instance.bagMassKg,
};
