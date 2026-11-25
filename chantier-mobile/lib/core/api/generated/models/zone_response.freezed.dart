// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zone_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ZoneResponse {

 String get id; String get siteId;/// Identifiant généré par le téléphone qui a créé la zone (création hors ligne), sinon `null`.
 String? get clientId;/// « Saisi le » du téléphone : information seulement, jamais utilisée pour trier ou décider.
 DateTime? get clientCreatedAt;/// Bloc, par exemple `Bloc 01`.
 String get block;/// Cote en mètres, 2 décimales (affichage signé côté client : −1,90 ; ±0,00 ; +3,40).
 double? get elevation;/// Type de local.
 RoomType? get roomType;/// Numéro du local (classe 02).
 int? get roomNumber;/// Libellé libre, seulement si le type est `Other`.
 String? get roomLabel;/// Date d'archivage ; une zone archivée n'est plus proposée à la saisie.
 DateTime? get archivedAt;/// Nom de la personne qui a archivé.
 String? get archivedByName;/// Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.
 String get version;/// Création (heure du serveur, UTC).
 DateTime get createdAt;/// Nom du créateur.
 String? get createdByName;/// Dernière modification (heure du serveur, UTC).
 DateTime? get updatedAt;/// Nom de la dernière personne ayant modifié.
 String? get updatedByName;
/// Create a copy of ZoneResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneResponseCopyWith<ZoneResponse> get copyWith => _$ZoneResponseCopyWithImpl<ZoneResponse>(this as ZoneResponse, _$identity);

  /// Serializes this ZoneResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZoneResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.block, block) || other.block == block)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.roomLabel, roomLabel) || other.roomLabel == roomLabel)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedByName, archivedByName) || other.archivedByName == archivedByName)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,siteId,clientId,clientCreatedAt,block,elevation,roomType,roomNumber,roomLabel,archivedAt,archivedByName,version,createdAt,createdByName,updatedAt,updatedByName);

@override
String toString() {
  return 'ZoneResponse(id: $id, siteId: $siteId, clientId: $clientId, clientCreatedAt: $clientCreatedAt, block: $block, elevation: $elevation, roomType: $roomType, roomNumber: $roomNumber, roomLabel: $roomLabel, archivedAt: $archivedAt, archivedByName: $archivedByName, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class $ZoneResponseCopyWith<$Res>  {
  factory $ZoneResponseCopyWith(ZoneResponse value, $Res Function(ZoneResponse) _then) = _$ZoneResponseCopyWithImpl;
@useResult
$Res call({
 String id, String siteId, String? clientId, DateTime? clientCreatedAt, String block, double? elevation, RoomType? roomType, int? roomNumber, String? roomLabel, DateTime? archivedAt, String? archivedByName, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class _$ZoneResponseCopyWithImpl<$Res>
    implements $ZoneResponseCopyWith<$Res> {
  _$ZoneResponseCopyWithImpl(this._self, this._then);

  final ZoneResponse _self;
  final $Res Function(ZoneResponse) _then;

/// Create a copy of ZoneResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? siteId = null,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? block = null,Object? elevation = freezed,Object? roomType = freezed,Object? roomNumber = freezed,Object? roomLabel = freezed,Object? archivedAt = freezed,Object? archivedByName = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as double?,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as RoomType?,roomNumber: freezed == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as int?,roomLabel: freezed == roomLabel ? _self.roomLabel : roomLabel // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedByName: freezed == archivedByName ? _self.archivedByName : archivedByName // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ZoneResponse implements ZoneResponse {
  const _ZoneResponse({required this.id, required this.siteId, required this.clientId, required this.clientCreatedAt, required this.block, required this.elevation, required this.roomType, required this.roomNumber, required this.roomLabel, required this.archivedAt, required this.archivedByName, required this.version, required this.createdAt, required this.createdByName, required this.updatedAt, required this.updatedByName});
  factory _ZoneResponse.fromJson(Map<String, dynamic> json) => _$ZoneResponseFromJson(json);

@override final  String id;
@override final  String siteId;
/// Identifiant généré par le téléphone qui a créé la zone (création hors ligne), sinon `null`.
@override final  String? clientId;
/// « Saisi le » du téléphone : information seulement, jamais utilisée pour trier ou décider.
@override final  DateTime? clientCreatedAt;
/// Bloc, par exemple `Bloc 01`.
@override final  String block;
/// Cote en mètres, 2 décimales (affichage signé côté client : −1,90 ; ±0,00 ; +3,40).
@override final  double? elevation;
/// Type de local.
@override final  RoomType? roomType;
/// Numéro du local (classe 02).
@override final  int? roomNumber;
/// Libellé libre, seulement si le type est `Other`.
@override final  String? roomLabel;
/// Date d'archivage ; une zone archivée n'est plus proposée à la saisie.
@override final  DateTime? archivedAt;
/// Nom de la personne qui a archivé.
@override final  String? archivedByName;
/// Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.
@override final  String version;
/// Création (heure du serveur, UTC).
@override final  DateTime createdAt;
/// Nom du créateur.
@override final  String? createdByName;
/// Dernière modification (heure du serveur, UTC).
@override final  DateTime? updatedAt;
/// Nom de la dernière personne ayant modifié.
@override final  String? updatedByName;

/// Create a copy of ZoneResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ZoneResponseCopyWith<_ZoneResponse> get copyWith => __$ZoneResponseCopyWithImpl<_ZoneResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ZoneResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ZoneResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.block, block) || other.block == block)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.roomLabel, roomLabel) || other.roomLabel == roomLabel)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedByName, archivedByName) || other.archivedByName == archivedByName)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,siteId,clientId,clientCreatedAt,block,elevation,roomType,roomNumber,roomLabel,archivedAt,archivedByName,version,createdAt,createdByName,updatedAt,updatedByName);

@override
String toString() {
  return 'ZoneResponse(id: $id, siteId: $siteId, clientId: $clientId, clientCreatedAt: $clientCreatedAt, block: $block, elevation: $elevation, roomType: $roomType, roomNumber: $roomNumber, roomLabel: $roomLabel, archivedAt: $archivedAt, archivedByName: $archivedByName, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class _$ZoneResponseCopyWith<$Res> implements $ZoneResponseCopyWith<$Res> {
  factory _$ZoneResponseCopyWith(_ZoneResponse value, $Res Function(_ZoneResponse) _then) = __$ZoneResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String siteId, String? clientId, DateTime? clientCreatedAt, String block, double? elevation, RoomType? roomType, int? roomNumber, String? roomLabel, DateTime? archivedAt, String? archivedByName, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class __$ZoneResponseCopyWithImpl<$Res>
    implements _$ZoneResponseCopyWith<$Res> {
  __$ZoneResponseCopyWithImpl(this._self, this._then);

  final _ZoneResponse _self;
  final $Res Function(_ZoneResponse) _then;

/// Create a copy of ZoneResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? siteId = null,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? block = null,Object? elevation = freezed,Object? roomType = freezed,Object? roomNumber = freezed,Object? roomLabel = freezed,Object? archivedAt = freezed,Object? archivedByName = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_ZoneResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as double?,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as RoomType?,roomNumber: freezed == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as int?,roomLabel: freezed == roomLabel ? _self.roomLabel : roomLabel // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedByName: freezed == archivedByName ? _self.archivedByName : archivedByName // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
