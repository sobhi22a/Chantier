// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'to_order_total_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ToOrderTotalLine {

/// Produit du catalogue ; `null` pour un nom libre.
 String? get productId; String get name; Quantity get total;/// Nombre de demandes comptees dans cette ligne.
 int get requestCount;/// Masse en tonnes d'un total en sacs ; absente sinon.
 Quantity? get massEquivalent;
/// Create a copy of ToOrderTotalLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToOrderTotalLineCopyWith<ToOrderTotalLine> get copyWith => _$ToOrderTotalLineCopyWithImpl<ToOrderTotalLine>(this as ToOrderTotalLine, _$identity);

  /// Serializes this ToOrderTotalLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToOrderTotalLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.total, total) || other.total == total)&&(identical(other.requestCount, requestCount) || other.requestCount == requestCount)&&(identical(other.massEquivalent, massEquivalent) || other.massEquivalent == massEquivalent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,total,requestCount,massEquivalent);

@override
String toString() {
  return 'ToOrderTotalLine(productId: $productId, name: $name, total: $total, requestCount: $requestCount, massEquivalent: $massEquivalent)';
}


}

/// @nodoc
abstract mixin class $ToOrderTotalLineCopyWith<$Res>  {
  factory $ToOrderTotalLineCopyWith(ToOrderTotalLine value, $Res Function(ToOrderTotalLine) _then) = _$ToOrderTotalLineCopyWithImpl;
@useResult
$Res call({
 String? productId, String name, Quantity total, int requestCount, Quantity? massEquivalent
});



}
/// @nodoc
class _$ToOrderTotalLineCopyWithImpl<$Res>
    implements $ToOrderTotalLineCopyWith<$Res> {
  _$ToOrderTotalLineCopyWithImpl(this._self, this._then);

  final ToOrderTotalLine _self;
  final $Res Function(ToOrderTotalLine) _then;

/// Create a copy of ToOrderTotalLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? name = null,Object? total = null,Object? requestCount = null,Object? massEquivalent = freezed,}) {
  return _then(_self.copyWith(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Quantity,requestCount: null == requestCount ? _self.requestCount : requestCount // ignore: cast_nullable_to_non_nullable
as int,massEquivalent: freezed == massEquivalent ? _self.massEquivalent : massEquivalent // ignore: cast_nullable_to_non_nullable
as Quantity?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ToOrderTotalLine implements ToOrderTotalLine {
  const _ToOrderTotalLine({required this.productId, required this.name, required this.total, required this.requestCount, this.massEquivalent});
  factory _ToOrderTotalLine.fromJson(Map<String, dynamic> json) => _$ToOrderTotalLineFromJson(json);

/// Produit du catalogue ; `null` pour un nom libre.
@override final  String? productId;
@override final  String name;
@override final  Quantity total;
/// Nombre de demandes comptees dans cette ligne.
@override final  int requestCount;
/// Masse en tonnes d'un total en sacs ; absente sinon.
@override final  Quantity? massEquivalent;

/// Create a copy of ToOrderTotalLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToOrderTotalLineCopyWith<_ToOrderTotalLine> get copyWith => __$ToOrderTotalLineCopyWithImpl<_ToOrderTotalLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToOrderTotalLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToOrderTotalLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.total, total) || other.total == total)&&(identical(other.requestCount, requestCount) || other.requestCount == requestCount)&&(identical(other.massEquivalent, massEquivalent) || other.massEquivalent == massEquivalent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,total,requestCount,massEquivalent);

@override
String toString() {
  return 'ToOrderTotalLine(productId: $productId, name: $name, total: $total, requestCount: $requestCount, massEquivalent: $massEquivalent)';
}


}

/// @nodoc
abstract mixin class _$ToOrderTotalLineCopyWith<$Res> implements $ToOrderTotalLineCopyWith<$Res> {
  factory _$ToOrderTotalLineCopyWith(_ToOrderTotalLine value, $Res Function(_ToOrderTotalLine) _then) = __$ToOrderTotalLineCopyWithImpl;
@override @useResult
$Res call({
 String? productId, String name, Quantity total, int requestCount, Quantity? massEquivalent
});



}
/// @nodoc
class __$ToOrderTotalLineCopyWithImpl<$Res>
    implements _$ToOrderTotalLineCopyWith<$Res> {
  __$ToOrderTotalLineCopyWithImpl(this._self, this._then);

  final _ToOrderTotalLine _self;
  final $Res Function(_ToOrderTotalLine) _then;

/// Create a copy of ToOrderTotalLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? name = null,Object? total = null,Object? requestCount = null,Object? massEquivalent = freezed,}) {
  return _then(_ToOrderTotalLine(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Quantity,requestCount: null == requestCount ? _self.requestCount : requestCount // ignore: cast_nullable_to_non_nullable
as int,massEquivalent: freezed == massEquivalent ? _self.massEquivalent : massEquivalent // ignore: cast_nullable_to_non_nullable
as Quantity?,
  ));
}


}

// dart format on
