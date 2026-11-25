// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SiteResponse {

 String get id;/// Code unique et immuable, par exemple `CH-ECO-UV18`.
 String get code; String get name;/// Nom en arabe, s'il existe.
 String? get nameAr; SiteType get type; String get wilaya; String get commune; double? get latitude; double? get longitude; String get owner; String? get contractNumber;/// Délai contractuel en jours calendaires.
 int? get delayDays;/// Date de l'ordre de service de démarrage.
 DateTime? get odsDate;/// Fin contractuelle = date de l'ODS + délai, calculée par le serveur ; `null` si l'un des deux manque (« À définir »).
 DateTime? get contractualEndDate;/// Date d'archivage ; un chantier archivé est en lecture seule.
 DateTime? get archivedAt;/// Nom de la personne qui a archivé.
 String? get archivedByName;/// Jeton de concurrence (entier décimal en chaîne), à renvoyer à la modification.
 String get version;/// Création (heure du serveur, UTC).
 DateTime get createdAt;/// Nom du créateur.
 String? get createdByName;/// Dernière modification (heure du serveur, UTC).
 DateTime? get updatedAt;/// Nom de la dernière personne ayant modifié.
 String? get updatedByName;/// Montant du marché en DZD (2 décimales) ; absent sans la permission `ContractAmount.View`.
 double? get contractAmount;
/// Create a copy of SiteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteResponseCopyWith<SiteResponse> get copyWith => _$SiteResponseCopyWithImpl<SiteResponse>(this as SiteResponse, _$identity);

  /// Serializes this SiteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.type, type) || other.type == type)&&(identical(other.wilaya, wilaya) || other.wilaya == wilaya)&&(identical(other.commune, commune) || other.commune == commune)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.contractNumber, contractNumber) || other.contractNumber == contractNumber)&&(identical(other.delayDays, delayDays) || other.delayDays == delayDays)&&(identical(other.odsDate, odsDate) || other.odsDate == odsDate)&&(identical(other.contractualEndDate, contractualEndDate) || other.contractualEndDate == contractualEndDate)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedByName, archivedByName) || other.archivedByName == archivedByName)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName)&&(identical(other.contractAmount, contractAmount) || other.contractAmount == contractAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,name,nameAr,type,wilaya,commune,latitude,longitude,owner,contractNumber,delayDays,odsDate,contractualEndDate,archivedAt,archivedByName,version,createdAt,createdByName,updatedAt,updatedByName,contractAmount]);

@override
String toString() {
  return 'SiteResponse(id: $id, code: $code, name: $name, nameAr: $nameAr, type: $type, wilaya: $wilaya, commune: $commune, latitude: $latitude, longitude: $longitude, owner: $owner, contractNumber: $contractNumber, delayDays: $delayDays, odsDate: $odsDate, contractualEndDate: $contractualEndDate, archivedAt: $archivedAt, archivedByName: $archivedByName, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName, contractAmount: $contractAmount)';
}


}

