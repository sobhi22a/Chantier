// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_photo_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryPhotoItem {

 String get id; PhotoContentStatus get contentStatus; int get sizeBytes; DateTime get takenAt;
/// Create a copy of DeliveryPhotoItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryPhotoItemCopyWith<DeliveryPhotoItem> get copyWith => _$DeliveryPhotoItemCopyWithImpl<DeliveryPhotoItem>(this as DeliveryPhotoItem, _$identity);

  /// Serializes this DeliveryPhotoItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryPhotoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.contentStatus, contentStatus) || other.contentStatus == contentStatus)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contentStatus,sizeBytes,takenAt);

@override
String toString() {
  return 'DeliveryPhotoItem(id: $id, contentStatus: $contentStatus, sizeBytes: $sizeBytes, takenAt: $takenAt)';
}


}

/// @nodoc
abstract mixin class $DeliveryPhotoItemCopyWith<$Res>  {
  factory $DeliveryPhotoItemCopyWith(DeliveryPhotoItem value, $Res Function(DeliveryPhotoItem) _then) = _$DeliveryPhotoItemCopyWithImpl;
@useResult
$Res call({
 String id, PhotoContentStatus contentStatus, int sizeBytes, DateTime takenAt
});



}
/// @nodoc
class _$DeliveryPhotoItemCopyWithImpl<$Res>
    implements $DeliveryPhotoItemCopyWith<$Res> {
  _$DeliveryPhotoItemCopyWithImpl(this._self, this._then);

  final DeliveryPhotoItem _self;
  final $Res Function(DeliveryPhotoItem) _then;

/// Create a copy of DeliveryPhotoItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contentStatus = null,Object? sizeBytes = null,Object? takenAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contentStatus: null == contentStatus ? _self.contentStatus : contentStatus // ignore: cast_nullable_to_non_nullable
as PhotoContentStatus,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _DeliveryPhotoItem implements DeliveryPhotoItem {
  const _DeliveryPhotoItem({required this.id, required this.contentStatus, required this.sizeBytes, required this.takenAt});
  factory _DeliveryPhotoItem.fromJson(Map<String, dynamic> json) => _$DeliveryPhotoItemFromJson(json);

@override final  String id;
@override final  PhotoContentStatus contentStatus;
@override final  int sizeBytes;
@override final  DateTime takenAt;

/// Create a copy of DeliveryPhotoItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryPhotoItemCopyWith<_DeliveryPhotoItem> get copyWith => __$DeliveryPhotoItemCopyWithImpl<_DeliveryPhotoItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryPhotoItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryPhotoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.contentStatus, contentStatus) || other.contentStatus == contentStatus)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contentStatus,sizeBytes,takenAt);

@override
String toString() {
  return 'DeliveryPhotoItem(id: $id, contentStatus: $contentStatus, sizeBytes: $sizeBytes, takenAt: $takenAt)';
}


}

/// @nodoc
abstract mixin class _$DeliveryPhotoItemCopyWith<$Res> implements $DeliveryPhotoItemCopyWith<$Res> {
  factory _$DeliveryPhotoItemCopyWith(_DeliveryPhotoItem value, $Res Function(_DeliveryPhotoItem) _then) = __$DeliveryPhotoItemCopyWithImpl;
@override @useResult
$Res call({
 String id, PhotoContentStatus contentStatus, int sizeBytes, DateTime takenAt
});



}
/// @nodoc
class __$DeliveryPhotoItemCopyWithImpl<$Res>
    implements _$DeliveryPhotoItemCopyWith<$Res> {
  __$DeliveryPhotoItemCopyWithImpl(this._self, this._then);

  final _DeliveryPhotoItem _self;
  final $Res Function(_DeliveryPhotoItem) _then;

/// Create a copy of DeliveryPhotoItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contentStatus = null,Object? sizeBytes = null,Object? takenAt = null,}) {
  return _then(_DeliveryPhotoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contentStatus: null == contentStatus ? _self.contentStatus : contentStatus // ignore: cast_nullable_to_non_nullable
as PhotoContentStatus,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
