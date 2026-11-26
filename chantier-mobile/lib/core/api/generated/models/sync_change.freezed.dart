// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncChange {

/// `site`, `zone` ou `member` ; un client ignore une entité qu'il ne connaît pas.
 String get entity;/// Identifiant de la ligne.
 String get id;/// Chantier de la ligne (pour un chantier : son propre identifiant) ; `null` pour une entité globale (`product`, `supplier`).
 String? get siteId;/// Version serveur (entier décimal en chaîne) : n'appliquer la ligne que si elle est plus grande que celle déjà connue.
 String get version;/// Ressource de la ligne, selon `entity` : `SiteResponse` (site), `ZoneResponse` (zone), `SyncMemberData` (member), `ProductResponse` (product), `SupplierSyncData` (supplier, sans téléphone), `RequestSyncData` (request, sans champ commercial), `DeliverySyncData` (delivery, sans montant ni photos) ou `PhotoResponse` (photo, métadonnées seulement).
 dynamic get data;
/// Create a copy of SyncChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncChangeCopyWith<SyncChange> get copyWith => _$SyncChangeCopyWithImpl<SyncChange>(this as SyncChange, _$identity);

  /// Serializes this SyncChange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncChange&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entity,id,siteId,version,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'SyncChange(entity: $entity, id: $id, siteId: $siteId, version: $version, data: $data)';
}


}

/// @nodoc
abstract mixin class $SyncChangeCopyWith<$Res>  {
  factory $SyncChangeCopyWith(SyncChange value, $Res Function(SyncChange) _then) = _$SyncChangeCopyWithImpl;
@useResult
$Res call({
 String entity, String id, String? siteId, String version, dynamic data
});



}
/// @nodoc
class _$SyncChangeCopyWithImpl<$Res>
    implements $SyncChangeCopyWith<$Res> {
  _$SyncChangeCopyWithImpl(this._self, this._then);

  final SyncChange _self;
  final $Res Function(SyncChange) _then;

/// Create a copy of SyncChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entity = null,Object? id = null,Object? siteId = freezed,Object? version = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
entity: null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SyncChange implements SyncChange {
  const _SyncChange({required this.entity, required this.id, required this.siteId, required this.version, required this.data});
  factory _SyncChange.fromJson(Map<String, dynamic> json) => _$SyncChangeFromJson(json);

/// `site`, `zone` ou `member` ; un client ignore une entité qu'il ne connaît pas.
@override final  String entity;
/// Identifiant de la ligne.
@override final  String id;
/// Chantier de la ligne (pour un chantier : son propre identifiant) ; `null` pour une entité globale (`product`, `supplier`).
@override final  String? siteId;
/// Version serveur (entier décimal en chaîne) : n'appliquer la ligne que si elle est plus grande que celle déjà connue.
@override final  String version;
/// Ressource de la ligne, selon `entity` : `SiteResponse` (site), `ZoneResponse` (zone), `SyncMemberData` (member), `ProductResponse` (product), `SupplierSyncData` (supplier, sans téléphone), `RequestSyncData` (request, sans champ commercial), `DeliverySyncData` (delivery, sans montant ni photos) ou `PhotoResponse` (photo, métadonnées seulement).
@override final  dynamic data;

/// Create a copy of SyncChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncChangeCopyWith<_SyncChange> get copyWith => __$SyncChangeCopyWithImpl<_SyncChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncChange&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entity,id,siteId,version,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'SyncChange(entity: $entity, id: $id, siteId: $siteId, version: $version, data: $data)';
}


}

/// @nodoc
abstract mixin class _$SyncChangeCopyWith<$Res> implements $SyncChangeCopyWith<$Res> {
  factory _$SyncChangeCopyWith(_SyncChange value, $Res Function(_SyncChange) _then) = __$SyncChangeCopyWithImpl;
@override @useResult
$Res call({
 String entity, String id, String? siteId, String version, dynamic data
});



}
/// @nodoc
class __$SyncChangeCopyWithImpl<$Res>
    implements _$SyncChangeCopyWith<$Res> {
  __$SyncChangeCopyWithImpl(this._self, this._then);

  final _SyncChange _self;
  final $Res Function(_SyncChange) _then;

/// Create a copy of SyncChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entity = null,Object? id = null,Object? siteId = freezed,Object? version = null,Object? data = freezed,}) {
  return _then(_SyncChange(
entity: null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
