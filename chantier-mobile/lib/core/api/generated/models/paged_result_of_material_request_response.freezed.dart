// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paged_result_of_material_request_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PagedResultOfMaterialRequestResponse {

 List<MaterialRequestResponse> get items; int get page; int get pageSize; int get totalCount;
/// Create a copy of PagedResultOfMaterialRequestResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedResultOfMaterialRequestResponseCopyWith<PagedResultOfMaterialRequestResponse> get copyWith => _$PagedResultOfMaterialRequestResponseCopyWithImpl<PagedResultOfMaterialRequestResponse>(this as PagedResultOfMaterialRequestResponse, _$identity);

  /// Serializes this PagedResultOfMaterialRequestResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedResultOfMaterialRequestResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,pageSize,totalCount);

@override
String toString() {
  return 'PagedResultOfMaterialRequestResponse(items: $items, page: $page, pageSize: $pageSize, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $PagedResultOfMaterialRequestResponseCopyWith<$Res>  {
  factory $PagedResultOfMaterialRequestResponseCopyWith(PagedResultOfMaterialRequestResponse value, $Res Function(PagedResultOfMaterialRequestResponse) _then) = _$PagedResultOfMaterialRequestResponseCopyWithImpl;
@useResult
$Res call({
 List<MaterialRequestResponse> items, int page, int pageSize, int totalCount
});



}
/// @nodoc
class _$PagedResultOfMaterialRequestResponseCopyWithImpl<$Res>
    implements $PagedResultOfMaterialRequestResponseCopyWith<$Res> {
  _$PagedResultOfMaterialRequestResponseCopyWithImpl(this._self, this._then);

  final PagedResultOfMaterialRequestResponse _self;
  final $Res Function(PagedResultOfMaterialRequestResponse) _then;

/// Create a copy of PagedResultOfMaterialRequestResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MaterialRequestResponse>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PagedResultOfMaterialRequestResponse implements PagedResultOfMaterialRequestResponse {
  const _PagedResultOfMaterialRequestResponse({required final  List<MaterialRequestResponse> items, required this.page, required this.pageSize, required this.totalCount}): _items = items;
  factory _PagedResultOfMaterialRequestResponse.fromJson(Map<String, dynamic> json) => _$PagedResultOfMaterialRequestResponseFromJson(json);

 final  List<MaterialRequestResponse> _items;
@override List<MaterialRequestResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  int pageSize;
@override final  int totalCount;

/// Create a copy of PagedResultOfMaterialRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedResultOfMaterialRequestResponseCopyWith<_PagedResultOfMaterialRequestResponse> get copyWith => __$PagedResultOfMaterialRequestResponseCopyWithImpl<_PagedResultOfMaterialRequestResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedResultOfMaterialRequestResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedResultOfMaterialRequestResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,pageSize,totalCount);

@override
String toString() {
  return 'PagedResultOfMaterialRequestResponse(items: $items, page: $page, pageSize: $pageSize, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$PagedResultOfMaterialRequestResponseCopyWith<$Res> implements $PagedResultOfMaterialRequestResponseCopyWith<$Res> {
  factory _$PagedResultOfMaterialRequestResponseCopyWith(_PagedResultOfMaterialRequestResponse value, $Res Function(_PagedResultOfMaterialRequestResponse) _then) = __$PagedResultOfMaterialRequestResponseCopyWithImpl;
@override @useResult
$Res call({
 List<MaterialRequestResponse> items, int page, int pageSize, int totalCount
});



}
/// @nodoc
class __$PagedResultOfMaterialRequestResponseCopyWithImpl<$Res>
    implements _$PagedResultOfMaterialRequestResponseCopyWith<$Res> {
  __$PagedResultOfMaterialRequestResponseCopyWithImpl(this._self, this._then);

  final _PagedResultOfMaterialRequestResponse _self;
  final $Res Function(_PagedResultOfMaterialRequestResponse) _then;

/// Create a copy of PagedResultOfMaterialRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,}) {
  return _then(_PagedResultOfMaterialRequestResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MaterialRequestResponse>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
