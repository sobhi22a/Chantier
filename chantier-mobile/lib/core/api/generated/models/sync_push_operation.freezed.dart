// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_push_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncPushOperation {

/// Identifiant généré par le téléphone : rend l'envoi idempotent (un renvoi donne `duplicate`).
 String get clientId;/// Entité visée (`zone` au socle) ; une autre entité reçoit `rejected` `ENTITE_NON_SYNCHRONISABLE`.
 String get entity;/// `create`, `update` ou `transition` (au socle : `create` d'une zone).
 String get operation;/// Chantier visé.
 String? get siteId;/// Contenu de l'opération : les champs de la ressource (pour une zone : `block`, `elevation`, `roomType`, `roomNumber`, `roomLabel`, `clientCreatedAt`).
 dynamic get payload;/// Version serveur lue par le téléphone (modifications) ; inutilisée pour une création.
 String? get baseVersion;
/// Create a copy of SyncPushOperation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncPushOperationCopyWith<SyncPushOperation> get copyWith => _$SyncPushOperationCopyWithImpl<SyncPushOperation>(this as SyncPushOperation, _$identity);

  /// Serializes this SyncPushOperation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncPushOperation&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.baseVersion, baseVersion) || other.baseVersion == baseVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,entity,operation,siteId,const DeepCollectionEquality().hash(payload),baseVersion);

@override
String toString() {
  return 'SyncPushOperation(clientId: $clientId, entity: $entity, operation: $operation, siteId: $siteId, payload: $payload, baseVersion: $baseVersion)';
}


}

/// @nodoc
abstract mixin class $SyncPushOperationCopyWith<$Res>  {
  factory $SyncPushOperationCopyWith(SyncPushOperation value, $Res Function(SyncPushOperation) _then) = _$SyncPushOperationCopyWithImpl;
@useResult
$Res call({
 String clientId, String entity, String operation, String? siteId, dynamic payload, String? baseVersion
});



}
/// @nodoc
class _$SyncPushOperationCopyWithImpl<$Res>
    implements $SyncPushOperationCopyWith<$Res> {
  _$SyncPushOperationCopyWithImpl(this._self, this._then);

  final SyncPushOperation _self;
  final $Res Function(SyncPushOperation) _then;

/// Create a copy of SyncPushOperation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = null,Object? entity = null,Object? operation = null,Object? siteId = freezed,Object? payload = freezed,Object? baseVersion = freezed,}) {
  return _then(_self.copyWith(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,entity: null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as dynamic,baseVersion: freezed == baseVersion ? _self.baseVersion : baseVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SyncPushOperation implements SyncPushOperation {
  const _SyncPushOperation({required this.clientId, required this.entity, required this.operation, this.siteId, this.payload, this.baseVersion});
  factory _SyncPushOperation.fromJson(Map<String, dynamic> json) => _$SyncPushOperationFromJson(json);

/// Identifiant généré par le téléphone : rend l'envoi idempotent (un renvoi donne `duplicate`).
@override final  String clientId;
/// Entité visée (`zone` au socle) ; une autre entité reçoit `rejected` `ENTITE_NON_SYNCHRONISABLE`.
@override final  String entity;
/// `create`, `update` ou `transition` (au socle : `create` d'une zone).
@override final  String operation;
/// Chantier visé.
@override final  String? siteId;
/// Contenu de l'opération : les champs de la ressource (pour une zone : `block`, `elevation`, `roomType`, `roomNumber`, `roomLabel`, `clientCreatedAt`).
@override final  dynamic payload;
/// Version serveur lue par le téléphone (modifications) ; inutilisée pour une création.
@override final  String? baseVersion;

/// Create a copy of SyncPushOperation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncPushOperationCopyWith<_SyncPushOperation> get copyWith => __$SyncPushOperationCopyWithImpl<_SyncPushOperation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncPushOperationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncPushOperation&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.baseVersion, baseVersion) || other.baseVersion == baseVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,entity,operation,siteId,const DeepCollectionEquality().hash(payload),baseVersion);

@override
String toString() {
  return 'SyncPushOperation(clientId: $clientId, entity: $entity, operation: $operation, siteId: $siteId, payload: $payload, baseVersion: $baseVersion)';
}


}

/// @nodoc
abstract mixin class _$SyncPushOperationCopyWith<$Res> implements $SyncPushOperationCopyWith<$Res> {
  factory _$SyncPushOperationCopyWith(_SyncPushOperation value, $Res Function(_SyncPushOperation) _then) = __$SyncPushOperationCopyWithImpl;
@override @useResult
$Res call({
 String clientId, String entity, String operation, String? siteId, dynamic payload, String? baseVersion
});



}
/// @nodoc
class __$SyncPushOperationCopyWithImpl<$Res>
    implements _$SyncPushOperationCopyWith<$Res> {
  __$SyncPushOperationCopyWithImpl(this._self, this._then);

  final _SyncPushOperation _self;
  final $Res Function(_SyncPushOperation) _then;

/// Create a copy of SyncPushOperation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = null,Object? entity = null,Object? operation = null,Object? siteId = freezed,Object? payload = freezed,Object? baseVersion = freezed,}) {
  return _then(_SyncPushOperation(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,entity: null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,siteId: freezed == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as dynamic,baseVersion: freezed == baseVersion ? _self.baseVersion : baseVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
