// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'material_request_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaterialRequestResponse {

 String get id; String get siteId;/// Numero `DEM-nnn`, donne par le serveur.
 String get number; ProductRefResponse get product;/// Quantite demandee et son unite.
 Quantity get quantity;/// Date de besoin (« pour le »), date complete sans fuseau.
 DateTime get neededBy; Priority get priority; RequestStatus get status;/// Manque definitif accepte (« solde »).
 bool get isSettled;/// Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon.
 int get overdueDays; String get requestedById;/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification.
 String get version; DateTime get createdAt;/// Code du chantier (liste transversale et REST) ; absent de la synchronisation.
 String? get siteCode;/// Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon `null`.
 String? get clientId; DateTime? get clientCreatedAt; String? get zoneId; String? get note;/// Motif du refus ou de l'annulation.
 StatusReasonResponse? get statusReason;/// Recu cumule dans l'unite de la demande ; absent tant que la demande n'est pas commandee.
 Quantity? get receivedQuantity;/// Reste a livrer, jamais negatif ; absent tant que la demande n'est pas commandee.
 Quantity? get remainingQuantity; VarianceResponse? get variance; DuplicateRefResponse? get possibleDuplicateOf;/// Commande active ; `null` sans commande. Ses champs commerciaux sont absents sans `Prices.View` et de la synchronisation.
 OrderResponse? get order;/// Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »).
 bool? get hasDeliveryWithoutOrder; String? get requestedByName; DateTime? get archivedAt; String? get archivedByName; String? get createdByName; DateTime? get updatedAt; String? get updatedByName;
/// Create a copy of MaterialRequestResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialRequestResponseCopyWith<MaterialRequestResponse> get copyWith => _$MaterialRequestResponseCopyWithImpl<MaterialRequestResponse>(this as MaterialRequestResponse, _$identity);

  /// Serializes this MaterialRequestResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterialRequestResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.number, number) || other.number == number)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.overdueDays, overdueDays) || other.overdueDays == overdueDays)&&(identical(other.requestedById, requestedById) || other.requestedById == requestedById)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.siteCode, siteCode) || other.siteCode == siteCode)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.note, note) || other.note == note)&&(identical(other.statusReason, statusReason) || other.statusReason == statusReason)&&(identical(other.receivedQuantity, receivedQuantity) || other.receivedQuantity == receivedQuantity)&&(identical(other.remainingQuantity, remainingQuantity) || other.remainingQuantity == remainingQuantity)&&(identical(other.variance, variance) || other.variance == variance)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&(identical(other.order, order) || other.order == order)&&(identical(other.hasDeliveryWithoutOrder, hasDeliveryWithoutOrder) || other.hasDeliveryWithoutOrder == hasDeliveryWithoutOrder)&&(identical(other.requestedByName, requestedByName) || other.requestedByName == requestedByName)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedByName, archivedByName) || other.archivedByName == archivedByName)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,siteId,number,product,quantity,neededBy,priority,status,isSettled,overdueDays,requestedById,version,createdAt,siteCode,clientId,clientCreatedAt,zoneId,note,statusReason,receivedQuantity,remainingQuantity,variance,possibleDuplicateOf,order,hasDeliveryWithoutOrder,requestedByName,archivedAt,archivedByName,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'MaterialRequestResponse(id: $id, siteId: $siteId, number: $number, product: $product, quantity: $quantity, neededBy: $neededBy, priority: $priority, status: $status, isSettled: $isSettled, overdueDays: $overdueDays, requestedById: $requestedById, version: $version, createdAt: $createdAt, siteCode: $siteCode, clientId: $clientId, clientCreatedAt: $clientCreatedAt, zoneId: $zoneId, note: $note, statusReason: $statusReason, receivedQuantity: $receivedQuantity, remainingQuantity: $remainingQuantity, variance: $variance, possibleDuplicateOf: $possibleDuplicateOf, order: $order, hasDeliveryWithoutOrder: $hasDeliveryWithoutOrder, requestedByName: $requestedByName, archivedAt: $archivedAt, archivedByName: $archivedByName, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class $MaterialRequestResponseCopyWith<$Res>  {
  factory $MaterialRequestResponseCopyWith(MaterialRequestResponse value, $Res Function(MaterialRequestResponse) _then) = _$MaterialRequestResponseCopyWithImpl;
