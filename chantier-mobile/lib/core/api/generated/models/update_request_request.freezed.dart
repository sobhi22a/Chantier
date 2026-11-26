// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_request_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateRequestRequest {

/// Version lue avec la demande.
 String get version;/// Produit du catalogue ; écarte le nom libre. Verrouillé après la validation (422 `DEMANDE_VERROUILLEE`).
 String? get productId;/// Nom libre ; écarte le produit du catalogue. Verrouillé après la validation.
 String? get freeProductName;/// Quantité et unité. Verrouillées après la validation.
 QuantityBody? get quantity;/// Zone. Verrouillée après la validation.
 String? get zoneId;/// Date de besoin : modifiable jusqu'à la livraison (droit `Requests.UpdateAny` après la validation).
 DateTime? get neededBy; Priority? get priority;/// Remarque ; une chaîne vide l'efface.
 String? get note;
/// Create a copy of UpdateRequestRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateRequestRequestCopyWith<UpdateRequestRequest> get copyWith => _$UpdateRequestRequestCopyWithImpl<UpdateRequestRequest>(this as UpdateRequestRequest, _$identity);

  /// Serializes this UpdateRequestRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateRequestRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.freeProductName, freeProductName) || other.freeProductName == freeProductName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,productId,freeProductName,quantity,zoneId,neededBy,priority,note);

@override
String toString() {
  return 'UpdateRequestRequest(version: $version, productId: $productId, freeProductName: $freeProductName, quantity: $quantity, zoneId: $zoneId, neededBy: $neededBy, priority: $priority, note: $note)';
}


}

/// @nodoc
abstract mixin class $UpdateRequestRequestCopyWith<$Res>  {
  factory $UpdateRequestRequestCopyWith(UpdateRequestRequest value, $Res Function(UpdateRequestRequest) _then) = _$UpdateRequestRequestCopyWithImpl;
@useResult
$Res call({
 String version, String? productId, String? freeProductName, QuantityBody? quantity, String? zoneId, DateTime? neededBy, Priority? priority, String? note
});



}
/// @nodoc
class _$UpdateRequestRequestCopyWithImpl<$Res>
    implements $UpdateRequestRequestCopyWith<$Res> {
  _$UpdateRequestRequestCopyWithImpl(this._self, this._then);

  final UpdateRequestRequest _self;
  final $Res Function(UpdateRequestRequest) _then;

/// Create a copy of UpdateRequestRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? productId = freezed,Object? freeProductName = freezed,Object? quantity = freezed,Object? zoneId = freezed,Object? neededBy = freezed,Object? priority = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,freeProductName: freezed == freeProductName ? _self.freeProductName : freeProductName // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,neededBy: freezed == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UpdateRequestRequest implements UpdateRequestRequest {
  const _UpdateRequestRequest({required this.version, this.productId, this.freeProductName, this.quantity, this.zoneId, this.neededBy, this.priority, this.note});
  factory _UpdateRequestRequest.fromJson(Map<String, dynamic> json) => _$UpdateRequestRequestFromJson(json);

/// Version lue avec la demande.
@override final  String version;
/// Produit du catalogue ; écarte le nom libre. Verrouillé après la validation (422 `DEMANDE_VERROUILLEE`).
@override final  String? productId;
/// Nom libre ; écarte le produit du catalogue. Verrouillé après la validation.
@override final  String? freeProductName;
/// Quantité et unité. Verrouillées après la validation.
@override final  QuantityBody? quantity;
/// Zone. Verrouillée après la validation.
@override final  String? zoneId;
/// Date de besoin : modifiable jusqu'à la livraison (droit `Requests.UpdateAny` après la validation).
@override final  DateTime? neededBy;
@override final  Priority? priority;
/// Remarque ; une chaîne vide l'efface.
@override final  String? note;

/// Create a copy of UpdateRequestRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateRequestRequestCopyWith<_UpdateRequestRequest> get copyWith => __$UpdateRequestRequestCopyWithImpl<_UpdateRequestRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateRequestRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateRequestRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.freeProductName, freeProductName) || other.freeProductName == freeProductName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,productId,freeProductName,quantity,zoneId,neededBy,priority,note);

@override
String toString() {
  return 'UpdateRequestRequest(version: $version, productId: $productId, freeProductName: $freeProductName, quantity: $quantity, zoneId: $zoneId, neededBy: $neededBy, priority: $priority, note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpdateRequestRequestCopyWith<$Res> implements $UpdateRequestRequestCopyWith<$Res> {
  factory _$UpdateRequestRequestCopyWith(_UpdateRequestRequest value, $Res Function(_UpdateRequestRequest) _then) = __$UpdateRequestRequestCopyWithImpl;
@override @useResult
$Res call({
 String version, String? productId, String? freeProductName, QuantityBody? quantity, String? zoneId, DateTime? neededBy, Priority? priority, String? note
});



}
/// @nodoc
class __$UpdateRequestRequestCopyWithImpl<$Res>
    implements _$UpdateRequestRequestCopyWith<$Res> {
  __$UpdateRequestRequestCopyWithImpl(this._self, this._then);

  final _UpdateRequestRequest _self;
  final $Res Function(_UpdateRequestRequest) _then;

/// Create a copy of UpdateRequestRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? productId = freezed,Object? freeProductName = freezed,Object? quantity = freezed,Object? zoneId = freezed,Object? neededBy = freezed,Object? priority = freezed,Object? note = freezed,}) {
  return _then(_UpdateRequestRequest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,freeProductName: freezed == freeProductName ? _self.freeProductName : freeProductName // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,neededBy: freezed == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
