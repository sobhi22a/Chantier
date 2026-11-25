// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'items_response_of_site_member_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemsResponseOfSiteMemberResponse {

 List<SiteMemberResponse> get items;
/// Create a copy of ItemsResponseOfSiteMemberResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemsResponseOfSiteMemberResponseCopyWith<ItemsResponseOfSiteMemberResponse> get copyWith => _$ItemsResponseOfSiteMemberResponseCopyWithImpl<ItemsResponseOfSiteMemberResponse>(this as ItemsResponseOfSiteMemberResponse, _$identity);

  /// Serializes this ItemsResponseOfSiteMemberResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemsResponseOfSiteMemberResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ItemsResponseOfSiteMemberResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $ItemsResponseOfSiteMemberResponseCopyWith<$Res>  {
  factory $ItemsResponseOfSiteMemberResponseCopyWith(ItemsResponseOfSiteMemberResponse value, $Res Function(ItemsResponseOfSiteMemberResponse) _then) = _$ItemsResponseOfSiteMemberResponseCopyWithImpl;
@useResult
$Res call({
 List<SiteMemberResponse> items
});



}
/// @nodoc
class _$ItemsResponseOfSiteMemberResponseCopyWithImpl<$Res>
    implements $ItemsResponseOfSiteMemberResponseCopyWith<$Res> {
  _$ItemsResponseOfSiteMemberResponseCopyWithImpl(this._self, this._then);

  final ItemsResponseOfSiteMemberResponse _self;
  final $Res Function(ItemsResponseOfSiteMemberResponse) _then;

/// Create a copy of ItemsResponseOfSiteMemberResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SiteMemberResponse>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ItemsResponseOfSiteMemberResponse implements ItemsResponseOfSiteMemberResponse {
  const _ItemsResponseOfSiteMemberResponse({required final  List<SiteMemberResponse> items}): _items = items;
  factory _ItemsResponseOfSiteMemberResponse.fromJson(Map<String, dynamic> json) => _$ItemsResponseOfSiteMemberResponseFromJson(json);

 final  List<SiteMemberResponse> _items;
@override List<SiteMemberResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ItemsResponseOfSiteMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemsResponseOfSiteMemberResponseCopyWith<_ItemsResponseOfSiteMemberResponse> get copyWith => __$ItemsResponseOfSiteMemberResponseCopyWithImpl<_ItemsResponseOfSiteMemberResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemsResponseOfSiteMemberResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemsResponseOfSiteMemberResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ItemsResponseOfSiteMemberResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$ItemsResponseOfSiteMemberResponseCopyWith<$Res> implements $ItemsResponseOfSiteMemberResponseCopyWith<$Res> {
  factory _$ItemsResponseOfSiteMemberResponseCopyWith(_ItemsResponseOfSiteMemberResponse value, $Res Function(_ItemsResponseOfSiteMemberResponse) _then) = __$ItemsResponseOfSiteMemberResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SiteMemberResponse> items
});



}
/// @nodoc
class __$ItemsResponseOfSiteMemberResponseCopyWithImpl<$Res>
    implements _$ItemsResponseOfSiteMemberResponseCopyWith<$Res> {
  __$ItemsResponseOfSiteMemberResponseCopyWithImpl(this._self, this._then);

  final _ItemsResponseOfSiteMemberResponse _self;
  final $Res Function(_ItemsResponseOfSiteMemberResponse) _then;

/// Create a copy of ItemsResponseOfSiteMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_ItemsResponseOfSiteMemberResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SiteMemberResponse>,
  ));
}


}

// dart format on
