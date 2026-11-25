// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_site_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateSiteRequest {

/// Version lue avec le chantier ; une version périmée donne 409 `CONFLIT_VERSION`.
 String get version;/// Nom du chantier (français).
 String get name;/// Type d'ouvrage.
 SiteType? get type;/// Wilaya (liste de référence).
 String get wilaya;/// Commune (liste de la wilaya ; une saisie libre est acceptée).
 String get commune;/// Maître d'ouvrage.
 String get owner;/// Nom en arabe (facultatif) : affiché à la place du nom français s'il est présent.
 String? get nameAr;/// Latitude en degrés décimaux (va avec la longitude).
 double? get latitude;/// Longitude en degrés décimaux (va avec la latitude).
 double? get longitude;/// Numéro du marché.
 String? get contractNumber;/// Montant du marché en DZD, 2 décimales.
 double? get contractAmount;/// Délai en jours calendaires (entier supérieur à 0).
 int? get delayDays;/// Date complète de l'ordre de service de démarrage ; une date incomplète (`../03/2026`) donne `DATE_INVALIDE`.
 DateTime? get odsDate;
/// Create a copy of UpdateSiteRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateSiteRequestCopyWith<UpdateSiteRequest> get copyWith => _$UpdateSiteRequestCopyWithImpl<UpdateSiteRequest>(this as UpdateSiteRequest, _$identity);

  /// Serializes this UpdateSiteRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateSiteRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.wilaya, wilaya) || other.wilaya == wilaya)&&(identical(other.commune, commune) || other.commune == commune)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.contractNumber, contractNumber) || other.contractNumber == contractNumber)&&(identical(other.contractAmount, contractAmount) || other.contractAmount == contractAmount)&&(identical(other.delayDays, delayDays) || other.delayDays == delayDays)&&(identical(other.odsDate, odsDate) || other.odsDate == odsDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,name,type,wilaya,commune,owner,nameAr,latitude,longitude,contractNumber,contractAmount,delayDays,odsDate);

@override
String toString() {
  return 'UpdateSiteRequest(version: $version, name: $name, type: $type, wilaya: $wilaya, commune: $commune, owner: $owner, nameAr: $nameAr, latitude: $latitude, longitude: $longitude, contractNumber: $contractNumber, contractAmount: $contractAmount, delayDays: $delayDays, odsDate: $odsDate)';
}


}

