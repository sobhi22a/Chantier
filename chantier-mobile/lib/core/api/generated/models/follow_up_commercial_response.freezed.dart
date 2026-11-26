// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_up_commercial_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowUpCommercialResponse {

 double get orderedAmount; double get receivedValue;
/// Create a copy of FollowUpCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowUpCommercialResponseCopyWith<FollowUpCommercialResponse> get copyWith => _$FollowUpCommercialResponseCopyWithImpl<FollowUpCommercialResponse>(this as FollowUpCommercialResponse, _$identity);

  /// Serializes this FollowUpCommercialResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowUpCommercialResponse&&(identical(other.orderedAmount, orderedAmount) || other.orderedAmount == orderedAmount)&&(identical(other.receivedValue, receivedValue) || other.receivedValue == receivedValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderedAmount,receivedValue);

@override
String toString() {
  return 'FollowUpCommercialResponse(orderedAmount: $orderedAmount, receivedValue: $receivedValue)';
}


}

/// @nodoc
abstract mixin class $FollowUpCommercialResponseCopyWith<$Res>  {
  factory $FollowUpCommercialResponseCopyWith(FollowUpCommercialResponse value, $Res Function(FollowUpCommercialResponse) _then) = _$FollowUpCommercialResponseCopyWithImpl;
@useResult
$Res call({
 double orderedAmount, double receivedValue
});



}
/// @nodoc
class _$FollowUpCommercialResponseCopyWithImpl<$Res>
    implements $FollowUpCommercialResponseCopyWith<$Res> {
  _$FollowUpCommercialResponseCopyWithImpl(this._self, this._then);

  final FollowUpCommercialResponse _self;
  final $Res Function(FollowUpCommercialResponse) _then;

/// Create a copy of FollowUpCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderedAmount = null,Object? receivedValue = null,}) {
  return _then(_self.copyWith(
orderedAmount: null == orderedAmount ? _self.orderedAmount : orderedAmount // ignore: cast_nullable_to_non_nullable
as double,receivedValue: null == receivedValue ? _self.receivedValue : receivedValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _FollowUpCommercialResponse implements FollowUpCommercialResponse {
  const _FollowUpCommercialResponse({required this.orderedAmount, required this.receivedValue});
  factory _FollowUpCommercialResponse.fromJson(Map<String, dynamic> json) => _$FollowUpCommercialResponseFromJson(json);

@override final  double orderedAmount;
@override final  double receivedValue;

/// Create a copy of FollowUpCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowUpCommercialResponseCopyWith<_FollowUpCommercialResponse> get copyWith => __$FollowUpCommercialResponseCopyWithImpl<_FollowUpCommercialResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowUpCommercialResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowUpCommercialResponse&&(identical(other.orderedAmount, orderedAmount) || other.orderedAmount == orderedAmount)&&(identical(other.receivedValue, receivedValue) || other.receivedValue == receivedValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderedAmount,receivedValue);

@override
String toString() {
  return 'FollowUpCommercialResponse(orderedAmount: $orderedAmount, receivedValue: $receivedValue)';
}


}

/// @nodoc
abstract mixin class _$FollowUpCommercialResponseCopyWith<$Res> implements $FollowUpCommercialResponseCopyWith<$Res> {
  factory _$FollowUpCommercialResponseCopyWith(_FollowUpCommercialResponse value, $Res Function(_FollowUpCommercialResponse) _then) = __$FollowUpCommercialResponseCopyWithImpl;
@override @useResult
$Res call({
 double orderedAmount, double receivedValue
});



}
/// @nodoc
class __$FollowUpCommercialResponseCopyWithImpl<$Res>
    implements _$FollowUpCommercialResponseCopyWith<$Res> {
  __$FollowUpCommercialResponseCopyWithImpl(this._self, this._then);

  final _FollowUpCommercialResponse _self;
  final $Res Function(_FollowUpCommercialResponse) _then;

/// Create a copy of FollowUpCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderedAmount = null,Object? receivedValue = null,}) {
  return _then(_FollowUpCommercialResponse(
orderedAmount: null == orderedAmount ? _self.orderedAmount : orderedAmount // ignore: cast_nullable_to_non_nullable
as double,receivedValue: null == receivedValue ? _self.receivedValue : receivedValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
