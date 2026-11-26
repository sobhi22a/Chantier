// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_order_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateOrderRequest {

/// Fournisseur du catalogue, actif (422 `FOURNISSEUR_INACTIF` sinon).
 String get supplierId;/// Identifiant généré par le client : un renvoi donne 200 et la même commande, sans nouvel effet.
 String? get clientId;/// Date de commande complète, pas dans le futur (heure d'Algérie).
 DateTime? get orderDate;/// Livraison prévue, complète et pas avant la date de commande. Au-delà de la date de besoin : avertissement (`plannedAfterNeedDays`), jamais un blocage.
 DateTime? get expectedDeliveryDate;/// Prix unitaire hors taxes par unité de commande, en DZD, supérieur à 0, 2 décimales au plus. Facultatif (« à renseigner »).
 double? get unitPrice;/// N° du bon de commande (50 caractères au plus).
 String? get purchaseOrderNumber;/// Remarque (200 caractères au plus).
 String? get note;
/// Create a copy of CreateOrderRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateOrderRequestCopyWith<CreateOrderRequest> get copyWith => _$CreateOrderRequestCopyWithImpl<CreateOrderRequest>(this as CreateOrderRequest, _$identity);

  /// Serializes this CreateOrderRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateOrderRequest&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.purchaseOrderNumber, purchaseOrderNumber) || other.purchaseOrderNumber == purchaseOrderNumber)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,supplierId,clientId,orderDate,expectedDeliveryDate,unitPrice,purchaseOrderNumber,note);

@override
String toString() {
  return 'CreateOrderRequest(supplierId: $supplierId, clientId: $clientId, orderDate: $orderDate, expectedDeliveryDate: $expectedDeliveryDate, unitPrice: $unitPrice, purchaseOrderNumber: $purchaseOrderNumber, note: $note)';
}


}

/// @nodoc
abstract mixin class $CreateOrderRequestCopyWith<$Res>  {
  factory $CreateOrderRequestCopyWith(CreateOrderRequest value, $Res Function(CreateOrderRequest) _then) = _$CreateOrderRequestCopyWithImpl;
@useResult
$Res call({
 String supplierId, String? clientId, DateTime? orderDate, DateTime? expectedDeliveryDate, double? unitPrice, String? purchaseOrderNumber, String? note
});



}
/// @nodoc
class _$CreateOrderRequestCopyWithImpl<$Res>
    implements $CreateOrderRequestCopyWith<$Res> {
  _$CreateOrderRequestCopyWithImpl(this._self, this._then);

  final CreateOrderRequest _self;
  final $Res Function(CreateOrderRequest) _then;

/// Create a copy of CreateOrderRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? supplierId = null,Object? clientId = freezed,Object? orderDate = freezed,Object? expectedDeliveryDate = freezed,Object? unitPrice = freezed,Object? purchaseOrderNumber = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,orderDate: freezed == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double?,purchaseOrderNumber: freezed == purchaseOrderNumber ? _self.purchaseOrderNumber : purchaseOrderNumber // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CreateOrderRequest implements CreateOrderRequest {
  const _CreateOrderRequest({required this.supplierId, this.clientId, this.orderDate, this.expectedDeliveryDate, this.unitPrice, this.purchaseOrderNumber, this.note});
  factory _CreateOrderRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestFromJson(json);

/// Fournisseur du catalogue, actif (422 `FOURNISSEUR_INACTIF` sinon).
@override final  String supplierId;
/// Identifiant généré par le client : un renvoi donne 200 et la même commande, sans nouvel effet.
@override final  String? clientId;
/// Date de commande complète, pas dans le futur (heure d'Algérie).
@override final  DateTime? orderDate;
/// Livraison prévue, complète et pas avant la date de commande. Au-delà de la date de besoin : avertissement (`plannedAfterNeedDays`), jamais un blocage.
@override final  DateTime? expectedDeliveryDate;
/// Prix unitaire hors taxes par unité de commande, en DZD, supérieur à 0, 2 décimales au plus. Facultatif (« à renseigner »).
@override final  double? unitPrice;
/// N° du bon de commande (50 caractères au plus).
@override final  String? purchaseOrderNumber;
/// Remarque (200 caractères au plus).
@override final  String? note;

/// Create a copy of CreateOrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateOrderRequestCopyWith<_CreateOrderRequest> get copyWith => __$CreateOrderRequestCopyWithImpl<_CreateOrderRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateOrderRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateOrderRequest&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.purchaseOrderNumber, purchaseOrderNumber) || other.purchaseOrderNumber == purchaseOrderNumber)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,supplierId,clientId,orderDate,expectedDeliveryDate,unitPrice,purchaseOrderNumber,note);

@override
String toString() {
  return 'CreateOrderRequest(supplierId: $supplierId, clientId: $clientId, orderDate: $orderDate, expectedDeliveryDate: $expectedDeliveryDate, unitPrice: $unitPrice, purchaseOrderNumber: $purchaseOrderNumber, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateOrderRequestCopyWith<$Res> implements $CreateOrderRequestCopyWith<$Res> {
  factory _$CreateOrderRequestCopyWith(_CreateOrderRequest value, $Res Function(_CreateOrderRequest) _then) = __$CreateOrderRequestCopyWithImpl;
@override @useResult
$Res call({
 String supplierId, String? clientId, DateTime? orderDate, DateTime? expectedDeliveryDate, double? unitPrice, String? purchaseOrderNumber, String? note
});



}
/// @nodoc
class __$CreateOrderRequestCopyWithImpl<$Res>
    implements _$CreateOrderRequestCopyWith<$Res> {
  __$CreateOrderRequestCopyWithImpl(this._self, this._then);

  final _CreateOrderRequest _self;
  final $Res Function(_CreateOrderRequest) _then;

/// Create a copy of CreateOrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? supplierId = null,Object? clientId = freezed,Object? orderDate = freezed,Object? expectedDeliveryDate = freezed,Object? unitPrice = freezed,Object? purchaseOrderNumber = freezed,Object? note = freezed,}) {
  return _then(_CreateOrderRequest(
supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,orderDate: freezed == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double?,purchaseOrderNumber: freezed == purchaseOrderNumber ? _self.purchaseOrderNumber : purchaseOrderNumber // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
