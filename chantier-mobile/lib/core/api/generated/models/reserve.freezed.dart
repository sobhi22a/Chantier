// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reserve.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reserve {

 String get code; String? get note;
/// Create a copy of Reserve
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReserveCopyWith<Reserve> get copyWith => _$ReserveCopyWithImpl<Reserve>(this as Reserve, _$identity);

  /// Serializes this Reserve to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reserve&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'Reserve(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class $ReserveCopyWith<$Res>  {
  factory $ReserveCopyWith(Reserve value, $Res Function(Reserve) _then) = _$ReserveCopyWithImpl;
@useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class _$ReserveCopyWithImpl<$Res>
    implements $ReserveCopyWith<$Res> {
  _$ReserveCopyWithImpl(this._self, this._then);

  final Reserve _self;
  final $Res Function(Reserve) _then;

/// Create a copy of Reserve
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Reserve implements Reserve {
  const _Reserve({required this.code, required this.note});
  factory _Reserve.fromJson(Map<String, dynamic> json) => _$ReserveFromJson(json);

@override final  String code;
@override final  String? note;

/// Create a copy of Reserve
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReserveCopyWith<_Reserve> get copyWith => __$ReserveCopyWithImpl<_Reserve>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReserveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reserve&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'Reserve(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ReserveCopyWith<$Res> implements $ReserveCopyWith<$Res> {
  factory _$ReserveCopyWith(_Reserve value, $Res Function(_Reserve) _then) = __$ReserveCopyWithImpl;
@override @useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class __$ReserveCopyWithImpl<$Res>
    implements _$ReserveCopyWith<$Res> {
  __$ReserveCopyWithImpl(this._self, this._then);

  final _Reserve _self;
  final $Res Function(_Reserve) _then;

/// Create a copy of Reserve
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? note = freezed,}) {
  return _then(_Reserve(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
