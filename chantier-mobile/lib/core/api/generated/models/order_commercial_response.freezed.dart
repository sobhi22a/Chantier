// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_commercial_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderCommercialResponse {

 double? get unitPrice; double? get amount; double? get receivedValue; String? get purchaseOrderNumber;
/// Create a copy of OrderCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCommercialResponseCopyWith<OrderCommercialResponse> get copyWith => _$OrderCommercialResponseCopyWithImpl<OrderCommercialResponse>(this as OrderCommercialResponse, _$identity);

  /// Serializes this OrderCommercialResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderCommercialResponse&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.receivedValue, receivedValue) || other.receivedValue == receivedValue)&&(identical(other.purchaseOrderNumber, purchaseOrderNumber) || other.purchaseOrderNumber == purchaseOrderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unitPrice,amount,receivedValue,purchaseOrderNumber);

@override
String toString() {
  return 'OrderCommercialResponse(unitPrice: $unitPrice, amount: $amount, receivedValue: $receivedValue, purchaseOrderNumber: $purchaseOrderNumber)';
}


}

/// @nodoc
abstract mixin class $OrderCommercialResponseCopyWith<$Res>  {
  factory $OrderCommercialResponseCopyWith(OrderCommercialResponse value, $Res Function(OrderCommercialResponse) _then) = _$OrderCommercialResponseCopyWithImpl;
@useResult
$Res call({
 double? unitPrice, double? amount, double? receivedValue, String? purchaseOrderNumber
});



}
/// @nodoc
class _$OrderCommercialResponseCopyWithImpl<$Res>
    implements $OrderCommercialResponseCopyWith<$Res> {
  _$OrderCommercialResponseCopyWithImpl(this._self, this._then);

  final OrderCommercialResponse _self;
  final $Res Function(OrderCommercialResponse) _then;

/// Create a copy of OrderCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unitPrice = freezed,Object? amount = freezed,Object? receivedValue = freezed,Object? purchaseOrderNumber = freezed,}) {
  return _then(_self.copyWith(
unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,receivedValue: freezed == receivedValue ? _self.receivedValue : receivedValue // ignore: cast_nullable_to_non_nullable
as double?,purchaseOrderNumber: freezed == purchaseOrderNumber ? _self.purchaseOrderNumber : purchaseOrderNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _OrderCommercialResponse implements OrderCommercialResponse {
  const _OrderCommercialResponse({required this.unitPrice, required this.amount, required this.receivedValue, required this.purchaseOrderNumber});
  factory _OrderCommercialResponse.fromJson(Map<String, dynamic> json) => _$OrderCommercialResponseFromJson(json);

@override final  double? unitPrice;
@override final  double? amount;
@override final  double? receivedValue;
@override final  String? purchaseOrderNumber;

/// Create a copy of OrderCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCommercialResponseCopyWith<_OrderCommercialResponse> get copyWith => __$OrderCommercialResponseCopyWithImpl<_OrderCommercialResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderCommercialResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderCommercialResponse&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.receivedValue, receivedValue) || other.receivedValue == receivedValue)&&(identical(other.purchaseOrderNumber, purchaseOrderNumber) || other.purchaseOrderNumber == purchaseOrderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unitPrice,amount,receivedValue,purchaseOrderNumber);

@override
String toString() {
  return 'OrderCommercialResponse(unitPrice: $unitPrice, amount: $amount, receivedValue: $receivedValue, purchaseOrderNumber: $purchaseOrderNumber)';
}


}

/// @nodoc
abstract mixin class _$OrderCommercialResponseCopyWith<$Res> implements $OrderCommercialResponseCopyWith<$Res> {
  factory _$OrderCommercialResponseCopyWith(_OrderCommercialResponse value, $Res Function(_OrderCommercialResponse) _then) = __$OrderCommercialResponseCopyWithImpl;
@override @useResult
$Res call({
 double? unitPrice, double? amount, double? receivedValue, String? purchaseOrderNumber
});



}
/// @nodoc
class __$OrderCommercialResponseCopyWithImpl<$Res>
    implements _$OrderCommercialResponseCopyWith<$Res> {
  __$OrderCommercialResponseCopyWithImpl(this._self, this._then);

  final _OrderCommercialResponse _self;
  final $Res Function(_OrderCommercialResponse) _then;

/// Create a copy of OrderCommercialResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unitPrice = freezed,Object? amount = freezed,Object? receivedValue = freezed,Object? purchaseOrderNumber = freezed,}) {
  return _then(_OrderCommercialResponse(
unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,receivedValue: freezed == receivedValue ? _self.receivedValue : receivedValue // ignore: cast_nullable_to_non_nullable
as double?,purchaseOrderNumber: freezed == purchaseOrderNumber ? _self.purchaseOrderNumber : purchaseOrderNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
