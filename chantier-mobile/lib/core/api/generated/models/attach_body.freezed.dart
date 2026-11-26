// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attach_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttachBody {

 String get requestId;
/// Create a copy of AttachBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachBodyCopyWith<AttachBody> get copyWith => _$AttachBodyCopyWithImpl<AttachBody>(this as AttachBody, _$identity);

  /// Serializes this AttachBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachBody&&(identical(other.requestId, requestId) || other.requestId == requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId);

@override
String toString() {
  return 'AttachBody(requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class $AttachBodyCopyWith<$Res>  {
  factory $AttachBodyCopyWith(AttachBody value, $Res Function(AttachBody) _then) = _$AttachBodyCopyWithImpl;
@useResult
$Res call({
 String requestId
});



}
/// @nodoc
class _$AttachBodyCopyWithImpl<$Res>
    implements $AttachBodyCopyWith<$Res> {
  _$AttachBodyCopyWithImpl(this._self, this._then);

  final AttachBody _self;
  final $Res Function(AttachBody) _then;

/// Create a copy of AttachBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestId = null,}) {
  return _then(_self.copyWith(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AttachBody implements AttachBody {
  const _AttachBody({required this.requestId});
  factory _AttachBody.fromJson(Map<String, dynamic> json) => _$AttachBodyFromJson(json);

@override final  String requestId;

/// Create a copy of AttachBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachBodyCopyWith<_AttachBody> get copyWith => __$AttachBodyCopyWithImpl<_AttachBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttachBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachBody&&(identical(other.requestId, requestId) || other.requestId == requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId);

@override
String toString() {
  return 'AttachBody(requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class _$AttachBodyCopyWith<$Res> implements $AttachBodyCopyWith<$Res> {
  factory _$AttachBodyCopyWith(_AttachBody value, $Res Function(_AttachBody) _then) = __$AttachBodyCopyWithImpl;
@override @useResult
$Res call({
 String requestId
});



}
/// @nodoc
class __$AttachBodyCopyWithImpl<$Res>
    implements _$AttachBodyCopyWith<$Res> {
  __$AttachBodyCopyWithImpl(this._self, this._then);

  final _AttachBody _self;
  final $Res Function(_AttachBody) _then;

/// Create a copy of AttachBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestId = null,}) {
  return _then(_AttachBody(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
