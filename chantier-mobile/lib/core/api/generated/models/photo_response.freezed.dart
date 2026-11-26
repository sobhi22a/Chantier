// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhotoResponse {

 String get id; String get siteId; String get deliveryId; String? get clientId; DateTime get takenAt; String get contentType; int get sizeBytes;/// Etat du fichier d'une photo : les metadonnees existent (`Pending`), puis le binaire est envoye (`Uploaded`).
 PhotoResponseContentStatus get contentStatus; DateTime? get uploadedAt; String get version; DateTime get createdAt;
/// Create a copy of PhotoResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoResponseCopyWith<PhotoResponse> get copyWith => _$PhotoResponseCopyWithImpl<PhotoResponse>(this as PhotoResponse, _$identity);

  /// Serializes this PhotoResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.deliveryId, deliveryId) || other.deliveryId == deliveryId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.contentStatus, contentStatus) || other.contentStatus == contentStatus)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,siteId,deliveryId,clientId,takenAt,contentType,sizeBytes,contentStatus,uploadedAt,version,createdAt);

@override
String toString() {
  return 'PhotoResponse(id: $id, siteId: $siteId, deliveryId: $deliveryId, clientId: $clientId, takenAt: $takenAt, contentType: $contentType, sizeBytes: $sizeBytes, contentStatus: $contentStatus, uploadedAt: $uploadedAt, version: $version, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PhotoResponseCopyWith<$Res>  {
  factory $PhotoResponseCopyWith(PhotoResponse value, $Res Function(PhotoResponse) _then) = _$PhotoResponseCopyWithImpl;
@useResult
$Res call({
 String id, String siteId, String deliveryId, String? clientId, DateTime takenAt, String contentType, int sizeBytes, PhotoResponseContentStatus contentStatus, DateTime? uploadedAt, String version, DateTime createdAt
});



}
/// @nodoc
class _$PhotoResponseCopyWithImpl<$Res>
    implements $PhotoResponseCopyWith<$Res> {
  _$PhotoResponseCopyWithImpl(this._self, this._then);

  final PhotoResponse _self;
  final $Res Function(PhotoResponse) _then;

/// Create a copy of PhotoResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? siteId = null,Object? deliveryId = null,Object? clientId = freezed,Object? takenAt = null,Object? contentType = null,Object? sizeBytes = null,Object? contentStatus = null,Object? uploadedAt = freezed,Object? version = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,deliveryId: null == deliveryId ? _self.deliveryId : deliveryId // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,contentStatus: null == contentStatus ? _self.contentStatus : contentStatus // ignore: cast_nullable_to_non_nullable
as PhotoResponseContentStatus,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PhotoResponse implements PhotoResponse {
  const _PhotoResponse({required this.id, required this.siteId, required this.deliveryId, required this.clientId, required this.takenAt, required this.contentType, required this.sizeBytes, required this.contentStatus, required this.uploadedAt, required this.version, required this.createdAt});
  factory _PhotoResponse.fromJson(Map<String, dynamic> json) => _$PhotoResponseFromJson(json);

@override final  String id;
@override final  String siteId;
@override final  String deliveryId;
@override final  String? clientId;
@override final  DateTime takenAt;
@override final  String contentType;
@override final  int sizeBytes;
/// Etat du fichier d'une photo : les metadonnees existent (`Pending`), puis le binaire est envoye (`Uploaded`).
@override final  PhotoResponseContentStatus contentStatus;
@override final  DateTime? uploadedAt;
@override final  String version;
@override final  DateTime createdAt;

/// Create a copy of PhotoResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoResponseCopyWith<_PhotoResponse> get copyWith => __$PhotoResponseCopyWithImpl<_PhotoResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.deliveryId, deliveryId) || other.deliveryId == deliveryId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.contentStatus, contentStatus) || other.contentStatus == contentStatus)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,siteId,deliveryId,clientId,takenAt,contentType,sizeBytes,contentStatus,uploadedAt,version,createdAt);

@override
String toString() {
  return 'PhotoResponse(id: $id, siteId: $siteId, deliveryId: $deliveryId, clientId: $clientId, takenAt: $takenAt, contentType: $contentType, sizeBytes: $sizeBytes, contentStatus: $contentStatus, uploadedAt: $uploadedAt, version: $version, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PhotoResponseCopyWith<$Res> implements $PhotoResponseCopyWith<$Res> {
  factory _$PhotoResponseCopyWith(_PhotoResponse value, $Res Function(_PhotoResponse) _then) = __$PhotoResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String siteId, String deliveryId, String? clientId, DateTime takenAt, String contentType, int sizeBytes, PhotoResponseContentStatus contentStatus, DateTime? uploadedAt, String version, DateTime createdAt
});



}
/// @nodoc
class __$PhotoResponseCopyWithImpl<$Res>
    implements _$PhotoResponseCopyWith<$Res> {
  __$PhotoResponseCopyWithImpl(this._self, this._then);

  final _PhotoResponse _self;
  final $Res Function(_PhotoResponse) _then;

/// Create a copy of PhotoResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? siteId = null,Object? deliveryId = null,Object? clientId = freezed,Object? takenAt = null,Object? contentType = null,Object? sizeBytes = null,Object? contentStatus = null,Object? uploadedAt = freezed,Object? version = null,Object? createdAt = null,}) {
  return _then(_PhotoResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,deliveryId: null == deliveryId ? _self.deliveryId : deliveryId // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,contentStatus: null == contentStatus ? _self.contentStatus : contentStatus // ignore: cast_nullable_to_non_nullable
as PhotoResponseContentStatus,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
