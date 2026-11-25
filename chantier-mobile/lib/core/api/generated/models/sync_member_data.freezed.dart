// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_member_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncMemberData {

/// Identifiant de l'affectation (celui des pierres tombales `member`).
 String get id; String get siteId; String get userId; String get fullName; String get role; DateTime get assignedAt;
/// Create a copy of SyncMemberData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncMemberDataCopyWith<SyncMemberData> get copyWith => _$SyncMemberDataCopyWithImpl<SyncMemberData>(this as SyncMemberData, _$identity);

  /// Serializes this SyncMemberData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncMemberData&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,siteId,userId,fullName,role,assignedAt);

@override
String toString() {
  return 'SyncMemberData(id: $id, siteId: $siteId, userId: $userId, fullName: $fullName, role: $role, assignedAt: $assignedAt)';
}


}

/// @nodoc
abstract mixin class $SyncMemberDataCopyWith<$Res>  {
  factory $SyncMemberDataCopyWith(SyncMemberData value, $Res Function(SyncMemberData) _then) = _$SyncMemberDataCopyWithImpl;
@useResult
$Res call({
 String id, String siteId, String userId, String fullName, String role, DateTime assignedAt
});



}
/// @nodoc
class _$SyncMemberDataCopyWithImpl<$Res>
    implements $SyncMemberDataCopyWith<$Res> {
  _$SyncMemberDataCopyWithImpl(this._self, this._then);

  final SyncMemberData _self;
  final $Res Function(SyncMemberData) _then;

/// Create a copy of SyncMemberData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? siteId = null,Object? userId = null,Object? fullName = null,Object? role = null,Object? assignedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SyncMemberData implements SyncMemberData {
  const _SyncMemberData({required this.id, required this.siteId, required this.userId, required this.fullName, required this.role, required this.assignedAt});
  factory _SyncMemberData.fromJson(Map<String, dynamic> json) => _$SyncMemberDataFromJson(json);

/// Identifiant de l'affectation (celui des pierres tombales `member`).
@override final  String id;
@override final  String siteId;
@override final  String userId;
@override final  String fullName;
@override final  String role;
@override final  DateTime assignedAt;

/// Create a copy of SyncMemberData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncMemberDataCopyWith<_SyncMemberData> get copyWith => __$SyncMemberDataCopyWithImpl<_SyncMemberData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncMemberDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncMemberData&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,siteId,userId,fullName,role,assignedAt);

@override
String toString() {
  return 'SyncMemberData(id: $id, siteId: $siteId, userId: $userId, fullName: $fullName, role: $role, assignedAt: $assignedAt)';
}


}

/// @nodoc
abstract mixin class _$SyncMemberDataCopyWith<$Res> implements $SyncMemberDataCopyWith<$Res> {
  factory _$SyncMemberDataCopyWith(_SyncMemberData value, $Res Function(_SyncMemberData) _then) = __$SyncMemberDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String siteId, String userId, String fullName, String role, DateTime assignedAt
});



}
/// @nodoc
class __$SyncMemberDataCopyWithImpl<$Res>
    implements _$SyncMemberDataCopyWith<$Res> {
  __$SyncMemberDataCopyWithImpl(this._self, this._then);

  final _SyncMemberData _self;
  final $Res Function(_SyncMemberData) _then;

/// Create a copy of SyncMemberData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? siteId = null,Object? userId = null,Object? fullName = null,Object? role = null,Object? assignedAt = null,}) {
  return _then(_SyncMemberData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
