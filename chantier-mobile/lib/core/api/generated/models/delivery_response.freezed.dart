// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryResponse {

 String get id; String get siteId;/// Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation.
 String get number; ProductRefResponse get product;/// Quantite recue, dans l'unite saisie.
 Quantity get quantity; DateTime get deliveryDate; Conformity get conformity; DeliveryStatus get status;/// Nombre de photos du bon.
 int get photoCount;/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.
 String get version; DateTime get createdAt; String? get clientId; DateTime? get clientCreatedAt;/// Demande liee ; `null` = non rattachee (voir `unattachedReason`).
 String? get requestId; String? get requestNumber; UnattachedReason? get unattachedReason; String? get supplierId; String? get supplierName; String? get freeSupplierName;/// Quantite convertie dans l'unite de la demande ; seulement si la livraison est rattachee.
 Quantity? get quantityInRequestUnit; String? get deliveryNoteNumber;/// Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`).
 bool? get missingNote; ReserveResponse? get reserve;/// Motif de l'annulation.
 StatusReasonResponse? get cancelReason;/// Livraison du meme fournisseur, du meme produit et du meme n° de BL deja enregistree (avertissement, jamais un blocage).
 DuplicateRefResponse? get possibleDuplicateOf;/// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
 List<DeliveryPhotoItem>? get photos;/// Montant de la livraison ; absent sans `Prices.View` ou sans prix de commande, et de la synchronisation.
 DeliveryCommercialResponse? get commercial; String? get createdByName; DateTime? get updatedAt; String? get updatedByName;
/// Create a copy of DeliveryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryResponseCopyWith<DeliveryResponse> get copyWith => _$DeliveryResponseCopyWithImpl<DeliveryResponse>(this as DeliveryResponse, _$identity);

  /// Serializes this DeliveryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.number, number) || other.number == number)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.status, status) || other.status == status)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.requestNumber, requestNumber) || other.requestNumber == requestNumber)&&(identical(other.unattachedReason, unattachedReason) || other.unattachedReason == unattachedReason)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.freeSupplierName, freeSupplierName) || other.freeSupplierName == freeSupplierName)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.missingNote, missingNote) || other.missingNote == missingNote)&&(identical(other.reserve, reserve) || other.reserve == reserve)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.commercial, commercial) || other.commercial == commercial)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,siteId,number,product,quantity,deliveryDate,conformity,status,photoCount,version,createdAt,clientId,clientCreatedAt,requestId,requestNumber,unattachedReason,supplierId,supplierName,freeSupplierName,quantityInRequestUnit,deliveryNoteNumber,missingNote,reserve,cancelReason,possibleDuplicateOf,const DeepCollectionEquality().hash(photos),commercial,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'DeliveryResponse(id: $id, siteId: $siteId, number: $number, product: $product, quantity: $quantity, deliveryDate: $deliveryDate, conformity: $conformity, status: $status, photoCount: $photoCount, version: $version, createdAt: $createdAt, clientId: $clientId, clientCreatedAt: $clientCreatedAt, requestId: $requestId, requestNumber: $requestNumber, unattachedReason: $unattachedReason, supplierId: $supplierId, supplierName: $supplierName, freeSupplierName: $freeSupplierName, quantityInRequestUnit: $quantityInRequestUnit, deliveryNoteNumber: $deliveryNoteNumber, missingNote: $missingNote, reserve: $reserve, cancelReason: $cancelReason, possibleDuplicateOf: $possibleDuplicateOf, photos: $photos, commercial: $commercial, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class $DeliveryResponseCopyWith<$Res>  {
  factory $DeliveryResponseCopyWith(DeliveryResponse value, $Res Function(DeliveryResponse) _then) = _$DeliveryResponseCopyWithImpl;
