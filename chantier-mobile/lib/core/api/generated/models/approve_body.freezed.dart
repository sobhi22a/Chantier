// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'approve_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApproveBody {

/// Quantité validée si elle diffère de la demande (ancienne et nouvelle valeurs sont tracées dans l'historique).
 QuantityBody? get quantity;
/// Create a copy of ApproveBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApproveBodyCopyWith<ApproveBody> get copyWith => _$ApproveBodyCopyWithImpl<ApproveBody>(this as ApproveBody, _$identity);

  /// Serializes this ApproveBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApproveBody&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quantity);

@override
String toString() {
  return 'ApproveBody(quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $ApproveBodyCopyWith<$Res>  {
  factory $ApproveBodyCopyWith(ApproveBody value, $Res Function(ApproveBody) _then) = _$ApproveBodyCopyWithImpl;
@useResult
$Res call({
 QuantityBody? quantity
});



}
/// @nodoc
class _$ApproveBodyCopyWithImpl<$Res>
    implements $ApproveBodyCopyWith<$Res> {
  _$ApproveBodyCopyWithImpl(this._self, this._then);

  final ApproveBody _self;
  final $Res Function(ApproveBody) _then;

/// Create a copy of ApproveBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quantity = freezed,}) {
  return _then(_self.copyWith(
quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ApproveBody implements ApproveBody {
  const _ApproveBody({this.quantity});
  factory _ApproveBody.fromJson(Map<String, dynamic> json) => _$ApproveBodyFromJson(json);

/// Quantité validée si elle diffère de la demande (ancienne et nouvelle valeurs sont tracées dans l'historique).
@override final  QuantityBody? quantity;

/// Create a copy of ApproveBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApproveBodyCopyWith<_ApproveBody> get copyWith => __$ApproveBodyCopyWithImpl<_ApproveBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApproveBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApproveBody&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quantity);

@override
String toString() {
  return 'ApproveBody(quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$ApproveBodyCopyWith<$Res> implements $ApproveBodyCopyWith<$Res> {
  factory _$ApproveBodyCopyWith(_ApproveBody value, $Res Function(_ApproveBody) _then) = __$ApproveBodyCopyWithImpl;
@override @useResult
$Res call({
 QuantityBody? quantity
});



}
/// @nodoc
class __$ApproveBodyCopyWithImpl<$Res>
    implements _$ApproveBodyCopyWith<$Res> {
  __$ApproveBodyCopyWithImpl(this._self, this._then);

  final _ApproveBody _self;
  final $Res Function(_ApproveBody) _then;

/// Create a copy of ApproveBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quantity = freezed,}) {
  return _then(_ApproveBody(
quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,
  ));
}


}

// dart format on
