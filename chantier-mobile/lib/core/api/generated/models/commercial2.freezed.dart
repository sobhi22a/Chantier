// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commercial2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Commercial2 {

 double? get unitPrice; double? get amount; double? get receivedValue; String? get purchaseOrderNumber;
/// Create a copy of Commercial2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Commercial2CopyWith<Commercial2> get copyWith => _$Commercial2CopyWithImpl<Commercial2>(this as Commercial2, _$identity);

  /// Serializes this Commercial2 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Commercial2&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.receivedValue, receivedValue) || other.receivedValue == receivedValue)&&(identical(other.purchaseOrderNumber, purchaseOrderNumber) || other.purchaseOrderNumber == purchaseOrderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unitPrice,amount,receivedValue,purchaseOrderNumber);

@override
String toString() {
  return 'Commercial2(unitPrice: $unitPrice, amount: $amount, receivedValue: $receivedValue, purchaseOrderNumber: $purchaseOrderNumber)';
}


}

/// @nodoc
abstract mixin class $Commercial2CopyWith<$Res>  {
  factory $Commercial2CopyWith(Commercial2 value, $Res Function(Commercial2) _then) = _$Commercial2CopyWithImpl;
@useResult
$Res call({
 double? unitPrice, double? amount, double? receivedValue, String? purchaseOrderNumber
});



}
/// @nodoc
class _$Commercial2CopyWithImpl<$Res>
    implements $Commercial2CopyWith<$Res> {
  _$Commercial2CopyWithImpl(this._self, this._then);

  final Commercial2 _self;
  final $Res Function(Commercial2) _then;

/// Create a copy of Commercial2
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

class _Commercial2 implements Commercial2 {
  const _Commercial2({required this.unitPrice, required this.amount, required this.receivedValue, required this.purchaseOrderNumber});
  factory _Commercial2.fromJson(Map<String, dynamic> json) => _$Commercial2FromJson(json);

@override final  double? unitPrice;
@override final  double? amount;
@override final  double? receivedValue;
@override final  String? purchaseOrderNumber;

/// Create a copy of Commercial2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$Commercial2CopyWith<_Commercial2> get copyWith => __$Commercial2CopyWithImpl<_Commercial2>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$Commercial2ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Commercial2&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.receivedValue, receivedValue) || other.receivedValue == receivedValue)&&(identical(other.purchaseOrderNumber, purchaseOrderNumber) || other.purchaseOrderNumber == purchaseOrderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unitPrice,amount,receivedValue,purchaseOrderNumber);

@override
String toString() {
  return 'Commercial2(unitPrice: $unitPrice, amount: $amount, receivedValue: $receivedValue, purchaseOrderNumber: $purchaseOrderNumber)';
}


}

/// @nodoc
abstract mixin class _$Commercial2CopyWith<$Res> implements $Commercial2CopyWith<$Res> {
  factory _$Commercial2CopyWith(_Commercial2 value, $Res Function(_Commercial2) _then) = __$Commercial2CopyWithImpl;
@override @useResult
$Res call({
 double? unitPrice, double? amount, double? receivedValue, String? purchaseOrderNumber
});



}
/// @nodoc
class __$Commercial2CopyWithImpl<$Res>
    implements _$Commercial2CopyWith<$Res> {
  __$Commercial2CopyWithImpl(this._self, this._then);

  final _Commercial2 _self;
  final $Res Function(_Commercial2) _then;

/// Create a copy of Commercial2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unitPrice = freezed,Object? amount = freezed,Object? receivedValue = freezed,Object? purchaseOrderNumber = freezed,}) {
  return _then(_Commercial2(
unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,receivedValue: freezed == receivedValue ? _self.receivedValue : receivedValue // ignore: cast_nullable_to_non_nullable
as double?,purchaseOrderNumber: freezed == purchaseOrderNumber ? _self.purchaseOrderNumber : purchaseOrderNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
