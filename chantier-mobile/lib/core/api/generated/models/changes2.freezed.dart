// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'changes2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Changes2 {

 String get field; String? get old;/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
@JsonKey(name: 'new') String? get newValue;
/// Create a copy of Changes2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Changes2CopyWith<Changes2> get copyWith => _$Changes2CopyWithImpl<Changes2>(this as Changes2, _$identity);

  /// Serializes this Changes2 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Changes2&&(identical(other.field, field) || other.field == field)&&(identical(other.old, old) || other.old == old)&&(identical(other.newValue, newValue) || other.newValue == newValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,old,newValue);

@override
String toString() {
  return 'Changes2(field: $field, old: $old, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class $Changes2CopyWith<$Res>  {
  factory $Changes2CopyWith(Changes2 value, $Res Function(Changes2) _then) = _$Changes2CopyWithImpl;
@useResult
$Res call({
 String field, String? old,@JsonKey(name: 'new') String? newValue
});



}
/// @nodoc
class _$Changes2CopyWithImpl<$Res>
    implements $Changes2CopyWith<$Res> {
  _$Changes2CopyWithImpl(this._self, this._then);

  final Changes2 _self;
  final $Res Function(Changes2) _then;

/// Create a copy of Changes2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = null,Object? old = freezed,Object? newValue = freezed,}) {
  return _then(_self.copyWith(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,old: freezed == old ? _self.old : old // ignore: cast_nullable_to_non_nullable
as String?,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Changes2 implements Changes2 {
  const _Changes2({required this.field, required this.old, @JsonKey(name: 'new') required this.newValue});
  factory _Changes2.fromJson(Map<String, dynamic> json) => _$Changes2FromJson(json);

@override final  String field;
@override final  String? old;
/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
@override@JsonKey(name: 'new') final  String? newValue;

/// Create a copy of Changes2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$Changes2CopyWith<_Changes2> get copyWith => __$Changes2CopyWithImpl<_Changes2>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$Changes2ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Changes2&&(identical(other.field, field) || other.field == field)&&(identical(other.old, old) || other.old == old)&&(identical(other.newValue, newValue) || other.newValue == newValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,old,newValue);

@override
String toString() {
  return 'Changes2(field: $field, old: $old, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class _$Changes2CopyWith<$Res> implements $Changes2CopyWith<$Res> {
  factory _$Changes2CopyWith(_Changes2 value, $Res Function(_Changes2) _then) = __$Changes2CopyWithImpl;
@override @useResult
$Res call({
 String field, String? old,@JsonKey(name: 'new') String? newValue
});



}
/// @nodoc
class __$Changes2CopyWithImpl<$Res>
    implements _$Changes2CopyWith<$Res> {
  __$Changes2CopyWithImpl(this._self, this._then);

  final _Changes2 _self;
  final $Res Function(_Changes2) _then;

/// Create a copy of Changes2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? old = freezed,Object? newValue = freezed,}) {
  return _then(_Changes2(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,old: freezed == old ? _self.old : old // ignore: cast_nullable_to_non_nullable
as String?,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
