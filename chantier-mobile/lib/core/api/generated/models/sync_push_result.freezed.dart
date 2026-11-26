// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_push_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncPushResult {

/// Identifiant de l'opération côté téléphone.
 String get clientId;/// `applied`, `duplicate`, `conflict`, `rejected` ou `retry`.
 String get status;/// Ressource créée ou déjà existante (`applied`, `duplicate`).
 dynamic get resource;/// État du serveur (`conflict`).
 dynamic get current;/// Code d'erreur du catalogue (`rejected`) : `INTROUVABLE`, `INTERDIT`, `CHANTIER_ARCHIVE`, `VALIDATION`, `ZONE_EXISTANTE`, `ENTITE_NON_SYNCHRONISABLE`.
 String? get code;/// Vrai si une ressource identique, créée par un autre téléphone, a été retenue : y rattacher les saisies, sans erreur affichée.
 bool? get merged;/// Détail par champ (`rejected` avec `VALIDATION`).
 Map<String, List<String>>? get errors;/// Champs en désaccord (`conflict` avec `CONFLIT_VERSION`) : la valeur saisie et celle du serveur diffèrent de la valeur de départ.
 List<String>? get conflictFields;
/// Create a copy of SyncPushResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncPushResultCopyWith<SyncPushResult> get copyWith => _$SyncPushResultCopyWithImpl<SyncPushResult>(this as SyncPushResult, _$identity);

  /// Serializes this SyncPushResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncPushResult&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.resource, resource)&&const DeepCollectionEquality().equals(other.current, current)&&(identical(other.code, code) || other.code == code)&&(identical(other.merged, merged) || other.merged == merged)&&const DeepCollectionEquality().equals(other.errors, errors)&&const DeepCollectionEquality().equals(other.conflictFields, conflictFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,status,const DeepCollectionEquality().hash(resource),const DeepCollectionEquality().hash(current),code,merged,const DeepCollectionEquality().hash(errors),const DeepCollectionEquality().hash(conflictFields));

@override
String toString() {
  return 'SyncPushResult(clientId: $clientId, status: $status, resource: $resource, current: $current, code: $code, merged: $merged, errors: $errors, conflictFields: $conflictFields)';
}


}

