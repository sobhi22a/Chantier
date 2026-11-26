// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_pull_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncPullResponse {

/// Lignes créées ou modifiées, par version croissante.
 List<SyncChange> get changes;/// Pierres tombales.
 List<SyncDeletion> get deleted;/// Curseur à renvoyer au prochain appel (donné par le serveur, jamais l'horloge du téléphone).
 String get cursor;/// Vrai s'il reste des changements : rappeler tout de suite avec ce curseur.
 bool get hasMore;/// Absent (faux) sauf signal additif (R3-05) : des demandes ou livraisons ont change depuis ce curseur mais sont sorties de la <b>fenetre de synchronisation</b>.
/// (`Sync:ClosedRetentionDays`, 60 jours) : le telephone en garde peut-etre une version perimee (une demande close qu'il croit ouverte) et ne la recevra jamais (aucune pierre tombale).
/// Le client vide alors ses donnees de synchronisation (hors file d'envoi) et recommence a `since` vide, <b>en ignorant ce signal jusqu'a la fin de ce pull complet</b>.
/// (un pull depuis zero le voit forcement). Les autres champs de la page restent valides : un client qui ignore le signal continue de se synchroniser.
 bool get resetRequired;
/// Create a copy of SyncPullResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncPullResponseCopyWith<SyncPullResponse> get copyWith => _$SyncPullResponseCopyWithImpl<SyncPullResponse>(this as SyncPullResponse, _$identity);

  /// Serializes this SyncPullResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncPullResponse&&const DeepCollectionEquality().equals(other.changes, changes)&&const DeepCollectionEquality().equals(other.deleted, deleted)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.resetRequired, resetRequired) || other.resetRequired == resetRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(changes),const DeepCollectionEquality().hash(deleted),cursor,hasMore,resetRequired);

@override
String toString() {
  return 'SyncPullResponse(changes: $changes, deleted: $deleted, cursor: $cursor, hasMore: $hasMore, resetRequired: $resetRequired)';
}


}

/// @nodoc
abstract mixin class $SyncPullResponseCopyWith<$Res>  {
  factory $SyncPullResponseCopyWith(SyncPullResponse value, $Res Function(SyncPullResponse) _then) = _$SyncPullResponseCopyWithImpl;
@useResult
$Res call({
 List<SyncChange> changes, List<SyncDeletion> deleted, String cursor, bool hasMore, bool resetRequired
});



}
/// @nodoc
class _$SyncPullResponseCopyWithImpl<$Res>
    implements $SyncPullResponseCopyWith<$Res> {
  _$SyncPullResponseCopyWithImpl(this._self, this._then);

  final SyncPullResponse _self;
  final $Res Function(SyncPullResponse) _then;

/// Create a copy of SyncPullResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? changes = null,Object? deleted = null,Object? cursor = null,Object? hasMore = null,Object? resetRequired = null,}) {
  return _then(_self.copyWith(
changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<SyncChange>,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as List<SyncDeletion>,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,resetRequired: null == resetRequired ? _self.resetRequired : resetRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SyncPullResponse implements SyncPullResponse {
  const _SyncPullResponse({required final  List<SyncChange> changes, required final  List<SyncDeletion> deleted, required this.cursor, required this.hasMore, this.resetRequired = false}): _changes = changes,_deleted = deleted;
  factory _SyncPullResponse.fromJson(Map<String, dynamic> json) => _$SyncPullResponseFromJson(json);

/// Lignes créées ou modifiées, par version croissante.
 final  List<SyncChange> _changes;
/// Lignes créées ou modifiées, par version croissante.
@override List<SyncChange> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}

/// Pierres tombales.
 final  List<SyncDeletion> _deleted;
/// Pierres tombales.
@override List<SyncDeletion> get deleted {
  if (_deleted is EqualUnmodifiableListView) return _deleted;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deleted);
}

/// Curseur à renvoyer au prochain appel (donné par le serveur, jamais l'horloge du téléphone).
@override final  String cursor;
/// Vrai s'il reste des changements : rappeler tout de suite avec ce curseur.
@override final  bool hasMore;
/// Absent (faux) sauf signal additif (R3-05) : des demandes ou livraisons ont change depuis ce curseur mais sont sorties de la <b>fenetre de synchronisation</b>.
/// (`Sync:ClosedRetentionDays`, 60 jours) : le telephone en garde peut-etre une version perimee (une demande close qu'il croit ouverte) et ne la recevra jamais (aucune pierre tombale).
/// Le client vide alors ses donnees de synchronisation (hors file d'envoi) et recommence a `since` vide, <b>en ignorant ce signal jusqu'a la fin de ce pull complet</b>.
/// (un pull depuis zero le voit forcement). Les autres champs de la page restent valides : un client qui ignore le signal continue de se synchroniser.
@override@JsonKey() final  bool resetRequired;

/// Create a copy of SyncPullResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncPullResponseCopyWith<_SyncPullResponse> get copyWith => __$SyncPullResponseCopyWithImpl<_SyncPullResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncPullResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncPullResponse&&const DeepCollectionEquality().equals(other._changes, _changes)&&const DeepCollectionEquality().equals(other._deleted, _deleted)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.resetRequired, resetRequired) || other.resetRequired == resetRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_changes),const DeepCollectionEquality().hash(_deleted),cursor,hasMore,resetRequired);

@override
String toString() {
  return 'SyncPullResponse(changes: $changes, deleted: $deleted, cursor: $cursor, hasMore: $hasMore, resetRequired: $resetRequired)';
}


}

/// @nodoc
abstract mixin class _$SyncPullResponseCopyWith<$Res> implements $SyncPullResponseCopyWith<$Res> {
  factory _$SyncPullResponseCopyWith(_SyncPullResponse value, $Res Function(_SyncPullResponse) _then) = __$SyncPullResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SyncChange> changes, List<SyncDeletion> deleted, String cursor, bool hasMore, bool resetRequired
});



}
/// @nodoc
class __$SyncPullResponseCopyWithImpl<$Res>
    implements _$SyncPullResponseCopyWith<$Res> {
  __$SyncPullResponseCopyWithImpl(this._self, this._then);

  final _SyncPullResponse _self;
  final $Res Function(_SyncPullResponse) _then;

/// Create a copy of SyncPullResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? changes = null,Object? deleted = null,Object? cursor = null,Object? hasMore = null,Object? resetRequired = null,}) {
  return _then(_SyncPullResponse(
changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<SyncChange>,deleted: null == deleted ? _self._deleted : deleted // ignore: cast_nullable_to_non_nullable
as List<SyncDeletion>,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,resetRequired: null == resetRequired ? _self.resetRequired : resetRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
