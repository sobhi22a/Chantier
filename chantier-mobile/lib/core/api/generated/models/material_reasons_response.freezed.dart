// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'material_reasons_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaterialReasonsResponse {

 List<String> get rejection; List<String> get requestCancellation; List<String> get orderCancellation; List<String> get settle; List<String> get deliveryCancellation; List<String> get reserve;
/// Create a copy of MaterialReasonsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialReasonsResponseCopyWith<MaterialReasonsResponse> get copyWith => _$MaterialReasonsResponseCopyWithImpl<MaterialReasonsResponse>(this as MaterialReasonsResponse, _$identity);

  /// Serializes this MaterialReasonsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterialReasonsResponse&&const DeepCollectionEquality().equals(other.rejection, rejection)&&const DeepCollectionEquality().equals(other.requestCancellation, requestCancellation)&&const DeepCollectionEquality().equals(other.orderCancellation, orderCancellation)&&const DeepCollectionEquality().equals(other.settle, settle)&&const DeepCollectionEquality().equals(other.deliveryCancellation, deliveryCancellation)&&const DeepCollectionEquality().equals(other.reserve, reserve));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rejection),const DeepCollectionEquality().hash(requestCancellation),const DeepCollectionEquality().hash(orderCancellation),const DeepCollectionEquality().hash(settle),const DeepCollectionEquality().hash(deliveryCancellation),const DeepCollectionEquality().hash(reserve));

@override
String toString() {
  return 'MaterialReasonsResponse(rejection: $rejection, requestCancellation: $requestCancellation, orderCancellation: $orderCancellation, settle: $settle, deliveryCancellation: $deliveryCancellation, reserve: $reserve)';
}


}

/// @nodoc
abstract mixin class $MaterialReasonsResponseCopyWith<$Res>  {
  factory $MaterialReasonsResponseCopyWith(MaterialReasonsResponse value, $Res Function(MaterialReasonsResponse) _then) = _$MaterialReasonsResponseCopyWithImpl;
@useResult
$Res call({
 List<String> rejection, List<String> requestCancellation, List<String> orderCancellation, List<String> settle, List<String> deliveryCancellation, List<String> reserve
});



}
/// @nodoc
class _$MaterialReasonsResponseCopyWithImpl<$Res>
    implements $MaterialReasonsResponseCopyWith<$Res> {
  _$MaterialReasonsResponseCopyWithImpl(this._self, this._then);

  final MaterialReasonsResponse _self;
  final $Res Function(MaterialReasonsResponse) _then;

/// Create a copy of MaterialReasonsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rejection = null,Object? requestCancellation = null,Object? orderCancellation = null,Object? settle = null,Object? deliveryCancellation = null,Object? reserve = null,}) {
  return _then(_self.copyWith(
rejection: null == rejection ? _self.rejection : rejection // ignore: cast_nullable_to_non_nullable
as List<String>,requestCancellation: null == requestCancellation ? _self.requestCancellation : requestCancellation // ignore: cast_nullable_to_non_nullable
as List<String>,orderCancellation: null == orderCancellation ? _self.orderCancellation : orderCancellation // ignore: cast_nullable_to_non_nullable
as List<String>,settle: null == settle ? _self.settle : settle // ignore: cast_nullable_to_non_nullable
as List<String>,deliveryCancellation: null == deliveryCancellation ? _self.deliveryCancellation : deliveryCancellation // ignore: cast_nullable_to_non_nullable
as List<String>,reserve: null == reserve ? _self.reserve : reserve // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _MaterialReasonsResponse implements MaterialReasonsResponse {
  const _MaterialReasonsResponse({required final  List<String> rejection, required final  List<String> requestCancellation, required final  List<String> orderCancellation, required final  List<String> settle, required final  List<String> deliveryCancellation, required final  List<String> reserve}): _rejection = rejection,_requestCancellation = requestCancellation,_orderCancellation = orderCancellation,_settle = settle,_deliveryCancellation = deliveryCancellation,_reserve = reserve;
  factory _MaterialReasonsResponse.fromJson(Map<String, dynamic> json) => _$MaterialReasonsResponseFromJson(json);

 final  List<String> _rejection;
@override List<String> get rejection {
  if (_rejection is EqualUnmodifiableListView) return _rejection;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejection);
}

 final  List<String> _requestCancellation;
@override List<String> get requestCancellation {
  if (_requestCancellation is EqualUnmodifiableListView) return _requestCancellation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requestCancellation);
}

 final  List<String> _orderCancellation;
@override List<String> get orderCancellation {
  if (_orderCancellation is EqualUnmodifiableListView) return _orderCancellation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orderCancellation);
}

 final  List<String> _settle;
