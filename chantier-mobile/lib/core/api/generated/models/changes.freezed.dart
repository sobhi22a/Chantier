// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'changes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Changes {

 String get field; String? get old;/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
@JsonKey(name: 'new') String? get newValue;
/// Create a copy of Changes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangesCopyWith<Changes> get copyWith => _$ChangesCopyWithImpl<Changes>(this as Changes, _$identity);

  /// Serializes this Changes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Changes&&(identical(other.field, field) || other.field == field)&&(identical(other.old, old) || other.old == old)&&(identical(other.newValue, newValue) || other.newValue == newValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,old,newValue);

@override
String toString() {
  return 'Changes(field: $field, old: $old, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class $ChangesCopyWith<$Res>  {
  factory $ChangesCopyWith(Changes value, $Res Function(Changes) _then) = _$ChangesCopyWithImpl;
@useResult
$Res call({
 String field, String? old,@JsonKey(name: 'new') String? newValue
});



}
/// @nodoc
class _$ChangesCopyWithImpl<$Res>
    implements $ChangesCopyWith<$Res> {
  _$ChangesCopyWithImpl(this._self, this._then);

  final Changes _self;
  final $Res Function(Changes) _then;

/// Create a copy of Changes
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

class _Changes implements Changes {
  const _Changes({required this.field, required this.old, @JsonKey(name: 'new') required this.newValue});
  factory _Changes.fromJson(Map<String, dynamic> json) => _$ChangesFromJson(json);

@override final  String field;
@override final  String? old;
/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
@override@JsonKey(name: 'new') final  String? newValue;

/// Create a copy of Changes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangesCopyWith<_Changes> get copyWith => __$ChangesCopyWithImpl<_Changes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Changes&&(identical(other.field, field) || other.field == field)&&(identical(other.old, old) || other.old == old)&&(identical(other.newValue, newValue) || other.newValue == newValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,old,newValue);

@override
String toString() {
  return 'Changes(field: $field, old: $old, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class _$ChangesCopyWith<$Res> implements $ChangesCopyWith<$Res> {
  factory _$ChangesCopyWith(_Changes value, $Res Function(_Changes) _then) = __$ChangesCopyWithImpl;
@override @useResult
$Res call({
 String field, String? old,@JsonKey(name: 'new') String? newValue
});



}
/// @nodoc
class __$ChangesCopyWithImpl<$Res>
    implements _$ChangesCopyWith<$Res> {
  __$ChangesCopyWithImpl(this._self, this._then);

  final _Changes _self;
  final $Res Function(_Changes) _then;

/// Create a copy of Changes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? old = freezed,Object? newValue = freezed,}) {
  return _then(_Changes(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,old: freezed == old ? _self.old : old // ignore: cast_nullable_to_non_nullable
as String?,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
