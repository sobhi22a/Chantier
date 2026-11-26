// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reserve_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReserveResponse {

 String get code; String? get note;
/// Create a copy of ReserveResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReserveResponseCopyWith<ReserveResponse> get copyWith => _$ReserveResponseCopyWithImpl<ReserveResponse>(this as ReserveResponse, _$identity);

  /// Serializes this ReserveResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReserveResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'ReserveResponse(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class $ReserveResponseCopyWith<$Res>  {
  factory $ReserveResponseCopyWith(ReserveResponse value, $Res Function(ReserveResponse) _then) = _$ReserveResponseCopyWithImpl;
@useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class _$ReserveResponseCopyWithImpl<$Res>
    implements $ReserveResponseCopyWith<$Res> {
  _$ReserveResponseCopyWithImpl(this._self, this._then);

  final ReserveResponse _self;
  final $Res Function(ReserveResponse) _then;

/// Create a copy of ReserveResponse
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

class _ReserveResponse implements ReserveResponse {
  const _ReserveResponse({required this.code, required this.note});
  factory _ReserveResponse.fromJson(Map<String, dynamic> json) => _$ReserveResponseFromJson(json);

@override final  String code;
@override final  String? note;

/// Create a copy of ReserveResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReserveResponseCopyWith<_ReserveResponse> get copyWith => __$ReserveResponseCopyWithImpl<_ReserveResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReserveResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReserveResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'ReserveResponse(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ReserveResponseCopyWith<$Res> implements $ReserveResponseCopyWith<$Res> {
  factory _$ReserveResponseCopyWith(_ReserveResponse value, $Res Function(_ReserveResponse) _then) = __$ReserveResponseCopyWithImpl;
@override @useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class __$ReserveResponseCopyWithImpl<$Res>
    implements _$ReserveResponseCopyWith<$Res> {
  __$ReserveResponseCopyWithImpl(this._self, this._then);

  final _ReserveResponse _self;
  final $Res Function(_ReserveResponse) _then;

/// Create a copy of ReserveResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? note = freezed,}) {
  return _then(_ReserveResponse(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
