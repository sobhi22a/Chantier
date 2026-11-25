// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_code_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SiteCodeSuggestion {

 String get code;
/// Create a copy of SiteCodeSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteCodeSuggestionCopyWith<SiteCodeSuggestion> get copyWith => _$SiteCodeSuggestionCopyWithImpl<SiteCodeSuggestion>(this as SiteCodeSuggestion, _$identity);

  /// Serializes this SiteCodeSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteCodeSuggestion&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'SiteCodeSuggestion(code: $code)';
}


}

/// @nodoc
abstract mixin class $SiteCodeSuggestionCopyWith<$Res>  {
  factory $SiteCodeSuggestionCopyWith(SiteCodeSuggestion value, $Res Function(SiteCodeSuggestion) _then) = _$SiteCodeSuggestionCopyWithImpl;
@useResult
$Res call({
 String code
});



}
/// @nodoc
class _$SiteCodeSuggestionCopyWithImpl<$Res>
    implements $SiteCodeSuggestionCopyWith<$Res> {
  _$SiteCodeSuggestionCopyWithImpl(this._self, this._then);

  final SiteCodeSuggestion _self;
  final $Res Function(SiteCodeSuggestion) _then;

/// Create a copy of SiteCodeSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SiteCodeSuggestion implements SiteCodeSuggestion {
  const _SiteCodeSuggestion({required this.code});
  factory _SiteCodeSuggestion.fromJson(Map<String, dynamic> json) => _$SiteCodeSuggestionFromJson(json);

@override final  String code;

/// Create a copy of SiteCodeSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteCodeSuggestionCopyWith<_SiteCodeSuggestion> get copyWith => __$SiteCodeSuggestionCopyWithImpl<_SiteCodeSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteCodeSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteCodeSuggestion&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'SiteCodeSuggestion(code: $code)';
}


}

/// @nodoc
abstract mixin class _$SiteCodeSuggestionCopyWith<$Res> implements $SiteCodeSuggestionCopyWith<$Res> {
  factory _$SiteCodeSuggestionCopyWith(_SiteCodeSuggestion value, $Res Function(_SiteCodeSuggestion) _then) = __$SiteCodeSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String code
});



}
/// @nodoc
class __$SiteCodeSuggestionCopyWithImpl<$Res>
    implements _$SiteCodeSuggestionCopyWith<$Res> {
  __$SiteCodeSuggestionCopyWithImpl(this._self, this._then);

  final _SiteCodeSuggestion _self;
  final $Res Function(_SiteCodeSuggestion) _then;

/// Create a copy of SiteCodeSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(_SiteCodeSuggestion(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
