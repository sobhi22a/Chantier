// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_sync_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestSyncData {

 List<History2>? get history;/// Livraisons de la demande, annulees comprises ; absentes de la synchronisation (l'entite `delivery` les porte).
 List<Deliveries>? get deliveries; String? get id; String? get siteId;/// Code du chantier (liste transversale et REST) ; absent de la synchronisation.
 String? get siteCode;/// Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon `null`.
 String? get clientId; DateTime? get clientCreatedAt;/// Numero `DEM-nnn`, donne par le serveur.
 String? get number;/// Produit d'une demande : du catalogue (`productId`, `name`) et/ou le nom libre saisi (`freeName`, conserve apres un rattachement).
 Product2? get product; Quantity? get quantity; String? get zoneId;/// Date de besoin (« pour le »), date complete sans fuseau.
 DateTime? get neededBy;/// Urgence : `Normal` par defaut ; `Blocking` = le chantier s'arrete (H-MAT-06).
 RequestSyncDataPriority? get priority; String? get note;/// Statut d'une demande de materiaux : calcule et change par le serveur seulement (le client ne fixe jamais un statut).
 RequestSyncDataStatus? get status;/// Motif d'un refus ou d'une annulation.
 StatusReason? get statusReason; Quantity? get receivedQuantity; Quantity? get remainingQuantity;/// Ecart entre le recu et le demande dans l'unite de la demande : negatif = manque, positif = surplus.
 Variance? get variance;/// Manque definitif accepte (« solde »).
 bool? get isSettled;/// Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon.
 int? get overdueDays;/// Demande semblable deja ouverte (avertissement, jamais un blocage).
 PossibleDuplicateOf2? get possibleDuplicateOf;/// Commande active d'une demande (une seule, sans numero propre) : fournisseur, date de commande, livraison prevue. Une commande annulee n'apparait plus ici.
/// (elle reste dans l'historique de la demande). Quantite et unite sont celles de la demande.
 Order? get order;/// Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »).
 bool? get hasDeliveryWithoutOrder; String? get requestedById; String? get requestedByName; DateTime? get archivedAt; String? get archivedByName;/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification.
 String? get version; DateTime? get createdAt; String? get createdByName; DateTime? get updatedAt; String? get updatedByName;
/// Create a copy of RequestSyncData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestSyncDataCopyWith<RequestSyncData> get copyWith => _$RequestSyncDataCopyWithImpl<RequestSyncData>(this as RequestSyncData, _$identity);

  /// Serializes this RequestSyncData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestSyncData&&const DeepCollectionEquality().equals(other.history, history)&&const DeepCollectionEquality().equals(other.deliveries, deliveries)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.siteCode, siteCode) || other.siteCode == siteCode)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.number, number) || other.number == number)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.note, note) || other.note == note)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusReason, statusReason) || other.statusReason == statusReason)&&(identical(other.receivedQuantity, receivedQuantity) || other.receivedQuantity == receivedQuantity)&&(identical(other.remainingQuantity, remainingQuantity) || other.remainingQuantity == remainingQuantity)&&(identical(other.variance, variance) || other.variance == variance)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.overdueDays, overdueDays) || other.overdueDays == overdueDays)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&(identical(other.order, order) || other.order == order)&&(identical(other.hasDeliveryWithoutOrder, hasDeliveryWithoutOrder) || other.hasDeliveryWithoutOrder == hasDeliveryWithoutOrder)&&(identical(other.requestedById, requestedById) || other.requestedById == requestedById)&&(identical(other.requestedByName, requestedByName) || other.requestedByName == requestedByName)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedByName, archivedByName) || other.archivedByName == archivedByName)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(history),const DeepCollectionEquality().hash(deliveries),id,siteId,siteCode,clientId,clientCreatedAt,number,product,quantity,zoneId,neededBy,priority,note,status,statusReason,receivedQuantity,remainingQuantity,variance,isSettled,overdueDays,possibleDuplicateOf,order,hasDeliveryWithoutOrder,requestedById,requestedByName,archivedAt,archivedByName,version,createdAt,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'RequestSyncData(history: $history, deliveries: $deliveries, id: $id, siteId: $siteId, siteCode: $siteCode, clientId: $clientId, clientCreatedAt: $clientCreatedAt, number: $number, product: $product, quantity: $quantity, zoneId: $zoneId, neededBy: $neededBy, priority: $priority, note: $note, status: $status, statusReason: $statusReason, receivedQuantity: $receivedQuantity, remainingQuantity: $remainingQuantity, variance: $variance, isSettled: $isSettled, overdueDays: $overdueDays, possibleDuplicateOf: $possibleDuplicateOf, order: $order, hasDeliveryWithoutOrder: $hasDeliveryWithoutOrder, requestedById: $requestedById, requestedByName: $requestedByName, archivedAt: $archivedAt, archivedByName: $archivedByName, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class $RequestSyncDataCopyWith<$Res>  {
  factory $RequestSyncDataCopyWith(RequestSyncData value, $Res Function(RequestSyncData) _then) = _$RequestSyncDataCopyWithImpl;
