// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_user_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthUserResponse {

 String get id; String get userName; String get fullName; String get role; String get language; bool get mustChangePassword;
/// Create a copy of AuthUserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUserResponseCopyWith<AuthUserResponse> get copyWith => _$AuthUserResponseCopyWithImpl<AuthUserResponse>(this as AuthUserResponse, _$identity);

  /// Serializes this AuthUserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUserResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.language, language) || other.language == language)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userName,fullName,role,language,mustChangePassword);

@override
String toString() {
  return 'AuthUserResponse(id: $id, userName: $userName, fullName: $fullName, role: $role, language: $language, mustChangePassword: $mustChangePassword)';
}


}

/// @nodoc
abstract mixin class $AuthUserResponseCopyWith<$Res>  {
  factory $AuthUserResponseCopyWith(AuthUserResponse value, $Res Function(AuthUserResponse) _then) = _$AuthUserResponseCopyWithImpl;
@useResult
$Res call({
 String id, String userName, String fullName, String role, String language, bool mustChangePassword
});



}
/// @nodoc
class _$AuthUserResponseCopyWithImpl<$Res>
    implements $AuthUserResponseCopyWith<$Res> {
  _$AuthUserResponseCopyWithImpl(this._self, this._then);

  final AuthUserResponse _self;
  final $Res Function(AuthUserResponse) _then;

/// Create a copy of AuthUserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userName = null,Object? fullName = null,Object? role = null,Object? language = null,Object? mustChangePassword = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AuthUserResponse implements AuthUserResponse {
  const _AuthUserResponse({required this.id, required this.userName, required this.fullName, required this.role, required this.language, required this.mustChangePassword});
  factory _AuthUserResponse.fromJson(Map<String, dynamic> json) => _$AuthUserResponseFromJson(json);

@override final  String id;
@override final  String userName;
@override final  String fullName;
@override final  String role;
@override final  String language;
@override final  bool mustChangePassword;

/// Create a copy of AuthUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthUserResponseCopyWith<_AuthUserResponse> get copyWith => __$AuthUserResponseCopyWithImpl<_AuthUserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthUserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthUserResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.language, language) || other.language == language)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userName,fullName,role,language,mustChangePassword);

@override
String toString() {
  return 'AuthUserResponse(id: $id, userName: $userName, fullName: $fullName, role: $role, language: $language, mustChangePassword: $mustChangePassword)';
}


}

/// @nodoc
abstract mixin class _$AuthUserResponseCopyWith<$Res> implements $AuthUserResponseCopyWith<$Res> {
  factory _$AuthUserResponseCopyWith(_AuthUserResponse value, $Res Function(_AuthUserResponse) _then) = __$AuthUserResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String userName, String fullName, String role, String language, bool mustChangePassword
});



}
/// @nodoc
class __$AuthUserResponseCopyWithImpl<$Res>
    implements _$AuthUserResponseCopyWith<$Res> {
  __$AuthUserResponseCopyWithImpl(this._self, this._then);

  final _AuthUserResponse _self;
  final $Res Function(_AuthUserResponse) _then;

/// Create a copy of AuthUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userName = null,Object? fullName = null,Object? role = null,Object? language = null,Object? mustChangePassword = null,}) {
  return _then(_AuthUserResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
