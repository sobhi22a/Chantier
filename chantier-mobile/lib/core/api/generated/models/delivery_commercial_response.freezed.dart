// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_commercial_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryCommercialResponse {

 double get amount;
/// Create a copy of DeliveryCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryCommercialResponseCopyWith<DeliveryCommercialResponse> get copyWith => _$DeliveryCommercialResponseCopyWithImpl<DeliveryCommercialResponse>(this as DeliveryCommercialResponse, _$identity);

  /// Serializes this DeliveryCommercialResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryCommercialResponse&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount);

@override
String toString() {
  return 'DeliveryCommercialResponse(amount: $amount)';
}


}

/// @nodoc
abstract mixin class $DeliveryCommercialResponseCopyWith<$Res>  {
  factory $DeliveryCommercialResponseCopyWith(DeliveryCommercialResponse value, $Res Function(DeliveryCommercialResponse) _then) = _$DeliveryCommercialResponseCopyWithImpl;
@useResult
$Res call({
 double amount
});



}
/// @nodoc
class _$DeliveryCommercialResponseCopyWithImpl<$Res>
    implements $DeliveryCommercialResponseCopyWith<$Res> {
  _$DeliveryCommercialResponseCopyWithImpl(this._self, this._then);

  final DeliveryCommercialResponse _self;
  final $Res Function(DeliveryCommercialResponse) _then;

/// Create a copy of DeliveryCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _DeliveryCommercialResponse implements DeliveryCommercialResponse {
  const _DeliveryCommercialResponse({required this.amount});
  factory _DeliveryCommercialResponse.fromJson(Map<String, dynamic> json) => _$DeliveryCommercialResponseFromJson(json);

@override final  double amount;

/// Create a copy of DeliveryCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryCommercialResponseCopyWith<_DeliveryCommercialResponse> get copyWith => __$DeliveryCommercialResponseCopyWithImpl<_DeliveryCommercialResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryCommercialResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryCommercialResponse&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount);

@override
String toString() {
  return 'DeliveryCommercialResponse(amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$DeliveryCommercialResponseCopyWith<$Res> implements $DeliveryCommercialResponseCopyWith<$Res> {
  factory _$DeliveryCommercialResponseCopyWith(_DeliveryCommercialResponse value, $Res Function(_DeliveryCommercialResponse) _then) = __$DeliveryCommercialResponseCopyWithImpl;
@override @useResult
$Res call({
 double amount
});



}
/// @nodoc
class __$DeliveryCommercialResponseCopyWithImpl<$Res>
    implements _$DeliveryCommercialResponseCopyWith<$Res> {
  __$DeliveryCommercialResponseCopyWithImpl(this._self, this._then);

  final _DeliveryCommercialResponse _self;
  final $Res Function(_DeliveryCommercialResponse) _then;

/// Create a copy of DeliveryCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,}) {
  return _then(_DeliveryCommercialResponse(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
