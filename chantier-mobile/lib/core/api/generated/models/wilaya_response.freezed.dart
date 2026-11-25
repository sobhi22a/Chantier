// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wilaya_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WilayaResponse {

 String get code; String get nameFr; String get nameAr;
/// Create a copy of WilayaResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WilayaResponseCopyWith<WilayaResponse> get copyWith => _$WilayaResponseCopyWithImpl<WilayaResponse>(this as WilayaResponse, _$identity);

  /// Serializes this WilayaResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WilayaResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,nameFr,nameAr);

@override
String toString() {
  return 'WilayaResponse(code: $code, nameFr: $nameFr, nameAr: $nameAr)';
}


}

/// @nodoc
abstract mixin class $WilayaResponseCopyWith<$Res>  {
  factory $WilayaResponseCopyWith(WilayaResponse value, $Res Function(WilayaResponse) _then) = _$WilayaResponseCopyWithImpl;
@useResult
$Res call({
 String code, String nameFr, String nameAr
});



}
/// @nodoc
class _$WilayaResponseCopyWithImpl<$Res>
    implements $WilayaResponseCopyWith<$Res> {
  _$WilayaResponseCopyWithImpl(this._self, this._then);

  final WilayaResponse _self;
  final $Res Function(WilayaResponse) _then;

/// Create a copy of WilayaResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? nameFr = null,Object? nameAr = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,nameFr: null == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _WilayaResponse implements WilayaResponse {
  const _WilayaResponse({required this.code, required this.nameFr, required this.nameAr});
  factory _WilayaResponse.fromJson(Map<String, dynamic> json) => _$WilayaResponseFromJson(json);

@override final  String code;
@override final  String nameFr;
@override final  String nameAr;

/// Create a copy of WilayaResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WilayaResponseCopyWith<_WilayaResponse> get copyWith => __$WilayaResponseCopyWithImpl<_WilayaResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WilayaResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WilayaResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,nameFr,nameAr);

@override
String toString() {
  return 'WilayaResponse(code: $code, nameFr: $nameFr, nameAr: $nameAr)';
}


}

/// @nodoc
abstract mixin class _$WilayaResponseCopyWith<$Res> implements $WilayaResponseCopyWith<$Res> {
  factory _$WilayaResponseCopyWith(_WilayaResponse value, $Res Function(_WilayaResponse) _then) = __$WilayaResponseCopyWithImpl;
@override @useResult
$Res call({
 String code, String nameFr, String nameAr
});



}
/// @nodoc
class __$WilayaResponseCopyWithImpl<$Res>
    implements _$WilayaResponseCopyWith<$Res> {
  __$WilayaResponseCopyWithImpl(this._self, this._then);

  final _WilayaResponse _self;
  final $Res Function(_WilayaResponse) _then;

/// Create a copy of WilayaResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? nameFr = null,Object? nameAr = null,}) {
  return _then(_WilayaResponse(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,nameFr: null == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
