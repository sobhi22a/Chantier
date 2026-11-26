// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryDetailResponse {

 List<RequestHistoryItem>? get history; String? get id; String? get siteId; String? get clientId; DateTime? get clientCreatedAt;/// Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation.
 String? get number;/// Demande liee ; `null` = non rattachee (voir `unattachedReason`).
 String? get requestId; String? get requestNumber; UnattachedReason? get unattachedReason; String? get supplierId; String? get supplierName; String? get freeSupplierName; ProductRefResponse? get product;/// Quantite recue, dans l'unite saisie.
 Quantity? get quantity;/// Quantite convertie dans l'unite de la demande ; seulement si la livraison est rattachee.
 Quantity? get quantityInRequestUnit; DateTime? get deliveryDate; String? get deliveryNoteNumber;/// Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`).
 bool? get missingNote; Conformity? get conformity; ReserveResponse? get reserve; DeliveryStatus? get status;/// Motif de l'annulation.
 StatusReasonResponse? get cancelReason;/// Livraison du meme fournisseur, du meme produit et du meme n° de BL deja enregistree (avertissement, jamais un blocage).
 DuplicateRefResponse? get possibleDuplicateOf;/// Nombre de photos du bon.
 int? get photoCount;/// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
 List<DeliveryPhotoItem>? get photos;/// Montant de la livraison ; absent sans `Prices.View` ou sans prix de commande, et de la synchronisation.
 DeliveryCommercialResponse? get commercial;/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.
 String? get version; DateTime? get createdAt; String? get createdByName; DateTime? get updatedAt; String? get updatedByName;
/// Create a copy of DeliveryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryDetailResponseCopyWith<DeliveryDetailResponse> get copyWith => _$DeliveryDetailResponseCopyWithImpl<DeliveryDetailResponse>(this as DeliveryDetailResponse, _$identity);

  /// Serializes this DeliveryDetailResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryDetailResponse&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.number, number) || other.number == number)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.requestNumber, requestNumber) || other.requestNumber == requestNumber)&&(identical(other.unattachedReason, unattachedReason) || other.unattachedReason == unattachedReason)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.freeSupplierName, freeSupplierName) || other.freeSupplierName == freeSupplierName)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.missingNote, missingNote) || other.missingNote == missingNote)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.reserve, reserve) || other.reserve == reserve)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.commercial, commercial) || other.commercial == commercial)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(history),id,siteId,clientId,clientCreatedAt,number,requestId,requestNumber,unattachedReason,supplierId,supplierName,freeSupplierName,product,quantity,quantityInRequestUnit,deliveryDate,deliveryNoteNumber,missingNote,conformity,reserve,status,cancelReason,possibleDuplicateOf,photoCount,const DeepCollectionEquality().hash(photos),commercial,version,createdAt,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'DeliveryDetailResponse(history: $history, id: $id, siteId: $siteId, clientId: $clientId, clientCreatedAt: $clientCreatedAt, number: $number, requestId: $requestId, requestNumber: $requestNumber, unattachedReason: $unattachedReason, supplierId: $supplierId, supplierName: $supplierName, freeSupplierName: $freeSupplierName, product: $product, quantity: $quantity, quantityInRequestUnit: $quantityInRequestUnit, deliveryDate: $deliveryDate, deliveryNoteNumber: $deliveryNoteNumber, missingNote: $missingNote, conformity: $conformity, reserve: $reserve, status: $status, cancelReason: $cancelReason, possibleDuplicateOf: $possibleDuplicateOf, photoCount: $photoCount, photos: $photos, commercial: $commercial, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class $DeliveryDetailResponseCopyWith<$Res>  {
  factory $DeliveryDetailResponseCopyWith(DeliveryDetailResponse value, $Res Function(DeliveryDetailResponse) _then) = _$DeliveryDetailResponseCopyWithImpl;
