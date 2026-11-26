// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_delivery_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestDeliveryItem {

 String get id; String get number; DateTime get deliveryDate; Quantity get quantity; DeliveryStatus get status; String? get deliveryNoteNumber; Conformity get conformity; int get photoCount;/// Quantite convertie dans l'unite de la demande ; absente d'une livraison annulee.
 Quantity? get quantityInRequestUnit;
/// Create a copy of RequestDeliveryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestDeliveryItemCopyWith<RequestDeliveryItem> get copyWith => _$RequestDeliveryItemCopyWithImpl<RequestDeliveryItem>(this as RequestDeliveryItem, _$identity);

  /// Serializes this RequestDeliveryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestDeliveryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,deliveryDate,quantity,status,deliveryNoteNumber,conformity,photoCount,quantityInRequestUnit);

@override
String toString() {
  return 'RequestDeliveryItem(id: $id, number: $number, deliveryDate: $deliveryDate, quantity: $quantity, status: $status, deliveryNoteNumber: $deliveryNoteNumber, conformity: $conformity, photoCount: $photoCount, quantityInRequestUnit: $quantityInRequestUnit)';
}


}

/// @nodoc
abstract mixin class $RequestDeliveryItemCopyWith<$Res>  {
  factory $RequestDeliveryItemCopyWith(RequestDeliveryItem value, $Res Function(RequestDeliveryItem) _then) = _$RequestDeliveryItemCopyWithImpl;
@useResult
$Res call({
 String id, String number, DateTime deliveryDate, Quantity quantity, DeliveryStatus status, String? deliveryNoteNumber, Conformity conformity, int photoCount, Quantity? quantityInRequestUnit
});



}
/// @nodoc
class _$RequestDeliveryItemCopyWithImpl<$Res>
    implements $RequestDeliveryItemCopyWith<$Res> {
  _$RequestDeliveryItemCopyWithImpl(this._self, this._then);

  final RequestDeliveryItem _self;
  final $Res Function(RequestDeliveryItem) _then;

/// Create a copy of RequestDeliveryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? deliveryDate = null,Object? quantity = null,Object? status = null,Object? deliveryNoteNumber = freezed,Object? conformity = null,Object? photoCount = null,Object? quantityInRequestUnit = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,conformity: null == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RequestDeliveryItem implements RequestDeliveryItem {
  const _RequestDeliveryItem({required this.id, required this.number, required this.deliveryDate, required this.quantity, required this.status, required this.deliveryNoteNumber, required this.conformity, required this.photoCount, this.quantityInRequestUnit});
  factory _RequestDeliveryItem.fromJson(Map<String, dynamic> json) => _$RequestDeliveryItemFromJson(json);

@override final  String id;
@override final  String number;
@override final  DateTime deliveryDate;
@override final  Quantity quantity;
@override final  DeliveryStatus status;
@override final  String? deliveryNoteNumber;
@override final  Conformity conformity;
@override final  int photoCount;
/// Quantite convertie dans l'unite de la demande ; absente d'une livraison annulee.
@override final  Quantity? quantityInRequestUnit;

/// Create a copy of RequestDeliveryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestDeliveryItemCopyWith<_RequestDeliveryItem> get copyWith => __$RequestDeliveryItemCopyWithImpl<_RequestDeliveryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestDeliveryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestDeliveryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,deliveryDate,quantity,status,deliveryNoteNumber,conformity,photoCount,quantityInRequestUnit);

@override
String toString() {
  return 'RequestDeliveryItem(id: $id, number: $number, deliveryDate: $deliveryDate, quantity: $quantity, status: $status, deliveryNoteNumber: $deliveryNoteNumber, conformity: $conformity, photoCount: $photoCount, quantityInRequestUnit: $quantityInRequestUnit)';
}


}

/// @nodoc
abstract mixin class _$RequestDeliveryItemCopyWith<$Res> implements $RequestDeliveryItemCopyWith<$Res> {
  factory _$RequestDeliveryItemCopyWith(_RequestDeliveryItem value, $Res Function(_RequestDeliveryItem) _then) = __$RequestDeliveryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String number, DateTime deliveryDate, Quantity quantity, DeliveryStatus status, String? deliveryNoteNumber, Conformity conformity, int photoCount, Quantity? quantityInRequestUnit
});



}
/// @nodoc
class __$RequestDeliveryItemCopyWithImpl<$Res>
    implements _$RequestDeliveryItemCopyWith<$Res> {
  __$RequestDeliveryItemCopyWithImpl(this._self, this._then);

  final _RequestDeliveryItem _self;
  final $Res Function(_RequestDeliveryItem) _then;

/// Create a copy of RequestDeliveryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? deliveryDate = null,Object? quantity = null,Object? status = null,Object? deliveryNoteNumber = freezed,Object? conformity = null,Object? photoCount = null,Object? quantityInRequestUnit = freezed,}) {
  return _then(_RequestDeliveryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,conformity: null == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,
  ));
}


}

// dart format on
