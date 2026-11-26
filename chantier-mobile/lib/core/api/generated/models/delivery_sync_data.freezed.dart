// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_sync_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliverySyncData {

 List<History>? get history; String? get id; String? get siteId; String? get clientId; DateTime? get clientCreatedAt;/// Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation.
 String? get number;/// Demande liee ; `null` = non rattachee (voir `unattachedReason`).
 String? get requestId; String? get requestNumber; DeliverySyncDataUnattachedReason? get unattachedReason; String? get supplierId; String? get supplierName; String? get freeSupplierName;/// Produit d'une demande : du catalogue (`productId`, `name`) et/ou le nom libre saisi (`freeName`, conserve apres un rattachement).
 Product? get product; Quantity? get quantity; Quantity? get quantityInRequestUnit; DateTime? get deliveryDate; String? get deliveryNoteNumber;/// Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`).
 bool? get missingNote;/// Conformite a la reception : « Avec reserve » exige un motif de la liste (quantite manquante, produit abime...).
 DeliverySyncDataConformity? get conformity;/// Reserve a la reception : un motif de la liste (`QuantityMissing`, `DamagedProduct`...) et une remarque.
 Reserve? get reserve;/// Etat d'une livraison : enregistree, ou annulee (elle reste visible mais n'entre plus dans aucun total).
 DeliverySyncDataStatus? get status;/// Motif d'un refus ou d'une annulation.
 CancelReason? get cancelReason;/// Demande semblable deja ouverte (avertissement, jamais un blocage).
 PossibleDuplicateOf? get possibleDuplicateOf;/// Nombre de photos du bon.
 int? get photoCount;/// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
 List<Photos>? get photos;/// Montant d'une livraison : prix de la commande x quantite convertie, arrondi au centime (DZD). Absent sans `Prices.View`.
 Commercial? get commercial;/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.
 String? get version; DateTime? get createdAt; String? get createdByName; DateTime? get updatedAt; String? get updatedByName;
/// Create a copy of DeliverySyncData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliverySyncDataCopyWith<DeliverySyncData> get copyWith => _$DeliverySyncDataCopyWithImpl<DeliverySyncData>(this as DeliverySyncData, _$identity);

  /// Serializes this DeliverySyncData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliverySyncData&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.number, number) || other.number == number)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.requestNumber, requestNumber) || other.requestNumber == requestNumber)&&(identical(other.unattachedReason, unattachedReason) || other.unattachedReason == unattachedReason)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.freeSupplierName, freeSupplierName) || other.freeSupplierName == freeSupplierName)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.missingNote, missingNote) || other.missingNote == missingNote)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.reserve, reserve) || other.reserve == reserve)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.commercial, commercial) || other.commercial == commercial)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(history),id,siteId,clientId,clientCreatedAt,number,requestId,requestNumber,unattachedReason,supplierId,supplierName,freeSupplierName,product,quantity,quantityInRequestUnit,deliveryDate,deliveryNoteNumber,missingNote,conformity,reserve,status,cancelReason,possibleDuplicateOf,photoCount,const DeepCollectionEquality().hash(photos),commercial,version,createdAt,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'DeliverySyncData(history: $history, id: $id, siteId: $siteId, clientId: $clientId, clientCreatedAt: $clientCreatedAt, number: $number, requestId: $requestId, requestNumber: $requestNumber, unattachedReason: $unattachedReason, supplierId: $supplierId, supplierName: $supplierName, freeSupplierName: $freeSupplierName, product: $product, quantity: $quantity, quantityInRequestUnit: $quantityInRequestUnit, deliveryDate: $deliveryDate, deliveryNoteNumber: $deliveryNoteNumber, missingNote: $missingNote, conformity: $conformity, reserve: $reserve, status: $status, cancelReason: $cancelReason, possibleDuplicateOf: $possibleDuplicateOf, photoCount: $photoCount, photos: $photos, commercial: $commercial, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class $DeliverySyncDataCopyWith<$Res>  {
  factory $DeliverySyncDataCopyWith(DeliverySyncData value, $Res Function(DeliverySyncData) _then) = _$DeliverySyncDataCopyWithImpl;