/// @nodoc
abstract mixin class $SyncPushResultCopyWith<$Res>  {
  factory $SyncPushResultCopyWith(SyncPushResult value, $Res Function(SyncPushResult) _then) = _$SyncPushResultCopyWithImpl;
@useResult
$Res call({
 String clientId, String status, dynamic resource, dynamic current, String? code, bool? merged, Map<String, List<String>>? errors, List<String>? conflictFields
});



}
/// @nodoc
class _$SyncPushResultCopyWithImpl<$Res>
    implements $SyncPushResultCopyWith<$Res> {
  _$SyncPushResultCopyWithImpl(this._self, this._then);

  final SyncPushResult _self;
  final $Res Function(SyncPushResult) _then;

/// Create a copy of SyncPushResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = null,Object? status = null,Object? resource = freezed,Object? current = freezed,Object? code = freezed,Object? merged = freezed,Object? errors = freezed,Object? conflictFields = freezed,}) {
  return _then(_self.copyWith(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,resource: freezed == resource ? _self.resource : resource // ignore: cast_nullable_to_non_nullable
as dynamic,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as dynamic,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,merged: freezed == merged ? _self.merged : merged // ignore: cast_nullable_to_non_nullable
as bool?,errors: freezed == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,conflictFields: freezed == conflictFields ? _self.conflictFields : conflictFields // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SyncPushResult implements SyncPushResult {
  const _SyncPushResult({required this.clientId, required this.status, this.resource, this.current, this.code, this.merged, final  Map<String, List<String>>? errors, final  List<String>? conflictFields}): _errors = errors,_conflictFields = conflictFields;
  factory _SyncPushResult.fromJson(Map<String, dynamic> json) => _$SyncPushResultFromJson(json);

/// Identifiant de l'opération côté téléphone.
@override final  String clientId;
/// `applied`, `duplicate`, `conflict`, `rejected` ou `retry`.
@override final  String status;
/// Ressource créée ou déjà existante (`applied`, `duplicate`).
@override final  dynamic resource;
/// État du serveur (`conflict`).
@override final  dynamic current;
/// Code d'erreur du catalogue (`rejected`) : `INTROUVABLE`, `INTERDIT`, `CHANTIER_ARCHIVE`, `VALIDATION`, `ZONE_EXISTANTE`, `ENTITE_NON_SYNCHRONISABLE`.
@override final  String? code;
/// Vrai si une ressource identique, créée par un autre téléphone, a été retenue : y rattacher les saisies, sans erreur affichée.
@override final  bool? merged;
/// Détail par champ (`rejected` avec `VALIDATION`).
 final  Map<String, List<String>>? _errors;
/// Détail par champ (`rejected` avec `VALIDATION`).
@override Map<String, List<String>>? get errors {
  final value = _errors;
  if (value == null) return null;
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Champs en désaccord (`conflict` avec `CONFLIT_VERSION`) : la valeur saisie et celle du serveur diffèrent de la valeur de départ.
 final  List<String>? _conflictFields;
/// Champs en désaccord (`conflict` avec `CONFLIT_VERSION`) : la valeur saisie et celle du serveur diffèrent de la valeur de départ.
@override List<String>? get conflictFields {
  final value = _conflictFields;
  if (value == null) return null;
  if (_conflictFields is EqualUnmodifiableListView) return _conflictFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SyncPushResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncPushResultCopyWith<_SyncPushResult> get copyWith => __$SyncPushResultCopyWithImpl<_SyncPushResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncPushResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncPushResult&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.resource, resource)&&const DeepCollectionEquality().equals(other.current, current)&&(identical(other.code, code) || other.code == code)&&(identical(other.merged, merged) || other.merged == merged)&&const DeepCollectionEquality().equals(other._errors, _errors)&&const DeepCollectionEquality().equals(other._conflictFields, _conflictFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,status,const DeepCollectionEquality().hash(resource),const DeepCollectionEquality().hash(current),code,merged,const DeepCollectionEquality().hash(_errors),const DeepCollectionEquality().hash(_conflictFields));

@override
String toString() {
  return 'SyncPushResult(clientId: $clientId, status: $status, resource: $resource, current: $current, code: $code, merged: $merged, errors: $errors, conflictFields: $conflictFields)';
}


}

/// @nodoc
abstract mixin class _$SyncPushResultCopyWith<$Res> implements $SyncPushResultCopyWith<$Res> {
  factory _$SyncPushResultCopyWith(_SyncPushResult value, $Res Function(_SyncPushResult) _then) = __$SyncPushResultCopyWithImpl;
@override @useResult
$Res call({
 String clientId, String status, dynamic resource, dynamic current, String? code, bool? merged, Map<String, List<String>>? errors, List<String>? conflictFields
});



}
/// @nodoc
class __$SyncPushResultCopyWithImpl<$Res>
    implements _$SyncPushResultCopyWith<$Res> {
  __$SyncPushResultCopyWithImpl(this._self, this._then);

  final _SyncPushResult _self;
  final $Res Function(_SyncPushResult) _then;

/// Create a copy of SyncPushResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = null,Object? status = null,Object? resource = freezed,Object? current = freezed,Object? code = freezed,Object? merged = freezed,Object? errors = freezed,Object? conflictFields = freezed,}) {
  return _then(_SyncPushResult(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,resource: freezed == resource ? _self.resource : resource // ignore: cast_nullable_to_non_nullable
as dynamic,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as dynamic,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,merged: freezed == merged ? _self.merged : merged // ignore: cast_nullable_to_non_nullable
as bool?,errors: freezed == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,conflictFields: freezed == conflictFields ? _self._conflictFields : conflictFields // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
