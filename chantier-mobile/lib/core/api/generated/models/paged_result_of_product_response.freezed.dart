// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paged_result_of_product_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PagedResultOfProductResponse {

 List<ProductResponse> get items; int get page; int get pageSize; int get totalCount;
/// Create a copy of PagedResultOfProductResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedResultOfProductResponseCopyWith<PagedResultOfProductResponse> get copyWith => _$PagedResultOfProductResponseCopyWithImpl<PagedResultOfProductResponse>(this as PagedResultOfProductResponse, _$identity);

  /// Serializes this PagedResultOfProductResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedResultOfProductResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,pageSize,totalCount);

@override
String toString() {
  return 'PagedResultOfProductResponse(items: $items, page: $page, pageSize: $pageSize, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $PagedResultOfProductResponseCopyWith<$Res>  {
  factory $PagedResultOfProductResponseCopyWith(PagedResultOfProductResponse value, $Res Function(PagedResultOfProductResponse) _then) = _$PagedResultOfProductResponseCopyWithImpl;
@useResult
$Res call({
 List<ProductResponse> items, int page, int pageSize, int totalCount
});



}
/// @nodoc
class _$PagedResultOfProductResponseCopyWithImpl<$Res>
    implements $PagedResultOfProductResponseCopyWith<$Res> {
  _$PagedResultOfProductResponseCopyWithImpl(this._self, this._then);

  final PagedResultOfProductResponse _self;
  final $Res Function(PagedResultOfProductResponse) _then;

/// Create a copy of PagedResultOfProductResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ProductResponse>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PagedResultOfProductResponse implements PagedResultOfProductResponse {
  const _PagedResultOfProductResponse({required final  List<ProductResponse> items, required this.page, required this.pageSize, required this.totalCount}): _items = items;
  factory _PagedResultOfProductResponse.fromJson(Map<String, dynamic> json) => _$PagedResultOfProductResponseFromJson(json);

 final  List<ProductResponse> _items;
@override List<ProductResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  int pageSize;
@override final  int totalCount;

/// Create a copy of PagedResultOfProductResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedResultOfProductResponseCopyWith<_PagedResultOfProductResponse> get copyWith => __$PagedResultOfProductResponseCopyWithImpl<_PagedResultOfProductResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedResultOfProductResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedResultOfProductResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,pageSize,totalCount);

@override
String toString() {
  return 'PagedResultOfProductResponse(items: $items, page: $page, pageSize: $pageSize, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$PagedResultOfProductResponseCopyWith<$Res> implements $PagedResultOfProductResponseCopyWith<$Res> {
  factory _$PagedResultOfProductResponseCopyWith(_PagedResultOfProductResponse value, $Res Function(_PagedResultOfProductResponse) _then) = __$PagedResultOfProductResponseCopyWithImpl;
@override @useResult
$Res call({
 List<ProductResponse> items, int page, int pageSize, int totalCount
});



}
/// @nodoc
class __$PagedResultOfProductResponseCopyWithImpl<$Res>
    implements _$PagedResultOfProductResponseCopyWith<$Res> {
  __$PagedResultOfProductResponseCopyWithImpl(this._self, this._then);

  final _PagedResultOfProductResponse _self;
  final $Res Function(_PagedResultOfProductResponse) _then;

/// Create a copy of PagedResultOfProductResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,}) {
  return _then(_PagedResultOfProductResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProductResponse>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
