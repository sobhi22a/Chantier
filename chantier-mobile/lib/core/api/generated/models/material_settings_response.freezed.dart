// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'material_settings_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaterialSettingsResponse {

/// Date de besoin proposée = aujourd'hui + ce nombre de jours.
 int get defaultNeededByDays;/// Tolérance de « livraison complète » en pourcentage de la quantité commandée.
 double get deliveryTolerancePercent;/// Nombre maximal de photos de bon de livraison par livraison.
 int get maxPhotosPerDelivery;/// Taille maximale d'une photo, en octets.
 int get maxPhotoBytes;/// Longueur maximale d'une remarque.
 int get noteMaxLength; MaterialReasonsResponse get reasons;
/// Create a copy of MaterialSettingsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialSettingsResponseCopyWith<MaterialSettingsResponse> get copyWith => _$MaterialSettingsResponseCopyWithImpl<MaterialSettingsResponse>(this as MaterialSettingsResponse, _$identity);

  /// Serializes this MaterialSettingsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterialSettingsResponse&&(identical(other.defaultNeededByDays, defaultNeededByDays) || other.defaultNeededByDays == defaultNeededByDays)&&(identical(other.deliveryTolerancePercent, deliveryTolerancePercent) || other.deliveryTolerancePercent == deliveryTolerancePercent)&&(identical(other.maxPhotosPerDelivery, maxPhotosPerDelivery) || other.maxPhotosPerDelivery == maxPhotosPerDelivery)&&(identical(other.maxPhotoBytes, maxPhotoBytes) || other.maxPhotoBytes == maxPhotoBytes)&&(identical(other.noteMaxLength, noteMaxLength) || other.noteMaxLength == noteMaxLength)&&(identical(other.reasons, reasons) || other.reasons == reasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultNeededByDays,deliveryTolerancePercent,maxPhotosPerDelivery,maxPhotoBytes,noteMaxLength,reasons);

