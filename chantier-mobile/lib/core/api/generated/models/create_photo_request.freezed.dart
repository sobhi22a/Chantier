// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_photo_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatePhotoRequest {

/// Identifiant généré par le téléphone : un renvoi donne 200 et les mêmes métadonnées.
 String? get clientId; DateTime? get clientCreatedAt;/// Heure de la prise de vue (téléphone) : information seulement.
 DateTime? get takenAt;/// Toujours `image/jpeg` (415 `TYPE_FICHIER_REFUSE` sinon).
 String? get contentType;/// Taille du fichier envoyé, en octets (413 `FICHIER_TROP_GROS` au-delà de `maxPhotoBytes`).
 int? get sizeBytes;/// Empreinte SHA-256 du fichier envoyé (64 caractères hexadécimaux) : rend l'envoi du fichier idempotent et vérifie son intégrité.
 String? get sha256;
/// Create a copy of CreatePhotoRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePhotoRequestCopyWith<CreatePhotoRequest> get copyWith => _$CreatePhotoRequestCopyWithImpl<CreatePhotoRequest>(this as CreatePhotoRequest, _$identity);

  /// Serializes this CreatePhotoRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePhotoRequest&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,clientCreatedAt,takenAt,contentType,sizeBytes,sha256);

@override
String toString() {
  return 'CreatePhotoRequest(clientId: $clientId, clientCreatedAt: $clientCreatedAt, takenAt: $takenAt, contentType: $contentType, sizeBytes: $sizeBytes, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class $CreatePhotoRequestCopyWith<$Res>  {
  factory $CreatePhotoRequestCopyWith(CreatePhotoRequest value, $Res Function(CreatePhotoRequest) _then) = _$CreatePhotoRequestCopyWithImpl;
@useResult
$Res call({
 String? clientId, DateTime? clientCreatedAt, DateTime? takenAt, String? contentType, int? sizeBytes, String? sha256
});



}
/// @nodoc
class _$CreatePhotoRequestCopyWithImpl<$Res>
    implements $CreatePhotoRequestCopyWith<$Res> {
  _$CreatePhotoRequestCopyWithImpl(this._self, this._then);

  final CreatePhotoRequest _self;
  final $Res Function(CreatePhotoRequest) _then;

/// Create a copy of CreatePhotoRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? takenAt = freezed,Object? contentType = freezed,Object? sizeBytes = freezed,Object? sha256 = freezed,}) {
  return _then(_self.copyWith(
clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,takenAt: freezed == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CreatePhotoRequest implements CreatePhotoRequest {
  const _CreatePhotoRequest({this.clientId, this.clientCreatedAt, this.takenAt, this.contentType, this.sizeBytes, this.sha256});
  factory _CreatePhotoRequest.fromJson(Map<String, dynamic> json) => _$CreatePhotoRequestFromJson(json);

/// Identifiant généré par le téléphone : un renvoi donne 200 et les mêmes métadonnées.
@override final  String? clientId;
@override final  DateTime? clientCreatedAt;
/// Heure de la prise de vue (téléphone) : information seulement.
@override final  DateTime? takenAt;
/// Toujours `image/jpeg` (415 `TYPE_FICHIER_REFUSE` sinon).
@override final  String? contentType;
/// Taille du fichier envoyé, en octets (413 `FICHIER_TROP_GROS` au-delà de `maxPhotoBytes`).
@override final  int? sizeBytes;
/// Empreinte SHA-256 du fichier envoyé (64 caractères hexadécimaux) : rend l'envoi du fichier idempotent et vérifie son intégrité.
@override final  String? sha256;

/// Create a copy of CreatePhotoRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePhotoRequestCopyWith<_CreatePhotoRequest> get copyWith => __$CreatePhotoRequestCopyWithImpl<_CreatePhotoRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePhotoRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePhotoRequest&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientCreatedAt, clientCreatedAt) || other.clientCreatedAt == clientCreatedAt)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,clientCreatedAt,takenAt,contentType,sizeBytes,sha256);

@override
String toString() {
  return 'CreatePhotoRequest(clientId: $clientId, clientCreatedAt: $clientCreatedAt, takenAt: $takenAt, contentType: $contentType, sizeBytes: $sizeBytes, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class _$CreatePhotoRequestCopyWith<$Res> implements $CreatePhotoRequestCopyWith<$Res> {
  factory _$CreatePhotoRequestCopyWith(_CreatePhotoRequest value, $Res Function(_CreatePhotoRequest) _then) = __$CreatePhotoRequestCopyWithImpl;
@override @useResult
$Res call({
 String? clientId, DateTime? clientCreatedAt, DateTime? takenAt, String? contentType, int? sizeBytes, String? sha256
});



}
/// @nodoc
class __$CreatePhotoRequestCopyWithImpl<$Res>
    implements _$CreatePhotoRequestCopyWith<$Res> {
  __$CreatePhotoRequestCopyWithImpl(this._self, this._then);

  final _CreatePhotoRequest _self;
  final $Res Function(_CreatePhotoRequest) _then;

/// Create a copy of CreatePhotoRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = freezed,Object? clientCreatedAt = freezed,Object? takenAt = freezed,Object? contentType = freezed,Object? sizeBytes = freezed,Object? sha256 = freezed,}) {
  return _then(_CreatePhotoRequest(
clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,clientCreatedAt: freezed == clientCreatedAt ? _self.clientCreatedAt : clientCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,takenAt: freezed == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
