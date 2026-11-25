// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commune_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommuneResponse {

 String get nameFr; String get nameAr;
/// Create a copy of CommuneResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommuneResponseCopyWith<CommuneResponse> get copyWith => _$CommuneResponseCopyWithImpl<CommuneResponse>(this as CommuneResponse, _$identity);

  /// Serializes this CommuneResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommuneResponse&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameFr,nameAr);

@override
String toString() {
  return 'CommuneResponse(nameFr: $nameFr, nameAr: $nameAr)';
}


}

/// @nodoc
abstract mixin class $CommuneResponseCopyWith<$Res>  {
  factory $CommuneResponseCopyWith(CommuneResponse value, $Res Function(CommuneResponse) _then) = _$CommuneResponseCopyWithImpl;
@useResult
$Res call({
 String nameFr, String nameAr
});



}
/// @nodoc
class _$CommuneResponseCopyWithImpl<$Res>
    implements $CommuneResponseCopyWith<$Res> {
  _$CommuneResponseCopyWithImpl(this._self, this._then);

  final CommuneResponse _self;
  final $Res Function(CommuneResponse) _then;

/// Create a copy of CommuneResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nameFr = null,Object? nameAr = null,}) {
  return _then(_self.copyWith(
nameFr: null == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CommuneResponse implements CommuneResponse {
  const _CommuneResponse({required this.nameFr, required this.nameAr});
  factory _CommuneResponse.fromJson(Map<String, dynamic> json) => _$CommuneResponseFromJson(json);

@override final  String nameFr;
@override final  String nameAr;

/// Create a copy of CommuneResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommuneResponseCopyWith<_CommuneResponse> get copyWith => __$CommuneResponseCopyWithImpl<_CommuneResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommuneResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommuneResponse&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameFr,nameAr);

@override
String toString() {
  return 'CommuneResponse(nameFr: $nameFr, nameAr: $nameAr)';
}


}

/// @nodoc
abstract mixin class _$CommuneResponseCopyWith<$Res> implements $CommuneResponseCopyWith<$Res> {
  factory _$CommuneResponseCopyWith(_CommuneResponse value, $Res Function(_CommuneResponse) _then) = __$CommuneResponseCopyWithImpl;
@override @useResult
$Res call({
 String nameFr, String nameAr
});



}
/// @nodoc
class __$CommuneResponseCopyWithImpl<$Res>
    implements _$CommuneResponseCopyWith<$Res> {
  __$CommuneResponseCopyWithImpl(this._self, this._then);

  final _CommuneResponse _self;
  final $Res Function(_CommuneResponse) _then;

/// Create a copy of CommuneResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nameFr = null,Object? nameAr = null,}) {
  return _then(_CommuneResponse(
nameFr: null == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
