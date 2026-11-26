// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderResponse {

 String get id; String get supplierId; String? get supplierName; DateTime get orderDate; DateTime? get expectedDeliveryDate;/// Jours entre la date de besoin et la livraison prevue quand elle la depasse (avertissement, jamais un blocage) ; 0 sinon.
 int get plannedAfterNeedDays;/// Remarque libre de la commande (200 caracteres), visible de tous les roles qui voient la demande, ChefChantier et ChefEquipe compris, et copiee sur leur telephone :.
/// ne jamais y saisir de prix, de remise ni de condition commerciale (le prix a son champ reserve a `Prices.View`). Aucun controle automatique ne peut le garantir sur un texte libre.
 String? get note;/// Jeton de concurrence de la commande (entier decimal en chaine).
 String get version;/// Prix, montant, valeur recue et n° de bon de commande ; absent sans `Prices.View` (construit uniquement par CommercialProjection).
 OrderCommercialResponse? get commercial;
/// Create a copy of OrderResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderResponseCopyWith<OrderResponse> get copyWith => _$OrderResponseCopyWithImpl<OrderResponse>(this as OrderResponse, _$identity);

  /// Serializes this OrderResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.plannedAfterNeedDays, plannedAfterNeedDays) || other.plannedAfterNeedDays == plannedAfterNeedDays)&&(identical(other.note, note) || other.note == note)&&(identical(other.version, version) || other.version == version)&&(identical(other.commercial, commercial) || other.commercial == commercial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,supplierId,supplierName,orderDate,expectedDeliveryDate,plannedAfterNeedDays,note,version,commercial);

@override
String toString() {
  return 'OrderResponse(id: $id, supplierId: $supplierId, supplierName: $supplierName, orderDate: $orderDate, expectedDeliveryDate: $expectedDeliveryDate, plannedAfterNeedDays: $plannedAfterNeedDays, note: $note, version: $version, commercial: $commercial)';
}


}

/// @nodoc
abstract mixin class $OrderResponseCopyWith<$Res>  {
  factory $OrderResponseCopyWith(OrderResponse value, $Res Function(OrderResponse) _then) = _$OrderResponseCopyWithImpl;
@useResult
$Res call({
 String id, String supplierId, String? supplierName, DateTime orderDate, DateTime? expectedDeliveryDate, int plannedAfterNeedDays, String? note, String version, OrderCommercialResponse? commercial
});



}
/// @nodoc
class _$OrderResponseCopyWithImpl<$Res>
    implements $OrderResponseCopyWith<$Res> {
  _$OrderResponseCopyWithImpl(this._self, this._then);

  final OrderResponse _self;
  final $Res Function(OrderResponse) _then;

/// Create a copy of OrderResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? supplierId = null,Object? supplierName = freezed,Object? orderDate = null,Object? expectedDeliveryDate = freezed,Object? plannedAfterNeedDays = null,Object? note = freezed,Object? version = null,Object? commercial = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,plannedAfterNeedDays: null == plannedAfterNeedDays ? _self.plannedAfterNeedDays : plannedAfterNeedDays // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as OrderCommercialResponse?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _OrderResponse implements OrderResponse {
  const _OrderResponse({required this.id, required this.supplierId, required this.supplierName, required this.orderDate, required this.expectedDeliveryDate, required this.plannedAfterNeedDays, required this.note, required this.version, this.commercial});
  factory _OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);

@override final  String id;
@override final  String supplierId;
@override final  String? supplierName;
@override final  DateTime orderDate;
@override final  DateTime? expectedDeliveryDate;
/// Jours entre la date de besoin et la livraison prevue quand elle la depasse (avertissement, jamais un blocage) ; 0 sinon.
@override final  int plannedAfterNeedDays;
/// Remarque libre de la commande (200 caracteres), visible de tous les roles qui voient la demande, ChefChantier et ChefEquipe compris, et copiee sur leur telephone :.
/// ne jamais y saisir de prix, de remise ni de condition commerciale (le prix a son champ reserve a `Prices.View`). Aucun controle automatique ne peut le garantir sur un texte libre.
@override final  String? note;
/// Jeton de concurrence de la commande (entier decimal en chaine).
@override final  String version;
/// Prix, montant, valeur recue et n° de bon de commande ; absent sans `Prices.View` (construit uniquement par CommercialProjection).
@override final  OrderCommercialResponse? commercial;

/// Create a copy of OrderResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderResponseCopyWith<_OrderResponse> get copyWith => __$OrderResponseCopyWithImpl<_OrderResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.plannedAfterNeedDays, plannedAfterNeedDays) || other.plannedAfterNeedDays == plannedAfterNeedDays)&&(identical(other.note, note) || other.note == note)&&(identical(other.version, version) || other.version == version)&&(identical(other.commercial, commercial) || other.commercial == commercial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,supplierId,supplierName,orderDate,expectedDeliveryDate,plannedAfterNeedDays,note,version,commercial);

@override
String toString() {
  return 'OrderResponse(id: $id, supplierId: $supplierId, supplierName: $supplierName, orderDate: $orderDate, expectedDeliveryDate: $expectedDeliveryDate, plannedAfterNeedDays: $plannedAfterNeedDays, note: $note, version: $version, commercial: $commercial)';
}


}

/// @nodoc
abstract mixin class _$OrderResponseCopyWith<$Res> implements $OrderResponseCopyWith<$Res> {
  factory _$OrderResponseCopyWith(_OrderResponse value, $Res Function(_OrderResponse) _then) = __$OrderResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String supplierId, String? supplierName, DateTime orderDate, DateTime? expectedDeliveryDate, int plannedAfterNeedDays, String? note, String version, OrderCommercialResponse? commercial
});



}
/// @nodoc
class __$OrderResponseCopyWithImpl<$Res>
    implements _$OrderResponseCopyWith<$Res> {
  __$OrderResponseCopyWithImpl(this._self, this._then);

  final _OrderResponse _self;
  final $Res Function(_OrderResponse) _then;

/// Create a copy of OrderResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? supplierId = null,Object? supplierName = freezed,Object? orderDate = null,Object? expectedDeliveryDate = freezed,Object? plannedAfterNeedDays = null,Object? note = freezed,Object? version = null,Object? commercial = freezed,}) {
  return _then(_OrderResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,plannedAfterNeedDays: null == plannedAfterNeedDays ? _self.plannedAfterNeedDays : plannedAfterNeedDays // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as OrderCommercialResponse?,
  ));
}


}

// dart format on
