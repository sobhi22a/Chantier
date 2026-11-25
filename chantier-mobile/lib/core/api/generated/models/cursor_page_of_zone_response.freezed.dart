// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cursor_page_of_zone_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CursorPageOfZoneResponse {

 List<ZoneResponse> get items; String? get nextCursor;
/// Create a copy of CursorPageOfZoneResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CursorPageOfZoneResponseCopyWith<CursorPageOfZoneResponse> get copyWith => _$CursorPageOfZoneResponseCopyWithImpl<CursorPageOfZoneResponse>(this as CursorPageOfZoneResponse, _$identity);

  /// Serializes this CursorPageOfZoneResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CursorPageOfZoneResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'CursorPageOfZoneResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $CursorPageOfZoneResponseCopyWith<$Res>  {
  factory $CursorPageOfZoneResponseCopyWith(CursorPageOfZoneResponse value, $Res Function(CursorPageOfZoneResponse) _then) = _$CursorPageOfZoneResponseCopyWithImpl;
@useResult
$Res call({
 List<ZoneResponse> items, String? nextCursor
});



}
/// @nodoc
class _$CursorPageOfZoneResponseCopyWithImpl<$Res>
    implements $CursorPageOfZoneResponseCopyWith<$Res> {
  _$CursorPageOfZoneResponseCopyWithImpl(this._self, this._then);

  final CursorPageOfZoneResponse _self;
  final $Res Function(CursorPageOfZoneResponse) _then;

/// Create a copy of CursorPageOfZoneResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ZoneResponse>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CursorPageOfZoneResponse implements CursorPageOfZoneResponse {
  const _CursorPageOfZoneResponse({required final  List<ZoneResponse> items, required this.nextCursor}): _items = items;
  factory _CursorPageOfZoneResponse.fromJson(Map<String, dynamic> json) => _$CursorPageOfZoneResponseFromJson(json);

 final  List<ZoneResponse> _items;
@override List<ZoneResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;

/// Create a copy of CursorPageOfZoneResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CursorPageOfZoneResponseCopyWith<_CursorPageOfZoneResponse> get copyWith => __$CursorPageOfZoneResponseCopyWithImpl<_CursorPageOfZoneResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CursorPageOfZoneResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CursorPageOfZoneResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'CursorPageOfZoneResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$CursorPageOfZoneResponseCopyWith<$Res> implements $CursorPageOfZoneResponseCopyWith<$Res> {
  factory _$CursorPageOfZoneResponseCopyWith(_CursorPageOfZoneResponse value, $Res Function(_CursorPageOfZoneResponse) _then) = __$CursorPageOfZoneResponseCopyWithImpl;
@override @useResult
$Res call({
 List<ZoneResponse> items, String? nextCursor
});



}
/// @nodoc
class __$CursorPageOfZoneResponseCopyWithImpl<$Res>
    implements _$CursorPageOfZoneResponseCopyWith<$Res> {
  __$CursorPageOfZoneResponseCopyWithImpl(this._self, this._then);

  final _CursorPageOfZoneResponse _self;
  final $Res Function(_CursorPageOfZoneResponse) _then;

/// Create a copy of CursorPageOfZoneResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_CursorPageOfZoneResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ZoneResponse>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