@useResult
$Res call({
 List<History>? history, String? id, String? siteId, String? clientId, DateTime? clientCreatedAt, String? number, String? requestId, String? requestNumber, DeliverySyncDataUnattachedReason? unattachedReason, String? supplierId, String? supplierName, String? freeSupplierName, Product? product, Quantity? quantity, Quantity? quantityInRequestUnit, DateTime? deliveryDate, String? deliveryNoteNumber, bool? missingNote, DeliverySyncDataConformity? conformity, Reserve? reserve, DeliverySyncDataStatus? status, CancelReason? cancelReason, PossibleDuplicateOf? possibleDuplicateOf, int? photoCount, List<Photos>? photos, Commercial? commercial, String? version, DateTime? createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class _$DeliverySyncDataCopyWithImpl<$Res>
    implements $DeliverySyncDataCopyWith<$Res> {
  _$DeliverySyncDataCopyWithImpl(this._self, this._then);

  final DeliverySyncData _self;
  final $Res Function(DeliverySyncData) _then;

/// Create a copy of DeliverySyncData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? history = freezed,Object? id = freezed,Object? siteId = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? number = freezed,Object? requestId = freezed,Object? requestNumber = freezed,Object? unattachedReason = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? freeSupplierName = freezed,Object? product = freezed,Object? quantity = freezed,Object? quantityInRequestUnit = freezed,Object? deliveryDate = freezed,Object? deliveryNoteNumber = freezed,Object? missingNote = freezed,Object? conformity = freezed,Object? reserve = freezed,Object? status = freezed,Object? cancelReason = freezed,Object? possibleDuplicateOf = freezed,Object? photoCount = freezed,Object? photos = freezed,Object? commercial = freezed,Object? version = freezed,Object? createdAt = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_self.copyWith(
history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<History>?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,requestNumber: freezed == requestNumber ? _self.requestNumber : requestNumber // ignore: cast_nullable_to_non_nullable
as String?,unattachedReason: freezed == unattachedReason ? _self.unattachedReason : unattachedReason // ignore: cast_nullable_to_non_nullable
as DeliverySyncDataUnattachedReason?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,freeSupplierName: freezed == freeSupplierName ? _self.freeSupplierName : freeSupplierName // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity?,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,missingNote: freezed == missingNote ? _self.missingNote : missingNote // ignore: cast_nullable_to_non_nullable
as bool?,conformity: freezed == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as DeliverySyncDataConformity?,reserve: freezed == reserve ? _self.reserve : reserve // ignore: cast_nullable_to_non_nullable
as Reserve?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliverySyncDataStatus?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as CancelReason?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as PossibleDuplicateOf?,photoCount: freezed == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int?,photos: freezed == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<Photos>?,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as Commercial?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
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

class _DeliverySyncData implements DeliverySyncData {
  const _DeliverySyncData({final  List<History>? history, this.id, this.siteId, this.clientId, this.clientCreatedAt, this.number, this.requestId, this.requestNumber, this.unattachedReason, this.supplierId, this.supplierName, this.freeSupplierName, this.product, this.quantity, this.quantityInRequestUnit, this.deliveryDate, this.deliveryNoteNumber, this.missingNote, this.conformity, this.reserve, this.status, this.cancelReason, this.possibleDuplicateOf, this.photoCount, final  List<Photos>? photos, this.commercial, this.version, this.createdAt, this.createdByName, this.updatedAt, this.updatedByName}): _history = history,_photos = photos;
  factory _DeliverySyncData.fromJson(Map<String, dynamic> json) => _$DeliverySyncDataFromJson(json);

 final  List<History>? _history;
@override List<History>? get history {
  final value = _history;
  if (value == null) return null;
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? id;
@override final  String? siteId;
@override final  String? clientId;
@override final  DateTime? clientCreatedAt;
/// Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation.
@override final  String? number;
/// Demande liee ; `null` = non rattachee (voir `unattachedReason`).
@override final  String? requestId;
@override final  String? requestNumber;
@override final  DeliverySyncDataUnattachedReason? unattachedReason;
@override final  String? supplierId;
@override final  String? supplierName;
@override final  String? freeSupplierName;
/// Produit d'une demande : du catalogue (`productId`, `name`) et/ou le nom libre saisi (`freeName`, conserve apres un rattachement).
@override final  Product? product;
@override final  Quantity? quantity;
@override final  Quantity? quantityInRequestUnit;
@override final  DateTime? deliveryDate;
@override final  String? deliveryNoteNumber;
/// Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`).
@override final  bool? missingNote;
/// Conformite a la reception : « Avec reserve » exige un motif de la liste (quantite manquante, produit abime...).
@override final  DeliverySyncDataConformity? conformity;
/// Reserve a la reception : un motif de la liste (`QuantityMissing`, `DamagedProduct`...) et une remarque.
@override final  Reserve? reserve;
/// Etat d'une livraison : enregistree, ou annulee (elle reste visible mais n'entre plus dans aucun total).
@override final  DeliverySyncDataStatus? status;
/// Motif d'un refus ou d'une annulation.
@override final  CancelReason? cancelReason;
/// Demande semblable deja ouverte (avertissement, jamais un blocage).
@override final  PossibleDuplicateOf? possibleDuplicateOf;
/// Nombre de photos du bon.
@override final  int? photoCount;
/// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
 final  List<Photos>? _photos;
/// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
@override List<Photos>? get photos {
  final value = _photos;
  if (value == null) return null;
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Montant d'une livraison : prix de la commande x quantite convertie, arrondi au centime (DZD). Absent sans `Prices.View`.
@override final  Commercial? commercial;
/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.
@override final  String? version;
@override final  DateTime? createdAt;
@override final  String? createdByName;
@override final  DateTime? updatedAt;
@override final  String? updatedByName;

/// Create a copy of DeliverySyncData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliverySyncDataCopyWith<_DeliverySyncData> get copyWith => __$DeliverySyncDataCopyWithImpl<_DeliverySyncData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliverySyncDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliverySyncData&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.number, number) || other.number == number)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.requestNumber, requestNumber) || other.requestNumber == requestNumber)&&(identical(other.unattachedReason, unattachedReason) || other.unattachedReason == unattachedReason)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.freeSupplierName, freeSupplierName) || other.freeSupplierName == freeSupplierName)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.missingNote, missingNote) || other.missingNote == missingNote)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.reserve, reserve) || other.reserve == reserve)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.commercial, commercial) || other.commercial == commercial)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_history),id,siteId,clientId,clientCreatedAt,number,requestId,requestNumber,unattachedReason,supplierId,supplierName,freeSupplierName,product,quantity,quantityInRequestUnit,deliveryDate,deliveryNoteNumber,missingNote,conformity,reserve,status,cancelReason,possibleDuplicateOf,photoCount,const DeepCollectionEquality().hash(_photos),commercial,version,createdAt,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'DeliverySyncData(history: $history, id: $id, siteId: $siteId, clientId: $clientId, clientCreatedAt: $clientCreatedAt, number: $number, requestId: $requestId, requestNumber: $requestNumber, unattachedReason: $unattachedReason, supplierId: $supplierId, supplierName: $supplierName, freeSupplierName: $freeSupplierName, product: $product, quantity: $quantity, quantityInRequestUnit: $quantityInRequestUnit, deliveryDate: $deliveryDate, deliveryNoteNumber: $deliveryNoteNumber, missingNote: $missingNote, conformity: $conformity, reserve: $reserve, status: $status, cancelReason: $cancelReason, possibleDuplicateOf: $possibleDuplicateOf, photoCount: $photoCount, photos: $photos, commercial: $commercial, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class _$DeliverySyncDataCopyWith<$Res> implements $DeliverySyncDataCopyWith<$Res> {
  factory _$DeliverySyncDataCopyWith(_DeliverySyncData value, $Res Function(_DeliverySyncData) _then) = __$DeliverySyncDataCopyWithImpl;
@override @useResult
$Res call({
 List<History>? history, String? id, String? siteId, String? clientId, DateTime? clientCreatedAt, String? number, String? requestId, String? requestNumber, DeliverySyncDataUnattachedReason? unattachedReason, String? supplierId, String? supplierName, String? freeSupplierName, Product? product, Quantity? quantity, Quantity? quantityInRequestUnit, DateTime? deliveryDate, String? deliveryNoteNumber, bool? missingNote, DeliverySyncDataConformity? conformity, Reserve? reserve, DeliverySyncDataStatus? status, CancelReason? cancelReason, PossibleDuplicateOf? possibleDuplicateOf, int? photoCount, List<Photos>? photos, Commercial? commercial, String? version, DateTime? createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class __$DeliverySyncDataCopyWithImpl<$Res>
    implements _$DeliverySyncDataCopyWith<$Res> {
  __$DeliverySyncDataCopyWithImpl(this._self, this._then);

  final _DeliverySyncData _self;
  final $Res Function(_DeliverySyncData) _then;

/// Create a copy of DeliverySyncData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? history = freezed,Object? id = freezed,Object? siteId = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? number = freezed,Object? requestId = freezed,Object? requestNumber = freezed,Object? unattachedReason = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? freeSupplierName = freezed,Object? product = freezed,Object? quantity = freezed,Object? quantityInRequestUnit = freezed,Object? deliveryDate = freezed,Object? deliveryNoteNumber = freezed,Object? missingNote = freezed,Object? conformity = freezed,Object? reserve = freezed,Object? status = freezed,Object? cancelReason = freezed,Object? possibleDuplicateOf = freezed,Object? photoCount = freezed,Object? photos = freezed,Object? commercial = freezed,Object? version = freezed,Object? createdAt = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_DeliverySyncData(
history: freezed == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<History>?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,requestNumber: freezed == requestNumber ? _self.requestNumber : requestNumber // ignore: cast_nullable_to_non_nullable
as String?,unattachedReason: freezed == unattachedReason ? _self.unattachedReason : unattachedReason // ignore: cast_nullable_to_non_nullable
as DeliverySyncDataUnattachedReason?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,freeSupplierName: freezed == freeSupplierName ? _self.freeSupplierName : freeSupplierName // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity?,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,missingNote: freezed == missingNote ? _self.missingNote : missingNote // ignore: cast_nullable_to_non_nullable
as bool?,conformity: freezed == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as DeliverySyncDataConformity?,reserve: freezed == reserve ? _self.reserve : reserve // ignore: cast_nullable_to_non_nullable
as Reserve?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliverySyncDataStatus?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as CancelReason?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as PossibleDuplicateOf?,photoCount: freezed == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int?,photos: freezed == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<Photos>?,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as Commercial?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