@useResult
$Res call({
 String id, String siteId, String number, ProductRefResponse product, Quantity quantity, DateTime neededBy, Priority priority, RequestStatus status, bool isSettled, int overdueDays, String requestedById, String version, DateTime createdAt, String? siteCode, String? clientId, DateTime? clientCreatedAt, String? zoneId, String? note, StatusReasonResponse? statusReason, Quantity? receivedQuantity, Quantity? remainingQuantity, VarianceResponse? variance, DuplicateRefResponse? possibleDuplicateOf, OrderResponse? order, bool? hasDeliveryWithoutOrder, String? requestedByName, DateTime? archivedAt, String? archivedByName, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class _$MaterialRequestResponseCopyWithImpl<$Res>
    implements $MaterialRequestResponseCopyWith<$Res> {
  _$MaterialRequestResponseCopyWithImpl(this._self, this._then);

  final MaterialRequestResponse _self;
  final $Res Function(MaterialRequestResponse) _then;

/// Create a copy of MaterialRequestResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? siteId = null,Object? number = null,Object? product = null,Object? quantity = null,Object? neededBy = null,Object? priority = null,Object? status = null,Object? isSettled = null,Object? overdueDays = null,Object? requestedById = null,Object? version = null,Object? createdAt = null,Object? siteCode = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? zoneId = freezed,Object? note = freezed,Object? statusReason = freezed,Object? receivedQuantity = freezed,Object? remainingQuantity = freezed,Object? variance = freezed,Object? possibleDuplicateOf = freezed,Object? order = freezed,Object? hasDeliveryWithoutOrder = freezed,Object? requestedByName = freezed,Object? archivedAt = freezed,Object? archivedByName = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefResponse,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,neededBy: null == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,overdueDays: null == overdueDays ? _self.overdueDays : overdueDays // ignore: cast_nullable_to_non_nullable
as int,requestedById: null == requestedById ? _self.requestedById : requestedById // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,siteCode: freezed == siteCode ? _self.siteCode : siteCode // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as StatusReasonResponse?,receivedQuantity: freezed == receivedQuantity ? _self.receivedQuantity : receivedQuantity // ignore: cast_nullable_to_non_nullable
as Quantity?,remainingQuantity: freezed == remainingQuantity ? _self.remainingQuantity : remainingQuantity // ignore: cast_nullable_to_non_nullable
as Quantity?,variance: freezed == variance ? _self.variance : variance // ignore: cast_nullable_to_non_nullable
as VarianceResponse?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as DuplicateRefResponse?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderResponse?,hasDeliveryWithoutOrder: freezed == hasDeliveryWithoutOrder ? _self.hasDeliveryWithoutOrder : hasDeliveryWithoutOrder // ignore: cast_nullable_to_non_nullable
as bool?,requestedByName: freezed == requestedByName ? _self.requestedByName : requestedByName // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedByName: freezed == archivedByName ? _self.archivedByName : archivedByName // ignore: cast_nullable_to_non_nullable
as String?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _MaterialRequestResponse implements MaterialRequestResponse {
  const _MaterialRequestResponse({required this.id, required this.siteId, required this.number, required this.product, required this.quantity, required this.neededBy, required this.priority, required this.status, required this.isSettled, required this.overdueDays, required this.requestedById, required this.version, required this.createdAt, this.siteCode, this.clientId, this.clientCreatedAt, this.zoneId, this.note, this.statusReason, this.receivedQuantity, this.remainingQuantity, this.variance, this.possibleDuplicateOf, this.order, this.hasDeliveryWithoutOrder, this.requestedByName, this.archivedAt, this.archivedByName, this.createdByName, this.updatedAt, this.updatedByName});
  factory _MaterialRequestResponse.fromJson(Map<String, dynamic> json) => _$MaterialRequestResponseFromJson(json);

@override final  String id;
@override final  String siteId;
/// Numero `DEM-nnn`, donne par le serveur.
@override final  String number;
@override final  ProductRefResponse product;
/// Quantite demandee et son unite.
@override final  Quantity quantity;
/// Date de besoin (« pour le »), date complete sans fuseau.
@override final  DateTime neededBy;
@override final  Priority priority;
@override final  RequestStatus status;
/// Manque definitif accepte (« solde »).
@override final  bool isSettled;
/// Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon.
@override final  int overdueDays;
@override final  String requestedById;
/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification.
@override final  String version;
@override final  DateTime createdAt;
/// Code du chantier (liste transversale et REST) ; absent de la synchronisation.
@override final  String? siteCode;
/// Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon `null`.
@override final  String? clientId;
@override final  DateTime? clientCreatedAt;
@override final  String? zoneId;
@override final  String? note;
/// Motif du refus ou de l'annulation.
@override final  StatusReasonResponse? statusReason;
/// Recu cumule dans l'unite de la demande ; absent tant que la demande n'est pas commandee.
@override final  Quantity? receivedQuantity;
/// Reste a livrer, jamais negatif ; absent tant que la demande n'est pas commandee.
@override final  Quantity? remainingQuantity;
@override final  VarianceResponse? variance;
@override final  DuplicateRefResponse? possibleDuplicateOf;
/// Commande active ; `null` sans commande. Ses champs commerciaux sont absents sans `Prices.View` et de la synchronisation.
@override final  OrderResponse? order;
/// Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »).
@override final  bool? hasDeliveryWithoutOrder;
@override final  String? requestedByName;
@override final  DateTime? archivedAt;
@override final  String? archivedByName;
@override final  String? createdByName;
@override final  DateTime? updatedAt;
@override final  String? updatedByName;

/// Create a copy of MaterialRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialRequestResponseCopyWith<_MaterialRequestResponse> get copyWith => __$MaterialRequestResponseCopyWithImpl<_MaterialRequestResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialRequestResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterialRequestResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.number, number) || other.number == number)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.neededBy, neededBy) || other.neededBy == neededBy)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.overdueDays, overdueDays) || other.overdueDays == overdueDays)&&(identical(other.requestedById, requestedById) || other.requestedById == requestedById)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.siteCode, siteCode) || other.siteCode == siteCode)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.note, note) || other.note == note)&&(identical(other.statusReason, statusReason) || other.statusReason == statusReason)&&(identical(other.receivedQuantity, receivedQuantity) || other.receivedQuantity == receivedQuantity)&&(identical(other.remainingQuantity, remainingQuantity) || other.remainingQuantity == remainingQuantity)&&(identical(other.variance, variance) || other.variance == variance)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&(identical(other.order, order) || other.order == order)&&(identical(other.hasDeliveryWithoutOrder, hasDeliveryWithoutOrder) || other.hasDeliveryWithoutOrder == hasDeliveryWithoutOrder)&&(identical(other.requestedByName, requestedByName) || other.requestedByName == requestedByName)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedByName, archivedByName) || other.archivedByName == archivedByName)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,siteId,number,product,quantity,neededBy,priority,status,isSettled,overdueDays,requestedById,version,createdAt,siteCode,clientId,clientCreatedAt,zoneId,note,statusReason,receivedQuantity,remainingQuantity,variance,possibleDuplicateOf,order,hasDeliveryWithoutOrder,requestedByName,archivedAt,archivedByName,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'MaterialRequestResponse(id: $id, siteId: $siteId, number: $number, product: $product, quantity: $quantity, neededBy: $neededBy, priority: $priority, status: $status, isSettled: $isSettled, overdueDays: $overdueDays, requestedById: $requestedById, version: $version, createdAt: $createdAt, siteCode: $siteCode, clientId: $clientId, clientCreatedAt: $clientCreatedAt, zoneId: $zoneId, note: $note, statusReason: $statusReason, receivedQuantity: $receivedQuantity, remainingQuantity: $remainingQuantity, variance: $variance, possibleDuplicateOf: $possibleDuplicateOf, order: $order, hasDeliveryWithoutOrder: $hasDeliveryWithoutOrder, requestedByName: $requestedByName, archivedAt: $archivedAt, archivedByName: $archivedByName, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class _$MaterialRequestResponseCopyWith<$Res> implements $MaterialRequestResponseCopyWith<$Res> {
  factory _$MaterialRequestResponseCopyWith(_MaterialRequestResponse value, $Res Function(_MaterialRequestResponse) _then) = __$MaterialRequestResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String siteId, String number, ProductRefResponse product, Quantity quantity, DateTime neededBy, Priority priority, RequestStatus status, bool isSettled, int overdueDays, String requestedById, String version, DateTime createdAt, String? siteCode, String? clientId, DateTime? clientCreatedAt, String? zoneId, String? note, StatusReasonResponse? statusReason, Quantity? receivedQuantity, Quantity? remainingQuantity, VarianceResponse? variance, DuplicateRefResponse? possibleDuplicateOf, OrderResponse? order, bool? hasDeliveryWithoutOrder, String? requestedByName, DateTime? archivedAt, String? archivedByName, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class __$MaterialRequestResponseCopyWithImpl<$Res>
    implements _$MaterialRequestResponseCopyWith<$Res> {
  __$MaterialRequestResponseCopyWithImpl(this._self, this._then);

  final _MaterialRequestResponse _self;
  final $Res Function(_MaterialRequestResponse) _then;

/// Create a copy of MaterialRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? siteId = null,Object? number = null,Object? product = null,Object? quantity = null,Object? neededBy = null,Object? priority = null,Object? status = null,Object? isSettled = null,Object? overdueDays = null,Object? requestedById = null,Object? version = null,Object? createdAt = null,Object? siteCode = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? zoneId = freezed,Object? note = freezed,Object? statusReason = freezed,Object? receivedQuantity = freezed,Object? remainingQuantity = freezed,Object? variance = freezed,Object? possibleDuplicateOf = freezed,Object? order = freezed,Object? hasDeliveryWithoutOrder = freezed,Object? requestedByName = freezed,Object? archivedAt = freezed,Object? archivedByName = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_MaterialRequestResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefResponse,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,neededBy: null == neededBy ? _self.neededBy : neededBy // ignore: cast_nullable_to_non_nullable
as DateTime,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,overdueDays: null == overdueDays ? _self.overdueDays : overdueDays // ignore: cast_nullable_to_non_nullable
as int,requestedById: null == requestedById ? _self.requestedById : requestedById // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,siteCode: freezed == siteCode ? _self.siteCode : siteCode // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,zoneId: freezed == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as StatusReasonResponse?,receivedQuantity: freezed == receivedQuantity ? _self.receivedQuantity : receivedQuantity // ignore: cast_nullable_to_non_nullable
as Quantity?,remainingQuantity: freezed == remainingQuantity ? _self.remainingQuantity : remainingQuantity // ignore: cast_nullable_to_non_nullable
as Quantity?,variance: freezed == variance ? _self.variance : variance // ignore: cast_nullable_to_non_nullable
as VarianceResponse?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as DuplicateRefResponse?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderResponse?,hasDeliveryWithoutOrder: freezed == hasDeliveryWithoutOrder ? _self.hasDeliveryWithoutOrder : hasDeliveryWithoutOrder // ignore: cast_nullable_to_non_nullable
as bool?,requestedByName: freezed == requestedByName ? _self.requestedByName : requestedByName // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedByName: freezed == archivedByName ? _self.archivedByName : archivedByName // ignore: cast_nullable_to_non_nullable
as String?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
