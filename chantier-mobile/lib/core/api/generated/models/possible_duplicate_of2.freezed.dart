// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'possible_duplicate_of2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PossibleDuplicateOf2 {

 String get id; String get number;
/// Create a copy of PossibleDuplicateOf2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PossibleDuplicateOf2CopyWith<PossibleDuplicateOf2> get copyWith => _$PossibleDuplicateOf2CopyWithImpl<PossibleDuplicateOf2>(this as PossibleDuplicateOf2, _$identity);

  /// Serializes this PossibleDuplicateOf2 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PossibleDuplicateOf2&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number);

@override
String toString() {
  return 'PossibleDuplicateOf2(id: $id, number: $number)';
}


}

/// @nodoc
abstract mixin class $PossibleDuplicateOf2CopyWith<$Res>  {
  factory $PossibleDuplicateOf2CopyWith(PossibleDuplicateOf2 value, $Res Function(PossibleDuplicateOf2) _then) = _$PossibleDuplicateOf2CopyWithImpl;
@useResult
$Res call({
 String id, String number
});



}
/// @nodoc
class _$PossibleDuplicateOf2CopyWithImpl<$Res>
    implements $PossibleDuplicateOf2CopyWith<$Res> {
  _$PossibleDuplicateOf2CopyWithImpl(this._self, this._then);

  final PossibleDuplicateOf2 _self;
  final $Res Function(PossibleDuplicateOf2) _then;

/// Create a copy of PossibleDuplicateOf2
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

class _PossibleDuplicateOf2 implements PossibleDuplicateOf2 {
  const _PossibleDuplicateOf2({required this.id, required this.number});
  factory _PossibleDuplicateOf2.fromJson(Map<String, dynamic> json) => _$PossibleDuplicateOf2FromJson(json);

@override final  String id;
@override final  String number;

/// Create a copy of PossibleDuplicateOf2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PossibleDuplicateOf2CopyWith<_PossibleDuplicateOf2> get copyWith => __$PossibleDuplicateOf2CopyWithImpl<_PossibleDuplicateOf2>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PossibleDuplicateOf2ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PossibleDuplicateOf2&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number);

@override
String toString() {
  return 'PossibleDuplicateOf2(id: $id, number: $number)';
}


}

/// @nodoc
abstract mixin class _$PossibleDuplicateOf2CopyWith<$Res> implements $PossibleDuplicateOf2CopyWith<$Res> {
  factory _$PossibleDuplicateOf2CopyWith(_PossibleDuplicateOf2 value, $Res Function(_PossibleDuplicateOf2) _then) = __$PossibleDuplicateOf2CopyWithImpl;
@override @useResult
$Res call({
 String id, String number
});



}
/// @nodoc
class __$PossibleDuplicateOf2CopyWithImpl<$Res>
    implements _$PossibleDuplicateOf2CopyWith<$Res> {
  __$PossibleDuplicateOf2CopyWithImpl(this._self, this._then);

  final _PossibleDuplicateOf2 _self;
  final $Res Function(_PossibleDuplicateOf2) _then;

/// Create a copy of PossibleDuplicateOf2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,}) {
  return _then(_PossibleDuplicateOf2(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
