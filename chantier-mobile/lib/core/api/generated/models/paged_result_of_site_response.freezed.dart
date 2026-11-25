// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paged_result_of_site_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PagedResultOfSiteResponse {

 List<SiteResponse> get items; int get page; int get pageSize; int get totalCount;
/// Create a copy of PagedResultOfSiteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedResultOfSiteResponseCopyWith<PagedResultOfSiteResponse> get copyWith => _$PagedResultOfSiteResponseCopyWithImpl<PagedResultOfSiteResponse>(this as PagedResultOfSiteResponse, _$identity);

  /// Serializes this PagedResultOfSiteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedResultOfSiteResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,pageSize,totalCount);

@override
String toString() {
  return 'PagedResultOfSiteResponse(items: $items, page: $page, pageSize: $pageSize, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $PagedResultOfSiteResponseCopyWith<$Res>  {
  factory $PagedResultOfSiteResponseCopyWith(PagedResultOfSiteResponse value, $Res Function(PagedResultOfSiteResponse) _then) = _$PagedResultOfSiteResponseCopyWithImpl;
@useResult
$Res call({
 List<SiteResponse> items, int page, int pageSize, int totalCount
});



}
/// @nodoc
class _$PagedResultOfSiteResponseCopyWithImpl<$Res>
    implements $PagedResultOfSiteResponseCopyWith<$Res> {
  _$PagedResultOfSiteResponseCopyWithImpl(this._self, this._then);

  final PagedResultOfSiteResponse _self;
  final $Res Function(PagedResultOfSiteResponse) _then;

/// Create a copy of PagedResultOfSiteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SiteResponse>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PagedResultOfSiteResponse implements PagedResultOfSiteResponse {
  const _PagedResultOfSiteResponse({required final  List<SiteResponse> items, required this.page, required this.pageSize, required this.totalCount}): _items = items;
  factory _PagedResultOfSiteResponse.fromJson(Map<String, dynamic> json) => _$PagedResultOfSiteResponseFromJson(json);

 final  List<SiteResponse> _items;
@override List<SiteResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  int pageSize;
@override final  int totalCount;

/// Create a copy of PagedResultOfSiteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedResultOfSiteResponseCopyWith<_PagedResultOfSiteResponse> get copyWith => __$PagedResultOfSiteResponseCopyWithImpl<_PagedResultOfSiteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedResultOfSiteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedResultOfSiteResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,pageSize,totalCount);

@override
String toString() {
  return 'PagedResultOfSiteResponse(items: $items, page: $page, pageSize: $pageSize, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$PagedResultOfSiteResponseCopyWith<$Res> implements $PagedResultOfSiteResponseCopyWith<$Res> {
  factory _$PagedResultOfSiteResponseCopyWith(_PagedResultOfSiteResponse value, $Res Function(_PagedResultOfSiteResponse) _then) = __$PagedResultOfSiteResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SiteResponse> items, int page, int pageSize, int totalCount
});



}
/// @nodoc
class __$PagedResultOfSiteResponseCopyWithImpl<$Res>
    implements _$PagedResultOfSiteResponseCopyWith<$Res> {
  __$PagedResultOfSiteResponseCopyWithImpl(this._self, this._then);

  final _PagedResultOfSiteResponse _self;
  final $Res Function(_PagedResultOfSiteResponse) _then;

/// Create a copy of PagedResultOfSiteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,}) {
  return _then(_PagedResultOfSiteResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SiteResponse>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
