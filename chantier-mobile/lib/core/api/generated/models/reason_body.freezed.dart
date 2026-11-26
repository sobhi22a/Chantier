// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reason_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReasonBody {

 String? get reasonCode;/// Remarque (200 caractères au plus), obligatoire pour `Other`.
 String? get reasonNote;
/// Create a copy of ReasonBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReasonBodyCopyWith<ReasonBody> get copyWith => _$ReasonBodyCopyWithImpl<ReasonBody>(this as ReasonBody, _$identity);

  /// Serializes this ReasonBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReasonBody&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reasonNote, reasonNote) || other.reasonNote == reasonNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reasonCode,reasonNote);

@override
String toString() {
  return 'ReasonBody(reasonCode: $reasonCode, reasonNote: $reasonNote)';
}


}

/// @nodoc
abstract mixin class $ReasonBodyCopyWith<$Res>  {
  factory $ReasonBodyCopyWith(ReasonBody value, $Res Function(ReasonBody) _then) = _$ReasonBodyCopyWithImpl;
@useResult
$Res call({
 String? reasonCode, String? reasonNote
});



}
/// @nodoc
class _$ReasonBodyCopyWithImpl<$Res>
    implements $ReasonBodyCopyWith<$Res> {
  _$ReasonBodyCopyWithImpl(this._self, this._then);

  final ReasonBody _self;
  final $Res Function(ReasonBody) _then;

/// Create a copy of ReasonBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reasonCode = freezed,Object? reasonNote = freezed,}) {
  return _then(_self.copyWith(
reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String?,reasonNote: freezed == reasonNote ? _self.reasonNote : reasonNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ReasonBody implements ReasonBody {
  const _ReasonBody({this.reasonCode, this.reasonNote});
  factory _ReasonBody.fromJson(Map<String, dynamic> json) => _$ReasonBodyFromJson(json);

@override final  String? reasonCode;
/// Remarque (200 caractères au plus), obligatoire pour `Other`.
@override final  String? reasonNote;

/// Create a copy of ReasonBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReasonBodyCopyWith<_ReasonBody> get copyWith => __$ReasonBodyCopyWithImpl<_ReasonBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReasonBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReasonBody&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reasonNote, reasonNote) || other.reasonNote == reasonNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reasonCode,reasonNote);

@override
String toString() {
  return 'ReasonBody(reasonCode: $reasonCode, reasonNote: $reasonNote)';
}


}

/// @nodoc
abstract mixin class _$ReasonBodyCopyWith<$Res> implements $ReasonBodyCopyWith<$Res> {
  factory _$ReasonBodyCopyWith(_ReasonBody value, $Res Function(_ReasonBody) _then) = __$ReasonBodyCopyWithImpl;
@override @useResult
$Res call({
 String? reasonCode, String? reasonNote
});



}
/// @nodoc
class __$ReasonBodyCopyWithImpl<$Res>
    implements _$ReasonBodyCopyWith<$Res> {
  __$ReasonBodyCopyWithImpl(this._self, this._then);

  final _ReasonBody _self;
  final $Res Function(_ReasonBody) _then;

/// Create a copy of ReasonBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reasonCode = freezed,Object? reasonNote = freezed,}) {
  return _then(_ReasonBody(
reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String?,reasonNote: freezed == reasonNote ? _self.reasonNote : reasonNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
