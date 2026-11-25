// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_push_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncPushRequest {

/// Opérations dans l'ordre de saisie ; les résultats reviennent dans le même ordre.
 List<SyncPushOperation> get operations;
/// Create a copy of SyncPushRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncPushRequestCopyWith<SyncPushRequest> get copyWith => _$SyncPushRequestCopyWithImpl<SyncPushRequest>(this as SyncPushRequest, _$identity);

  /// Serializes this SyncPushRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncPushRequest&&const DeepCollectionEquality().equals(other.operations, operations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(operations));

@override
String toString() {
  return 'SyncPushRequest(operations: $operations)';
}


}

/// @nodoc
abstract mixin class $SyncPushRequestCopyWith<$Res>  {
  factory $SyncPushRequestCopyWith(SyncPushRequest value, $Res Function(SyncPushRequest) _then) = _$SyncPushRequestCopyWithImpl;
@useResult
$Res call({
 List<SyncPushOperation> operations
});



}
/// @nodoc
class _$SyncPushRequestCopyWithImpl<$Res>
    implements $SyncPushRequestCopyWith<$Res> {
  _$SyncPushRequestCopyWithImpl(this._self, this._then);

  final SyncPushRequest _self;
  final $Res Function(SyncPushRequest) _then;

/// Create a copy of SyncPushRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? operations = null,}) {
  return _then(_self.copyWith(
operations: null == operations ? _self.operations : operations // ignore: cast_nullable_to_non_nullable
as List<SyncPushOperation>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SyncPushRequest implements SyncPushRequest {
  const _SyncPushRequest({required final  List<SyncPushOperation> operations}): _operations = operations;
  factory _SyncPushRequest.fromJson(Map<String, dynamic> json) => _$SyncPushRequestFromJson(json);

/// Opérations dans l'ordre de saisie ; les résultats reviennent dans le même ordre.
 final  List<SyncPushOperation> _operations;
/// Opérations dans l'ordre de saisie ; les résultats reviennent dans le même ordre.
@override List<SyncPushOperation> get operations {
  if (_operations is EqualUnmodifiableListView) return _operations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_operations);
}


/// Create a copy of SyncPushRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncPushRequestCopyWith<_SyncPushRequest> get copyWith => __$SyncPushRequestCopyWithImpl<_SyncPushRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncPushRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncPushRequest&&const DeepCollectionEquality().equals(other._operations, _operations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_operations));

@override
String toString() {
  return 'SyncPushRequest(operations: $operations)';
}


}

/// @nodoc
abstract mixin class _$SyncPushRequestCopyWith<$Res> implements $SyncPushRequestCopyWith<$Res> {
  factory _$SyncPushRequestCopyWith(_SyncPushRequest value, $Res Function(_SyncPushRequest) _then) = __$SyncPushRequestCopyWithImpl;
@override @useResult
$Res call({
 List<SyncPushOperation> operations
});



}
/// @nodoc
class __$SyncPushRequestCopyWithImpl<$Res>
    implements _$SyncPushRequestCopyWith<$Res> {
  __$SyncPushRequestCopyWithImpl(this._self, this._then);

  final _SyncPushRequest _self;
  final $Res Function(_SyncPushRequest) _then;

/// Create a copy of SyncPushRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? operations = null,}) {
  return _then(_SyncPushRequest(
operations: null == operations ? _self._operations : operations // ignore: cast_nullable_to_non_nullable
as List<SyncPushOperation>,
  ));
}


}

// dart format on
