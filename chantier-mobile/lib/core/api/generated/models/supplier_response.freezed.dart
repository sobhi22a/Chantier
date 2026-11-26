// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SupplierResponse {

 String get id; String get name;/// Produits fournis (liste indicative).
 List<String> get productIds; bool get isActive; DateTime? get deactivatedAt; String get version; DateTime get createdAt; String? get createdByName; DateTime? get updatedAt; String? get updatedByName;/// Téléphone au format algérien (`0550 00 00 21`) ; donnée sensible.
 String? get phone;
/// Create a copy of SupplierResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierResponseCopyWith<SupplierResponse> get copyWith => _$SupplierResponseCopyWithImpl<SupplierResponse>(this as SupplierResponse, _$identity);

  /// Serializes this SupplierResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.productIds, productIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(productIds),isActive,deactivatedAt,version,createdAt,createdByName,updatedAt,updatedByName,phone);

@override
String toString() {
  return 'SupplierResponse(id: $id, name: $name, productIds: $productIds, isActive: $isActive, deactivatedAt: $deactivatedAt, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $SupplierResponseCopyWith<$Res>  {
  factory $SupplierResponseCopyWith(SupplierResponse value, $Res Function(SupplierResponse) _then) = _$SupplierResponseCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> productIds, bool isActive, DateTime? deactivatedAt, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName, String? phone
});



}
/// @nodoc
class _$SupplierResponseCopyWithImpl<$Res>
    implements $SupplierResponseCopyWith<$Res> {
  _$SupplierResponseCopyWithImpl(this._self, this._then);

  final SupplierResponse _self;
  final $Res Function(SupplierResponse) _then;

/// Create a copy of SupplierResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? productIds = null,Object? isActive = null,Object? deactivatedAt = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,Object? phone = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,productIds: null == productIds ? _self.productIds : productIds // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,deactivatedAt: freezed == deactivatedAt ? _self.deactivatedAt : deactivatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SupplierResponse implements SupplierResponse {
  const _SupplierResponse({required this.id, required this.name, required final  List<String> productIds, required this.isActive, required this.deactivatedAt, required this.version, required this.createdAt, required this.createdByName, required this.updatedAt, required this.updatedByName, this.phone}): _productIds = productIds;
  factory _SupplierResponse.fromJson(Map<String, dynamic> json) => _$SupplierResponseFromJson(json);

@override final  String id;
@override final  String name;
/// Produits fournis (liste indicative).
 final  List<String> _productIds;
/// Produits fournis (liste indicative).
@override List<String> get productIds {
  if (_productIds is EqualUnmodifiableListView) return _productIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_productIds);
}

@override final  bool isActive;
@override final  DateTime? deactivatedAt;
@override final  String version;
@override final  DateTime createdAt;
@override final  String? createdByName;
@override final  DateTime? updatedAt;
@override final  String? updatedByName;
/// Téléphone au format algérien (`0550 00 00 21`) ; donnée sensible.
@override final  String? phone;

/// Create a copy of SupplierResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierResponseCopyWith<_SupplierResponse> get copyWith => __$SupplierResponseCopyWithImpl<_SupplierResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupplierResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._productIds, _productIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_productIds),isActive,deactivatedAt,version,createdAt,createdByName,updatedAt,updatedByName,phone);

@override
String toString() {
  return 'SupplierResponse(id: $id, name: $name, productIds: $productIds, isActive: $isActive, deactivatedAt: $deactivatedAt, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$SupplierResponseCopyWith<$Res> implements $SupplierResponseCopyWith<$Res> {
  factory _$SupplierResponseCopyWith(_SupplierResponse value, $Res Function(_SupplierResponse) _then) = __$SupplierResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> productIds, bool isActive, DateTime? deactivatedAt, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName, String? phone
});



}
/// @nodoc
class __$SupplierResponseCopyWithImpl<$Res>
    implements _$SupplierResponseCopyWith<$Res> {
  __$SupplierResponseCopyWithImpl(this._self, this._then);

  final _SupplierResponse _self;
  final $Res Function(_SupplierResponse) _then;

/// Create a copy of SupplierResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? productIds = null,Object? isActive = null,Object? deactivatedAt = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,Object? phone = freezed,}) {
  return _then(_SupplierResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,productIds: null == productIds ? _self._productIds : productIds // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,deactivatedAt: freezed == deactivatedAt ? _self.deactivatedAt : deactivatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
