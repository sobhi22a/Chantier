// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductResponse {

 String get id;/// Nom en français.
 String get nameFr;/// Nom en arabe, s'il existe (sinon le nom français est affiché).
 String? get nameAr; ProductResponseCategory get category;/// Unités autorisées (codes du référentiel : `sac`, `t`, `kg`...), jamais du texte libre.
 List<ProductResponseAllowedUnits> get allowedUnits;/// Unites du referentiel (skill `metier-chantier`), identifiees par leur <b>code stable</b> dans le JSON, la base et les vecteurs de calcul :.
/// `u ml m2 m3 kg t sac l h j pj ft`. Une quantite n'existe jamais sans unite (regle 1).
 ProductResponseDefaultUnit get defaultUnit;/// Masse d'un sac en kg (50 pour le ciment) ; obligatoire si l'unité `sac` est autorisée. Sert aux conversions sac, kg, T.
 double? get bagMassKg;/// Un produit désactivé reste affiché dans l'historique mais ne peut plus être demandé ni livré.
 bool get isActive; DateTime? get deactivatedAt;/// Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.
 String get version; DateTime get createdAt; String? get createdByName; DateTime? get updatedAt; String? get updatedByName;
/// Create a copy of ProductResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductResponseCopyWith<ProductResponse> get copyWith => _$ProductResponseCopyWithImpl<ProductResponse>(this as ProductResponse, _$identity);

  /// Serializes this ProductResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.allowedUnits, allowedUnits)&&(identical(other.defaultUnit, defaultUnit) || other.defaultUnit == defaultUnit)&&(identical(other.bagMassKg, bagMassKg) || other.bagMassKg == bagMassKg)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameFr,nameAr,category,const DeepCollectionEquality().hash(allowedUnits),defaultUnit,bagMassKg,isActive,deactivatedAt,version,createdAt,createdByName,updatedAt,updatedByName);

