// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cancel_reason.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CancelReason {

 String get code; String? get note;
/// Create a copy of CancelReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelReasonCopyWith<CancelReason> get copyWith => _$CancelReasonCopyWithImpl<CancelReason>(this as CancelReason, _$identity);

  /// Serializes this CancelReason to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelReason&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'CancelReason(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class $CancelReasonCopyWith<$Res>  {
  factory $CancelReasonCopyWith(CancelReason value, $Res Function(CancelReason) _then) = _$CancelReasonCopyWithImpl;
@useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class _$CancelReasonCopyWithImpl<$Res>
    implements $CancelReasonCopyWith<$Res> {
  _$CancelReasonCopyWithImpl(this._self, this._then);

  final CancelReason _self;
  final $Res Function(CancelReason) _then;

/// Create a copy of CancelReason
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

class _CancelReason implements CancelReason {
  const _CancelReason({required this.code, required this.note});
  factory _CancelReason.fromJson(Map<String, dynamic> json) => _$CancelReasonFromJson(json);

@override final  String code;
@override final  String? note;

/// Create a copy of CancelReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelReasonCopyWith<_CancelReason> get copyWith => __$CancelReasonCopyWithImpl<_CancelReason>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CancelReasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelReason&&(identical(other.code, code) || other.code == code)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,note);

@override
String toString() {
  return 'CancelReason(code: $code, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CancelReasonCopyWith<$Res> implements $CancelReasonCopyWith<$Res> {
  factory _$CancelReasonCopyWith(_CancelReason value, $Res Function(_CancelReason) _then) = __$CancelReasonCopyWithImpl;
@override @useResult
$Res call({
 String code, String? note
});



}
/// @nodoc
class __$CancelReasonCopyWithImpl<$Res>
    implements _$CancelReasonCopyWith<$Res> {
  __$CancelReasonCopyWithImpl(this._self, this._then);

  final _CancelReason _self;
  final $Res Function(_CancelReason) _then;

/// Create a copy of CancelReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? note = freezed,}) {
  return _then(_CancelReason(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
