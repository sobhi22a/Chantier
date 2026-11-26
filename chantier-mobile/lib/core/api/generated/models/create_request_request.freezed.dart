// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_request_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateRequestRequest {

/// Quantité demandée avec son unité (une unité autorisée du produit).
 QuantityBody? get quantity;/// Identifiant généré par le téléphone : un renvoi avec le même `clientId` donne 200 et la même demande, sans nouveau numéro.
 String? get clientId;/// Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider.
 DateTime? get clientCreatedAt;/// Produit du catalogue (actif). Exactement un de `productId` et `freeProductName`.
 String? get productId;/// « Autre produit » : nom libre de 3 à 100 caractères.
 String? get freeProductName;/// Zone du chantier (facultative) ; 422 `ZONE_HORS_CHANTIER` si elle appartient à un autre chantier.
 String? get zoneId;/// Date de besoin complète (« pour le ») ; une date passée est acceptée (avertissement côté client).
 DateTime? get neededBy;/// `Normal` (défaut), `Urgent` ou `Blocking` (le chantier s'arrête).
 Priority? get priority;/// Usage ou remarque (200 caractères au plus).
 String? get note;
/// Create a copy of CreateRequestRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRequestRequestCopyWith<CreateRequestRequest> get copyWith => _$CreateRequestRequestCopyWithImpl<CreateRequestRequest>(this as CreateRequestRequest, _$identity);

  /// Serializes this CreateRequestRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRequestRequest&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.freeProductName, freeProductName) || other.freeProductName == freeProductName)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quantity,clientId,clientCreatedAt,productId,freeProductName,zoneId,neededBy,priority,note);

@override
String toString() {
  return 'CreateRequestRequest(quantity: $quantity, clientId: $clientId, clientCreatedAt: $clientCreatedAt, productId: $productId, freeProductName: $freeProductName, zoneId: $zoneId, neededBy: $neededBy, priority: $priority, note: $note)';
}


}

/// @nodoc
abstract mixin class $CreateRequestRequestCopyWith<$Res>  {
  factory $CreateRequestRequestCopyWith(CreateRequestRequest value, $Res Function(CreateRequestRequest) _then) = _$CreateRequestRequestCopyWithImpl;
@useResult
$Res call({
 QuantityBody? quantity, String? clientId, DateTime? clientCreatedAt, String? productId, String? freeProductName, String? zoneId, DateTime? neededBy, Priority? priority, String? note
});



}
/// @nodoc
class _$CreateRequestRequestCopyWithImpl<$Res>
    implements $CreateRequestRequestCopyWith<$Res> {
  _$CreateRequestRequestCopyWithImpl(this._self, this._then);

  final CreateRequestRequest _self;
  final $Res Function(CreateRequestRequest) _then;

/// Create a copy of CreateRequestRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quantity = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? productId = freezed,Object? freeProductName = freezed,Object? zoneId = freezed,Object? neededBy = freezed,Object? priority = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,freeProductName: freezed == freeProductName ? _self.freeProductName : freeProductName // ignore: cast_nullable_to_non_nullable
as String?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,neededBy: freezed == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CreateRequestRequest implements CreateRequestRequest {
  const _CreateRequestRequest({required this.quantity, this.clientId, this.clientCreatedAt, this.productId, this.freeProductName, this.zoneId, this.neededBy, this.priority, this.note});
  factory _CreateRequestRequest.fromJson(Map<String, dynamic> json) => _$CreateRequestRequestFromJson(json);

/// Quantité demandée avec son unité (une unité autorisée du produit).
@override final  QuantityBody? quantity;
/// Identifiant généré par le téléphone : un renvoi avec le même `clientId` donne 200 et la même demande, sans nouveau numéro.
@override final  String? clientId;
/// Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider.
@override final  DateTime? clientCreatedAt;
/// Produit du catalogue (actif). Exactement un de `productId` et `freeProductName`.
@override final  String? productId;
/// « Autre produit » : nom libre de 3 à 100 caractères.
@override final  String? freeProductName;
/// Zone du chantier (facultative) ; 422 `ZONE_HORS_CHANTIER` si elle appartient à un autre chantier.
@override final  String? zoneId;
/// Date de besoin complète (« pour le ») ; une date passée est acceptée (avertissement côté client).
@override final  DateTime? neededBy;
/// `Normal` (défaut), `Urgent` ou `Blocking` (le chantier s'arrête).
@override final  Priority? priority;
/// Usage ou remarque (200 caractères au plus).
@override final  String? note;

/// Create a copy of CreateRequestRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRequestRequestCopyWith<_CreateRequestRequest> get copyWith => __$CreateRequestRequestCopyWithImpl<_CreateRequestRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRequestRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRequestRequest&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.freeProductName, freeProductName) || other.freeProductName == freeProductName)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quantity,clientId,clientCreatedAt,productId,freeProductName,zoneId,neededBy,priority,note);

@override
String toString() {
  return 'CreateRequestRequest(quantity: $quantity, clientId: $clientId, clientCreatedAt: $clientCreatedAt, productId: $productId, freeProductName: $freeProductName, zoneId: $zoneId, neededBy: $neededBy, priority: $priority, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateRequestRequestCopyWith<$Res> implements $CreateRequestRequestCopyWith<$Res> {
  factory _$CreateRequestRequestCopyWith(_CreateRequestRequest value, $Res Function(_CreateRequestRequest) _then) = __$CreateRequestRequestCopyWithImpl;
@override @useResult
$Res call({
 QuantityBody? quantity, String? clientId, DateTime? clientCreatedAt, String? productId, String? freeProductName, String? zoneId, DateTime? neededBy, Priority? priority, String? note
});



}
/// @nodoc
class __$CreateRequestRequestCopyWithImpl<$Res>
    implements _$CreateRequestRequestCopyWith<$Res> {
  __$CreateRequestRequestCopyWithImpl(this._self, this._then);

  final _CreateRequestRequest _self;
  final $Res Function(_CreateRequestRequest) _then;

/// Create a copy of CreateRequestRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quantity = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? productId = freezed,Object? freeProductName = freezed,Object? zoneId = freezed,Object? neededBy = freezed,Object? priority = freezed,Object? note = freezed,}) {
  return _then(_CreateRequestRequest(
quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,freeProductName: freezed == freeProductName ? _self.freeProductName : freeProductName // ignore: cast_nullable_to_non_nullable
as String?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,neededBy: freezed == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
