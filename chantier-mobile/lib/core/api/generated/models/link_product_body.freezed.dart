// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_product_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinkProductBody {

 String get productId;
/// Create a copy of LinkProductBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkProductBodyCopyWith<LinkProductBody> get copyWith => _$LinkProductBodyCopyWithImpl<LinkProductBody>(this as LinkProductBody, _$identity);

  /// Serializes this LinkProductBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkProductBody&&(identical(other.productId, productId) || other.productId == productId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId);

@override
String toString() {
  return 'LinkProductBody(productId: $productId)';
}


}

/// @nodoc
abstract mixin class $LinkProductBodyCopyWith<$Res>  {
  factory $LinkProductBodyCopyWith(LinkProductBody value, $Res Function(LinkProductBody) _then) = _$LinkProductBodyCopyWithImpl;
@useResult
$Res call({
 String productId
});



}
/// @nodoc
class _$LinkProductBodyCopyWithImpl<$Res>
    implements $LinkProductBodyCopyWith<$Res> {
  _$LinkProductBodyCopyWithImpl(this._self, this._then);

  final LinkProductBody _self;
  final $Res Function(LinkProductBody) _then;

/// Create a copy of LinkProductBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _LinkProductBody implements LinkProductBody {
  const _LinkProductBody({required this.productId});
  factory _LinkProductBody.fromJson(Map<String, dynamic> json) => _$LinkProductBodyFromJson(json);

@override final  String productId;

/// Create a copy of LinkProductBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkProductBodyCopyWith<_LinkProductBody> get copyWith => __$LinkProductBodyCopyWithImpl<_LinkProductBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkProductBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkProductBody&&(identical(other.productId, productId) || other.productId == productId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId);

@override
String toString() {
  return 'LinkProductBody(productId: $productId)';
}


}

/// @nodoc
abstract mixin class _$LinkProductBodyCopyWith<$Res> implements $LinkProductBodyCopyWith<$Res> {
  factory _$LinkProductBodyCopyWith(_LinkProductBody value, $Res Function(_LinkProductBody) _then) = __$LinkProductBodyCopyWithImpl;
@override @useResult
$Res call({
 String productId
});



}
/// @nodoc
class __$LinkProductBodyCopyWithImpl<$Res>
    implements _$LinkProductBodyCopyWith<$Res> {
  __$LinkProductBodyCopyWithImpl(this._self, this._then);

  final _LinkProductBody _self;
  final $Res Function(_LinkProductBody) _then;

/// Create a copy of LinkProductBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,}) {
  return _then(_LinkProductBody(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