@override List<String> get settle {
  if (_settle is EqualUnmodifiableListView) return _settle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_settle);
}

 final  List<String> _deliveryCancellation;
@override List<String> get deliveryCancellation {
  if (_deliveryCancellation is EqualUnmodifiableListView) return _deliveryCancellation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deliveryCancellation);
}

 final  List<String> _reserve;
@override List<String> get reserve {
  if (_reserve is EqualUnmodifiableListView) return _reserve;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reserve);
}


/// Create a copy of MaterialReasonsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialReasonsResponseCopyWith<_MaterialReasonsResponse> get copyWith => __$MaterialReasonsResponseCopyWithImpl<_MaterialReasonsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialReasonsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterialReasonsResponse&&const DeepCollectionEquality().equals(other._rejection, _rejection)&&const DeepCollectionEquality().equals(other._requestCancellation, _requestCancellation)&&const DeepCollectionEquality().equals(other._orderCancellation, _orderCancellation)&&const DeepCollectionEquality().equals(other._settle, _settle)&&const DeepCollectionEquality().equals(other._deliveryCancellation, _deliveryCancellation)&&const DeepCollectionEquality().equals(other._reserve, _reserve));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rejection),const DeepCollectionEquality().hash(_requestCancellation),const DeepCollectionEquality().hash(_orderCancellation),const DeepCollectionEquality().hash(_settle),const DeepCollectionEquality().hash(_deliveryCancellation),const DeepCollectionEquality().hash(_reserve));

@override
String toString() {
  return 'MaterialReasonsResponse(rejection: $rejection, requestCancellation: $requestCancellation, orderCancellation: $orderCancellation, settle: $settle, deliveryCancellation: $deliveryCancellation, reserve: $reserve)';
}


}

/// @nodoc
abstract mixin class _$MaterialReasonsResponseCopyWith<$Res> implements $MaterialReasonsResponseCopyWith<$Res> {
  factory _$MaterialReasonsResponseCopyWith(_MaterialReasonsResponse value, $Res Function(_MaterialReasonsResponse) _then) = __$MaterialReasonsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<String> rejection, List<String> requestCancellation, List<String> orderCancellation, List<String> settle, List<String> deliveryCancellation, List<String> reserve
});



}
/// @nodoc
class __$MaterialReasonsResponseCopyWithImpl<$Res>
    implements _$MaterialReasonsResponseCopyWith<$Res> {
  __$MaterialReasonsResponseCopyWithImpl(this._self, this._then);

  final _MaterialReasonsResponse _self;
  final $Res Function(_MaterialReasonsResponse) _then;

/// Create a copy of MaterialReasonsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rejection = null,Object? requestCancellation = null,Object? orderCancellation = null,Object? settle = null,Object? deliveryCancellation = null,Object? reserve = null,}) {
  return _then(_MaterialReasonsResponse(
rejection: null == rejection ? _self._rejection : rejection // ignore: cast_nullable_to_non_nullable
as List<String>,requestCancellation: null == requestCancellation ? _self._requestCancellation : requestCancellation // ignore: cast_nullable_to_non_nullable
as List<String>,orderCancellation: null == orderCancellation ? _self._orderCancellation : orderCancellation // ignore: cast_nullable_to_non_nullable
as List<String>,settle: null == settle ? _self._settle : settle // ignore: cast_nullable_to_non_nullable
as List<String>,deliveryCancellation: null == deliveryCancellation ? _self._deliveryCancellation : deliveryCancellation // ignore: cast_nullable_to_non_nullable
as List<String>,reserve: null == reserve ? _self._reserve : reserve // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