/// @nodoc
abstract mixin class $SiteResponseCopyWith<$Res>  {
  factory $SiteResponseCopyWith(SiteResponse value, $Res Function(SiteResponse) _then) = _$SiteResponseCopyWithImpl;
@useResult
$Res call({
 String id, String code, String name, String? nameAr, SiteType type, String wilaya, String commune, double? latitude, double? longitude, String owner, String? contractNumber, int? delayDays, DateTime? odsDate, DateTime? contractualEndDate, DateTime? archivedAt, String? archivedByName, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName, double? contractAmount
});



}
/// @nodoc
class _$SiteResponseCopyWithImpl<$Res>
    implements $SiteResponseCopyWith<$Res> {
  _$SiteResponseCopyWithImpl(this._self, this._then);

  final SiteResponse _self;
  final $Res Function(SiteResponse) _then;

/// Create a copy of SiteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? nameAr = freezed,Object? type = null,Object? wilaya = null,Object? commune = null,Object? latitude = freezed,Object? longitude = freezed,Object? owner = null,Object? contractNumber = freezed,Object? delayDays = freezed,Object? odsDate = freezed,Object? contractualEndDate = freezed,Object? archivedAt = freezed,Object? archivedByName = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,Object? contractAmount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SiteType,wilaya: null == wilaya ? _self.wilaya : wilaya // ignore: cast_nullable_to_non_nullable
as String,commune: null == commune ? _self.commune : commune // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,contractNumber: freezed == contractNumber ? _self.contractNumber : contractNumber // ignore: cast_nullable_to_non_nullable
as String?,delayDays: freezed == delayDays ? _self.delayDays : delayDays // ignore: cast_nullable_to_non_nullable
as int?,odsDate: freezed == odsDate ? _self.odsDate : odsDate // ignore: cast_nullable_to_non_nullable
as DateTime?,contractualEndDate: freezed == contractualEndDate ? _self.contractualEndDate : contractualEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedByName: freezed == archivedByName ? _self.archivedByName : archivedByName // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,contractAmount: freezed == contractAmount ? _self.contractAmount : contractAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SiteResponse implements SiteResponse {
  const _SiteResponse({required this.id, required this.code, required this.name, required this.nameAr, required this.type, required this.wilaya, required this.commune, required this.latitude, required this.longitude, required this.owner, required this.contractNumber, required this.delayDays, required this.odsDate, required this.contractualEndDate, required this.archivedAt, required this.archivedByName, required this.version, required this.createdAt, required this.createdByName, required this.updatedAt, required this.updatedByName, this.contractAmount});
  factory _SiteResponse.fromJson(Map<String, dynamic> json) => _$SiteResponseFromJson(json);

@override final  String id;
/// Code unique et immuable, par exemple `CH-ECO-UV18`.
@override final  String code;
@override final  String name;
/// Nom en arabe, s'il existe.
@override final  String? nameAr;
@override final  SiteType type;
@override final  String wilaya;
@override final  String commune;
@override final  double? latitude;
@override final  double? longitude;
@override final  String owner;
@override final  String? contractNumber;
/// Délai contractuel en jours calendaires.
@override final  int? delayDays;
/// Date de l'ordre de service de démarrage.
@override final  DateTime? odsDate;
/// Fin contractuelle = date de l'ODS + délai, calculée par le serveur ; `null` si l'un des deux manque (« À définir »).
@override final  DateTime? contractualEndDate;
/// Date d'archivage ; un chantier archivé est en lecture seule.
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
/// Montant du marché en DZD (2 décimales) ; absent sans la permission `ContractAmount.View`.
@override final  double? contractAmount;

/// Create a copy of SiteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteResponseCopyWith<_SiteResponse> get copyWith => __$SiteResponseCopyWithImpl<_SiteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.type, type) || other.type == type)&&(identical(other.wilaya, wilaya) || other.wilaya == wilaya)&&(identical(other.commune, commune) || other.commune == commune)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.contractNumber, contractNumber) || other.contractNumber == contractNumber)&&(identical(other.delayDays, delayDays) || other.delayDays == delayDays)&&(identical(other.odsDate, odsDate) || other.odsDate == odsDate)&&(identical(other.contractualEndDate, contractualEndDate) || other.contractualEndDate == contractualEndDate)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedByName, archivedByName) || other.archivedByName == archivedByName)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName)&&(identical(other.contractAmount, contractAmount) || other.contractAmount == contractAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,name,nameAr,type,wilaya,commune,latitude,longitude,owner,contractNumber,delayDays,odsDate,contractualEndDate,archivedAt,archivedByName,version,createdAt,createdByName,updatedAt,updatedByName,contractAmount]);

@override
String toString() {
  return 'SiteResponse(id: $id, code: $code, name: $name, nameAr: $nameAr, type: $type, wilaya: $wilaya, commune: $commune, latitude: $latitude, longitude: $longitude, owner: $owner, contractNumber: $contractNumber, delayDays: $delayDays, odsDate: $odsDate, contractualEndDate: $contractualEndDate, archivedAt: $archivedAt, archivedByName: $archivedByName, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName, contractAmount: $contractAmount)';
}


}

/// @nodoc
abstract mixin class _$SiteResponseCopyWith<$Res> implements $SiteResponseCopyWith<$Res> {
  factory _$SiteResponseCopyWith(_SiteResponse value, $Res Function(_SiteResponse) _then) = __$SiteResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String name, String? nameAr, SiteType type, String wilaya, String commune, double? latitude, double? longitude, String owner, String? contractNumber, int? delayDays, DateTime? odsDate, DateTime? contractualEndDate, DateTime? archivedAt, String? archivedByName, String version, DateTime createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName, double? contractAmount
});



}
/// @nodoc
class __$SiteResponseCopyWithImpl<$Res>
    implements _$SiteResponseCopyWith<$Res> {
  __$SiteResponseCopyWithImpl(this._self, this._then);

  final _SiteResponse _self;
  final $Res Function(_SiteResponse) _then;

/// Create a copy of SiteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? nameAr = freezed,Object? type = null,Object? wilaya = null,Object? commune = null,Object? latitude = freezed,Object? longitude = freezed,Object? owner = null,Object? contractNumber = freezed,Object? delayDays = freezed,Object? odsDate = freezed,Object? contractualEndDate = freezed,Object? archivedAt = freezed,Object? archivedByName = freezed,Object? version = null,Object? createdAt = null,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,Object? contractAmount = freezed,}) {
  return _then(_SiteResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SiteType,wilaya: null == wilaya ? _self.wilaya : wilaya // ignore: cast_nullable_to_non_nullable
as String,commune: null == commune ? _self.commune : commune // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,contractNumber: freezed == contractNumber ? _self.contractNumber : contractNumber // ignore: cast_nullable_to_non_nullable
as String?,delayDays: freezed == delayDays ? _self.delayDays : delayDays // ignore: cast_nullable_to_non_nullable
as int?,odsDate: freezed == odsDate ? _self.odsDate : odsDate // ignore: cast_nullable_to_non_nullable
as DateTime?,contractualEndDate: freezed == contractualEndDate ? _self.contractualEndDate : contractualEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedByName: freezed == archivedByName ? _self.archivedByName : archivedByName // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,contractAmount: freezed == contractAmount ? _self.contractAmount : contractAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
