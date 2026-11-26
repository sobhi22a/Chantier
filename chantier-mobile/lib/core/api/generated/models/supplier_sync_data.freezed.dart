// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_sync_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SupplierSyncData {

 String get id; String get name; List<String> get productIds; bool get isActive; DateTime? get deactivatedAt; String get version; DateTime get createdAt; String? get createdByName; DateTime? get updatedAt; String? get updatedByName;
/// Create a copy of SupplierSyncData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierSyncDataCopyWith<SupplierSyncData> get copyWith => _$SupplierSyncDataCopyWithImpl<SupplierSyncData>(this as SupplierSyncData, _$identity);

  /// Serializes this SupplierSyncData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierSyncData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.productIds, productIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(productIds),isActive,deactivatedAt,version,createdAt,createdByName,updatedAt,updatedByName);

@override
String toString() {
  return 'SupplierSyncData(id: $id, name: $name, productIds: $productIds, isActive: $isActive, deactivatedAt: $deactivatedAt, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class $SupplierSyncDataCopyWith<$Res>  {
  factory $SupplierSyncDataCopyWith(SupplierSyncData value, $Res Function(SupplierSyncData) _then) = _$SupplierSyncDataCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> productIds, bool isActive, DateTime? deactivatedAt, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class _$SupplierSyncDataCopyWithImpl<$Res>
    implements $SupplierSyncDataCopyWith<$Res> {
  _$SupplierSyncDataCopyWithImpl(this._self, this._then);

  final SupplierSyncData _self;
  final $Res Function(SupplierSyncData) _then;

/// Create a copy of SupplierSyncData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? productIds = null,Object? isActive = null,Object? deactivatedAt = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
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
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SupplierSyncData implements SupplierSyncData {
  const _SupplierSyncData({required this.id, required this.name, required final  List<String> productIds, required this.isActive, required this.deactivatedAt, required this.version, required this.createdAt, required this.createdByName, required this.updatedAt, required this.updatedByName}): _productIds = productIds;
  factory _SupplierSyncData.fromJson(Map<String, dynamic> json) => _$SupplierSyncDataFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _productIds;
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

/// Create a copy of SupplierSyncData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierSyncDataCopyWith<_SupplierSyncData> get copyWith => __$SupplierSyncDataCopyWithImpl<_SupplierSyncData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupplierSyncDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierSyncData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._productIds, _productIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_productIds),isActive,deactivatedAt,version,createdAt,createdByName,updatedAt,updatedByName);

@override
String toString() {
  return 'SupplierSyncData(id: $id, name: $name, productIds: $productIds, isActive: $isActive, deactivatedAt: $deactivatedAt, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class _$SupplierSyncDataCopyWith<$Res> implements $SupplierSyncDataCopyWith<$Res> {
  factory _$SupplierSyncDataCopyWith(_SupplierSyncData value, $Res Function(_SupplierSyncData) _then) = __$SupplierSyncDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> productIds, bool isActive, DateTime? deactivatedAt, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class __$SupplierSyncDataCopyWithImpl<$Res>
    implements _$SupplierSyncDataCopyWith<$Res> {
  __$SupplierSyncDataCopyWithImpl(this._self, this._then);

  final _SupplierSyncData _self;
  final $Res Function(_SupplierSyncData) _then;

/// Create a copy of SupplierSyncData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? productIds = null,Object? isActive = null,Object? deactivatedAt = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_SupplierSyncData(
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
as String?,
  ));
}


}

// dart format on
