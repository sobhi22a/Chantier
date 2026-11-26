// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_history_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestHistoryItem {

 String get id; MaterialEventType get type; RequestStatus? get fromStatus; RequestStatus? get toStatus; String? get reasonCode; String? get reasonNote; List<FieldChange>? get changes; String? get actorName; DateTime get occurredAt;/// « Saisi le » du telephone pour une saisie hors ligne : information seulement.
 DateTime? get deviceAt; MaterialEventSource get source;
/// Create a copy of RequestHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestHistoryItemCopyWith<RequestHistoryItem> get copyWith => _$RequestHistoryItemCopyWithImpl<RequestHistoryItem>(this as RequestHistoryItem, _$identity);

  /// Serializes this RequestHistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reasonNote, reasonNote) || other.reasonNote == reasonNote)&&const DeepCollectionEquality().equals(other.changes, changes)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.deviceAt, deviceAt) || other.deviceAt == deviceAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fromStatus,toStatus,reasonCode,reasonNote,const DeepCollectionEquality().hash(changes),actorName,occurredAt,deviceAt,source);

@override
String toString() {
  return 'RequestHistoryItem(id: $id, type: $type, fromStatus: $fromStatus, toStatus: $toStatus, reasonCode: $reasonCode, reasonNote: $reasonNote, changes: $changes, actorName: $actorName, occurredAt: $occurredAt, deviceAt: $deviceAt, source: $source)';
}


}

/// @nodoc
abstract mixin class $RequestHistoryItemCopyWith<$Res>  {
  factory $RequestHistoryItemCopyWith(RequestHistoryItem value, $Res Function(RequestHistoryItem) _then) = _$RequestHistoryItemCopyWithImpl;
@useResult
$Res call({
 String id, MaterialEventType type, RequestStatus? fromStatus, RequestStatus? toStatus, String? reasonCode, String? reasonNote, List<FieldChange>? changes, String? actorName, DateTime occurredAt, DateTime? deviceAt, MaterialEventSource source
});



}
/// @nodoc
class _$RequestHistoryItemCopyWithImpl<$Res>
    implements $RequestHistoryItemCopyWith<$Res> {
  _$RequestHistoryItemCopyWithImpl(this._self, this._then);

  final RequestHistoryItem _self;
  final $Res Function(RequestHistoryItem) _then;

/// Create a copy of RequestHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? fromStatus = freezed,Object? toStatus = freezed,Object? reasonCode = freezed,Object? reasonNote = freezed,Object? changes = freezed,Object? actorName = freezed,Object? occurredAt = null,Object? deviceAt = freezed,Object? source = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MaterialEventType,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as RequestStatus?,toStatus: freezed == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as RequestStatus?,reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String?,reasonNote: freezed == reasonNote ? _self.reasonNote : reasonNote // ignore: cast_nullable_to_non_nullable
as String?,changes: freezed == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<FieldChange>?,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceAt: freezed == deviceAt ? _self.deviceAt : deviceAt // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MaterialEventSource,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RequestHistoryItem implements RequestHistoryItem {
  const _RequestHistoryItem({required this.id, required this.type, required this.fromStatus, required this.toStatus, required this.reasonCode, required this.reasonNote, required final  List<FieldChange>? changes, required this.actorName, required this.occurredAt, required this.deviceAt, required this.source}): _changes = changes;
  factory _RequestHistoryItem.fromJson(Map<String, dynamic> json) => _$RequestHistoryItemFromJson(json);

@override final  String id;
@override final  MaterialEventType type;
@override final  RequestStatus? fromStatus;
@override final  RequestStatus? toStatus;
@override final  String? reasonCode;
@override final  String? reasonNote;
 final  List<FieldChange>? _changes;
@override List<FieldChange>? get changes {
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
@override final  MaterialEventSource source;

/// Create a copy of RequestHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestHistoryItemCopyWith<_RequestHistoryItem> get copyWith => __$RequestHistoryItemCopyWithImpl<_RequestHistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestHistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reasonNote, reasonNote) || other.reasonNote == reasonNote)&&const DeepCollectionEquality().equals(other._changes, _changes)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.deviceAt, deviceAt) || other.deviceAt == deviceAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fromStatus,toStatus,reasonCode,reasonNote,const DeepCollectionEquality().hash(_changes),actorName,occurredAt,deviceAt,source);

@override
String toString() {
  return 'RequestHistoryItem(id: $id, type: $type, fromStatus: $fromStatus, toStatus: $toStatus, reasonCode: $reasonCode, reasonNote: $reasonNote, changes: $changes, actorName: $actorName, occurredAt: $occurredAt, deviceAt: $deviceAt, source: $source)';
}


}

/// @nodoc
abstract mixin class _$RequestHistoryItemCopyWith<$Res> implements $RequestHistoryItemCopyWith<$Res> {
  factory _$RequestHistoryItemCopyWith(_RequestHistoryItem value, $Res Function(_RequestHistoryItem) _then) = __$RequestHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, MaterialEventType type, RequestStatus? fromStatus, RequestStatus? toStatus, String? reasonCode, String? reasonNote, List<FieldChange>? changes, String? actorName, DateTime occurredAt, DateTime? deviceAt, MaterialEventSource source
});



}
/// @nodoc
class __$RequestHistoryItemCopyWithImpl<$Res>
    implements _$RequestHistoryItemCopyWith<$Res> {
  __$RequestHistoryItemCopyWithImpl(this._self, this._then);

  final _RequestHistoryItem _self;
  final $Res Function(_RequestHistoryItem) _then;

/// Create a copy of RequestHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? fromStatus = freezed,Object? toStatus = freezed,Object? reasonCode = freezed,Object? reasonNote = freezed,Object? changes = freezed,Object? actorName = freezed,Object? occurredAt = null,Object? deviceAt = freezed,Object? source = null,}) {
  return _then(_RequestHistoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MaterialEventType,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as RequestStatus?,toStatus: freezed == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as RequestStatus?,reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String?,reasonNote: freezed == reasonNote ? _self.reasonNote : reasonNote // ignore: cast_nullable_to_non_nullable
as String?,changes: freezed == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<FieldChange>?,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,deviceAt: freezed == deviceAt ? _self.deviceAt : deviceAt // ignore: cast_nullable_to_non_nullable
as DateTime?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MaterialEventSource,
  ));
}


}

// dart format on
