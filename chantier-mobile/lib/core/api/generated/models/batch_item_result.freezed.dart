// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_item_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BatchItemResult {

 String get requestId; String get outcome; String? get code;
/// Create a copy of BatchItemResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchItemResultCopyWith<BatchItemResult> get copyWith => _$BatchItemResultCopyWithImpl<BatchItemResult>(this as BatchItemResult, _$identity);

  /// Serializes this BatchItemResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchItemResult&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId,outcome,code);

@override
String toString() {
  return 'BatchItemResult(requestId: $requestId, outcome: $outcome, code: $code)';
}


}

/// @nodoc
abstract mixin class $BatchItemResultCopyWith<$Res>  {
  factory $BatchItemResultCopyWith(BatchItemResult value, $Res Function(BatchItemResult) _then) = _$BatchItemResultCopyWithImpl;
@useResult
$Res call({
 String requestId, String outcome, String? code
});



}
/// @nodoc
class _$BatchItemResultCopyWithImpl<$Res>
    implements $BatchItemResultCopyWith<$Res> {
  _$BatchItemResultCopyWithImpl(this._self, this._then);

  final BatchItemResult _self;
  final $Res Function(BatchItemResult) _then;

/// Create a copy of BatchItemResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestId = null,Object? outcome = null,Object? code = freezed,}) {
  return _then(_self.copyWith(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _BatchItemResult implements BatchItemResult {
  const _BatchItemResult({required this.requestId, required this.outcome, this.code});
  factory _BatchItemResult.fromJson(Map<String, dynamic> json) => _$BatchItemResultFromJson(json);

@override final  String requestId;
@override final  String outcome;
@override final  String? code;

/// Create a copy of BatchItemResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchItemResultCopyWith<_BatchItemResult> get copyWith => __$BatchItemResultCopyWithImpl<_BatchItemResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchItemResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchItemResult&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId,outcome,code);

@override
String toString() {
  return 'BatchItemResult(requestId: $requestId, outcome: $outcome, code: $code)';
}


}

/// @nodoc
abstract mixin class _$BatchItemResultCopyWith<$Res> implements $BatchItemResultCopyWith<$Res> {
  factory _$BatchItemResultCopyWith(_BatchItemResult value, $Res Function(_BatchItemResult) _then) = __$BatchItemResultCopyWithImpl;
@override @useResult
$Res call({
 String requestId, String outcome, String? code
});



}
/// @nodoc
class __$BatchItemResultCopyWithImpl<$Res>
    implements _$BatchItemResultCopyWith<$Res> {
  __$BatchItemResultCopyWithImpl(this._self, this._then);

  final _BatchItemResult _self;
  final $Res Function(_BatchItemResult) _then;

/// Create a copy of BatchItemResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestId = null,Object? outcome = null,Object? code = freezed,}) {
  return _then(_BatchItemResult(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
