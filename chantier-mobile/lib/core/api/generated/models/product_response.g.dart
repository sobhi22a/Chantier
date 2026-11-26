// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductResponse _$ProductResponseFromJson(Map<String, dynamic> json) =>
    _ProductResponse(
      id: json['id'] as String,
      nameFr: json['nameFr'] as String,
      nameAr: json['nameAr'] as String?,
      category: ProductResponseCategory.fromJson(json['category'] as String),
      allowedUnits: (json['allowedUnits'] as List<dynamic>)
          .map((e) => ProductResponseAllowedUnits.fromJson(e as String))
          .toList(),
      defaultUnit: ProductResponseDefaultUnit.fromJson(
        json['defaultUnit'] as String,
      ),
      bagMassKg: (json['bagMassKg'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool,
      deactivatedAt: json['deactivatedAt'] == null
          ? null
          : DateTime.parse(json['deactivatedAt'] as String),
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdByName: json['createdByName'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedByName: json['updatedByName'] as String?,
    );

Map<String, dynamic> _$ProductResponseToJson(_ProductResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameFr': instance.nameFr,
      'nameAr': instance.nameAr,
      'category': instance.category,
      'allowedUnits': instance.allowedUnits,
      'defaultUnit': instance.defaultUnit,
      'bagMassKg': instance.bagMassKg,
      'isActive': instance.isActive,
      'deactivatedAt': instance.deactivatedAt?.toIso8601String(),
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdByName': instance.createdByName,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedByName': instance.updatedByName,
    };
