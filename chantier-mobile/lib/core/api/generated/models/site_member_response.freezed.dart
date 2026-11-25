// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_member_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SiteMemberResponse {

 String get userId; String get fullName; String get role;/// Date d'affectation (heure du serveur, UTC).
 DateTime get assignedAt;
/// Create a copy of SiteMemberResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteMemberResponseCopyWith<SiteMemberResponse> get copyWith => _$SiteMemberResponseCopyWithImpl<SiteMemberResponse>(this as SiteMemberResponse, _$identity);

  /// Serializes this SiteMemberResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteMemberResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,fullName,role,assignedAt);

@override
String toString() {
  return 'SiteMemberResponse(userId: $userId, fullName: $fullName, role: $role, assignedAt: $assignedAt)';
}


}

/// @nodoc
abstract mixin class $SiteMemberResponseCopyWith<$Res>  {
  factory $SiteMemberResponseCopyWith(SiteMemberResponse value, $Res Function(SiteMemberResponse) _then) = _$SiteMemberResponseCopyWithImpl;
@useResult
$Res call({
 String userId, String fullName, String role, DateTime assignedAt
});



}
/// @nodoc
class _$SiteMemberResponseCopyWithImpl<$Res>
    implements $SiteMemberResponseCopyWith<$Res> {
  _$SiteMemberResponseCopyWithImpl(this._self, this._then);

  final SiteMemberResponse _self;
  final $Res Function(SiteMemberResponse) _then;

/// Create a copy of SiteMemberResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? fullName = null,Object? role = null,Object? assignedAt = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SiteMemberResponse implements SiteMemberResponse {
  const _SiteMemberResponse({required this.userId, required this.fullName, required this.role, required this.assignedAt});
  factory _SiteMemberResponse.fromJson(Map<String, dynamic> json) => _$SiteMemberResponseFromJson(json);

@override final  String userId;
@override final  String fullName;
@override final  String role;
/// Date d'affectation (heure du serveur, UTC).
@override final  DateTime assignedAt;

/// Create a copy of SiteMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteMemberResponseCopyWith<_SiteMemberResponse> get copyWith => __$SiteMemberResponseCopyWithImpl<_SiteMemberResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteMemberResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteMemberResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,fullName,role,assignedAt);

@override
String toString() {
  return 'SiteMemberResponse(userId: $userId, fullName: $fullName, role: $role, assignedAt: $assignedAt)';
}


}

/// @nodoc
abstract mixin class _$SiteMemberResponseCopyWith<$Res> implements $SiteMemberResponseCopyWith<$Res> {
  factory _$SiteMemberResponseCopyWith(_SiteMemberResponse value, $Res Function(_SiteMemberResponse) _then) = __$SiteMemberResponseCopyWithImpl;
@override @useResult
$Res call({
 String userId, String fullName, String role, DateTime assignedAt
});



}
/// @nodoc
class __$SiteMemberResponseCopyWithImpl<$Res>
    implements _$SiteMemberResponseCopyWith<$Res> {
  __$SiteMemberResponseCopyWithImpl(this._self, this._then);

  final _SiteMemberResponse _self;
  final $Res Function(_SiteMemberResponse) _then;

/// Create a copy of SiteMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? fullName = null,Object? role = null,Object? assignedAt = null,}) {
  return _then(_SiteMemberResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
