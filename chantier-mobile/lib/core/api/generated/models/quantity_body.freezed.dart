// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quantity_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuantityBody {

/// Valeur strictement positive, 3 décimales au plus ; entier pour `sac` et `u` (422 `QUANTITE_INVALIDE`, `QUANTITE_ENTIERE_REQUISE`).
 double? get value;/// Unité du référentiel : `u ml m2 m3 kg t sac l h j pj ft`.
 MeasureUnit? get unit;
/// Create a copy of QuantityBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuantityBodyCopyWith<QuantityBody> get copyWith => _$QuantityBodyCopyWithImpl<QuantityBody>(this as QuantityBody, _$identity);

  /// Serializes this QuantityBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuantityBody&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unit);

@override
String toString() {
  return 'QuantityBody(value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $QuantityBodyCopyWith<$Res>  {
  factory $QuantityBodyCopyWith(QuantityBody value, $Res Function(QuantityBody) _then) = _$QuantityBodyCopyWithImpl;
@useResult
$Res call({
 double? value, MeasureUnit? unit
});



}
/// @nodoc
class _$QuantityBodyCopyWithImpl<$Res>
    implements $QuantityBodyCopyWith<$Res> {
  _$QuantityBodyCopyWithImpl(this._self, this._then);

  final QuantityBody _self;
  final $Res Function(QuantityBody) _then;

/// Create a copy of QuantityBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = freezed,Object? unit = freezed,}) {
  return _then(_self.copyWith(
value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as MeasureUnit?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _QuantityBody implements QuantityBody {
  const _QuantityBody({this.value, this.unit});
  factory _QuantityBody.fromJson(Map<String, dynamic> json) => _$QuantityBodyFromJson(json);

/// Valeur strictement positive, 3 décimales au plus ; entier pour `sac` et `u` (422 `QUANTITE_INVALIDE`, `QUANTITE_ENTIERE_REQUISE`).
@override final  double? value;
/// Unité du référentiel : `u ml m2 m3 kg t sac l h j pj ft`.
@override final  MeasureUnit? unit;

/// Create a copy of QuantityBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuantityBodyCopyWith<_QuantityBody> get copyWith => __$QuantityBodyCopyWithImpl<_QuantityBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuantityBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuantityBody&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unit);

@override
String toString() {
  return 'QuantityBody(value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$QuantityBodyCopyWith<$Res> implements $QuantityBodyCopyWith<$Res> {
  factory _$QuantityBodyCopyWith(_QuantityBody value, $Res Function(_QuantityBody) _then) = __$QuantityBodyCopyWithImpl;
@override @useResult
$Res call({
 double? value, MeasureUnit? unit
});



}
/// @nodoc
class __$QuantityBodyCopyWithImpl<$Res>
    implements _$QuantityBodyCopyWith<$Res> {
  __$QuantityBodyCopyWithImpl(this._self, this._then);

  final _QuantityBody _self;
  final $Res Function(_QuantityBody) _then;

/// Create a copy of QuantityBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = freezed,Object? unit = freezed,}) {
  return _then(_QuantityBody(
value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as MeasureUnit?,
  ));
}


}

// dart format on