@useResult
$Res call({
 String id, String siteId, String number, ProductRefResponse product, Quantity quantity, DateTime deliveryDate, Conformity conformity, DeliveryStatus status, int photoCount, String version, DateTime createdAt, String? clientId, DateTime? clientCreatedAt, String? requestId, String? requestNumber, UnattachedReason? unattachedReason, String? supplierId, String? supplierName, String? freeSupplierName, Quantity? quantityInRequestUnit, String? deliveryNoteNumber, bool? missingNote, ReserveResponse? reserve, StatusReasonResponse? cancelReason, DuplicateRefResponse? possibleDuplicateOf, List<DeliveryPhotoItem>? photos, DeliveryCommercialResponse? commercial, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class _$DeliveryResponseCopyWithImpl<$Res>
    implements $DeliveryResponseCopyWith<$Res> {
  _$DeliveryResponseCopyWithImpl(this._self, this._then);

  final DeliveryResponse _self;
  final $Res Function(DeliveryResponse) _then;

/// Create a copy of DeliveryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? siteId = null,Object? number = null,Object? product = null,Object? quantity = null,Object? deliveryDate = null,Object? conformity = null,Object? status = null,Object? photoCount = null,Object? version = null,Object? createdAt = null,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? requestId = freezed,Object? requestNumber = freezed,Object? unattachedReason = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? freeSupplierName = freezed,Object? quantityInRequestUnit = freezed,Object? deliveryNoteNumber = freezed,Object? missingNote = freezed,Object? reserve = freezed,Object? cancelReason = freezed,Object? possibleDuplicateOf = freezed,Object? photos = freezed,Object? commercial = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefResponse,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime,conformity: null == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,requestNumber: freezed == requestNumber ? _self.requestNumber : requestNumber // ignore: cast_nullable_to_non_nullable
as String?,unattachedReason: freezed == unattachedReason ? _self.unattachedReason : unattachedReason // ignore: cast_nullable_to_non_nullable
as UnattachedReason?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,freeSupplierName: freezed == freeSupplierName ? _self.freeSupplierName : freeSupplierName // ignore: cast_nullable_to_non_nullable
as String?,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,missingNote: freezed == missingNote ? _self.missingNote : missingNote // ignore: cast_nullable_to_non_nullable
as bool?,reserve: freezed == reserve ? _self.reserve : reserve // ignore: cast_nullable_to_non_nullable
as ReserveResponse?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as StatusReasonResponse?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as DuplicateRefResponse?,photos: freezed == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<DeliveryPhotoItem>?,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as DeliveryCommercialResponse?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _DeliveryResponse implements DeliveryResponse {
  const _DeliveryResponse({required this.id, required this.siteId, required this.number, required this.product, required this.quantity, required this.deliveryDate, required this.conformity, required this.status, required this.photoCount, required this.version, required this.createdAt, this.clientId, this.clientCreatedAt, this.requestId, this.requestNumber, this.unattachedReason, this.supplierId, this.supplierName, this.freeSupplierName, this.quantityInRequestUnit, this.deliveryNoteNumber, this.missingNote, this.reserve, this.cancelReason, this.possibleDuplicateOf, final  List<DeliveryPhotoItem>? photos, this.commercial, this.createdByName, this.updatedAt, this.updatedByName}): _photos = photos;
  factory _DeliveryResponse.fromJson(Map<String, dynamic> json) => _$DeliveryResponseFromJson(json);

@override final  String id;
@override final  String siteId;
/// Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation.
@override final  String number;
@override final  ProductRefResponse product;
/// Quantite recue, dans l'unite saisie.
@override final  Quantity quantity;
@override final  DateTime deliveryDate;
@override final  Conformity conformity;
@override final  DeliveryStatus status;
/// Nombre de photos du bon.
@override final  int photoCount;
/// Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.
@override final  String version;
@override final  DateTime createdAt;
@override final  String? clientId;
@override final  DateTime? clientCreatedAt;
/// Demande liee ; `null` = non rattachee (voir `unattachedReason`).
@override final  String? requestId;
@override final  String? requestNumber;
@override final  UnattachedReason? unattachedReason;
@override final  String? supplierId;
@override final  String? supplierName;
@override final  String? freeSupplierName;
/// Quantite convertie dans l'unite de la demande ; seulement si la livraison est rattachee.
@override final  Quantity? quantityInRequestUnit;
@override final  String? deliveryNoteNumber;
/// Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`).
@override final  bool? missingNote;
@override final  ReserveResponse? reserve;
/// Motif de l'annulation.
@override final  StatusReasonResponse? cancelReason;
/// Livraison du meme fournisseur, du meme produit et du meme n° de BL deja enregistree (avertissement, jamais un blocage).
@override final  DuplicateRefResponse? possibleDuplicateOf;
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
@override final  String? createdByName;
@override final  DateTime? updatedAt;
@override final  String? updatedByName;

/// Create a copy of DeliveryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryResponseCopyWith<_DeliveryResponse> get copyWith => __$DeliveryResponseCopyWithImpl<_DeliveryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.number, number) || other.number == number)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.status, status) || other.status == status)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.requestNumber, requestNumber) || other.requestNumber == requestNumber)&&(identical(other.unattachedReason, unattachedReason) || other.unattachedReason == unattachedReason)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.freeSupplierName, freeSupplierName) || other.freeSupplierName == freeSupplierName)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.missingNote, missingNote) || other.missingNote == missingNote)&&(identical(other.reserve, reserve) || other.reserve == reserve)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.possibleDuplicateOf, possibleDuplicateOf) || other.possibleDuplicateOf == possibleDuplicateOf)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.commercial, commercial) || other.commercial == commercial)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedByName, updatedByName) || other.updatedByName == updatedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,siteId,number,product,quantity,deliveryDate,conformity,status,photoCount,version,createdAt,clientId,clientCreatedAt,requestId,requestNumber,unattachedReason,supplierId,supplierName,freeSupplierName,quantityInRequestUnit,deliveryNoteNumber,missingNote,reserve,cancelReason,possibleDuplicateOf,const DeepCollectionEquality().hash(_photos),commercial,createdByName,updatedAt,updatedByName]);

@override
String toString() {
  return 'DeliveryResponse(id: $id, siteId: $siteId, number: $number, product: $product, quantity: $quantity, deliveryDate: $deliveryDate, conformity: $conformity, status: $status, photoCount: $photoCount, version: $version, createdAt: $createdAt, clientId: $clientId, clientCreatedAt: $clientCreatedAt, requestId: $requestId, requestNumber: $requestNumber, unattachedReason: $unattachedReason, supplierId: $supplierId, supplierName: $supplierName, freeSupplierName: $freeSupplierName, quantityInRequestUnit: $quantityInRequestUnit, deliveryNoteNumber: $deliveryNoteNumber, missingNote: $missingNote, reserve: $reserve, cancelReason: $cancelReason, possibleDuplicateOf: $possibleDuplicateOf, photos: $photos, commercial: $commercial, createdByName: $createdByName, updatedAt: $updatedAt, updatedByName: $updatedByName)';
}


}

/// @nodoc
abstract mixin class _$DeliveryResponseCopyWith<$Res> implements $DeliveryResponseCopyWith<$Res> {
  factory _$DeliveryResponseCopyWith(_DeliveryResponse value, $Res Function(_DeliveryResponse) _then) = __$DeliveryResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String siteId, String number, ProductRefResponse product, Quantity quantity, DateTime deliveryDate, Conformity conformity, DeliveryStatus status, int photoCount, String version, DateTime createdAt, String? clientId, DateTime? clientCreatedAt, String? requestId, String? requestNumber, UnattachedReason? unattachedReason, String? supplierId, String? supplierName, String? freeSupplierName, Quantity? quantityInRequestUnit, String? deliveryNoteNumber, bool? missingNote, ReserveResponse? reserve, StatusReasonResponse? cancelReason, DuplicateRefResponse? possibleDuplicateOf, List<DeliveryPhotoItem>? photos, DeliveryCommercialResponse? commercial, String? createdByName, DateTime? updatedAt, String? updatedByName
});



}
/// @nodoc
class __$DeliveryResponseCopyWithImpl<$Res>
    implements _$DeliveryResponseCopyWith<$Res> {
  __$DeliveryResponseCopyWithImpl(this._self, this._then);

  final _DeliveryResponse _self;
  final $Res Function(_DeliveryResponse) _then;

/// Create a copy of DeliveryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? siteId = null,Object? number = null,Object? product = null,Object? quantity = null,Object? deliveryDate = null,Object? conformity = null,Object? status = null,Object? photoCount = null,Object? version = null,Object? createdAt = null,Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? requestId = freezed,Object? requestNumber = freezed,Object? unattachedReason = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? freeSupplierName = freezed,Object? quantityInRequestUnit = freezed,Object? deliveryNoteNumber = freezed,Object? missingNote = freezed,Object? reserve = freezed,Object? cancelReason = freezed,Object? possibleDuplicateOf = freezed,Object? photos = freezed,Object? commercial = freezed,Object? createdByName = freezed,Object? updatedAt = freezed,Object? updatedByName = freezed,}) {
  return _then(_DeliveryResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductRefResponse,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime,conformity: null == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,requestNumber: freezed == requestNumber ? _self.requestNumber : requestNumber // ignore: cast_nullable_to_non_nullable
as String?,unattachedReason: freezed == unattachedReason ? _self.unattachedReason : unattachedReason // ignore: cast_nullable_to_non_nullable
as UnattachedReason?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,freeSupplierName: freezed == freeSupplierName ? _self.freeSupplierName : freeSupplierName // ignore: cast_nullable_to_non_nullable
as String?,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,missingNote: freezed == missingNote ? _self.missingNote : missingNote // ignore: cast_nullable_to_non_nullable
as bool?,reserve: freezed == reserve ? _self.reserve : reserve // ignore: cast_nullable_to_non_nullable
as ReserveResponse?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as StatusReasonResponse?,possibleDuplicateOf: freezed == possibleDuplicateOf ? _self.possibleDuplicateOf : possibleDuplicateOf // ignore: cast_nullable_to_non_nullable
as DuplicateRefResponse?,photos: freezed == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<DeliveryPhotoItem>?,commercial: freezed == commercial ? _self.commercial : commercial // ignore: cast_nullable_to_non_nullable
as DeliveryCommercialResponse?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedByName: freezed == updatedByName ? _self.updatedByName : updatedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
