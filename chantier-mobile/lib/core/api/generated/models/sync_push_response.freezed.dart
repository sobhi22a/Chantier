// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_push_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncPushResponse {

 List<SyncPushResult> get results;
/// Create a copy of SyncPushResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncPushResponseCopyWith<SyncPushResponse> get copyWith => _$SyncPushResponseCopyWithImpl<SyncPushResponse>(this as SyncPushResponse, _$identity);

  /// Serializes this SyncPushResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncPushResponse&&const DeepCollectionEquality().equals(other.results, results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results));

@override
String toString() {
  return 'SyncPushResponse(results: $results)';
}


}

/// @nodoc
abstract mixin class $SyncPushResponseCopyWith<$Res>  {
  factory $SyncPushResponseCopyWith(SyncPushResponse value, $Res Function(SyncPushResponse) _then) = _$SyncPushResponseCopyWithImpl;
@useResult
$Res call({
 List<SyncPushResult> results
});



}
/// @nodoc
class _$SyncPushResponseCopyWithImpl<$Res>
    implements $SyncPushResponseCopyWith<$Res> {
  _$SyncPushResponseCopyWithImpl(this._self, this._then);

  final SyncPushResponse _self;
  final $Res Function(SyncPushResponse) _then;

/// Create a copy of SyncPushResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<SyncPushResult>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SyncPushResponse implements SyncPushResponse {
  const _SyncPushResponse({required final  List<SyncPushResult> results}): _results = results;
  factory _SyncPushResponse.fromJson(Map<String, dynamic> json) => _$SyncPushResponseFromJson(json);

 final  List<SyncPushResult> _results;
@override List<SyncPushResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of SyncPushResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncPushResponseCopyWith<_SyncPushResponse> get copyWith => __$SyncPushResponseCopyWithImpl<_SyncPushResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncPushResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncPushResponse&&const DeepCollectionEquality().equals(other._results, _results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results));

@override
String toString() {
  return 'SyncPushResponse(results: $results)';
}


}

/// @nodoc
abstract mixin class _$SyncPushResponseCopyWith<$Res> implements $SyncPushResponseCopyWith<$Res> {
  factory _$SyncPushResponseCopyWith(_SyncPushResponse value, $Res Function(_SyncPushResponse) _then) = __$SyncPushResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SyncPushResult> results
});



}
/// @nodoc
class __$SyncPushResponseCopyWithImpl<$Res>
    implements _$SyncPushResponseCopyWith<$Res> {
  __$SyncPushResponseCopyWithImpl(this._self, this._then);

  final _SyncPushResponse _self;
  final $Res Function(_SyncPushResponse) _then;

/// Create a copy of SyncPushResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,}) {
  return _then(_SyncPushResponse(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<SyncPushResult>,
  ));
}


}

// dart format on