/// @nodoc
abstract mixin class $UpdateSiteRequestCopyWith<$Res>  {
  factory $UpdateSiteRequestCopyWith(UpdateSiteRequest value, $Res Function(UpdateSiteRequest) _then) = _$UpdateSiteRequestCopyWithImpl;
@useResult
$Res call({
 String version, String name, SiteType? type, String wilaya, String commune, String owner, String? nameAr, double? latitude, double? longitude, String? contractNumber, double? contractAmount, int? delayDays, DateTime? odsDate
});



}
/// @nodoc
class _$UpdateSiteRequestCopyWithImpl<$Res>
    implements $UpdateSiteRequestCopyWith<$Res> {
  _$UpdateSiteRequestCopyWithImpl(this._self, this._then);

  final UpdateSiteRequest _self;
  final $Res Function(UpdateSiteRequest) _then;

/// Create a copy of UpdateSiteRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? name = null,Object? type = freezed,Object? wilaya = null,Object? commune = null,Object? owner = null,Object? nameAr = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? contractNumber = freezed,Object? contractAmount = freezed,Object? delayDays = freezed,Object? odsDate = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SiteType?,wilaya: null == wilaya ? _self.wilaya : wilaya // ignore: cast_nullable_to_non_nullable
as String,commune: null == commune ? _self.commune : commune // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,contractNumber: freezed == contractNumber ? _self.contractNumber : contractNumber // ignore: cast_nullable_to_non_nullable
as String?,contractAmount: freezed == contractAmount ? _self.contractAmount : contractAmount // ignore: cast_nullable_to_non_nullable
as double?,delayDays: freezed == delayDays ? _self.delayDays : delayDays // ignore: cast_nullable_to_non_nullable
as int?,odsDate: freezed == odsDate ? _self.odsDate : odsDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UpdateSiteRequest implements UpdateSiteRequest {
  const _UpdateSiteRequest({required this.version, required this.name, required this.type, required this.wilaya, required this.commune, required this.owner, this.nameAr, this.latitude, this.longitude, this.contractNumber, this.contractAmount, this.delayDays, this.odsDate});
  factory _UpdateSiteRequest.fromJson(Map<String, dynamic> json) => _$UpdateSiteRequestFromJson(json);

/// Version lue avec le chantier ; une version périmée donne 409 `CONFLIT_VERSION`.
@override final  String version;
/// Nom du chantier (français).
@override final  String name;
/// Type d'ouvrage.
@override final  SiteType? type;
/// Wilaya (liste de référence).
@override final  String wilaya;
/// Commune (liste de la wilaya ; une saisie libre est acceptée).
@override final  String commune;
/// Maître d'ouvrage.
@override final  String owner;
/// Nom en arabe (facultatif) : affiché à la place du nom français s'il est présent.
@override final  String? nameAr;
/// Latitude en degrés décimaux (va avec la longitude).
@override final  double? latitude;
/// Longitude en degrés décimaux (va avec la latitude).
@override final  double? longitude;
/// Numéro du marché.
@override final  String? contractNumber;
/// Montant du marché en DZD, 2 décimales.
@override final  double? contractAmount;
/// Délai en jours calendaires (entier supérieur à 0).
@override final  int? delayDays;
/// Date complète de l'ordre de service de démarrage ; une date incomplète (`../03/2026`) donne `DATE_INVALIDE`.
@override final  DateTime? odsDate;

/// Create a copy of UpdateSiteRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateSiteRequestCopyWith<_UpdateSiteRequest> get copyWith => __$UpdateSiteRequestCopyWithImpl<_UpdateSiteRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateSiteRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateSiteRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.wilaya, wilaya) || other.wilaya == wilaya)&&(identical(other.commune, commune) || other.commune == commune)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.contractNumber, contractNumber) || other.contractNumber == contractNumber)&&(identical(other.contractAmount, contractAmount) || other.contractAmount == contractAmount)&&(identical(other.delayDays, delayDays) || other.delayDays == delayDays)&&(identical(other.odsDate, odsDate) || other.odsDate == odsDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,name,type,wilaya,commune,owner,nameAr,latitude,longitude,contractNumber,contractAmount,delayDays,odsDate);

@override
String toString() {
  return 'UpdateSiteRequest(version: $version, name: $name, type: $type, wilaya: $wilaya, commune: $commune, owner: $owner, nameAr: $nameAr, latitude: $latitude, longitude: $longitude, contractNumber: $contractNumber, contractAmount: $contractAmount, delayDays: $delayDays, odsDate: $odsDate)';
}


}

/// @nodoc
abstract mixin class _$UpdateSiteRequestCopyWith<$Res> implements $UpdateSiteRequestCopyWith<$Res> {
  factory _$UpdateSiteRequestCopyWith(_UpdateSiteRequest value, $Res Function(_UpdateSiteRequest) _then) = __$UpdateSiteRequestCopyWithImpl;
@override @useResult
$Res call({
 String version, String name, SiteType? type, String wilaya, String commune, String owner, String? nameAr, double? latitude, double? longitude, String? contractNumber, double? contractAmount, int? delayDays, DateTime? odsDate
});



}
/// @nodoc
class __$UpdateSiteRequestCopyWithImpl<$Res>
    implements _$UpdateSiteRequestCopyWith<$Res> {
  __$UpdateSiteRequestCopyWithImpl(this._self, this._then);

  final _UpdateSiteRequest _self;
  final $Res Function(_UpdateSiteRequest) _then;

/// Create a copy of UpdateSiteRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? name = null,Object? type = freezed,Object? wilaya = null,Object? commune = null,Object? owner = null,Object? nameAr = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? contractNumber = freezed,Object? contractAmount = freezed,Object? delayDays = freezed,Object? odsDate = freezed,}) {
  return _then(_UpdateSiteRequest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SiteType?,wilaya: null == wilaya ? _self.wilaya : wilaya // ignore: cast_nullable_to_non_nullable
as String,commune: null == commune ? _self.commune : commune // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,contractNumber: freezed == contractNumber ? _self.contractNumber : contractNumber // ignore: cast_nullable_to_non_nullable
as String?,contractAmount: freezed == contractAmount ? _self.contractAmount : contractAmount // ignore: cast_nullable_to_non_nullable
as double?,delayDays: freezed == delayDays ? _self.delayDays : delayDays // ignore: cast_nullable_to_non_nullable
as int?,odsDate: freezed == odsDate ? _self.odsDate : odsDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
