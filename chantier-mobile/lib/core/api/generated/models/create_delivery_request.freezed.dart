// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_delivery_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateDeliveryRequest {

/// Quantité reçue, dans l'unité de la demande ou une unité convertible (sac, kg, T) ; sinon 422 `UNITES_INCOMPATIBLES`.
 QuantityBody? get quantity;/// Identifiant généré par le téléphone : un renvoi donne 200 et la même livraison, sans nouveau numéro.
 String? get clientId;/// Heure du téléphone (« saisi le ») : information seulement.
 DateTime? get clientCreatedAt;/// Demande livrée ; absente = livraison non rattachée. Une demande d'un autre chantier : 404.
 String? get requestId;/// Fournisseur du catalogue (par défaut celui de la commande) ; exactement un de `supplierId` et `freeSupplierName`.
 String? get supplierId;/// « Autre fournisseur » : nom libre de 3 à 100 caractères.
 String? get freeSupplierName;/// Produit du catalogue ; sans demande seulement (avec une demande, c'est celui de la demande : un autre produit donne 422 `PRODUIT_DIFFERENT`).
 String? get productId; String? get freeProductName;/// Date de livraison complète, pas dans le futur (heure d'Algérie).
 DateTime? get deliveryDate;/// N° du bon de livraison (30 caractères au plus), mis en majuscules.
 String? get deliveryNoteNumber;/// `Conform` (défaut) ou `WithReserve` (exige `reserveReasonCode`).
 Conformity? get conformity;/// Motif de réserve, de la liste de `GET /settings/materials` ; `Other` impose une remarque.
 String? get reserveReasonCode; String? get reserveNote;
/// Create a copy of CreateDeliveryRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateDeliveryRequestCopyWith<CreateDeliveryRequest> get copyWith => _$CreateDeliveryRequestCopyWithImpl<CreateDeliveryRequest>(this as CreateDeliveryRequest, _$identity);

  /// Serializes this CreateDeliveryRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateDeliveryRequest&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.freeSupplierName, freeSupplierName) || other.freeSupplierName == freeSupplierName)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.freeProductName, freeProductName) || other.freeProductName == freeProductName)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.reserveReasonCode, reserveReasonCode) || other.reserveReasonCode == reserveReasonCode)&&(identical(other.reserveNote, reserveNote) || other.reserveNote == reserveNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quantity,clientId,clientCreatedAt,requestId,supplierId,freeSupplierName,productId,freeProductName,deliveryDate,deliveryNoteNumber,conformity,reserveReasonCode,reserveNote);

@override
String toString() {
  return 'CreateDeliveryRequest(quantity: $quantity, clientId: $clientId, clientCreatedAt: $clientCreatedAt, requestId: $requestId, supplierId: $supplierId, freeSupplierName: $freeSupplierName, productId: $productId, freeProductName: $freeProductName, deliveryDate: $deliveryDate, deliveryNoteNumber: $deliveryNoteNumber, conformity: $conformity, reserveReasonCode: $reserveReasonCode, reserveNote: $reserveNote)';
}


}

