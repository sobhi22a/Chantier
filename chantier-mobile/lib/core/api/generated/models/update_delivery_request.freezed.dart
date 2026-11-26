// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_delivery_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateDeliveryRequest {

/// Version lue avec la livraison.
 String get version; QuantityBody? get quantity; DateTime? get deliveryDate;/// N° de BL ; une valeur déjà posée se remplace, elle ne s'efface pas.
 String? get deliveryNoteNumber; Conformity? get conformity; String? get reserveReasonCode; String? get reserveNote;
/// Create a copy of UpdateDeliveryRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateDeliveryRequestCopyWith<UpdateDeliveryRequest> get copyWith => _$UpdateDeliveryRequestCopyWithImpl<UpdateDeliveryRequest>(this as UpdateDeliveryRequest, _$identity);

  /// Serializes this UpdateDeliveryRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateDeliveryRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.reserveReasonCode, reserveReasonCode) || other.reserveReasonCode == reserveReasonCode)&&(identical(other.reserveNote, reserveNote) || other.reserveNote == reserveNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,quantity,deliveryDate,deliveryNoteNumber,conformity,reserveReasonCode,reserveNote);

@override
String toString() {
  return 'UpdateDeliveryRequest(version: $version, quantity: $quantity, deliveryDate: $deliveryDate, deliveryNoteNumber: $deliveryNoteNumber, conformity: $conformity, reserveReasonCode: $reserveReasonCode, reserveNote: $reserveNote)';
}


}

/// @nodoc
abstract mixin class $UpdateDeliveryRequestCopyWith<$Res>  {
  factory $UpdateDeliveryRequestCopyWith(UpdateDeliveryRequest value, $Res Function(UpdateDeliveryRequest) _then) = _$UpdateDeliveryRequestCopyWithImpl;
@useResult
$Res call({
 String version, QuantityBody? quantity, DateTime? deliveryDate, String? deliveryNoteNumber, Conformity? conformity, String? reserveReasonCode, String? reserveNote
});



}
/// @nodoc
class _$UpdateDeliveryRequestCopyWithImpl<$Res>
    implements $UpdateDeliveryRequestCopyWith<$Res> {
  _$UpdateDeliveryRequestCopyWithImpl(this._self, this._then);

  final UpdateDeliveryRequest _self;
  final $Res Function(UpdateDeliveryRequest) _then;

/// Create a copy of UpdateDeliveryRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? quantity = freezed,Object? deliveryDate = freezed,Object? deliveryNoteNumber = freezed,Object? conformity = freezed,Object? reserveReasonCode = freezed,Object? reserveNote = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,conformity: freezed == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity?,reserveReasonCode: freezed == reserveReasonCode ? _self.reserveReasonCode : reserveReasonCode // ignore: cast_nullable_to_non_nullable
as String?,reserveNote: freezed == reserveNote ? _self.reserveNote : reserveNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UpdateDeliveryRequest implements UpdateDeliveryRequest {
  const _UpdateDeliveryRequest({required this.version, this.quantity, this.deliveryDate, this.deliveryNoteNumber, this.conformity, this.reserveReasonCode, this.reserveNote});
  factory _UpdateDeliveryRequest.fromJson(Map<String, dynamic> json) => _$UpdateDeliveryRequestFromJson(json);

/// Version lue avec la livraison.
@override final  String version;
@override final  QuantityBody? quantity;
@override final  DateTime? deliveryDate;
/// N° de BL ; une valeur déjà posée se remplace, elle ne s'efface pas.
@override final  String? deliveryNoteNumber;
@override final  Conformity? conformity;
@override final  String? reserveReasonCode;
@override final  String? reserveNote;

/// Create a copy of UpdateDeliveryRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateDeliveryRequestCopyWith<_UpdateDeliveryRequest> get copyWith => __$UpdateDeliveryRequestCopyWithImpl<_UpdateDeliveryRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateDeliveryRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateDeliveryRequest&&(identical(other.version, version) || other.version == version)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.deliveryNoteNumber, deliveryNoteNumber) || other.deliveryNoteNumber == deliveryNoteNumber)&&(identical(other.conformity, conformity) || other.conformity == conformity)&&(identical(other.reserveReasonCode, reserveReasonCode) || other.reserveReasonCode == reserveReasonCode)&&(identical(other.reserveNote, reserveNote) || other.reserveNote == reserveNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,quantity,deliveryDate,deliveryNoteNumber,conformity,reserveReasonCode,reserveNote);

@override
String toString() {
  return 'UpdateDeliveryRequest(version: $version, quantity: $quantity, deliveryDate: $deliveryDate, deliveryNoteNumber: $deliveryNoteNumber, conformity: $conformity, reserveReasonCode: $reserveReasonCode, reserveNote: $reserveNote)';
}


}

/// @nodoc
abstract mixin class _$UpdateDeliveryRequestCopyWith<$Res> implements $UpdateDeliveryRequestCopyWith<$Res> {
  factory _$UpdateDeliveryRequestCopyWith(_UpdateDeliveryRequest value, $Res Function(_UpdateDeliveryRequest) _then) = __$UpdateDeliveryRequestCopyWithImpl;
@override @useResult
$Res call({
 String version, QuantityBody? quantity, DateTime? deliveryDate, String? deliveryNoteNumber, Conformity? conformity, String? reserveReasonCode, String? reserveNote
});



}
/// @nodoc
class __$UpdateDeliveryRequestCopyWithImpl<$Res>
    implements _$UpdateDeliveryRequestCopyWith<$Res> {
  __$UpdateDeliveryRequestCopyWithImpl(this._self, this._then);

  final _UpdateDeliveryRequest _self;
  final $Res Function(_UpdateDeliveryRequest) _then;

/// Create a copy of UpdateDeliveryRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? quantity = freezed,Object? deliveryDate = freezed,Object? deliveryNoteNumber = freezed,Object? conformity = freezed,Object? reserveReasonCode = freezed,Object? reserveNote = freezed,}) {
  return _then(_UpdateDeliveryRequest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityBody?,deliveryDate: freezed == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveryNoteNumber: freezed == deliveryNoteNumber ? _self.deliveryNoteNumber : deliveryNoteNumber // ignore: cast_nullable_to_non_nullable
as String?,conformity: freezed == conformity ? _self.conformity : conformity // ignore: cast_nullable_to_non_nullable
as Conformity?,reserveReasonCode: freezed == reserveReasonCode ? _self.reserveReasonCode : reserveReasonCode // ignore: cast_nullable_to_non_nullable
as String?,reserveNote: freezed == reserveNote ? _self.reserveNote : reserveNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
