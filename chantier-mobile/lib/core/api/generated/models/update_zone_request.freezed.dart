// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_zone_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateZoneRequest {

/// Version lue avec la zone ; une version périmée donne 409 `CONFLIT_VERSION`.
 String get version;/// Bloc du chantier (obligatoire).
 String get block;/// Cote en mètres, 2 décimales, de -20,00 à +60,00 (paramétrable).
 double? get elevation;/// Type de local (classe, couloir, cantine...).
 RoomType? get roomType;/// Numéro du local (1 à 999) ; exige un type de local.
 int? get roomNumber;/// Libellé libre, seulement si `roomType = Other`.
 String? get roomLabel;
/// Create a copy of UpdateZoneRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateZoneRequestCopyWith<UpdateZoneRequest> get copyWith => _$UpdateZoneRequestCopyWithImpl<UpdateZoneRequest>(this as UpdateZoneRequest, _$identity);

  /// Serializes this UpdateZoneRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateZoneRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.block, block) || other.block == block)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.roomLabel, roomLabel) || other.roomLabel == roomLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,block,elevation,roomType,roomNumber,roomLabel);

@override
String toString() {
  return 'UpdateZoneRequest(version: $version, block: $block, elevation: $elevation, roomType: $roomType, roomNumber: $roomNumber, roomLabel: $roomLabel)';
}


}

/// @nodoc
abstract mixin class $UpdateZoneRequestCopyWith<$Res>  {
  factory $UpdateZoneRequestCopyWith(UpdateZoneRequest value, $Res Function(UpdateZoneRequest) _then) = _$UpdateZoneRequestCopyWithImpl;
@useResult
$Res call({
 String version, String block, double? elevation, RoomType? roomType, int? roomNumber, String? roomLabel
});



}
/// @nodoc
class _$UpdateZoneRequestCopyWithImpl<$Res>
    implements $UpdateZoneRequestCopyWith<$Res> {
  _$UpdateZoneRequestCopyWithImpl(this._self, this._then);

  final UpdateZoneRequest _self;
  final $Res Function(UpdateZoneRequest) _then;

/// Create a copy of UpdateZoneRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? block = null,Object? elevation = freezed,Object? roomType = freezed,Object? roomNumber = freezed,Object? roomLabel = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as double?,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as RoomType?,roomNumber: freezed == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as int?,roomLabel: freezed == roomLabel ? _self.roomLabel : roomLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UpdateZoneRequest implements UpdateZoneRequest {
  const _UpdateZoneRequest({required this.version, required this.block, this.elevation, this.roomType, this.roomNumber, this.roomLabel});
  factory _UpdateZoneRequest.fromJson(Map<String, dynamic> json) => _$UpdateZoneRequestFromJson(json);

/// Version lue avec la zone ; une version périmée donne 409 `CONFLIT_VERSION`.
@override final  String version;
/// Bloc du chantier (obligatoire).
@override final  String block;
/// Cote en mètres, 2 décimales, de -20,00 à +60,00 (paramétrable).
@override final  double? elevation;
/// Type de local (classe, couloir, cantine...).
@override final  RoomType? roomType;
/// Numéro du local (1 à 999) ; exige un type de local.
@override final  int? roomNumber;
/// Libellé libre, seulement si `roomType = Other`.
@override final  String? roomLabel;

/// Create a copy of UpdateZoneRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateZoneRequestCopyWith<_UpdateZoneRequest> get copyWith => __$UpdateZoneRequestCopyWithImpl<_UpdateZoneRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateZoneRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateZoneRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.block, block) || other.block == block)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.roomLabel, roomLabel) || other.roomLabel == roomLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,block,elevation,roomType,roomNumber,roomLabel);

@override
String toString() {
  return 'UpdateZoneRequest(version: $version, block: $block, elevation: $elevation, roomType: $roomType, roomNumber: $roomNumber, roomLabel: $roomLabel)';
}


}

/// @nodoc
abstract mixin class _$UpdateZoneRequestCopyWith<$Res> implements $UpdateZoneRequestCopyWith<$Res> {
  factory _$UpdateZoneRequestCopyWith(_UpdateZoneRequest value, $Res Function(_UpdateZoneRequest) _then) = __$UpdateZoneRequestCopyWithImpl;
@override @useResult
$Res call({
 String version, String block, double? elevation, RoomType? roomType, int? roomNumber, String? roomLabel
});



}
/// @nodoc
class __$UpdateZoneRequestCopyWithImpl<$Res>
    implements _$UpdateZoneRequestCopyWith<$Res> {
  __$UpdateZoneRequestCopyWithImpl(this._self, this._then);

  final _UpdateZoneRequest _self;
  final $Res Function(_UpdateZoneRequest) _then;

/// Create a copy of UpdateZoneRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? block = null,Object? elevation = freezed,Object? roomType = freezed,Object? roomNumber = freezed,Object? roomLabel = freezed,}) {
  return _then(_UpdateZoneRequest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as double?,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as RoomType?,roomNumber: freezed == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as int?,roomLabel: freezed == roomLabel ? _self.roomLabel : roomLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
