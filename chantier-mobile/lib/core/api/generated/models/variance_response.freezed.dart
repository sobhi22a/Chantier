// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'variance_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VarianceResponse {

 double get value; MeasureUnit get unit; double get percent;
/// Create a copy of VarianceResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VarianceResponseCopyWith<VarianceResponse> get copyWith => _$VarianceResponseCopyWithImpl<VarianceResponse>(this as VarianceResponse, _$identity);

  /// Serializes this VarianceResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VarianceResponse&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.percent, percent) || other.percent == percent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unit,percent);

@override
String toString() {
  return 'VarianceResponse(value: $value, unit: $unit, percent: $percent)';
}


}

/// @nodoc
abstract mixin class $VarianceResponseCopyWith<$Res>  {
  factory $VarianceResponseCopyWith(VarianceResponse value, $Res Function(VarianceResponse) _then) = _$VarianceResponseCopyWithImpl;
@useResult
$Res call({
 double value, MeasureUnit unit, double percent
});



}
/// @nodoc
class _$VarianceResponseCopyWithImpl<$Res>
    implements $VarianceResponseCopyWith<$Res> {
  _$VarianceResponseCopyWithImpl(this._self, this._then);

  final VarianceResponse _self;
  final $Res Function(VarianceResponse) _then;

/// Create a copy of VarianceResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? unit = null,Object? percent = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as MeasureUnit,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _VarianceResponse implements VarianceResponse {
  const _VarianceResponse({required this.value, required this.unit, required this.percent});
  factory _VarianceResponse.fromJson(Map<String, dynamic> json) => _$VarianceResponseFromJson(json);

@override final  double value;
@override final  MeasureUnit unit;
@override final  double percent;

/// Create a copy of VarianceResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VarianceResponseCopyWith<_VarianceResponse> get copyWith => __$VarianceResponseCopyWithImpl<_VarianceResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VarianceResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VarianceResponse&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.percent, percent) || other.percent == percent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unit,percent);

@override
String toString() {
  return 'VarianceResponse(value: $value, unit: $unit, percent: $percent)';
}


}

/// @nodoc
abstract mixin class _$VarianceResponseCopyWith<$Res> implements $VarianceResponseCopyWith<$Res> {
  factory _$VarianceResponseCopyWith(_VarianceResponse value, $Res Function(_VarianceResponse) _then) = __$VarianceResponseCopyWithImpl;
@override @useResult
$Res call({
 double value, MeasureUnit unit, double percent
});



}
/// @nodoc
class __$VarianceResponseCopyWithImpl<$Res>
    implements _$VarianceResponseCopyWith<$Res> {
  __$VarianceResponseCopyWithImpl(this._self, this._then);

  final _VarianceResponse _self;
  final $Res Function(_VarianceResponse) _then;

/// Create a copy of VarianceResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? unit = null,Object? percent = null,}) {
  return _then(_VarianceResponse(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as MeasureUnit,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
