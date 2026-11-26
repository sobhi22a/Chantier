// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'sync_change.dart';
import 'sync_deletion.dart';

part 'sync_pull_response.freezed.dart';
part 'sync_pull_response.g.dart';

/// Une page de changements.
@Freezed()
abstract class SyncPullResponse with _$SyncPullResponse {
  const factory SyncPullResponse({
    /// Lignes créées ou modifiées, par version croissante.
    required List<SyncChange> changes,

    /// Pierres tombales.
    required List<SyncDeletion> deleted,

    /// Curseur à renvoyer au prochain appel (donné par le serveur, jamais l'horloge du téléphone).
    required String cursor,

    /// Vrai s'il reste des changements : rappeler tout de suite avec ce curseur.
    required bool hasMore,

    /// Absent (faux) sauf signal additif (R3-05) : des demandes ou livraisons ont change depuis ce curseur mais sont sorties de la <b>fenetre de synchronisation</b>.
    /// (`Sync:ClosedRetentionDays`, 60 jours) : le telephone en garde peut-etre une version perimee (une demande close qu'il croit ouverte) et ne la recevra jamais (aucune pierre tombale).
    /// Le client vide alors ses donnees de synchronisation (hors file d'envoi) et recommence a `since` vide, <b>en ignorant ce signal jusqu'a la fin de ce pull complet</b>.
    /// (un pull depuis zero le voit forcement). Les autres champs de la page restent valides : un client qui ignore le signal continue de se synchroniser.
    @Default(false) bool resetRequired,
  }) = _SyncPullResponse;

  factory SyncPullResponse.fromJson(Map<String, Object?> json) =>
      _$SyncPullResponseFromJson(json);
}
