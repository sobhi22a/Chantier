// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_up_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowUpResponse {

 FollowUpCounters get counters; List<ToOrderTotalLine> get toOrderTotals; FollowUpCommercialResponse? get commercial;
/// Create a copy of FollowUpResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowUpResponseCopyWith<FollowUpResponse> get copyWith => _$FollowUpResponseCopyWithImpl<FollowUpResponse>(this as FollowUpResponse, _$identity);

  /// Serializes this FollowUpResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowUpResponse&&(identical(other.counters, counters) || other.counters == counters)&&const DeepCollectionEquality().equals(other.toOrderTotals, toOrderTotals)&&(identical(other.commercial, commercial) || other.commercial == commercial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,counters,const DeepCollectionEquality().hash(toOrderTotals),commercial);

@override
String toString() {
  return 'FollowUpResponse(counters: $counters, toOrderTotals: $toOrderTotals, commercial: $commercial)';
}


}

/// @nodoc
abstract mixin class $FollowUpResponseCopyWith<$Res>  {
  factory $FollowUpResponseCopyWith(FollowUpResponse value, $Res Function(FollowUpResponse) _then) = _$FollowUpResponseCopyWithImpl;
@useResult
$Res call({
 FollowUpCounters counters, List<ToOrderTotalLine> toOrderTotals, FollowUpCommercialResponse? commercial
});



}
/// @nodoc
class _$FollowUpResponseCopyWithImpl<$Res>
    implements $FollowUpResponseCopyWith<$Res> {
  _$FollowUpResponseCopyWithImpl(this._self, this._then);

  final FollowUpResponse _self;
  final $Res Function(FollowUpResponse) _then;

/// Create a copy of FollowUpResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? counters = null,Object? toOrderTotals = null,Object? commercial = freezed,}) {
  return _then(_self.copyWith(
counters: null == counters ? _self.counters : counters // ignore: cast_nullable_to_non_nullable
as FollowUpCounters,toOrderTotals: null == toOrderTotals ? _self.toOrderTotals : toOrderTotals // ignore: cast_nullable_to_non_nullable
as List<ToOrderTotalLine>,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as FollowUpCommercialResponse?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _FollowUpResponse implements FollowUpResponse {
  const _FollowUpResponse({required this.counters, required final  List<ToOrderTotalLine> toOrderTotals, this.commercial}): _toOrderTotals = toOrderTotals;
  factory _FollowUpResponse.fromJson(Map<String, dynamic> json) => _$FollowUpResponseFromJson(json);

@override final  FollowUpCounters counters;
 final  List<ToOrderTotalLine> _toOrderTotals;
@override List<ToOrderTotalLine> get toOrderTotals {
  if (_toOrderTotals is EqualUnmodifiableListView) return _toOrderTotals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_toOrderTotals);
}

@override final  FollowUpCommercialResponse? commercial;

/// Create a copy of FollowUpResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowUpResponseCopyWith<_FollowUpResponse> get copyWith => __$FollowUpResponseCopyWithImpl<_FollowUpResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowUpResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowUpResponse&&(identical(other.counters, counters) || other.counters == counters)&&const DeepCollectionEquality().equals(other._toOrderTotals, _toOrderTotals)&&(identical(other.commercial, commercial) || other.commercial == commercial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,counters,const DeepCollectionEquality().hash(_toOrderTotals),commercial);

@override
String toString() {
  return 'FollowUpResponse(counters: $counters, toOrderTotals: $toOrderTotals, commercial: $commercial)';
}


}

/// @nodoc
abstract mixin class _$FollowUpResponseCopyWith<$Res> implements $FollowUpResponseCopyWith<$Res> {
  factory _$FollowUpResponseCopyWith(_FollowUpResponse value, $Res Function(_FollowUpResponse) _then) = __$FollowUpResponseCopyWithImpl;
@override @useResult
$Res call({
 FollowUpCounters counters, List<ToOrderTotalLine> toOrderTotals, FollowUpCommercialResponse? commercial
});



}
/// @nodoc
class __$FollowUpResponseCopyWithImpl<$Res>
    implements _$FollowUpResponseCopyWith<$Res> {
  __$FollowUpResponseCopyWithImpl(this._self, this._then);

  final _FollowUpResponse _self;
  final $Res Function(_FollowUpResponse) _then;

/// Create a copy of FollowUpResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? counters = null,Object? toOrderTotals = null,Object? commercial = freezed,}) {
  return _then(_FollowUpResponse(
counters: null == counters ? _self.counters : counters // ignore: cast_nullable_to_non_nullable
as FollowUpCounters,toOrderTotals: null == toOrderTotals ? _self._toOrderTotals : toOrderTotals // ignore: cast_nullable_to_non_nullable
as List<ToOrderTotalLine>,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as FollowUpCommercialResponse?,
  ));
}


}

// dart format on
