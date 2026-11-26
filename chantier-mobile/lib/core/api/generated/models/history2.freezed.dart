// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$History2 {

 String get id;/// Type d'evenement de l'historique. `OrderCommercialEdited` est sensible : rendu seulement avec `Prices.View`, jamais synchronise.
 Type get type; FromStatus get fromStatus; ToStatus get toStatus; String? get reasonCode; String? get reasonNote; List<Changes2>? get changes; String? get actorName; DateTime get occurredAt;/// « Saisi le » du telephone pour une saisie hors ligne : information seulement.
 DateTime? get deviceAt;/// Origine d'un evenement : API directe, push de synchronisation, ou systeme (recalcul).
 Source get source;
/// Create a copy of History2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$History2CopyWith<History2> get copyWith => _$History2CopyWithImpl<History2>(this as History2, _$identity);

  /// Serializes this History2 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is History2&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reasonNote, reasonNote) || other.reasonNote == reasonNote)&&const DeepCollectionEquality().equals(other.changes, changes)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.deviceAt, deviceAt) || other.deviceAt == deviceAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fromStatus,toStatus,reasonCode,reasonNote,const DeepCollectionEquality().hash(changes),actorName,occurredAt,deviceAt,source);

@override
String toString() {
  return 'History2(id: $id, type: $type, fromStatus: $fromStatus, toStatus: $toStatus, reasonCode: $reasonCode, reasonNote: $reasonNote, changes: $changes, actorName: $actorName, occurredAt: $occurredAt, deviceAt: $deviceAt, source: $source)';
}


}

/// @nodoc
abstract mixin class $History2CopyWith<$Res>  {
  factory $History2CopyWith(History2 value, $Res Function(History2) _then) = _$History2CopyWithImpl;
@useResult
$Res call({
 String id, Type type, FromStatus fromStatus, ToStatus toStatus, String? reasonCode, String? reasonNote, List<Changes2>? changes, String? actorName, DateTime occurredAt, DateTime? deviceAt, Source source
});



}
/// @nodoc
class _$History2CopyWithImpl<$Res>
    implements $History2CopyWith<$Res> {
  _$History2CopyWithImpl(this._self, this._then);

  final History2 _self;
  final $Res Function(History2) _then;

/// Create a copy of History2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? fromStatus = null,Object? toStatus = null,Object? reasonCode = freezed,Object? reasonNote = freezed,Object? changes = freezed,Object? actorName = freezed,Object? occurredAt = null,Object? deviceAt = freezed,Object? source = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as Type,fromStatus: null == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as FromStatus,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as ToStatus,reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String?,reasonNote: freezed == reasonNote ? _self.reasonNote : reasonNote // ignore: cast_nullable_to_non_nullable
as String?,changes: freezed == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<Changes2>?,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceAt: freezed == deviceAt ? _self.deviceAt : deviceAt // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Source,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _History2 implements History2 {
  const _History2({required this.id, required this.type, required this.fromStatus, required this.toStatus, required this.reasonCode, required this.reasonNote, required final  List<Changes2>? changes, required this.actorName, required this.occurredAt, required this.deviceAt, required this.source}): _changes = changes;
  factory _History2.fromJson(Map<String, dynamic> json) => _$History2FromJson(json);

@override final  String id;
/// Type d'evenement de l'historique. `OrderCommercialEdited` est sensible : rendu seulement avec `Prices.View`, jamais synchronise.
@override final  Type type;
@override final  FromStatus fromStatus;
@override final  ToStatus toStatus;
@override final  String? reasonCode;
@override final  String? reasonNote;
 final  List<Changes2>? _changes;
@override List<Changes2>? get changes {
  final value = _changes;
  if (value == null) return null;
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? actorName;
@override final  DateTime occurredAt;
/// « Saisi le » du telephone pour une saisie hors ligne : information seulement.
@override final  DateTime? deviceAt;
/// Origine d'un evenement : API directe, push de synchronisation, ou systeme (recalcul).
@override final  Source source;

/// Create a copy of History2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$History2CopyWith<_History2> get copyWith => __$History2CopyWithImpl<_History2>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$History2ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _History2&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reasonNote, reasonNote) || other.reasonNote == reasonNote)&&const DeepCollectionEquality().equals(other._changes, _changes)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.deviceAt, deviceAt) || other.deviceAt == deviceAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fromStatus,toStatus,reasonCode,reasonNote,const DeepCollectionEquality().hash(_changes),actorName,occurredAt,deviceAt,source);

@override
String toString() {
  return 'History2(id: $id, type: $type, fromStatus: $fromStatus, toStatus: $toStatus, reasonCode: $reasonCode, reasonNote: $reasonNote, changes: $changes, actorName: $actorName, occurredAt: $occurredAt, deviceAt: $deviceAt, source: $source)';
}


}

/// @nodoc
abstract mixin class _$History2CopyWith<$Res> implements $History2CopyWith<$Res> {
  factory _$History2CopyWith(_History2 value, $Res Function(_History2) _then) = __$History2CopyWithImpl;
@override @useResult
$Res call({
 String id, Type type, FromStatus fromStatus, ToStatus toStatus, String? reasonCode, String? reasonNote, List<Changes2>? changes, String? actorName, DateTime occurredAt, DateTime? deviceAt, Source source
});



}
/// @nodoc
class __$History2CopyWithImpl<$Res>
    implements _$History2CopyWith<$Res> {
  __$History2CopyWithImpl(this._self, this._then);

  final _History2 _self;
  final $Res Function(_History2) _then;

/// Create a copy of History2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? fromStatus = null,Object? toStatus = null,Object? reasonCode = freezed,Object? reasonNote = freezed,Object? changes = freezed,Object? actorName = freezed,Object? occurredAt = null,Object? deviceAt = freezed,Object? source = null,}) {
  return _then(_History2(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as Type,fromStatus: null == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as FromStatus,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as ToStatus,reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String?,reasonNote: freezed == reasonNote ? _self.reasonNote : reasonNote // ignore: cast_nullable_to_non_nullable
as String?,changes: freezed == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<Changes2>?,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceAt: freezed == deviceAt ? _self.deviceAt : deviceAt // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Source,
  ));
}


}

// dart format on