@override
String toString() {
  return 'ProductResponse(id: $id, nameFr: $nameFr, nameAr: $nameAr, category: $category, allowedUnits: $allowedUnits, defaultUnit: $defaultUnit, bagMassKg: $bagMassKg, isActive: $isActive, deactivatedAt: $deactivatedAt, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class $ProductResponseCopyWith<$Res>  {
  factory $ProductResponseCopyWith(ProductResponse value, $Res Function(ProductResponse) _then) = _$ProductResponseCopyWithImpl;
@useResult
$Res call({
 String id, String nameFr, String? nameAr, ProductResponseCategory category, List<ProductResponseAllowedUnits> allowedUnits, ProductResponseDefaultUnit defaultUnit, double? bagMassKg, bool isActive, DateTime? deactivatedAt, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class _$ProductResponseCopyWithImpl<$Res>
    implements $ProductResponseCopyWith<$Res> {
  _$ProductResponseCopyWithImpl(this._self, this._then);

  final ProductResponse _self;
  final $Res Function(ProductResponse) _then;

/// Create a copy of ProductResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameFr = null,Object? nameAr = freezed,Object? category = null,Object? allowedUnits = null,Object? defaultUnit = null,Object? bagMassKg = freezed,Object? isActive = null,Object? deactivatedAt = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameFr: null == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ProductResponseCategory,allowedUnits: null == allowedUnits ? _self.allowedUnits : allowedUnits // ignore: cast_nullable_to_non_nullable
as List<ProductResponseAllowedUnits>,defaultUnit: null == defaultUnit ? _self.defaultUnit : defaultUnit // ignore: cast_nullable_to_non_nullable
as ProductResponseDefaultUnit,bagMassKg: freezed == bagMassKg ? _self.bagMassKg : bagMassKg // ignore: cast_nullable_to_non_nullable
as double?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,deactivatedAt: freezed == deactivatedAt ? _self.deactivatedAt : deactivatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ProductResponse implements ProductResponse {
  const _ProductResponse({required this.id, required this.nameFr, required this.nameAr, required this.category, required final  List<ProductResponseAllowedUnits> allowedUnits, required this.defaultUnit, required this.bagMassKg, required this.isActive, required this.deactivatedAt, required this.version, required this.createdAt, required this.createdByName, required this.updatedAt, required this.updatedByName}): _allowedUnits = allowedUnits;
  factory _ProductResponse.fromJson(Map<String, dynamic> json) => _$ProductResponseFromJson(json);

@override final  String id;
/// Nom en français.
@override final  String nameFr;
/// Nom en arabe, s'il existe (sinon le nom français est affiché).
@override final  String? nameAr;
@override final  ProductResponseCategory category;
/// Unités autorisées (codes du référentiel : `sac`, `t`, `kg`...), jamais du texte libre.
 final  List<ProductResponseAllowedUnits> _allowedUnits;
/// Unités autorisées (codes du référentiel : `sac`, `t`, `kg`...), jamais du texte libre.
@override List<ProductResponseAllowedUnits> get allowedUnits {
  if (_allowedUnits is EqualUnmodifiableListView) return _allowedUnits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedUnits);
}

/// Unites du referentiel (skill `metier-chantier`), identifiees par leur <b>code stable</b> dans le JSON, la base et les vecteurs de calcul :.
/// `u ml m2 m3 kg t sac l h j pj ft`. Une quantite n'existe jamais sans unite (regle 1).
@override final  ProductResponseDefaultUnit defaultUnit;
/// Masse d'un sac en kg (50 pour le ciment) ; obligatoire si l'unité `sac` est autorisée. Sert aux conversions sac, kg, T.
@override final  double? bagMassKg;
/// Un produit désactivé reste affiché dans l'historique mais ne peut plus être demandé ni livré.
@override final  bool isActive;
@override final  DateTime? deactivatedAt;
/// Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.
@override final  String version;
@override final  DateTime createdAt;
@override final  String? createdByName;
@override final  DateTime? updatedAt;
@override final  String? updatedByName;

/// Create a copy of ProductResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductResponseCopyWith<_ProductResponse> get copyWith => __$ProductResponseCopyWithImpl<_ProductResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._allowedUnits, _allowedUnits)&&(identical(other.defaultUnit, defaultUnit) || other.defaultUnit == defaultUnit)&&(identical(other.bagMassKg, bagMassKg) || other.bagMassKg == bagMassKg)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameFr,nameAr,category,const DeepCollectionEquality().hash(_allowedUnits),defaultUnit,bagMassKg,isActive,deactivatedAt,version,createdAt,createdByName,updatedAt,updatedByName);

@override
String toString() {
  return 'ProductResponse(id: $id, nameFr: $nameFr, nameAr: $nameAr, category: $category, allowedUnits: $allowedUnits, defaultUnit: $defaultUnit, bagMassKg: $bagMassKg, isActive: $isActive, deactivatedAt: $deactivatedAt, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class _$ProductResponseCopyWith<$Res> implements $ProductResponseCopyWith<$Res> {
  factory _$ProductResponseCopyWith(_ProductResponse value, $Res Function(_ProductResponse) _then) = __$ProductResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameFr, String? nameAr, ProductResponseCategory category, List<ProductResponseAllowedUnits> allowedUnits, ProductResponseDefaultUnit defaultUnit, double? bagMassKg, bool isActive, DateTime? deactivatedAt, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class __$ProductResponseCopyWithImpl<$Res>
    implements _$ProductResponseCopyWith<$Res> {
  __$ProductResponseCopyWithImpl(this._self, this._then);

  final _ProductResponse _self;
  final $Res Function(_ProductResponse) _then;

/// Create a copy of ProductResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameFr = null,Object? nameAr = freezed,Object? category = null,Object? allowedUnits = null,Object? defaultUnit = null,Object? bagMassKg = freezed,Object? isActive = null,Object? deactivatedAt = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_ProductResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameFr: null == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ProductResponseCategory,allowedUnits: null == allowedUnits ? _self._allowedUnits : allowedUnits // ignore: cast_nullable_to_non_nullable
as List<ProductResponseAllowedUnits>,defaultUnit: null == defaultUnit ? _self.defaultUnit : defaultUnit // ignore: cast_nullable_to_non_nullable
as ProductResponseDefaultUnit,bagMassKg: freezed == bagMassKg ? _self.bagMassKg : bagMassKg // ignore: cast_nullable_to_non_nullable
as double?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,deactivatedAt: freezed == deactivatedAt ? _self.deactivatedAt : deactivatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
