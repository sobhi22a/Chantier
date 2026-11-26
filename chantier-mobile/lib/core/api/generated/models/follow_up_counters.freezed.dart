// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_up_counters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowUpCounters {

/// A valider : demandees.
 int get toApprove;/// A commander : validees.
 int get toOrder;/// Attendues : commandees et livrees partiellement.
 int get expected;/// En retard : date de besoin depassee, ou commande attendue dont la date prevue est depassee.
/// The name has been replaced because it contains a keyword. Original name: `late`.
@JsonKey(name: 'late') int get lateValue;/// A receptionner : livrees.
 int get toReceive;
/// Create a copy of FollowUpCounters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowUpCountersCopyWith<FollowUpCounters> get copyWith => _$FollowUpCountersCopyWithImpl<FollowUpCounters>(this as FollowUpCounters, _$identity);

  /// Serializes this FollowUpCounters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowUpCounters&&(identical(other.toApprove, toApprove) || other.toApprove == toApprove)&&(identical(other.toOrder, toOrder) || other.toOrder == toOrder)&&(identical(other.expected, expected) || other.expected == expected)&&(identical(other.lateValue, lateValue) || other.lateValue == lateValue)&&(identical(other.toReceive, toReceive) || other.toReceive == toReceive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,toApprove,toOrder,expected,lateValue,toReceive);

@override
String toString() {
  return 'FollowUpCounters(toApprove: $toApprove, toOrder: $toOrder, expected: $expected, lateValue: $lateValue, toReceive: $toReceive)';
}


}

/// @nodoc
abstract mixin class $FollowUpCountersCopyWith<$Res>  {
  factory $FollowUpCountersCopyWith(FollowUpCounters value, $Res Function(FollowUpCounters) _then) = _$FollowUpCountersCopyWithImpl;
@useResult
$Res call({
 int toApprove, int toOrder, int expected,@JsonKey(name: 'late') int lateValue, int toReceive
});



}
/// @nodoc
class _$FollowUpCountersCopyWithImpl<$Res>
    implements $FollowUpCountersCopyWith<$Res> {
  _$FollowUpCountersCopyWithImpl(this._self, this._then);

  final FollowUpCounters _self;
  final $Res Function(FollowUpCounters) _then;

/// Create a copy of FollowUpCounters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? toApprove = null,Object? toOrder = null,Object? expected = null,Object? lateValue = null,Object? toReceive = null,}) {
  return _then(_self.copyWith(
toApprove: null == toApprove ? _self.toApprove : toApprove // ignore: cast_nullable_to_non_nullable
as int,toOrder: null == toOrder ? _self.toOrder : toOrder // ignore: cast_nullable_to_non_nullable
as int,expected: null == expected ? _self.expected : expected // ignore: cast_nullable_to_non_nullable
as int,lateValue: null == lateValue ? _self.lateValue : lateValue // ignore: cast_nullable_to_non_nullable
as int,toReceive: null == toReceive ? _self.toReceive : toReceive // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _FollowUpCounters implements FollowUpCounters {
  const _FollowUpCounters({required this.toApprove, required this.toOrder, required this.expected, @JsonKey(name: 'late') required this.lateValue, required this.toReceive});
  factory _FollowUpCounters.fromJson(Map<String, dynamic> json) => _$FollowUpCountersFromJson(json);

/// A valider : demandees.
@override final  int toApprove;
/// A commander : validees.
@override final  int toOrder;
/// Attendues : commandees et livrees partiellement.
@override final  int expected;
/// En retard : date de besoin depassee, ou commande attendue dont la date prevue est depassee.
/// The name has been replaced because it contains a keyword. Original name: `late`.
@override@JsonKey(name: 'late') final  int lateValue;
/// A receptionner : livrees.
@override final  int toReceive;

/// Create a copy of FollowUpCounters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowUpCountersCopyWith<_FollowUpCounters> get copyWith => __$FollowUpCountersCopyWithImpl<_FollowUpCounters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowUpCountersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowUpCounters&&(identical(other.toApprove, toApprove) || other.toApprove == toApprove)&&(identical(other.toOrder, toOrder) || other.toOrder == toOrder)&&(identical(other.expected, expected) || other.expected == expected)&&(identical(other.lateValue, lateValue) || other.lateValue == lateValue)&&(identical(other.toReceive, toReceive) || other.toReceive == toReceive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,toApprove,toOrder,expected,lateValue,toReceive);

@override
String toString() {
  return 'FollowUpCounters(toApprove: $toApprove, toOrder: $toOrder, expected: $expected, lateValue: $lateValue, toReceive: $toReceive)';
}


}

/// @nodoc
abstract mixin class _$FollowUpCountersCopyWith<$Res> implements $FollowUpCountersCopyWith<$Res> {
  factory _$FollowUpCountersCopyWith(_FollowUpCounters value, $Res Function(_FollowUpCounters) _then) = __$FollowUpCountersCopyWithImpl;
@override @useResult
$Res call({
 int toApprove, int toOrder, int expected,@JsonKey(name: 'late') int lateValue, int toReceive
});



}
/// @nodoc
class __$FollowUpCountersCopyWithImpl<$Res>
    implements _$FollowUpCountersCopyWith<$Res> {
  __$FollowUpCountersCopyWithImpl(this._self, this._then);

  final _FollowUpCounters _self;
  final $Res Function(_FollowUpCounters) _then;

/// Create a copy of FollowUpCounters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? toApprove = null,Object? toOrder = null,Object? expected = null,Object? lateValue = null,Object? toReceive = null,}) {
  return _then(_FollowUpCounters(
toApprove: null == toApprove ? _self.toApprove : toApprove // ignore: cast_nullable_to_non_nullable
as int,toOrder: null == toOrder ? _self.toOrder : toOrder // ignore: cast_nullable_to_non_nullable
as int,expected: null == expected ? _self.expected : expected // ignore: cast_nullable_to_non_nullable
as int,lateValue: null == lateValue ? _self.lateValue : lateValue // ignore: cast_nullable_to_non_nullable
as int,toReceive: null == toReceive ? _self.toReceive : toReceive // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
