// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_ids_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestIdsBody {

 List<String> get requestIds;
/// Create a copy of RequestIdsBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestIdsBodyCopyWith<RequestIdsBody> get copyWith => _$RequestIdsBodyCopyWithImpl<RequestIdsBody>(this as RequestIdsBody, _$identity);

  /// Serializes this RequestIdsBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestIdsBody&&const DeepCollectionEquality().equals(other.requestIds, requestIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(requestIds));

@override
String toString() {
  return 'RequestIdsBody(requestIds: $requestIds)';
}


}

/// @nodoc
abstract mixin class $RequestIdsBodyCopyWith<$Res>  {
  factory $RequestIdsBodyCopyWith(RequestIdsBody value, $Res Function(RequestIdsBody) _then) = _$RequestIdsBodyCopyWithImpl;
@useResult
$Res call({
 List<String> requestIds
});



}
/// @nodoc
class _$RequestIdsBodyCopyWithImpl<$Res>
    implements $RequestIdsBodyCopyWith<$Res> {
  _$RequestIdsBodyCopyWithImpl(this._self, this._then);

  final RequestIdsBody _self;
  final $Res Function(RequestIdsBody) _then;

/// Create a copy of RequestIdsBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestIds = null,}) {
  return _then(_self.copyWith(
requestIds: null == requestIds ? _self.requestIds : requestIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RequestIdsBody implements RequestIdsBody {
  const _RequestIdsBody({required final  List<String> requestIds}): _requestIds = requestIds;
  factory _RequestIdsBody.fromJson(Map<String, dynamic> json) => _$RequestIdsBodyFromJson(json);

 final  List<String> _requestIds;
@override List<String> get requestIds {
  if (_requestIds is EqualUnmodifiableListView) return _requestIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requestIds);
}


/// Create a copy of RequestIdsBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestIdsBodyCopyWith<_RequestIdsBody> get copyWith => __$RequestIdsBodyCopyWithImpl<_RequestIdsBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestIdsBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestIdsBody&&const DeepCollectionEquality().equals(other._requestIds, _requestIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_requestIds));

@override
String toString() {
  return 'RequestIdsBody(requestIds: $requestIds)';
}


}

/// @nodoc
abstract mixin class _$RequestIdsBodyCopyWith<$Res> implements $RequestIdsBodyCopyWith<$Res> {
  factory _$RequestIdsBodyCopyWith(_RequestIdsBody value, $Res Function(_RequestIdsBody) _then) = __$RequestIdsBodyCopyWithImpl;
@override @useResult
$Res call({
 List<String> requestIds
});



}
/// @nodoc
class __$RequestIdsBodyCopyWithImpl<$Res>
    implements _$RequestIdsBodyCopyWith<$Res> {
  __$RequestIdsBodyCopyWithImpl(this._self, this._then);

  final _RequestIdsBody _self;
  final $Res Function(_RequestIdsBody) _then;

/// Create a copy of RequestIdsBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestIds = null,}) {
  return _then(_RequestIdsBody(
requestIds: null == requestIds ? _self._requestIds : requestIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
