// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_supplier_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateSupplierRequest {

/// Version lue avec le fournisseur ; une version périmée donne 409 `CONFLIT_VERSION`.
 String get version;/// Nom du fournisseur (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus).
 String get name;/// Téléphone au format algérien (05, 06 ou 07 suivi de 8 chiffres, espaces facultatifs).
 String? get phone;/// Produits fournis (identifiants du catalogue), liste indicative.
 List<String>? get productIds;
/// Create a copy of UpdateSupplierRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateSupplierRequestCopyWith<UpdateSupplierRequest> get copyWith => _$UpdateSupplierRequestCopyWithImpl<UpdateSupplierRequest>(this as UpdateSupplierRequest, _$identity);

  /// Serializes this UpdateSupplierRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateSupplierRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other.productIds, productIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,name,phone,const DeepCollectionEquality().hash(productIds));

@override
String toString() {
  return 'UpdateSupplierRequest(version: $version, name: $name, phone: $phone, productIds: $productIds)';
}


}

/// @nodoc
abstract mixin class $UpdateSupplierRequestCopyWith<$Res>  {
  factory $UpdateSupplierRequestCopyWith(UpdateSupplierRequest value, $Res Function(UpdateSupplierRequest) _then) = _$UpdateSupplierRequestCopyWithImpl;
@useResult
$Res call({
 String version, String name, String? phone, List<String>? productIds
});



}
/// @nodoc
class _$UpdateSupplierRequestCopyWithImpl<$Res>
    implements $UpdateSupplierRequestCopyWith<$Res> {
  _$UpdateSupplierRequestCopyWithImpl(this._self, this._then);

  final UpdateSupplierRequest _self;
  final $Res Function(UpdateSupplierRequest) _then;

/// Create a copy of UpdateSupplierRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? name = null,Object? phone = freezed,Object? productIds = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,productIds: freezed == productIds ? _self.productIds : productIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UpdateSupplierRequest implements UpdateSupplierRequest {
  const _UpdateSupplierRequest({required this.version, required this.name, this.phone, final  List<String>? productIds}): _productIds = productIds;
  factory _UpdateSupplierRequest.fromJson(Map<String, dynamic> json) => _$UpdateSupplierRequestFromJson(json);

/// Version lue avec le fournisseur ; une version périmée donne 409 `CONFLIT_VERSION`.
@override final  String version;
/// Nom du fournisseur (obligatoire, unique sans tenir compte de la casse, des accents ni des espaces superflus).
@override final  String name;
/// Téléphone au format algérien (05, 06 ou 07 suivi de 8 chiffres, espaces facultatifs).
@override final  String? phone;
/// Produits fournis (identifiants du catalogue), liste indicative.
 final  List<String>? _productIds;
/// Produits fournis (identifiants du catalogue), liste indicative.
@override List<String>? get productIds {
  final value = _productIds;
  if (value == null) return null;
  if (_productIds is EqualUnmodifiableListView) return _productIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UpdateSupplierRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateSupplierRequestCopyWith<_UpdateSupplierRequest> get copyWith => __$UpdateSupplierRequestCopyWithImpl<_UpdateSupplierRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateSupplierRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateSupplierRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other._productIds, _productIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,name,phone,const DeepCollectionEquality().hash(_productIds));

@override
String toString() {
  return 'UpdateSupplierRequest(version: $version, name: $name, phone: $phone, productIds: $productIds)';
}


}

/// @nodoc
abstract mixin class _$UpdateSupplierRequestCopyWith<$Res> implements $UpdateSupplierRequestCopyWith<$Res> {
  factory _$UpdateSupplierRequestCopyWith(_UpdateSupplierRequest value, $Res Function(_UpdateSupplierRequest) _then) = __$UpdateSupplierRequestCopyWithImpl;
@override @useResult
$Res call({
 String version, String name, String? phone, List<String>? productIds
});



}
/// @nodoc
class __$UpdateSupplierRequestCopyWithImpl<$Res>
    implements _$UpdateSupplierRequestCopyWith<$Res> {
  __$UpdateSupplierRequestCopyWithImpl(this._self, this._then);

  final _UpdateSupplierRequest _self;
  final $Res Function(_UpdateSupplierRequest) _then;

/// Create a copy of UpdateSupplierRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? name = null,Object? phone = freezed,Object? productIds = freezed,}) {
  return _then(_UpdateSupplierRequest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,productIds: freezed == productIds ? _self._productIds : productIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
