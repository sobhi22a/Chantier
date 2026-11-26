// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_ref_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductRefResponse {

 String? get productId; String? get name; String? get nameAr; String? get freeName;
/// Create a copy of ProductRefResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductRefResponseCopyWith<ProductRefResponse> get copyWith => _$ProductRefResponseCopyWithImpl<ProductRefResponse>(this as ProductRefResponse, _$identity);

  /// Serializes this ProductRefResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductRefResponse&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.freeName, freeName) || other.freeName == freeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,nameAr,freeName);

@override
String toString() {
  return 'ProductRefResponse(productId: $productId, name: $name, nameAr: $nameAr, freeName: $freeName)';
}


}

/// @nodoc
abstract mixin class $ProductRefResponseCopyWith<$Res>  {
  factory $ProductRefResponseCopyWith(ProductRefResponse value, $Res Function(ProductRefResponse) _then) = _$ProductRefResponseCopyWithImpl;
@useResult
$Res call({
 String? productId, String? name, String? nameAr, String? freeName
});



}
/// @nodoc
class _$ProductRefResponseCopyWithImpl<$Res>
    implements $ProductRefResponseCopyWith<$Res> {
  _$ProductRefResponseCopyWithImpl(this._self, this._then);

  final ProductRefResponse _self;
  final $Res Function(ProductRefResponse) _then;

/// Create a copy of ProductRefResponse
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

class _ProductRefResponse implements ProductRefResponse {
  const _ProductRefResponse({required this.productId, required this.name, required this.nameAr, required this.freeName});
  factory _ProductRefResponse.fromJson(Map<String, dynamic> json) => _$ProductRefResponseFromJson(json);

@override final  String? productId;
@override final  String? name;
@override final  String? nameAr;
@override final  String? freeName;

/// Create a copy of ProductRefResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductRefResponseCopyWith<_ProductRefResponse> get copyWith => __$ProductRefResponseCopyWithImpl<_ProductRefResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductRefResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductRefResponse&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.freeName, freeName) || other.freeName == freeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,nameAr,freeName);

@override
String toString() {
  return 'ProductRefResponse(productId: $productId, name: $name, nameAr: $nameAr, freeName: $freeName)';
}


}

/// @nodoc
abstract mixin class _$ProductRefResponseCopyWith<$Res> implements $ProductRefResponseCopyWith<$Res> {
  factory _$ProductRefResponseCopyWith(_ProductRefResponse value, $Res Function(_ProductRefResponse) _then) = __$ProductRefResponseCopyWithImpl;
@override @useResult
$Res call({
 String? productId, String? name, String? nameAr, String? freeName
});



}
/// @nodoc
class __$ProductRefResponseCopyWithImpl<$Res>
    implements _$ProductRefResponseCopyWith<$Res> {
  __$ProductRefResponseCopyWithImpl(this._self, this._then);

  final _ProductRefResponse _self;
  final $Res Function(_ProductRefResponse) _then;

/// Create a copy of ProductRefResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? name = freezed,Object? nameAr = freezed,Object? freeName = freezed,}) {
  return _then(_ProductRefResponse(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,freeName: freezed == freeName ? _self.freeName : freeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
