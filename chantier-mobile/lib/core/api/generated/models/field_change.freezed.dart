// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'field_change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FieldChange {

 String get field; String? get old;/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
@JsonKey(name: 'new') String? get newValue;
/// Create a copy of FieldChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldChangeCopyWith<FieldChange> get copyWith => _$FieldChangeCopyWithImpl<FieldChange>(this as FieldChange, _$identity);

  /// Serializes this FieldChange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldChange&&(identical(other.field, field) || other.field == field)&&(identical(other.old, old) || other.old == old)&&(identical(other.newValue, newValue) || other.newValue == newValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,old,newValue);

@override
String toString() {
  return 'FieldChange(field: $field, old: $old, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class $FieldChangeCopyWith<$Res>  {
  factory $FieldChangeCopyWith(FieldChange value, $Res Function(FieldChange) _then) = _$FieldChangeCopyWithImpl;
@useResult
$Res call({
 String field, String? old,@JsonKey(name: 'new') String? newValue
});



}
/// @nodoc
class _$FieldChangeCopyWithImpl<$Res>
    implements $FieldChangeCopyWith<$Res> {
  _$FieldChangeCopyWithImpl(this._self, this._then);

  final FieldChange _self;
  final $Res Function(FieldChange) _then;

/// Create a copy of FieldChange
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

class _FieldChange implements FieldChange {
  const _FieldChange({required this.field, required this.old, @JsonKey(name: 'new') required this.newValue});
  factory _FieldChange.fromJson(Map<String, dynamic> json) => _$FieldChangeFromJson(json);

@override final  String field;
@override final  String? old;
/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
/// The name has been replaced because it contains a keyword. Original name: `new`.
@override@JsonKey(name: 'new') final  String? newValue;

/// Create a copy of FieldChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldChangeCopyWith<_FieldChange> get copyWith => __$FieldChangeCopyWithImpl<_FieldChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FieldChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldChange&&(identical(other.field, field) || other.field == field)&&(identical(other.old, old) || other.old == old)&&(identical(other.newValue, newValue) || other.newValue == newValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,old,newValue);

@override
String toString() {
  return 'FieldChange(field: $field, old: $old, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class _$FieldChangeCopyWith<$Res> implements $FieldChangeCopyWith<$Res> {
  factory _$FieldChangeCopyWith(_FieldChange value, $Res Function(_FieldChange) _then) = __$FieldChangeCopyWithImpl;
@override @useResult
$Res call({
 String field, String? old,@JsonKey(name: 'new') String? newValue
});



}
/// @nodoc
class __$FieldChangeCopyWithImpl<$Res>
    implements _$FieldChangeCopyWith<$Res> {
  __$FieldChangeCopyWithImpl(this._self, this._then);

  final _FieldChange _self;
  final $Res Function(_FieldChange) _then;

/// Create a copy of FieldChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? old = freezed,Object? newValue = freezed,}) {
  return _then(_FieldChange(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,old: freezed == old ? _self.old : old // ignore: cast_nullable_to_non_nullable
as String?,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
