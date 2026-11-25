// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_zone_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateZoneRequest {

/// Bloc du chantier (obligatoire).
 String get block;/// Identifiant généré par le téléphone : un renvoi avec le même `clientId` donne 200 et la même zone.
 String? get clientId;/// Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider.
 DateTime? get clientCreatedAt;/// Cote en mètres, 2 décimales, de -20,00 à +60,00 (paramétrable).
 double? get elevation;/// Type de local (classe, couloir, cantine...).
 RoomType? get roomType;/// Numéro du local (1 à 999) ; exige un type de local.
 int? get roomNumber;/// Libellé libre, seulement si `roomType = Other`.
 String? get roomLabel;
/// Create a copy of CreateZoneRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateZoneRequestCopyWith<CreateZoneRequest> get copyWith => _$CreateZoneRequestCopyWithImpl<CreateZoneRequest>(this as CreateZoneRequest, _$identity);

  /// Serializes this CreateZoneRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateZoneRequest&&(identical(other.block, block) || other.block == block)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.roomLabel, roomLabel) || other.roomLabel == roomLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,block,clientId,clientCreatedAt,elevation,roomType,roomNumber,roomLabel);

@override
String toString() {
  return 'CreateZoneRequest(block: $block, clientId: $clientId, clientCreatedAt: $clientCreatedAt, elevation: $elevation, roomType: $roomType, roomNumber: $roomNumber, roomLabel: $roomLabel)';
}


}

/// @nodoc
abstract mixin class $CreateZoneRequestCopyWith<$Res>  {
  factory $CreateZoneRequestCopyWith(CreateZoneRequest value, $Res Function(CreateZoneRequest) _then) = _$CreateZoneRequestCopyWithImpl;
@useResult
$Res call({
 String block, String? clientId, DateTime? clientCreatedAt, double? elevation, RoomType? roomType, int? roomNumber, String? roomLabel
});



}
/// @nodoc
class _$CreateZoneRequestCopyWithImpl<$Res>
    implements $CreateZoneRequestCopyWith<$Res> {
  _$CreateZoneRequestCopyWithImpl(this._self, this._then);

  final CreateZoneRequest _self;
  final $Res Function(CreateZoneRequest) _then;

/// Create a copy of CreateZoneRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? block = null,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? elevation = freezed,Object? roomType = freezed,Object? roomNumber = freezed,Object? roomLabel = freezed,}) {
  return _then(_self.copyWith(
block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as double?,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as RoomType?,roomNumber: freezed == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as int?,roomLabel: freezed == roomLabel ? _self.roomLabel : roomLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CreateZoneRequest implements CreateZoneRequest {
  const _CreateZoneRequest({required this.block, this.clientId, this.clientCreatedAt, this.elevation, this.roomType, this.roomNumber, this.roomLabel});
  factory _CreateZoneRequest.fromJson(Map<String, dynamic> json) => _$CreateZoneRequestFromJson(json);

/// Bloc du chantier (obligatoire).
@override final  String block;
/// Identifiant généré par le téléphone : un renvoi avec le même `clientId` donne 200 et la même zone.
@override final  String? clientId;
/// Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider.
@override final  DateTime? clientCreatedAt;
/// Cote en mètres, 2 décimales, de -20,00 à +60,00 (paramétrable).
@override final  double? elevation;
/// Type de local (classe, couloir, cantine...).
@override final  RoomType? roomType;
/// Numéro du local (1 à 999) ; exige un type de local.
@override final  int? roomNumber;
/// Libellé libre, seulement si `roomType = Other`.
@override final  String? roomLabel;

/// Create a copy of CreateZoneRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateZoneRequestCopyWith<_CreateZoneRequest> get copyWith => __$CreateZoneRequestCopyWithImpl<_CreateZoneRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateZoneRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateZoneRequest&&(identical(other.block, block) || other.block == block)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.roomLabel, roomLabel) || other.roomLabel == roomLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,block,clientId,clientCreatedAt,elevation,roomType,roomNumber,roomLabel);

@override
String toString() {
  return 'CreateZoneRequest(block: $block, clientId: $clientId, clientCreatedAt: $clientCreatedAt, elevation: $elevation, roomType: $roomType, roomNumber: $roomNumber, roomLabel: $roomLabel)';
}


}

/// @nodoc
abstract mixin class _$CreateZoneRequestCopyWith<$Res> implements $CreateZoneRequestCopyWith<$Res> {
  factory _$CreateZoneRequestCopyWith(_CreateZoneRequest value, $Res Function(_CreateZoneRequest) _then) = __$CreateZoneRequestCopyWithImpl;
@override @useResult
$Res call({
 String block, String? clientId, DateTime? clientCreatedAt, double? elevation, RoomType? roomType, int? roomNumber, String? roomLabel
});



}
/// @nodoc
class __$CreateZoneRequestCopyWithImpl<$Res>
    implements _$CreateZoneRequestCopyWith<$Res> {
  __$CreateZoneRequestCopyWithImpl(this._self, this._then);

  final _CreateZoneRequest _self;
  final $Res Function(_CreateZoneRequest) _then;

/// Create a copy of CreateZoneRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? block = null,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? elevation = freezed,Object? roomType = freezed,Object? roomNumber = freezed,Object? roomLabel = freezed,}) {
  return _then(_CreateZoneRequest(
block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as double?,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as RoomType?,roomNumber: freezed == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as int?,roomLabel: freezed == roomLabel ? _self.roomLabel : roomLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
