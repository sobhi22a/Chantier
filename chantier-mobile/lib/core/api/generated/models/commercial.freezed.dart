// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commercial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Commercial {

 double get amount;
/// Create a copy of Commercial
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommercialCopyWith<Commercial> get copyWith => _$CommercialCopyWithImpl<Commercial>(this as Commercial, _$identity);

  /// Serializes this Commercial to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Commercial&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount);

@override
String toString() {
  return 'Commercial(amount: $amount)';
}


}

/// @nodoc
abstract mixin class $CommercialCopyWith<$Res>  {
  factory $CommercialCopyWith(Commercial value, $Res Function(Commercial) _then) = _$CommercialCopyWithImpl;
@useResult
$Res call({
 double amount
});



}
/// @nodoc
class _$CommercialCopyWithImpl<$Res>
    implements $CommercialCopyWith<$Res> {
  _$CommercialCopyWithImpl(this._self, this._then);

  final Commercial _self;
  final $Res Function(Commercial) _then;

/// Create a copy of Commercial
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

class _Commercial implements Commercial {
  const _Commercial({required this.amount});
  factory _Commercial.fromJson(Map<String, dynamic> json) => _$CommercialFromJson(json);

@override final  double amount;

/// Create a copy of Commercial
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommercialCopyWith<_Commercial> get copyWith => __$CommercialCopyWithImpl<_Commercial>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommercialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Commercial&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount);

@override
String toString() {
  return 'Commercial(amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$CommercialCopyWith<$Res> implements $CommercialCopyWith<$Res> {
  factory _$CommercialCopyWith(_Commercial value, $Res Function(_Commercial) _then) = __$CommercialCopyWithImpl;
@override @useResult
$Res call({
 double amount
});



}
/// @nodoc
class __$CommercialCopyWithImpl<$Res>
    implements _$CommercialCopyWith<$Res> {
  __$CommercialCopyWithImpl(this._self, this._then);

  final _Commercial _self;
  final $Res Function(_Commercial) _then;

/// Create a copy of Commercial
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,}) {
  return _then(_Commercial(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
