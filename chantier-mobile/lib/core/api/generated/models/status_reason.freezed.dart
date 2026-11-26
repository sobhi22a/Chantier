// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_reason.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatusReason {

 String get code; String? get note;
/// Create a copy of StatusReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusReasonCopyWith<StatusReason> get copyWith => _$StatusReasonCopyWithImpl<StatusReason>(this as StatusReason, _$identity);

  /// Serializes this StatusReason to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusReason&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'StatusReason(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class $StatusReasonCopyWith<$Res>  {
  factory $StatusReasonCopyWith(StatusReason value, $Res Function(StatusReason) _then) = _$StatusReasonCopyWithImpl;
@useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class _$StatusReasonCopyWithImpl<$Res>
    implements $StatusReasonCopyWith<$Res> {
  _$StatusReasonCopyWithImpl(this._self, this._then);

  final StatusReason _self;
  final $Res Function(StatusReason) _then;

/// Create a copy of StatusReason
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

class _StatusReason implements StatusReason {
  const _StatusReason({required this.code, required this.note});
  factory _StatusReason.fromJson(Map<String, dynamic> json) => _$StatusReasonFromJson(json);

@override final  String code;
@override final  String? note;

/// Create a copy of StatusReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusReasonCopyWith<_StatusReason> get copyWith => __$StatusReasonCopyWithImpl<_StatusReason>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusReasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusReason&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'StatusReason(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class _$StatusReasonCopyWith<$Res> implements $StatusReasonCopyWith<$Res> {
  factory _$StatusReasonCopyWith(_StatusReason value, $Res Function(_StatusReason) _then) = __$StatusReasonCopyWithImpl;
@override @useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class __$StatusReasonCopyWithImpl<$Res>
    implements _$StatusReasonCopyWith<$Res> {
  __$StatusReasonCopyWithImpl(this._self, this._then);

  final _StatusReason _self;
  final $Res Function(_StatusReason) _then;

/// Create a copy of StatusReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? note = freezed,}) {
  return _then(_StatusReason(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
