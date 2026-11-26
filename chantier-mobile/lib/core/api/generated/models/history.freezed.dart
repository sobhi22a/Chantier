// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$History {

 String get id;/// Type d'evenement de l'historique. `OrderCommercialEdited` est sensible : rendu seulement avec `Prices.View`, jamais synchronise.
 Type get type; FromStatus get fromStatus; ToStatus get toStatus; String? get reasonCode; String? get reasonNote; List<Changes>? get changes; String? get actorName; DateTime get occurredAt;/// « Saisi le » du telephone pour une saisie hors ligne : information seulement.
 DateTime? get deviceAt;/// Origine d'un evenement : API directe, push de synchronisation, ou systeme (recalcul).
 Source get source;
/// Create a copy of History
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryCopyWith<History> get copyWith => _$HistoryCopyWithImpl<History>(this as History, _$identity);

  /// Serializes this History to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is History&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reasonNote, reasonNote) || other.reasonNote == reasonNote)&&const DeepCollectionEquality().equals(other.changes, changes)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.deviceAt, deviceAt) || other.deviceAt == deviceAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fromStatus,toStatus,reasonCode,reasonNote,const DeepCollectionEquality().hash(changes),actorName,occurredAt,deviceAt,source);

@override
String toString() {
  return 'History(id: $id, type: $type, fromStatus: $fromStatus, toStatus: $toStatus, reasonCode: $reasonCode, reasonNote: $reasonNote, changes: $changes, actorName: $actorName, occurredAt: $occurredAt, deviceAt: $deviceAt, source: $source)';
}


}

/// @nodoc
abstract mixin class $HistoryCopyWith<$Res>  {
  factory $HistoryCopyWith(History value, $Res Function(History) _then) = _$HistoryCopyWithImpl;
@useResult
$Res call({
 String id, Type type, FromStatus fromStatus, ToStatus toStatus, String? reasonCode, String? reasonNote, List<Changes>? changes, String? actorName, DateTime occurredAt, DateTime? deviceAt, Source source
});



}
/// @nodoc
class _$HistoryCopyWithImpl<$Res>
    implements $HistoryCopyWith<$Res> {
  _$HistoryCopyWithImpl(this._self, this._then);

  final History _self;
  final $Res Function(History) _then;

/// Create a copy of History
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
as List<Changes>?,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceAt: freezed == deviceAt ? _self.deviceAt : deviceAt // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Source,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _History implements History {
  const _History({required this.id, required this.type, required this.fromStatus, required this.toStatus, required this.reasonCode, required this.reasonNote, required final  List<Changes>? changes, required this.actorName, required this.occurredAt, required this.deviceAt, required this.source}): _changes = changes;
  factory _History.fromJson(Map<String, dynamic> json) => _$HistoryFromJson(json);

@override final  String id;
/// Type d'evenement de l'historique. `OrderCommercialEdited` est sensible : rendu seulement avec `Prices.View`, jamais synchronise.
@override final  Type type;
@override final  FromStatus fromStatus;
@override final  ToStatus toStatus;
@override final  String? reasonCode;
@override final  String? reasonNote;
 final  List<Changes>? _changes;
@override List<Changes>? get changes {
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

/// Create a copy of History
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryCopyWith<_History> get copyWith => __$HistoryCopyWithImpl<_History>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _History&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reasonNote, reasonNote) || other.reasonNote == reasonNote)&&const DeepCollectionEquality().equals(other._changes, _changes)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.deviceAt, deviceAt) || other.deviceAt == deviceAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fromStatus,toStatus,reasonCode,reasonNote,const DeepCollectionEquality().hash(_changes),actorName,occurredAt,deviceAt,source);

@override
String toString() {
  return 'History(id: $id, type: $type, fromStatus: $fromStatus, toStatus: $toStatus, reasonCode: $reasonCode, reasonNote: $reasonNote, changes: $changes, actorName: $actorName, occurredAt: $occurredAt, deviceAt: $deviceAt, source: $source)';
}


}

/// @nodoc
abstract mixin class _$HistoryCopyWith<$Res> implements $HistoryCopyWith<$Res> {
  factory _$HistoryCopyWith(_History value, $Res Function(_History) _then) = __$HistoryCopyWithImpl;
@override @useResult
$Res call({
 String id, Type type, FromStatus fromStatus, ToStatus toStatus, String? reasonCode, String? reasonNote, List<Changes>? changes, String? actorName, DateTime occurredAt, DateTime? deviceAt, Source source
});



}
/// @nodoc
class __$HistoryCopyWithImpl<$Res>
    implements _$HistoryCopyWith<$Res> {
  __$HistoryCopyWithImpl(this._self, this._then);

  final _History _self;
  final $Res Function(_History) _then;

/// Create a copy of History
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? fromStatus = null,Object? toStatus = null,Object? reasonCode = freezed,Object? reasonNote = freezed,Object? changes = freezed,Object? actorName = freezed,Object? occurredAt = null,Object? deviceAt = freezed,Object? source = null,}) {
  return _then(_History(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as Type,fromStatus: null == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as FromStatus,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as ToStatus,reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String?,reasonNote: freezed == reasonNote ? _self.reasonNote : reasonNote // ignore: cast_nullable_to_non_nullable
as String?,changes: freezed == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<Changes>?,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceAt: freezed == deviceAt ? _self.deviceAt : deviceAt // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Source,
  ));
}


}

// dart format on
