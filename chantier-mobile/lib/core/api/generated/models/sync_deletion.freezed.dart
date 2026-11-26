// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_deletion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncDeletion {

/// `site`, `zone` ou `member`.
 String get entity;/// Identifiant de la ligne supprimée.
 String get id;/// Chantier de la ligne ; `null` pour une entité globale.
 String? get siteId;/// Version serveur de la suppression.
 String get version;
/// Create a copy of SyncDeletion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncDeletionCopyWith<SyncDeletion> get copyWith => _$SyncDeletionCopyWithImpl<SyncDeletion>(this as SyncDeletion, _$identity);

  /// Serializes this SyncDeletion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncDeletion&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entity,id,siteId,version);

@override
String toString() {
  return 'SyncDeletion(entity: $entity, id: $id, siteId: $siteId, version: $version)';
}


}

/// @nodoc
abstract mixin class $SyncDeletionCopyWith<$Res>  {
  factory $SyncDeletionCopyWith(SyncDeletion value, $Res Function(SyncDeletion) _then) = _$SyncDeletionCopyWithImpl;
@useResult
$Res call({
 String entity, String id, String? siteId, String version
});



}
/// @nodoc
class _$SyncDeletionCopyWithImpl<$Res>
    implements $SyncDeletionCopyWith<$Res> {
  _$SyncDeletionCopyWithImpl(this._self, this._then);

  final SyncDeletion _self;
  final $Res Function(SyncDeletion) _then;

/// Create a copy of SyncDeletion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entity = null,Object? id = null,Object? siteId = freezed,Object? version = null,}) {
  return _then(_self.copyWith(
entity: null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SyncDeletion implements SyncDeletion {
  const _SyncDeletion({required this.entity, required this.id, required this.siteId, required this.version});
  factory _SyncDeletion.fromJson(Map<String, dynamic> json) => _$SyncDeletionFromJson(json);

/// `site`, `zone` ou `member`.
@override final  String entity;
/// Identifiant de la ligne supprimée.
@override final  String id;
/// Chantier de la ligne ; `null` pour une entité globale.
@override final  String? siteId;
/// Version serveur de la suppression.
@override final  String version;

/// Create a copy of SyncDeletion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncDeletionCopyWith<_SyncDeletion> get copyWith => __$SyncDeletionCopyWithImpl<_SyncDeletion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncDeletionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncDeletion&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entity,id,siteId,version);

@override
String toString() {
  return 'SyncDeletion(entity: $entity, id: $id, siteId: $siteId, version: $version)';
}


}

/// @nodoc
abstract mixin class _$SyncDeletionCopyWith<$Res> implements $SyncDeletionCopyWith<$Res> {
  factory _$SyncDeletionCopyWith(_SyncDeletion value, $Res Function(_SyncDeletion) _then) = __$SyncDeletionCopyWithImpl;
@override @useResult
$Res call({
 String entity, String id, String? siteId, String version
});



}
/// @nodoc
class __$SyncDeletionCopyWithImpl<$Res>
    implements _$SyncDeletionCopyWith<$Res> {
  __$SyncDeletionCopyWithImpl(this._self, this._then);

  final _SyncDeletion _self;
  final $Res Function(_SyncDeletion) _then;

/// Create a copy of SyncDeletion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entity = null,Object? id = null,Object? siteId = freezed,Object? version = null,}) {
  return _then(_SyncDeletion(
entity: null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
