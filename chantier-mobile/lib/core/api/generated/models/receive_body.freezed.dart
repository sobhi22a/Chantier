// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receive_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReceiveBody {

/// Remarque facultative (200 caractères au plus).
 String? get note;
/// Create a copy of ReceiveBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiveBodyCopyWith<ReceiveBody> get copyWith => _$ReceiveBodyCopyWithImpl<ReceiveBody>(this as ReceiveBody, _$identity);

  /// Serializes this ReceiveBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveBody&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note);

@override
String toString() {
  return 'ReceiveBody(note: $note)';
}


}

/// @nodoc
abstract mixin class $ReceiveBodyCopyWith<$Res>  {
  factory $ReceiveBodyCopyWith(ReceiveBody value, $Res Function(ReceiveBody) _then) = _$ReceiveBodyCopyWithImpl;
@useResult
$Res call({
 String? note
});



}
/// @nodoc
class _$ReceiveBodyCopyWithImpl<$Res>
    implements $ReceiveBodyCopyWith<$Res> {
  _$ReceiveBodyCopyWithImpl(this._self, this._then);

  final ReceiveBody _self;
  final $Res Function(ReceiveBody) _then;

/// Create a copy of ReceiveBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = freezed,}) {
  return _then(_self.copyWith(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ReceiveBody implements ReceiveBody {
  const _ReceiveBody({this.note});
  factory _ReceiveBody.fromJson(Map<String, dynamic> json) => _$ReceiveBodyFromJson(json);

/// Remarque facultative (200 caractères au plus).
@override final  String? note;

/// Create a copy of ReceiveBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiveBodyCopyWith<_ReceiveBody> get copyWith => __$ReceiveBodyCopyWithImpl<_ReceiveBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiveBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiveBody&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note);

@override
String toString() {
  return 'ReceiveBody(note: $note)';
}


}

/// @nodoc
abstract mixin class _$ReceiveBodyCopyWith<$Res> implements $ReceiveBodyCopyWith<$Res> {
  factory _$ReceiveBodyCopyWith(_ReceiveBody value, $Res Function(_ReceiveBody) _then) = __$ReceiveBodyCopyWithImpl;
@override @useResult
$Res call({
 String? note
});



}
/// @nodoc
class __$ReceiveBodyCopyWithImpl<$Res>
    implements _$ReceiveBodyCopyWith<$Res> {
  __$ReceiveBodyCopyWithImpl(this._self, this._then);

  final _ReceiveBody _self;
  final $Res Function(_ReceiveBody) _then;

/// Create a copy of ReceiveBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = freezed,}) {
  return _then(_ReceiveBody(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
