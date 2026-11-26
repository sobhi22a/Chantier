// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_product_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateProductRequest {

/// Nom en français (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus).
 String get nameFr;/// Catégorie du catalogue.
 ProductCategory? get category;/// Unités autorisées (au moins une), parmi le référentiel : jamais de texte libre.
 List<MeasureUnit> get allowedUnits;/// Unité proposée par défaut ; doit faire partie des unités autorisées (422 `UNITE_NON_AUTORISEE` sinon).
 MeasureUnit? get defaultUnit;/// Nom en arabe (facultatif : le nom français est affiché à défaut).
 String? get nameAr;/// Masse d'un sac en kg ; obligatoire si l'unité `sac` est autorisée (422 `MASSE_SAC_OBLIGATOIRE`).
 double? get bagMassKg;
/// Create a copy of CreateProductRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateProductRequestCopyWith<CreateProductRequest> get copyWith => _$CreateProductRequestCopyWithImpl<CreateProductRequest>(this as CreateProductRequest, _$identity);

  /// Serializes this CreateProductRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateProductRequest&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.allowedUnits, allowedUnits)&&(identical(other.defaultUnit, defaultUnit) || other.defaultUnit == defaultUnit)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.bagMassKg, bagMassKg) || other.bagMassKg == bagMassKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameFr,category,const DeepCollectionEquality().hash(allowedUnits),defaultUnit,nameAr,bagMassKg);

@override
String toString() {
  return 'CreateProductRequest(nameFr: $nameFr, category: $category, allowedUnits: $allowedUnits, defaultUnit: $defaultUnit, nameAr: $nameAr, bagMassKg: $bagMassKg)';
}


}

/// @nodoc
abstract mixin class $CreateProductRequestCopyWith<$Res>  {
  factory $CreateProductRequestCopyWith(CreateProductRequest value, $Res Function(CreateProductRequest) _then) = _$CreateProductRequestCopyWithImpl;
@useResult
$Res call({
 String nameFr, ProductCategory? category, List<MeasureUnit> allowedUnits, MeasureUnit? defaultUnit, String? nameAr, double? bagMassKg
});



}
/// @nodoc
class _$CreateProductRequestCopyWithImpl<$Res>
    implements $CreateProductRequestCopyWith<$Res> {
  _$CreateProductRequestCopyWithImpl(this._self, this._then);

  final CreateProductRequest _self;
  final $Res Function(CreateProductRequest) _then;

/// Create a copy of CreateProductRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nameFr = null,Object? category = freezed,Object? allowedUnits = null,Object? defaultUnit = freezed,Object? nameAr = freezed,Object? bagMassKg = freezed,}) {
  return _then(_self.copyWith(
nameFr: null == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ProductCategory?,allowedUnits: null == allowedUnits ? _self.allowedUnits : allowedUnits // ignore: cast_nullable_to_non_nullable
as List<MeasureUnit>,defaultUnit: freezed == defaultUnit ? _self.defaultUnit : defaultUnit // ignore: cast_nullable_to_non_nullable
as MeasureUnit?,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,bagMassKg: freezed == bagMassKg ? _self.bagMassKg : bagMassKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CreateProductRequest implements CreateProductRequest {
  const _CreateProductRequest({required this.nameFr, required this.category, required final  List<MeasureUnit> allowedUnits, required this.defaultUnit, this.nameAr, this.bagMassKg}): _allowedUnits = allowedUnits;
  factory _CreateProductRequest.fromJson(Map<String, dynamic> json) => _$CreateProductRequestFromJson(json);

/// Nom en français (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus).
@override final  String nameFr;
/// Catégorie du catalogue.
@override final  ProductCategory? category;
/// Unités autorisées (au moins une), parmi le référentiel : jamais de texte libre.
 final  List<MeasureUnit> _allowedUnits;
/// Unités autorisées (au moins une), parmi le référentiel : jamais de texte libre.
@override List<MeasureUnit> get allowedUnits {
  if (_allowedUnits is EqualUnmodifiableListView) return _allowedUnits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedUnits);
}

/// Unité proposée par défaut ; doit faire partie des unités autorisées (422 `UNITE_NON_AUTORISEE` sinon).
@override final  MeasureUnit? defaultUnit;
/// Nom en arabe (facultatif : le nom français est affiché à défaut).
@override final  String? nameAr;
/// Masse d'un sac en kg ; obligatoire si l'unité `sac` est autorisée (422 `MASSE_SAC_OBLIGATOIRE`).
@override final  double? bagMassKg;

/// Create a copy of CreateProductRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateProductRequestCopyWith<_CreateProductRequest> get copyWith => __$CreateProductRequestCopyWithImpl<_CreateProductRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateProductRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateProductRequest&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._allowedUnits, _allowedUnits)&&(identical(other.defaultUnit, defaultUnit) || other.defaultUnit == defaultUnit)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.bagMassKg, bagMassKg) || other.bagMassKg == bagMassKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameFr,category,const DeepCollectionEquality().hash(_allowedUnits),defaultUnit,nameAr,bagMassKg);

@override
String toString() {
  return 'CreateProductRequest(nameFr: $nameFr, category: $category, allowedUnits: $allowedUnits, defaultUnit: $defaultUnit, nameAr: $nameAr, bagMassKg: $bagMassKg)';
}


}

/// @nodoc
abstract mixin class _$CreateProductRequestCopyWith<$Res> implements $CreateProductRequestCopyWith<$Res> {
  factory _$CreateProductRequestCopyWith(_CreateProductRequest value, $Res Function(_CreateProductRequest) _then) = __$CreateProductRequestCopyWithImpl;
@override @useResult
$Res call({
 String nameFr, ProductCategory? category, List<MeasureUnit> allowedUnits, MeasureUnit? defaultUnit, String? nameAr, double? bagMassKg
});



}
/// @nodoc
class __$CreateProductRequestCopyWithImpl<$Res>
    implements _$CreateProductRequestCopyWith<$Res> {
  __$CreateProductRequestCopyWithImpl(this._self, this._then);

  final _CreateProductRequest _self;
  final $Res Function(_CreateProductRequest) _then;

/// Create a copy of CreateProductRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nameFr = null,Object? category = freezed,Object? allowedUnits = null,Object? defaultUnit = freezed,Object? nameAr = freezed,Object? bagMassKg = freezed,}) {
  return _then(_CreateProductRequest(
nameFr: null == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ProductCategory?,allowedUnits: null == allowedUnits ? _self._allowedUnits : allowedUnits // ignore: cast_nullable_to_non_nullable
as List<MeasureUnit>,defaultUnit: freezed == defaultUnit ? _self.defaultUnit : defaultUnit // ignore: cast_nullable_to_non_nullable
as MeasureUnit?,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,bagMassKg: freezed == bagMassKg ? _self.bagMassKg : bagMassKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