@override
String toString() {
  return 'MaterialSettingsResponse(defaultNeededByDays: $defaultNeededByDays, deliveryTolerancePercent: $deliveryTolerancePercent, maxPhotosPerDelivery: $maxPhotosPerDelivery, maxPhotoBytes: $maxPhotoBytes, noteMaxLength: $noteMaxLength, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class $MaterialSettingsResponseCopyWith<$Res>  {
  factory $MaterialSettingsResponseCopyWith(MaterialSettingsResponse value, $Res Function(MaterialSettingsResponse) _then) = _$MaterialSettingsResponseCopyWithImpl;
@useResult
$Res call({
 int defaultNeededByDays, double deliveryTolerancePercent, int maxPhotosPerDelivery, int maxPhotoBytes, int noteMaxLength, MaterialReasonsResponse reasons
});



}
/// @nodoc
class _$MaterialSettingsResponseCopyWithImpl<$Res>
    implements $MaterialSettingsResponseCopyWith<$Res> {
  _$MaterialSettingsResponseCopyWithImpl(this._self, this._then);

  final MaterialSettingsResponse _self;
  final $Res Function(MaterialSettingsResponse) _then;

/// Create a copy of MaterialSettingsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultNeededByDays = null,Object? deliveryTolerancePercent = null,Object? maxPhotosPerDelivery = null,Object? maxPhotoBytes = null,Object? noteMaxLength = null,Object? reasons = null,}) {
  return _then(_self.copyWith(
defaultNeededByDays: null == defaultNeededByDays ? _self.defaultNeededByDays : defaultNeededByDays // ignore: cast_nullable_to_non_nullable
as int,deliveryTolerancePercent: null == deliveryTolerancePercent ? _self.deliveryTolerancePercent : deliveryTolerancePercent // ignore: cast_nullable_to_non_nullable
as double,maxPhotosPerDelivery: null == maxPhotosPerDelivery ? _self.maxPhotosPerDelivery : maxPhotosPerDelivery // ignore: cast_nullable_to_non_nullable
as int,maxPhotoBytes: null == maxPhotoBytes ? _self.maxPhotoBytes : maxPhotoBytes // ignore: cast_nullable_to_non_nullable
as int,noteMaxLength: null == noteMaxLength ? _self.noteMaxLength : noteMaxLength // ignore: cast_nullable_to_non_nullable
as int,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as MaterialReasonsResponse,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _MaterialSettingsResponse implements MaterialSettingsResponse {
  const _MaterialSettingsResponse({required this.defaultNeededByDays, required this.deliveryTolerancePercent, required this.maxPhotosPerDelivery, required this.maxPhotoBytes, required this.noteMaxLength, required this.reasons});
  factory _MaterialSettingsResponse.fromJson(Map<String, dynamic> json) => _$MaterialSettingsResponseFromJson(json);

/// Date de besoin proposée = aujourd'hui + ce nombre de jours.
@override final  int defaultNeededByDays;
/// Tolérance de « livraison complète » en pourcentage de la quantité commandée.
@override final  double deliveryTolerancePercent;
/// Nombre maximal de photos de bon de livraison par livraison.
@override final  int maxPhotosPerDelivery;
/// Taille maximale d'une photo, en octets.
@override final  int maxPhotoBytes;
/// Longueur maximale d'une remarque.
@override final  int noteMaxLength;
@override final  MaterialReasonsResponse reasons;

/// Create a copy of MaterialSettingsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialSettingsResponseCopyWith<_MaterialSettingsResponse> get copyWith => __$MaterialSettingsResponseCopyWithImpl<_MaterialSettingsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialSettingsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterialSettingsResponse&&(identical(other.defaultNeededByDays, defaultNeededByDays) || other.defaultNeededByDays == defaultNeededByDays)&&(identical(other.deliveryTolerancePercent, deliveryTolerancePercent) || other.deliveryTolerancePercent == deliveryTolerancePercent)&&(identical(other.maxPhotosPerDelivery, maxPhotosPerDelivery) || other.maxPhotosPerDelivery == maxPhotosPerDelivery)&&(identical(other.maxPhotoBytes, maxPhotoBytes) || other.maxPhotoBytes == maxPhotoBytes)&&(identical(other.noteMaxLength, noteMaxLength) || other.noteMaxLength == noteMaxLength)&&(identical(other.reasons, reasons) || other.reasons == reasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultNeededByDays,deliveryTolerancePercent,maxPhotosPerDelivery,maxPhotoBytes,noteMaxLength,reasons);

@override
String toString() {
  return 'MaterialSettingsResponse(defaultNeededByDays: $defaultNeededByDays, deliveryTolerancePercent: $deliveryTolerancePercent, maxPhotosPerDelivery: $maxPhotosPerDelivery, maxPhotoBytes: $maxPhotoBytes, noteMaxLength: $noteMaxLength, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class _$MaterialSettingsResponseCopyWith<$Res> implements $MaterialSettingsResponseCopyWith<$Res> {
  factory _$MaterialSettingsResponseCopyWith(_MaterialSettingsResponse value, $Res Function(_MaterialSettingsResponse) _then) = __$MaterialSettingsResponseCopyWithImpl;
@override @useResult
$Res call({
 int defaultNeededByDays, double deliveryTolerancePercent, int maxPhotosPerDelivery, int maxPhotoBytes, int noteMaxLength, MaterialReasonsResponse reasons
});



}
/// @nodoc
class __$MaterialSettingsResponseCopyWithImpl<$Res>
    implements _$MaterialSettingsResponseCopyWith<$Res> {
  __$MaterialSettingsResponseCopyWithImpl(this._self, this._then);

  final _MaterialSettingsResponse _self;
  final $Res Function(_MaterialSettingsResponse) _then;

/// Create a copy of MaterialSettingsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultNeededByDays = null,Object? deliveryTolerancePercent = null,Object? maxPhotosPerDelivery = null,Object? maxPhotoBytes = null,Object? noteMaxLength = null,Object? reasons = null,}) {
  return _then(_MaterialSettingsResponse(
defaultNeededByDays: null == defaultNeededByDays ? _self.defaultNeededByDays : defaultNeededByDays // ignore: cast_nullable_to_non_nullable
as int,deliveryTolerancePercent: null == deliveryTolerancePercent ? _self.deliveryTolerancePercent : deliveryTolerancePercent // ignore: cast_nullable_to_non_nullable
as double,maxPhotosPerDelivery: null == maxPhotosPerDelivery ? _self.maxPhotosPerDelivery : maxPhotosPerDelivery // ignore: cast_nullable_to_non_nullable
as int,maxPhotoBytes: null == maxPhotoBytes ? _self.maxPhotoBytes : maxPhotoBytes // ignore: cast_nullable_to_non_nullable
as int,noteMaxLength: null == noteMaxLength ? _self.noteMaxLength : noteMaxLength // ignore: cast_nullable_to_non_nullable
as int,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as MaterialReasonsResponse,
  ));
}


}

// dart format on
