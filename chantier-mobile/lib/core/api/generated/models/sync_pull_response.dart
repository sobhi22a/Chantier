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
  }) = _SyncPullResponse;

  factory SyncPullResponse.fromJson(Map<String, Object?> json) =>
      _$SyncPullResponseFromJson(json);
}
