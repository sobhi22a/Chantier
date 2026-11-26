// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deliveries.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Deliveries {

 String get id; String get number; DateTime get deliveryDate; Quantity get quantity;/// Etat d'une livraison : enregistree, ou annulee (elle reste visible mais n'entre plus dans aucun total).
 Status get status; String? get deliveryNoteNumber;/// Conformite a la reception : « Avec reserve » exige un motif de la liste (quantite manquante, produit abime...).
 Conformity get conformity; int get photoCount; Quantity? get quantityInRequestUnit;
/// Create a copy of Deliveries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveriesCopyWith<Deliveries> get copyWith => _$DeliveriesCopyWithImpl<Deliveries>(this as Deliveries, _$identity);

  /// Serializes this Deliveries to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Deliveries&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,deliveryDate,quantity,status,deliveryNoteNumber,conformity,photoCount,quantityInRequestUnit);

@override
String toString() {
  return 'Deliveries(id: $id, number: $number, deliveryDate: $deliveryDate, quantity: $quantity, status: $status, deliveryNoteNumber: $deliveryNoteNumber, conformity: $conformity, photoCount: $photoCount, quantityInRequestUnit: $quantityInRequestUnit)';
}


}

/// @nodoc
abstract mixin class $DeliveriesCopyWith<$Res>  {
  factory $DeliveriesCopyWith(Deliveries value, $Res Function(Deliveries) _then) = _$DeliveriesCopyWithImpl;
@useResult
$Res call({
 String id, String number, DateTime deliveryDate, Quantity quantity, Status status, String? deliveryNoteNumber, Conformity conformity, int photoCount, Quantity? quantityInRequestUnit
});



}
/// @nodoc
class _$DeliveriesCopyWithImpl<$Res>
    implements $DeliveriesCopyWith<$Res> {
  _$DeliveriesCopyWithImpl(this._self, this._then);

  final Deliveries _self;
  final $Res Function(Deliveries) _then;

/// Create a copy of Deliveries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? deliveryDate = null,Object? quantity = null,Object? status = null,Object? deliveryNoteNumber = freezed,Object? conformity = null,Object? photoCount = null,Object? quantityInRequestUnit = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,conformity: null == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Deliveries implements Deliveries {
  const _Deliveries({required this.id, required this.number, required this.deliveryDate, required this.quantity, required this.status, required this.deliveryNoteNumber, required this.conformity, required this.photoCount, this.quantityInRequestUnit});
  factory _Deliveries.fromJson(Map<String, dynamic> json) => _$DeliveriesFromJson(json);

@override final  String id;
@override final  String number;
@override final  DateTime deliveryDate;
@override final  Quantity quantity;
/// Etat d'une livraison : enregistree, ou annulee (elle reste visible mais n'entre plus dans aucun total).
@override final  Status status;
@override final  String? deliveryNoteNumber;
/// Conformite a la reception : « Avec reserve » exige un motif de la liste (quantite manquante, produit abime...).
@override final  Conformity conformity;
@override final  int photoCount;
@override final  Quantity? quantityInRequestUnit;

/// Create a copy of Deliveries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveriesCopyWith<_Deliveries> get copyWith => __$DeliveriesCopyWithImpl<_Deliveries>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveriesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deliveries&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.quantityInRequestUnit, quantityInRequestUnit) || other.quantityInRequestUnit == quantityInRequestUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,deliveryDate,quantity,status,deliveryNoteNumber,conformity,photoCount,quantityInRequestUnit);

@override
String toString() {
  return 'Deliveries(id: $id, number: $number, deliveryDate: $deliveryDate, quantity: $quantity, status: $status, deliveryNoteNumber: $deliveryNoteNumber, conformity: $conformity, photoCount: $photoCount, quantityInRequestUnit: $quantityInRequestUnit)';
}


}

/// @nodoc
abstract mixin class _$DeliveriesCopyWith<$Res> implements $DeliveriesCopyWith<$Res> {
  factory _$DeliveriesCopyWith(_Deliveries value, $Res Function(_Deliveries) _then) = __$DeliveriesCopyWithImpl;
@override @useResult
$Res call({
 String id, String number, DateTime deliveryDate, Quantity quantity, Status status, String? deliveryNoteNumber, Conformity conformity, int photoCount, Quantity? quantityInRequestUnit
});



}
/// @nodoc
class __$DeliveriesCopyWithImpl<$Res>
    implements _$DeliveriesCopyWith<$Res> {
  __$DeliveriesCopyWithImpl(this._self, this._then);

  final _Deliveries _self;
  final $Res Function(_Deliveries) _then;

/// Create a copy of Deliveries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? deliveryDate = null,Object? quantity = null,Object? status = null,Object? deliveryNoteNumber = freezed,Object? conformity = null,Object? photoCount = null,Object? quantityInRequestUnit = freezed,}) {
  return _then(_Deliveries(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,conformity: null == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,quantityInRequestUnit: freezed == quantityInRequestUnit ? _self.quantityInRequestUnit : quantityInRequestUnit // ignore: cast_nullable_to_non_nullable
as Quantity?,
  ));
}


}

// dart format on
