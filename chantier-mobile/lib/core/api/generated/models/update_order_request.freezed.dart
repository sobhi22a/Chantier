// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_order_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateOrderRequest {

/// Version de la commande, lue dans `order.version`.
 String get version; String? get supplierId; DateTime? get expectedDeliveryDate;/// Nouveau prix : recalcule le montant de la commande et de chaque livraison (événement sensible `OrderCommercialEdited`).
 double? get unitPrice; String? get purchaseOrderNumber; String? get note;
/// Create a copy of UpdateOrderRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateOrderRequestCopyWith<UpdateOrderRequest> get copyWith => _$UpdateOrderRequestCopyWithImpl<UpdateOrderRequest>(this as UpdateOrderRequest, _$identity);

  /// Serializes this UpdateOrderRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateOrderRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.purchaseOrderNumber, purchaseOrderNumber) || other.purchaseOrderNumber == purchaseOrderNumber)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,supplierId,expectedDeliveryDate,unitPrice,purchaseOrderNumber,note);

@override
String toString() {
  return 'UpdateOrderRequest(version: $version, supplierId: $supplierId, expectedDeliveryDate: $expectedDeliveryDate, unitPrice: $unitPrice, purchaseOrderNumber: $purchaseOrderNumber, note: $note)';
}


}

/// @nodoc
abstract mixin class $UpdateOrderRequestCopyWith<$Res>  {
  factory $UpdateOrderRequestCopyWith(UpdateOrderRequest value, $Res Function(UpdateOrderRequest) _then) = _$UpdateOrderRequestCopyWithImpl;
@useResult
$Res call({
 String version, String? supplierId, DateTime? expectedDeliveryDate, double? unitPrice, String? purchaseOrderNumber, String? note
});



}
/// @nodoc
class _$UpdateOrderRequestCopyWithImpl<$Res>
    implements $UpdateOrderRequestCopyWith<$Res> {
  _$UpdateOrderRequestCopyWithImpl(this._self, this._then);

  final UpdateOrderRequest _self;
  final $Res Function(UpdateOrderRequest) _then;

/// Create a copy of UpdateOrderRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? supplierId = freezed,Object? expectedDeliveryDate = freezed,Object? unitPrice = freezed,Object? purchaseOrderNumber = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double?,purchaseOrderNumber: freezed == purchaseOrderNumber ? _self.purchaseOrderNumber : purchaseOrderNumber // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UpdateOrderRequest implements UpdateOrderRequest {
  const _UpdateOrderRequest({required this.version, this.supplierId, this.expectedDeliveryDate, this.unitPrice, this.purchaseOrderNumber, this.note});
  factory _UpdateOrderRequest.fromJson(Map<String, dynamic> json) => _$UpdateOrderRequestFromJson(json);

/// Version de la commande, lue dans `order.version`.
@override final  String version;
@override final  String? supplierId;
@override final  DateTime? expectedDeliveryDate;
/// Nouveau prix : recalcule le montant de la commande et de chaque livraison (événement sensible `OrderCommercialEdited`).
@override final  double? unitPrice;
@override final  String? purchaseOrderNumber;
@override final  String? note;

/// Create a copy of UpdateOrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateOrderRequestCopyWith<_UpdateOrderRequest> get copyWith => __$UpdateOrderRequestCopyWithImpl<_UpdateOrderRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateOrderRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateOrderRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.purchaseOrderNumber, purchaseOrderNumber) || other.purchaseOrderNumber == purchaseOrderNumber)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,supplierId,expectedDeliveryDate,unitPrice,purchaseOrderNumber,note);

@override
String toString() {
  return 'UpdateOrderRequest(version: $version, supplierId: $supplierId, expectedDeliveryDate: $expectedDeliveryDate, unitPrice: $unitPrice, purchaseOrderNumber: $purchaseOrderNumber, note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpdateOrderRequestCopyWith<$Res> implements $UpdateOrderRequestCopyWith<$Res> {
  factory _$UpdateOrderRequestCopyWith(_UpdateOrderRequest value, $Res Function(_UpdateOrderRequest) _then) = __$UpdateOrderRequestCopyWithImpl;
@override @useResult
$Res call({
 String version, String? supplierId, DateTime? expectedDeliveryDate, double? unitPrice, String? purchaseOrderNumber, String? note
});



}
/// @nodoc
class __$UpdateOrderRequestCopyWithImpl<$Res>
    implements _$UpdateOrderRequestCopyWith<$Res> {
  __$UpdateOrderRequestCopyWithImpl(this._self, this._then);

  final _UpdateOrderRequest _self;
  final $Res Function(_UpdateOrderRequest) _then;

/// Create a copy of UpdateOrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? supplierId = freezed,Object? expectedDeliveryDate = freezed,Object? unitPrice = freezed,Object? purchaseOrderNumber = freezed,Object? note = freezed,}) {
  return _then(_UpdateOrderRequest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String?,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double?,purchaseOrderNumber: freezed == purchaseOrderNumber ? _self.purchaseOrderNumber : purchaseOrderNumber // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
