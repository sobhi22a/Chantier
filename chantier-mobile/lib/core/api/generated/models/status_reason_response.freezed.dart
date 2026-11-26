// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_reason_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatusReasonResponse {

 String get code; String? get note;
/// Create a copy of StatusReasonResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusReasonResponseCopyWith<StatusReasonResponse> get copyWith => _$StatusReasonResponseCopyWithImpl<StatusReasonResponse>(this as StatusReasonResponse, _$identity);

  /// Serializes this StatusReasonResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusReasonResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'StatusReasonResponse(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class $StatusReasonResponseCopyWith<$Res>  {
  factory $StatusReasonResponseCopyWith(StatusReasonResponse value, $Res Function(StatusReasonResponse) _then) = _$StatusReasonResponseCopyWithImpl;
@useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class _$StatusReasonResponseCopyWithImpl<$Res>
    implements $StatusReasonResponseCopyWith<$Res> {
  _$StatusReasonResponseCopyWithImpl(this._self, this._then);

  final StatusReasonResponse _self;
  final $Res Function(StatusReasonResponse) _then;

/// Create a copy of StatusReasonResponse
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

class _StatusReasonResponse implements StatusReasonResponse {
  const _StatusReasonResponse({required this.code, required this.note});
  factory _StatusReasonResponse.fromJson(Map<String, dynamic> json) => _$StatusReasonResponseFromJson(json);

@override final  String code;
@override final  String? note;

/// Create a copy of StatusReasonResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusReasonResponseCopyWith<_StatusReasonResponse> get copyWith => __$StatusReasonResponseCopyWithImpl<_StatusReasonResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusReasonResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusReasonResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'StatusReasonResponse(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class _$StatusReasonResponseCopyWith<$Res> implements $StatusReasonResponseCopyWith<$Res> {
  factory _$StatusReasonResponseCopyWith(_StatusReasonResponse value, $Res Function(_StatusReasonResponse) _then) = __$StatusReasonResponseCopyWithImpl;
@override @useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class __$StatusReasonResponseCopyWithImpl<$Res>
    implements _$StatusReasonResponseCopyWith<$Res> {
  __$StatusReasonResponseCopyWithImpl(this._self, this._then);

  final _StatusReasonResponse _self;
  final $Res Function(_StatusReasonResponse) _then;

/// Create a copy of StatusReasonResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? note = freezed,}) {
  return _then(_StatusReasonResponse(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