/// @nodoc
abstract mixin class $CreateDeliveryRequestCopyWith<$Res>  {
  factory $CreateDeliveryRequestCopyWith(CreateDeliveryRequest value, $Res Function(CreateDeliveryRequest) _then) = _$CreateDeliveryRequestCopyWithImpl;
@useResult
$Res call({
 QuantityBody? quantity, String? clientId, DateTime? clientCreatedAt, String? requestId, String? supplierId, String? freeSupplierName, String? productId, String? freeProductName, DateTime? deliveryDate, String? deliveryNoteNumber, Conformity? conformity, String? reserveReasonCode, String? reserveNote
});



}
/// @nodoc
class _$CreateDeliveryRequestCopyWithImpl<$Res>
    implements $CreateDeliveryRequestCopyWith<$Res> {
  _$CreateDeliveryRequestCopyWithImpl(this._self, this._then);

  final CreateDeliveryRequest _self;
  final $Res Function(CreateDeliveryRequest) _then;

/// Create a copy of CreateDeliveryRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quantity = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? requestId = freezed,Object? supplierId = freezed,Object? freeSupplierName = freezed,Object? productId = freezed,Object? freeProductName = freezed,Object? deliveryDate = freezed,Object? deliveryNoteNumber = freezed,Object? conformity = freezed,Object? reserveReasonCode = freezed,Object? reserveNote = freezed,}) {
  return _then(_self.copyWith(
quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,freeSupplierName: freezed == freeSupplierName ? _self.freeSupplierName : freeSupplierName // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,freeProductName: freezed == freeProductName ? _self.freeProductName : freeProductName // ignore: cast_nullable_to_non_nullable
as String?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,conformity: freezed == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity?,reserveReasonCode: freezed == reserveReasonCode ? _self.reserveReasonCode : reserveReasonCode // ignore: cast_nullable_to_non_nullable
as String?,reserveNote: freezed == reserveNote ? _self.reserveNote : reserveNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CreateDeliveryRequest implements CreateDeliveryRequest {
  const _CreateDeliveryRequest({required this.quantity, this.clientId, this.clientCreatedAt, this.requestId, this.supplierId, this.freeSupplierName, this.productId, this.freeProductName, this.deliveryDate, this.deliveryNoteNumber, this.conformity, this.reserveReasonCode, this.reserveNote});
  factory _CreateDeliveryRequest.fromJson(Map<String, dynamic> json) => _$CreateDeliveryRequestFromJson(json);

/// Quantité reçue, dans l'unité de la demande ou une unité convertible (sac, kg, T) ; sinon 422 `UNITES_INCOMPATIBLES`.
@override final  QuantityBody? quantity;
/// Identifiant généré par le téléphone : un renvoi donne 200 et la même livraison, sans nouveau numéro.
@override final  String? clientId;
/// Heure du téléphone (« saisi le ») : information seulement.
@override final  DateTime? clientCreatedAt;
/// Demande livrée ; absente = livraison non rattachée. Une demande d'un autre chantier : 404.
@override final  String? requestId;
/// Fournisseur du catalogue (par défaut celui de la commande) ; exactement un de `supplierId` et `freeSupplierName`.
@override final  String? supplierId;
/// « Autre fournisseur » : nom libre de 3 à 100 caractères.
@override final  String? freeSupplierName;
/// Produit du catalogue ; sans demande seulement (avec une demande, c'est celui de la demande : un autre produit donne 422 `PRODUIT_DIFFERENT`).
@override final  String? productId;
@override final  String? freeProductName;
/// Date de livraison complète, pas dans le futur (heure d'Algérie).
@override final  DateTime? deliveryDate;
/// N° du bon de livraison (30 caractères au plus), mis en majuscules.
@override final  String? deliveryNoteNumber;
/// `Conform` (défaut) ou `WithReserve` (exige `reserveReasonCode`).
@override final  Conformity? conformity;
/// Motif de réserve, de la liste de `GET /settings/materials` ; `Other` impose une remarque.
@override final  String? reserveReasonCode;
@override final  String? reserveNote;

/// Create a copy of CreateDeliveryRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateDeliveryRequestCopyWith<_CreateDeliveryRequest> get copyWith => __$CreateDeliveryRequestCopyWithImpl<_CreateDeliveryRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateDeliveryRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateDeliveryRequest&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.freeSupplierName, freeSupplierName) || other.freeSupplierName == freeSupplierName)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.freeProductName, freeProductName) || other.freeProductName == freeProductName)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.reserveReasonCode, reserveReasonCode) || other.reserveReasonCode == reserveReasonCode)&&(identical(other.reserveNote, reserveNote) || other.reserveNote == reserveNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quantity,clientId,clientCreatedAt,requestId,supplierId,freeSupplierName,productId,freeProductName,deliveryDate,deliveryNoteNumber,conformity,reserveReasonCode,reserveNote);

@override
String toString() {
  return 'CreateDeliveryRequest(quantity: $quantity, clientId: $clientId, clientCreatedAt: $clientCreatedAt, requestId: $requestId, supplierId: $supplierId, freeSupplierName: $freeSupplierName, productId: $productId, freeProductName: $freeProductName, deliveryDate: $deliveryDate, deliveryNoteNumber: $deliveryNoteNumber, conformity: $conformity, reserveReasonCode: $reserveReasonCode, reserveNote: $reserveNote)';
}


}

/// @nodoc
abstract mixin class _$CreateDeliveryRequestCopyWith<$Res> implements $CreateDeliveryRequestCopyWith<$Res> {
  factory _$CreateDeliveryRequestCopyWith(_CreateDeliveryRequest value, $Res Function(_CreateDeliveryRequest) _then) = __$CreateDeliveryRequestCopyWithImpl;
@override @useResult
$Res call({
 QuantityBody? quantity, String? clientId, DateTime? clientCreatedAt, String? requestId, String? supplierId, String? freeSupplierName, String? productId, String? freeProductName, DateTime? deliveryDate, String? deliveryNoteNumber, Conformity? conformity, String? reserveReasonCode, String? reserveNote
});



}
/// @nodoc
class __$CreateDeliveryRequestCopyWithImpl<$Res>
    implements _$CreateDeliveryRequestCopyWith<$Res> {
  __$CreateDeliveryRequestCopyWithImpl(this._self, this._then);

  final _CreateDeliveryRequest _self;
  final $Res Function(_CreateDeliveryRequest) _then;

/// Create a copy of CreateDeliveryRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quantity = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? requestId = freezed,Object? supplierId = freezed,Object? freeSupplierName = freezed,Object? productId = freezed,Object? freeProductName = freezed,Object? deliveryDate = freezed,Object? deliveryNoteNumber = freezed,Object? conformity = freezed,Object? reserveReasonCode = freezed,Object? reserveNote = freezed,}) {
  return _then(_CreateDeliveryRequest(
quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,freeSupplierName: freezed == freeSupplierName ? _self.freeSupplierName : freeSupplierName // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,freeProductName: freezed == freeProductName ? _self.freeProductName : freeProductName // ignore: cast_nullable_to_non_nullable
as String?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,conformity: freezed == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity?,reserveReasonCode: freezed == reserveReasonCode ? _self.reserveReasonCode : reserveReasonCode // ignore: cast_nullable_to_non_nullable
as String?,reserveNote: freezed == reserveNote ? _self.reserveNote : reserveNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
