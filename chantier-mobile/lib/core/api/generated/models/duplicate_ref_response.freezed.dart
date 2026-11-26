// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'duplicate_ref_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DuplicateRefResponse {

 String get id; String get number;
/// Create a copy of DuplicateRefResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuplicateRefResponseCopyWith<DuplicateRefResponse> get copyWith => _$DuplicateRefResponseCopyWithImpl<DuplicateRefResponse>(this as DuplicateRefResponse, _$identity);

  /// Serializes this DuplicateRefResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DuplicateRefResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number);

@override
String toString() {
  return 'DuplicateRefResponse(id: $id, number: $number)';
}


}

/// @nodoc
abstract mixin class $DuplicateRefResponseCopyWith<$Res>  {
  factory $DuplicateRefResponseCopyWith(DuplicateRefResponse value, $Res Function(DuplicateRefResponse) _then) = _$DuplicateRefResponseCopyWithImpl;
@useResult
$Res call({
 String id, String number
});



}
/// @nodoc
class _$DuplicateRefResponseCopyWithImpl<$Res>
    implements $DuplicateRefResponseCopyWith<$Res> {
  _$DuplicateRefResponseCopyWithImpl(this._self, this._then);

  final DuplicateRefResponse _self;
  final $Res Function(DuplicateRefResponse) _then;

/// Create a copy of DuplicateRefResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _DuplicateRefResponse implements DuplicateRefResponse {
  const _DuplicateRefResponse({required this.id, required this.number});
  factory _DuplicateRefResponse.fromJson(Map<String, dynamic> json) => _$DuplicateRefResponseFromJson(json);

@override final  String id;
@override final  String number;

/// Create a copy of DuplicateRefResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DuplicateRefResponseCopyWith<_DuplicateRefResponse> get copyWith => __$DuplicateRefResponseCopyWithImpl<_DuplicateRefResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DuplicateRefResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DuplicateRefResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number);

@override
String toString() {
  return 'DuplicateRefResponse(id: $id, number: $number)';
}


}

/// @nodoc
abstract mixin class _$DuplicateRefResponseCopyWith<$Res> implements $DuplicateRefResponseCopyWith<$Res> {
  factory _$DuplicateRefResponseCopyWith(_DuplicateRefResponse value, $Res Function(_DuplicateRefResponse) _then) = __$DuplicateRefResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String number
});



}
/// @nodoc
class __$DuplicateRefResponseCopyWithImpl<$Res>
    implements _$DuplicateRefResponseCopyWith<$Res> {
  __$DuplicateRefResponseCopyWithImpl(this._self, this._then);

  final _DuplicateRefResponse _self;
  final $Res Function(_DuplicateRefResponse) _then;

/// Create a copy of DuplicateRefResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,}) {
  return _then(_DuplicateRefResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
