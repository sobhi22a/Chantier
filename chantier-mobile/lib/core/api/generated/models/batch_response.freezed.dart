// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BatchResponse {

 List<BatchItemResult> get results;
/// Create a copy of BatchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchResponseCopyWith<BatchResponse> get copyWith => _$BatchResponseCopyWithImpl<BatchResponse>(this as BatchResponse, _$identity);

  /// Serializes this BatchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchResponse&&const DeepCollectionEquality().equals(other.results, results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results));

@override
String toString() {
  return 'BatchResponse(results: $results)';
}


}

/// @nodoc
abstract mixin class $BatchResponseCopyWith<$Res>  {
  factory $BatchResponseCopyWith(BatchResponse value, $Res Function(BatchResponse) _then) = _$BatchResponseCopyWithImpl;
@useResult
$Res call({
 List<BatchItemResult> results
});



}
/// @nodoc
class _$BatchResponseCopyWithImpl<$Res>
    implements $BatchResponseCopyWith<$Res> {
  _$BatchResponseCopyWithImpl(this._self, this._then);

  final BatchResponse _self;
  final $Res Function(BatchResponse) _then;

/// Create a copy of BatchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<BatchItemResult>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _BatchResponse implements BatchResponse {
  const _BatchResponse({required final  List<BatchItemResult> results}): _results = results;
  factory _BatchResponse.fromJson(Map<String, dynamic> json) => _$BatchResponseFromJson(json);

 final  List<BatchItemResult> _results;
@override List<BatchItemResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of BatchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchResponseCopyWith<_BatchResponse> get copyWith => __$BatchResponseCopyWithImpl<_BatchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchResponse&&const DeepCollectionEquality().equals(other._results, _results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results));

@override
String toString() {
  return 'BatchResponse(results: $results)';
}


}

/// @nodoc
abstract mixin class _$BatchResponseCopyWith<$Res> implements $BatchResponseCopyWith<$Res> {
  factory _$BatchResponseCopyWith(_BatchResponse value, $Res Function(_BatchResponse) _then) = __$BatchResponseCopyWithImpl;
@override @useResult
$Res call({
 List<BatchItemResult> results
});



}
/// @nodoc
class __$BatchResponseCopyWithImpl<$Res>
    implements _$BatchResponseCopyWith<$Res> {
  __$BatchResponseCopyWithImpl(this._self, this._then);

  final _BatchResponse _self;
  final $Res Function(_BatchResponse) _then;

/// Create a copy of BatchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,}) {
  return _then(_BatchResponse(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<BatchItemResult>,
  ));
}


}

// dart format on