@useResult
$Res call({
 List<History2>? history, List<Deliveries>? deliveries, String? id, String? siteId, String? siteCode, String? clientId, DateTime? clientCreatedAt, String? number, Product2? product, Quantity? quantity, String? zoneId, DateTime? neededBy, RequestSyncDataPriority? priority, String? note, RequestSyncDataStatus? status, StatusReason? statusReason, Quantity? receivedQuantity, Quantity? remainingQuantity, Variance? variance, bool? isSettled, int? overdueDays, PossibleDuplicateOf2? possibleDuplicateOf, Order? order, bool? hasDeliveryWithoutOrder, String? requestedById, String? requestedByName, DateTime? archivedAt, String? archivedByName, String? version, DateTime? createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class _$RequestSyncDataCopyWithImpl<$Res>
    implements $RequestSyncDataCopyWith<$Res> {
  _$RequestSyncDataCopyWithImpl(this._self, this._then);

  final RequestSyncData _self;
  final $Res Function(RequestSyncData) _then;

/// Create a copy of RequestSyncData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? history = freezed,Object? deliveries = freezed,Object? id = freezed,Object? siteId = freezed,Object? siteCode = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? number = freezed,Object? product = freezed,Object? quantity = freezed,Object? zoneId = freezed,Object? neededBy = freezed,Object? priority = freezed,Object? note = freezed,Object? status = freezed,Object? statusReason = freezed,Object? receivedQuantity = freezed,Object? remainingQuantity = freezed,Object? variance = freezed,Object? isSettled = freezed,Object? overdueDays = freezed,Object? possibleDuplicateOf = freezed,Object? order = freezed,Object? hasDeliveryWithoutOrder = freezed,Object? requestedById = freezed,Object? requestedByName = freezed,Object? archivedAt = freezed,Object? archivedByName = freezed,Object? version = freezed,Object? createdAt = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_self.copyWith(
history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<History2>?,deliveries: freezed == deliveries ? _self.deliveries : deliveries // ignore: cast_nullable_to_non_nullable
as List<Deliveries>?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,siteCode: freezed == siteCode ? _self.siteCode : siteCode // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product2?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,neededBy: freezed == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as RequestSyncDataPriority?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestSyncDataStatus?,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as StatusReason?,receivedQuantity: freezed == receivedQuantity ? _self.receivedQuantity : receivedQuantity // ignore: cast_nullable_to_non_nullable
as Quantity?,remainingQuantity: freezed == remainingQuantity ? _self.remainingQuantity : remainingQuantity // ignore: cast_nullable_to_non_nullable
as Quantity?,variance: freezed == variance ? _self.variance : variance // ignore: cast_nullable_to_non_nullable
as Variance?,isSettled: freezed == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool?,overdueDays: freezed == overdueDays ? _self.overdueDays : overdueDays // ignore: cast_nullable_to_non_nullable
as int?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as PossibleDuplicateOf2?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order?,hasDeliveryWithoutOrder: freezed == hasDeliveryWithoutOrder ? _self.hasDeliveryWithoutOrder : hasDeliveryWithoutOrder // ignore: cast_nullable_to_non_nullable
as bool?,requestedById: freezed == requestedById ? _self.requestedById : requestedById // ignore: cast_nullable_to_non_nullable
as String?,requestedByName: freezed == requestedByName ? _self.requestedByName : requestedByName // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedByName: freezed == archivedByName ? _self.archivedByName : archivedByName // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RequestSyncData implements RequestSyncData {
  const _RequestSyncData({final  List<History2>? history, final  List<Deliveries>? deliveries, this.id, this.siteId, this.siteCode, this.clientId, this.clientCreatedAt, this.number, this.product, this.quantity, this.zoneId, this.neededBy, this.priority, this.note, this.status, this.statusReason, this.receivedQuantity, this.remainingQuantity, this.variance, this.isSettled, this.overdueDays, this.possibleDuplicateOf, this.order, this.hasDeliveryWithoutOrder, this.requestedById, this.requestedByName, this.archivedAt, this.archivedByName, this.version, this.createdAt, this.createdByName, this.updatedAt, this.updatedByName}): _history = history,_deliveries = deliveries;
  factory _RequestSyncData.fromJson(Map<String, dynamic> json) => _$RequestSyncDataFromJson(json);

 final  List<History2>? _history;
@override List<History2>? get history {
  final value = _history;
  if (value == null) return null;
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Livraisons de la demande, annulees comprises ; absentes de la synchronisation (l'entite `delivery` les porte).
 final  List<Deliveries>? _deliveries;
/// Livraisons de la demande, annulees comprises ; absentes de la synchronisation (l'entite `delivery` les porte).
@override List<Deliveries>? get deliveries {
  final value = _deliveries;
  if (value == null) return null;
  if (_deliveries is EqualUnmodifiableListView) return _deliveries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? id;
@override final  String? siteId;
/// Code du chantier (liste transversale et REST) ; absent de la synchronisation.
@override final  String? siteCode;
/// Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon `null`.
@override final  String? clientId;
@override final  DateTime? clientCreatedAt;
/// Numero `DEM-nnn`, donne par le serveur.
@override final  String? number;
/// Produit d'une demande : du catalogue (`productId`, `name`) et/ou le nom libre saisi (`freeName`, conserve apres un rattachement).
@override final  Product2? product;
@override final  Quantity? quantity;
@override final  String? zoneId;
/// Date de besoin (« pour le »), date complete sans fuseau.
@override final  DateTime? neededBy;
/// Urgence : `Normal` par defaut ; `Blocking` = le chantier s'arrete (H-MAT-06).
@override final  RequestSyncDataPriority? priority;
@override final  String? note;
/// Statut d'une demande de materiaux : calcule et change par le serveur seulement (le client ne fixe jamais un statut).
@override final  RequestSyncDataStatus? status;
/// Motif d'un refus ou d'une annulation.
@override final  StatusReason? statusReason;
@override final  Quantity? receivedQuantity;
@override final  Quantity? remainingQuantity;
/// Ecart entre le recu et le demande dans l'unite de la demande : negatif = manque, positif = surplus.
@override final  Variance? variance;
/// Manque definitif accepte (« solde »).
@override final  bool? isSettled;
/// Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon.
@override final  int? overdueDays;
/// Demande semblable deja ouverte (avertissement, jamais un blocage).
@override final  PossibleDuplicateOf2? possibleDuplicateOf;
/// Commande active d'une demande (une seule, sans numero propre) : fournisseur, date de commande, livraison prevue. Une commande annulee n'apparait plus ici.
/// (elle reste dans l'historique de la demande). Quantite et unite sont celles de la demande.
@override final  Order? order;
/// Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »).
@override final  bool? hasDeliveryWithoutOrder;
@override final  String? requestedById;
@override final  String? requestedByName;
@override final  DateTime? archivedAt;
@override final  String? archivedByName;
/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification.
@override final  String? version;
@override final  DateTime? createdAt;
@override final  String? createdByName;
@override final  DateTime? updatedAt;
@override final  String? updatedByName;

/// Create a copy of RequestSyncData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestSyncDataCopyWith<_RequestSyncData> get copyWith => __$RequestSyncDataCopyWithImpl<_RequestSyncData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestSyncDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestSyncData&&const DeepCollectionEquality().equals(other._history, _history)&&const DeepCollectionEquality().equals(other._deliveries, _deliveries)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.siteCode, siteCode) || other.siteCode == siteCode)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.number, number) || other.number == number)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.note, note) || other.note == note)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusReason, statusReason) || other.statusReason == statusReason)&&(identical(other.receivedQuantity, receivedQuantity) || other.receivedQuantity == receivedQuantity)&&(identical(other.remainingQuantity, remainingQuantity) || other.remainingQuantity == remainingQuantity)&&(identical(other.variance, variance) || other.variance == variance)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.overdueDays, overdueDays) || other.overdueDays == overdueDays)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&(identical(other.order, order) || other.order == order)&&(identical(other.hasDeliveryWithoutOrder, hasDeliveryWithoutOrder) || other.hasDeliveryWithoutOrder == hasDeliveryWithoutOrder)&&(identical(other.requestedById, requestedById) || other.requestedById == requestedById)&&(identical(other.requestedByName, requestedByName) || other.requestedByName == requestedByName)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedByName, archivedByName) || other.archivedByName == archivedByName)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_history),const DeepCollectionEquality().hash(_deliveries),id,siteId,siteCode,clientId,clientCreatedAt,number,product,quantity,zoneId,neededBy,priority,note,status,statusReason,receivedQuantity,remainingQuantity,variance,isSettled,overdueDays,possibleDuplicateOf,order,hasDeliveryWithoutOrder,requestedById,requestedByName,archivedAt,archivedByName,version,createdAt,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'RequestSyncData(history: $history, deliveries: $deliveries, id: $id, siteId: $siteId, siteCode: $siteCode, clientId: $clientId, clientCreatedAt: $clientCreatedAt, number: $number, product: $product, quantity: $quantity, zoneId: $zoneId, neededBy: $neededBy, priority: $priority, note: $note, status: $status, statusReason: $statusReason, receivedQuantity: $receivedQuantity, remainingQuantity: $remainingQuantity, variance: $variance, isSettled: $isSettled, overdueDays: $overdueDays, possibleDuplicateOf: $possibleDuplicateOf, order: $order, hasDeliveryWithoutOrder: $hasDeliveryWithoutOrder, requestedById: $requestedById, requestedByName: $requestedByName, archivedAt: $archivedAt, archivedByName: $archivedByName, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class _$RequestSyncDataCopyWith<$Res> implements $RequestSyncDataCopyWith<$Res> {
  factory _$RequestSyncDataCopyWith(_RequestSyncData value, $Res Function(_RequestSyncData) _then) = __$RequestSyncDataCopyWithImpl;
@override @useResult
$Res call({
 List<History2>? history, List<Deliveries>? deliveries, String? id, String? siteId, String? siteCode, String? clientId, DateTime? clientCreatedAt, String? number, Product2? product, Quantity? quantity, String? zoneId, DateTime? neededBy, RequestSyncDataPriority? priority, String? note, RequestSyncDataStatus? status, StatusReason? statusReason, Quantity? receivedQuantity, Quantity? remainingQuantity, Variance? variance, bool? isSettled, int? overdueDays, PossibleDuplicateOf2? possibleDuplicateOf, Order? order, bool? hasDeliveryWithoutOrder, String? requestedById, String? requestedByName, DateTime? archivedAt, String? archivedByName, String? version, DateTime? createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class __$RequestSyncDataCopyWithImpl<$Res>
    implements _$RequestSyncDataCopyWith<$Res> {
  __$RequestSyncDataCopyWithImpl(this._self, this._then);

  final _RequestSyncData _self;
  final $Res Function(_RequestSyncData) _then;

/// Create a copy of RequestSyncData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? history = freezed,Object? deliveries = freezed,Object? id = freezed,Object? siteId = freezed,Object? siteCode = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? number = freezed,Object? product = freezed,Object? quantity = freezed,Object? zoneId = freezed,Object? neededBy = freezed,Object? priority = freezed,Object? note = freezed,Object? status = freezed,Object? statusReason = freezed,Object? receivedQuantity = freezed,Object? remainingQuantity = freezed,Object? variance = freezed,Object? isSettled = freezed,Object? overdueDays = freezed,Object? possibleDuplicateOf = freezed,Object? order = freezed,Object? hasDeliveryWithoutOrder = freezed,Object? requestedById = freezed,Object? requestedByName = freezed,Object? archivedAt = freezed,Object? archivedByName = freezed,Object? version = freezed,Object? createdAt = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_RequestSyncData(
history: freezed == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<History2>?,deliveries: freezed == deliveries ? _self._deliveries : deliveries // ignore: cast_nullable_to_non_nullable
as List<Deliveries>?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,siteCode: freezed == siteCode ? _self.siteCode : siteCode // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product2?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,neededBy: freezed == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as RequestSyncDataPriority?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestSyncDataStatus?,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as StatusReason?,receivedQuantity: freezed == receivedQuantity ? _self.receivedQuantity : receivedQuantity // ignore: cast_nullable_to_non_nullable
as Quantity?,remainingQuantity: freezed == remainingQuantity ? _self.remainingQuantity : remainingQuantity // ignore: cast_nullable_to_non_nullable
as Quantity?,variance: freezed == variance ? _self.variance : variance // ignore: cast_nullable_to_non_nullable
as Variance?,isSettled: freezed == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool?,overdueDays: freezed == overdueDays ? _self.overdueDays : overdueDays // ignore: cast_nullable_to_non_nullable
as int?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as PossibleDuplicateOf2?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order?,hasDeliveryWithoutOrder: freezed == hasDeliveryWithoutOrder ? _self.hasDeliveryWithoutOrder : hasDeliveryWithoutOrder // ignore: cast_nullable_to_non_nullable
as bool?,requestedById: freezed == requestedById ? _self.requestedById : requestedById // ignore: cast_nullable_to_non_nullable
as String?,requestedByName: freezed == requestedByName ? _self.requestedByName : requestedByName // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedByName: freezed == archivedByName ? _self.archivedByName : archivedByName // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