@useResult
$Res call({
 List<RequestHistoryItem>? history, String? id, String? siteId, String? clientId, DateTime? clientCreatedAt, String? number, String? requestId, String? requestNumber, UnattachedReason? unattachedReason, String? supplierId, String? supplierName, String? freeSupplierName, ProductRefResponse? product, Quantity? quantity, Quantity? quantityInRequestUnit, DateTime? deliveryDate, String? deliveryNoteNumber, bool? missingNote, Conformity? conformity, ReserveResponse? reserve, DeliveryStatus? status, StatusReasonResponse? cancelReason, DuplicateRefResponse? possibleDuplicateOf, int? photoCount, List<DeliveryPhotoItem>? photos, DeliveryCommercialResponse? commercial, String? version, DateTime? createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class _$DeliveryDetailResponseCopyWithImpl<$Res>
    implements $DeliveryDetailResponseCopyWith<$Res> {
  _$DeliveryDetailResponseCopyWithImpl(this._self, this._then);

  final DeliveryDetailResponse _self;
  final $Res Function(DeliveryDetailResponse) _then;

/// Create a copy of DeliveryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? history = freezed,Object? id = freezed,Object? siteId = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? number = freezed,Object? requestId = freezed,Object? requestNumber = freezed,Object? unattachedReason = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? freeSupplierName = freezed,Object? product = freezed,Object? quantity = freezed,Object? quantityInRequestUnit = freezed,Object? deliveryDate = freezed,Object? deliveryNoteNumber = freezed,Object? missingNote = freezed,Object? conformity = freezed,Object? reserve = freezed,Object? status = freezed,Object? cancelReason = freezed,Object? possibleDuplicateOf = freezed,Object? photoCount = freezed,Object? photos = freezed,Object? commercial = freezed,Object? version = freezed,Object? createdAt = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_self.copyWith(
history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<RequestHistoryItem>?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,requestNumber: freezed == requestNumber ? _self.requestNumber : requestNumber // ignore: cast_nullable_to_non_nullable
as String?,unattachedReason: freezed == unattachedReason ? _self.unattachedReason : unattachedReason // ignore: cast_nullable_to_non_nullable
as UnattachedReason?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,freeSupplierName: freezed == freeSupplierName ? _self.freeSupplierName : freeSupplierName // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefResponse?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity?,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,missingNote: freezed == missingNote ? _self.missingNote : missingNote // ignore: cast_nullable_to_non_nullable
as bool?,conformity: freezed == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity?,reserve: freezed == reserve ? _self.reserve : reserve // ignore: cast_nullable_to_non_nullable
as ReserveResponse?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as StatusReasonResponse?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as DuplicateRefResponse?,photoCount: freezed == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int?,photos: freezed == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<DeliveryPhotoItem>?,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as DeliveryCommercialResponse?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
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

class _DeliveryDetailResponse implements DeliveryDetailResponse {
  const _DeliveryDetailResponse({final  List<RequestHistoryItem>? history, this.id, this.siteId, this.clientId, this.clientCreatedAt, this.number, this.requestId, this.requestNumber, this.unattachedReason, this.supplierId, this.supplierName, this.freeSupplierName, this.product, this.quantity, this.quantityInRequestUnit, this.deliveryDate, this.deliveryNoteNumber, this.missingNote, this.conformity, this.reserve, this.status, this.cancelReason, this.possibleDuplicateOf, this.photoCount, final  List<DeliveryPhotoItem>? photos, this.commercial, this.version, this.createdAt, this.createdByName, this.updatedAt, this.updatedByName}): _history = history,_photos = photos;
  factory _DeliveryDetailResponse.fromJson(Map<String, dynamic> json) => _$DeliveryDetailResponseFromJson(json);

 final  List<RequestHistoryItem>? _history;
@override List<RequestHistoryItem>? get history {
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
@override final  UnattachedReason? unattachedReason;
@override final  String? supplierId;
@override final  String? supplierName;
@override final  String? freeSupplierName;
@override final  ProductRefResponse? product;
/// Quantite recue, dans l'unite saisie.
@override final  Quantity? quantity;
/// Quantite convertie dans l'unite de la demande ; seulement si la livraison est rattachee.
@override final  Quantity? quantityInRequestUnit;
@override final  DateTime? deliveryDate;
@override final  String? deliveryNoteNumber;
/// Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`).
@override final  bool? missingNote;
@override final  Conformity? conformity;
@override final  ReserveResponse? reserve;
@override final  DeliveryStatus? status;
/// Motif de l'annulation.
@override final  StatusReasonResponse? cancelReason;
/// Livraison du meme fournisseur, du meme produit et du meme n° de BL deja enregistree (avertissement, jamais un blocage).
@override final  DuplicateRefResponse? possibleDuplicateOf;
/// Nombre de photos du bon.
@override final  int? photoCount;
/// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
 final  List<DeliveryPhotoItem>? _photos;
/// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
@override List<DeliveryPhotoItem>? get photos {
  final value = _photos;
  if (value == null) return null;
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Montant de la livraison ; absent sans `Prices.View` ou sans prix de commande, et de la synchronisation.
@override final  DeliveryCommercialResponse? commercial;
/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.
@override final  String? version;
@override final  DateTime? createdAt;
@override final  String? createdByName;
@override final  DateTime? updatedAt;
@override final  String? updatedByName;

/// Create a copy of DeliveryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryDetailResponseCopyWith<_DeliveryDetailResponse> get copyWith => __$DeliveryDetailResponseCopyWithImpl<_DeliveryDetailResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryDetailResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryDetailResponse&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.number, number) || other.number == number)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.requestNumber, requestNumber) || other.requestNumber == requestNumber)&&(identical(other.unattachedReason, unattachedReason) || other.unattachedReason == unattachedReason)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.freeSupplierName, freeSupplierName) || other.freeSupplierName == freeSupplierName)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.missingNote, missingNote) || other.missingNote == missingNote)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.reserve, reserve) || other.reserve == reserve)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.commercial, commercial) || other.commercial == commercial)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_history),id,siteId,clientId,clientCreatedAt,number,requestId,requestNumber,unattachedReason,supplierId,supplierName,freeSupplierName,product,quantity,quantityInRequestUnit,deliveryDate,deliveryNoteNumber,missingNote,conformity,reserve,status,cancelReason,possibleDuplicateOf,photoCount,const DeepCollectionEquality().hash(_photos),commercial,version,createdAt,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'DeliveryDetailResponse(history: $history, id: $id, siteId: $siteId, clientId: $clientId, clientCreatedAt: $clientCreatedAt, number: $number, requestId: $requestId, requestNumber: $requestNumber, unattachedReason: $unattachedReason, supplierId: $supplierId, supplierName: $supplierName, freeSupplierName: $freeSupplierName, product: $product, quantity: $quantity, quantityInRequestUnit: $quantityInRequestUnit, deliveryDate: $deliveryDate, deliveryNoteNumber: $deliveryNoteNumber, missingNote: $missingNote, conformity: $conformity, reserve: $reserve, status: $status, cancelReason: $cancelReason, possibleDuplicateOf: $possibleDuplicateOf, photoCount: $photoCount, photos: $photos, commercial: $commercial, version: $version, createdAt: $createdAt, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class _$DeliveryDetailResponseCopyWith<$Res> implements $DeliveryDetailResponseCopyWith<$Res> {
  factory _$DeliveryDetailResponseCopyWith(_DeliveryDetailResponse value, $Res Function(_DeliveryDetailResponse) _then) = __$DeliveryDetailResponseCopyWithImpl;
@override @useResult
$Res call({
 List<RequestHistoryItem>? history, String? id, String? siteId, String? clientId, DateTime? clientCreatedAt, String? number, String? requestId, String? requestNumber, UnattachedReason? unattachedReason, String? supplierId, String? supplierName, String? freeSupplierName, ProductRefResponse? product, Quantity? quantity, Quantity? quantityInRequestUnit, DateTime? deliveryDate, String? deliveryNoteNumber, bool? missingNote, Conformity? conformity, ReserveResponse? reserve, DeliveryStatus? status, StatusReasonResponse? cancelReason, DuplicateRefResponse? possibleDuplicateOf, int? photoCount, List<DeliveryPhotoItem>? photos, DeliveryCommercialResponse? commercial, String? version, DateTime? createdAt, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class __$DeliveryDetailResponseCopyWithImpl<$Res>
    implements _$DeliveryDetailResponseCopyWith<$Res> {
  __$DeliveryDetailResponseCopyWithImpl(this._self, this._then);

  final _DeliveryDetailResponse _self;
  final $Res Function(_DeliveryDetailResponse) _then;

/// Create a copy of DeliveryDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? history = freezed,Object? id = freezed,Object? siteId = freezed,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? number = freezed,Object? requestId = freezed,Object? requestNumber = freezed,Object? unattachedReason = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? freeSupplierName = freezed,Object? product = freezed,Object? quantity = freezed,Object? quantityInRequestUnit = freezed,Object? deliveryDate = freezed,Object? deliveryNoteNumber = freezed,Object? missingNote = freezed,Object? conformity = freezed,Object? reserve = freezed,Object? status = freezed,Object? cancelReason = freezed,Object? possibleDuplicateOf = freezed,Object? photoCount = freezed,Object? photos = freezed,Object? commercial = freezed,Object? version = freezed,Object? createdAt = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_DeliveryDetailResponse(
history: freezed == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<RequestHistoryItem>?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,requestNumber: freezed == requestNumber ? _self.requestNumber : requestNumber // ignore: cast_nullable_to_non_nullable
as String?,unattachedReason: freezed == unattachedReason ? _self.unattachedReason : unattachedReason // ignore: cast_nullable_to_non_nullable
as UnattachedReason?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,freeSupplierName: freezed == freeSupplierName ? _self.freeSupplierName : freeSupplierName // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefResponse?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity?,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,missingNote: freezed == missingNote ? _self.missingNote : missingNote // ignore: cast_nullable_to_non_nullable
as bool?,conformity: freezed == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity?,reserve: freezed == reserve ? _self.reserve : reserve // ignore: cast_nullable_to_non_nullable
as ReserveResponse?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as StatusReasonResponse?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as DuplicateRefResponse?,photoCount: freezed == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int?,photos: freezed == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<DeliveryPhotoItem>?,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as DeliveryCommercialResponse?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
