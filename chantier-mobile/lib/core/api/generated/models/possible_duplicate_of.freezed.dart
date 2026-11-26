// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'possible_duplicate_of.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PossibleDuplicateOf {

 String get id; String get number;
/// Create a copy of PossibleDuplicateOf
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PossibleDuplicateOfCopyWith<PossibleDuplicateOf> get copyWith => _$PossibleDuplicateOfCopyWithImpl<PossibleDuplicateOf>(this as PossibleDuplicateOf, _$identity);

  /// Serializes this PossibleDuplicateOf to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PossibleDuplicateOf&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number);

@override
String toString() {
  return 'PossibleDuplicateOf(id: $id, number: $number)';
}


}

/// @nodoc
abstract mixin class $PossibleDuplicateOfCopyWith<$Res>  {
  factory $PossibleDuplicateOfCopyWith(PossibleDuplicateOf value, $Res Function(PossibleDuplicateOf) _then) = _$PossibleDuplicateOfCopyWithImpl;
@useResult
$Res call({
 String id, String number
});



}
/// @nodoc
class _$PossibleDuplicateOfCopyWithImpl<$Res>
    implements $PossibleDuplicateOfCopyWith<$Res> {
  _$PossibleDuplicateOfCopyWithImpl(this._self, this._then);

  final PossibleDuplicateOf _self;
  final $Res Function(PossibleDuplicateOf) _then;

/// Create a copy of PossibleDuplicateOf
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PossibleDuplicateOf implements PossibleDuplicateOf {
  const _PossibleDuplicateOf({required this.id, required this.number});
  factory _PossibleDuplicateOf.fromJson(Map<String, dynamic> json) => _$PossibleDuplicateOfFromJson(json);

@override final  String id;
@override final  String number;

/// Create a copy of PossibleDuplicateOf
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PossibleDuplicateOfCopyWith<_PossibleDuplicateOf> get copyWith => __$PossibleDuplicateOfCopyWithImpl<_PossibleDuplicateOf>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PossibleDuplicateOfToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PossibleDuplicateOf&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number);

@override
String toString() {
  return 'PossibleDuplicateOf(id: $id, number: $number)';
}


}

/// @nodoc
abstract mixin class _$PossibleDuplicateOfCopyWith<$Res> implements $PossibleDuplicateOfCopyWith<$Res> {
  factory _$PossibleDuplicateOfCopyWith(_PossibleDuplicateOf value, $Res Function(_PossibleDuplicateOf) _then) = __$PossibleDuplicateOfCopyWithImpl;
@override @useResult
$Res call({
 String id, String number
});



}
/// @nodoc
class __$PossibleDuplicateOfCopyWithImpl<$Res>
    implements _$PossibleDuplicateOfCopyWith<$Res> {
  __$PossibleDuplicateOfCopyWithImpl(this._self, this._then);

  final _PossibleDuplicateOf _self;
  final $Res Function(_PossibleDuplicateOf) _then;

/// Create a copy of PossibleDuplicateOf
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,}) {
  return _then(_PossibleDuplicateOf(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
