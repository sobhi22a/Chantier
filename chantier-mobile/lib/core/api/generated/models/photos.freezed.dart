// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Photos {

 String get id;/// Etat du fichier d'une photo : les metadonnees existent (`Pending`), puis le binaire est envoye (`Uploaded`).
 ContentStatus get contentStatus; int get sizeBytes; DateTime get takenAt;
/// Create a copy of Photos
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotosCopyWith<Photos> get copyWith => _$PhotosCopyWithImpl<Photos>(this as Photos, _$identity);

  /// Serializes this Photos to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Photos&&(identical(other.id, id) || other.id == id)&&(identical(other.contentStatus, contentStatus) || other.contentStatus == contentStatus)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contentStatus,sizeBytes,takenAt);

@override
String toString() {
  return 'Photos(id: $id, contentStatus: $contentStatus, sizeBytes: $sizeBytes, takenAt: $takenAt)';
}


}

/// @nodoc
abstract mixin class $PhotosCopyWith<$Res>  {
  factory $PhotosCopyWith(Photos value, $Res Function(Photos) _then) = _$PhotosCopyWithImpl;
@useResult
$Res call({
 String id, ContentStatus contentStatus, int sizeBytes, DateTime takenAt
});



}
/// @nodoc
class _$PhotosCopyWithImpl<$Res>
    implements $PhotosCopyWith<$Res> {
  _$PhotosCopyWithImpl(this._self, this._then);

  final Photos _self;
  final $Res Function(Photos) _then;

/// Create a copy of Photos
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contentStatus = null,Object? sizeBytes = null,Object? takenAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contentStatus: null == contentStatus ? _self.contentStatus : contentStatus // ignore: cast_nullable_to_non_nullable
as ContentStatus,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Photos implements Photos {
  const _Photos({required this.id, required this.contentStatus, required this.sizeBytes, required this.takenAt});
  factory _Photos.fromJson(Map<String, dynamic> json) => _$PhotosFromJson(json);

@override final  String id;
/// Etat du fichier d'une photo : les metadonnees existent (`Pending`), puis le binaire est envoye (`Uploaded`).
@override final  ContentStatus contentStatus;
@override final  int sizeBytes;
@override final  DateTime takenAt;

/// Create a copy of Photos
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotosCopyWith<_Photos> get copyWith => __$PhotosCopyWithImpl<_Photos>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotosToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Photos&&(identical(other.id, id) || other.id == id)&&(identical(other.contentStatus, contentStatus) || other.contentStatus == contentStatus)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contentStatus,sizeBytes,takenAt);

@override
String toString() {
  return 'Photos(id: $id, contentStatus: $contentStatus, sizeBytes: $sizeBytes, takenAt: $takenAt)';
}


}

/// @nodoc
abstract mixin class _$PhotosCopyWith<$Res> implements $PhotosCopyWith<$Res> {
  factory _$PhotosCopyWith(_Photos value, $Res Function(_Photos) _then) = __$PhotosCopyWithImpl;
@override @useResult
$Res call({
 String id, ContentStatus contentStatus, int sizeBytes, DateTime takenAt
});



}
/// @nodoc
class __$PhotosCopyWithImpl<$Res>
    implements _$PhotosCopyWith<$Res> {
  __$PhotosCopyWithImpl(this._self, this._then);

  final _Photos _self;
  final $Res Function(_Photos) _then;

/// Create a copy of Photos
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contentStatus = null,Object? sizeBytes = null,Object? takenAt = null,}) {
  return _then(_Photos(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contentStatus: null == contentStatus ? _self.contentStatus : contentStatus // ignore: cast_nullable_to_non_nullable
as ContentStatus,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
