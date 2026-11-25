// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_language_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateLanguageRequest {

/// `fr` ou `ar`.
 String get language;
/// Create a copy of UpdateLanguageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateLanguageRequestCopyWith<UpdateLanguageRequest> get copyWith => _$UpdateLanguageRequestCopyWithImpl<UpdateLanguageRequest>(this as UpdateLanguageRequest, _$identity);

  /// Serializes this UpdateLanguageRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateLanguageRequest&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language);

@override
String toString() {
  return 'UpdateLanguageRequest(language: $language)';
}


}

/// @nodoc
abstract mixin class $UpdateLanguageRequestCopyWith<$Res>  {
  factory $UpdateLanguageRequestCopyWith(UpdateLanguageRequest value, $Res Function(UpdateLanguageRequest) _then) = _$UpdateLanguageRequestCopyWithImpl;
@useResult
$Res call({
 String language
});



}
/// @nodoc
class _$UpdateLanguageRequestCopyWithImpl<$Res>
    implements $UpdateLanguageRequestCopyWith<$Res> {
  _$UpdateLanguageRequestCopyWithImpl(this._self, this._then);

  final UpdateLanguageRequest _self;
  final $Res Function(UpdateLanguageRequest) _then;

/// Create a copy of UpdateLanguageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,}) {
  return _then(_self.copyWith(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UpdateLanguageRequest implements UpdateLanguageRequest {
  const _UpdateLanguageRequest({required this.language});
  factory _UpdateLanguageRequest.fromJson(Map<String, dynamic> json) => _$UpdateLanguageRequestFromJson(json);

/// `fr` ou `ar`.
@override final  String language;

/// Create a copy of UpdateLanguageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateLanguageRequestCopyWith<_UpdateLanguageRequest> get copyWith => __$UpdateLanguageRequestCopyWithImpl<_UpdateLanguageRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateLanguageRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateLanguageRequest&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language);

@override
String toString() {
  return 'UpdateLanguageRequest(language: $language)';
}


}

/// @nodoc
abstract mixin class _$UpdateLanguageRequestCopyWith<$Res> implements $UpdateLanguageRequestCopyWith<$Res> {
  factory _$UpdateLanguageRequestCopyWith(_UpdateLanguageRequest value, $Res Function(_UpdateLanguageRequest) _then) = __$UpdateLanguageRequestCopyWithImpl;
@override @useResult
$Res call({
 String language
});



}
/// @nodoc
class __$UpdateLanguageRequestCopyWithImpl<$Res>
    implements _$UpdateLanguageRequestCopyWith<$Res> {
  __$UpdateLanguageRequestCopyWithImpl(this._self, this._then);

  final _UpdateLanguageRequest _self;
  final $Res Function(_UpdateLanguageRequest) _then;

/// Create a copy of UpdateLanguageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,}) {
  return _then(_UpdateLanguageRequest(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
