// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'variance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Variance {

 double get value;/// Unites du referentiel (skill `metier-chantier`), identifiees par leur <b>code stable</b> dans le JSON, la base et les vecteurs de calcul :.
/// `u ml m2 m3 kg t sac l h j pj ft`. Une quantite n'existe jamais sans unite (regle 1).
 Unit get unit; double get percent;
/// Create a copy of Variance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VarianceCopyWith<Variance> get copyWith => _$VarianceCopyWithImpl<Variance>(this as Variance, _$identity);

  /// Serializes this Variance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Variance&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.percent, percent) || other.percent == percent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unit,percent);

@override
String toString() {
  return 'Variance(value: $value, unit: $unit, percent: $percent)';
}


}

/// @nodoc
abstract mixin class $VarianceCopyWith<$Res>  {
  factory $VarianceCopyWith(Variance value, $Res Function(Variance) _then) = _$VarianceCopyWithImpl;
@useResult
$Res call({
 double value, Unit unit, double percent
});



}
/// @nodoc
class _$VarianceCopyWithImpl<$Res>
    implements $VarianceCopyWith<$Res> {
  _$VarianceCopyWithImpl(this._self, this._then);

  final Variance _self;
  final $Res Function(Variance) _then;

/// Create a copy of Variance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? unit = null,Object? percent = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as Unit,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Variance implements Variance {
  const _Variance({required this.value, required this.unit, required this.percent});
  factory _Variance.fromJson(Map<String, dynamic> json) => _$VarianceFromJson(json);

@override final  double value;
/// Unites du referentiel (skill `metier-chantier`), identifiees par leur <b>code stable</b> dans le JSON, la base et les vecteurs de calcul :.
/// `u ml m2 m3 kg t sac l h j pj ft`. Une quantite n'existe jamais sans unite (regle 1).
@override final  Unit unit;
@override final  double percent;

/// Create a copy of Variance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VarianceCopyWith<_Variance> get copyWith => __$VarianceCopyWithImpl<_Variance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VarianceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Variance&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.percent, percent) || other.percent == percent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unit,percent);

@override
String toString() {
  return 'Variance(value: $value, unit: $unit, percent: $percent)';
}


}

/// @nodoc
abstract mixin class _$VarianceCopyWith<$Res> implements $VarianceCopyWith<$Res> {
  factory _$VarianceCopyWith(_Variance value, $Res Function(_Variance) _then) = __$VarianceCopyWithImpl;
@override @useResult
$Res call({
 double value, Unit unit, double percent
});



}
/// @nodoc
class __$VarianceCopyWithImpl<$Res>
    implements _$VarianceCopyWith<$Res> {
  __$VarianceCopyWithImpl(this._self, this._then);

  final _Variance _self;
  final $Res Function(_Variance) _then;

/// Create a copy of Variance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? unit = null,Object? percent = null,}) {
  return _then(_Variance(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as Unit,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
