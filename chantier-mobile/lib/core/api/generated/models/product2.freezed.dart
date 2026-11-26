// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product2 {

 String? get productId; String? get name; String? get nameAr; String? get freeName;
/// Create a copy of Product2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Product2CopyWith<Product2> get copyWith => _$Product2CopyWithImpl<Product2>(this as Product2, _$identity);

  /// Serializes this Product2 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product2&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.freeName, freeName) || other.freeName == freeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,nameAr,freeName);

@override
String toString() {
  return 'Product2(productId: $productId, name: $name, nameAr: $nameAr, freeName: $freeName)';
}


}

/// @nodoc
abstract mixin class $Product2CopyWith<$Res>  {
  factory $Product2CopyWith(Product2 value, $Res Function(Product2) _then) = _$Product2CopyWithImpl;
@useResult
$Res call({
 String? productId, String? name, String? nameAr, String? freeName
});



}
/// @nodoc
class _$Product2CopyWithImpl<$Res>
    implements $Product2CopyWith<$Res> {
  _$Product2CopyWithImpl(this._self, this._then);

  final Product2 _self;
  final $Res Function(Product2) _then;

/// Create a copy of Product2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? name = freezed,Object? nameAr = freezed,Object? freeName = freezed,}) {
  return _then(_self.copyWith(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,freeName: freezed == freeName ? _self.freeName : freeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Product2 implements Product2 {
  const _Product2({required this.productId, required this.name, required this.nameAr, required this.freeName});
  factory _Product2.fromJson(Map<String, dynamic> json) => _$Product2FromJson(json);

@override final  String? productId;
@override final  String? name;
@override final  String? nameAr;
@override final  String? freeName;

/// Create a copy of Product2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$Product2CopyWith<_Product2> get copyWith => __$Product2CopyWithImpl<_Product2>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$Product2ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product2&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.freeName, freeName) || other.freeName == freeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,nameAr,freeName);

@override
String toString() {
  return 'Product2(productId: $productId, name: $name, nameAr: $nameAr, freeName: $freeName)';
}


}

/// @nodoc
abstract mixin class _$Product2CopyWith<$Res> implements $Product2CopyWith<$Res> {
  factory _$Product2CopyWith(_Product2 value, $Res Function(_Product2) _then) = __$Product2CopyWithImpl;
@override @useResult
$Res call({
 String? productId, String? name, String? nameAr, String? freeName
});



}
/// @nodoc
class __$Product2CopyWithImpl<$Res>
    implements _$Product2CopyWith<$Res> {
  __$Product2CopyWithImpl(this._self, this._then);

  final _Product2 _self;
  final $Res Function(_Product2) _then;

/// Create a copy of Product2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? name = freezed,Object? nameAr = freezed,Object? freeName = freezed,}) {
  return _then(_Product2(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,freeName: freezed == freeName ? _self.freeName : freeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
