// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_deletion.freezed.dart';
part 'sync_deletion.g.dart';

/// Pierre tombale : le client supprime la ligne (et, pour un chantier, tous ses enfants).
@Freezed()
abstract class SyncDeletion with _$SyncDeletion {
  const factory SyncDeletion({
    /// `site`, `zone` ou `member`.
    required String entity,

    /// Identifiant de la ligne supprimée.
    required String id,

    /// Chantier de la ligne.
    required String siteId,

    /// Version serveur de la suppression.
    required String version,
  }) = _SyncDeletion;

  factory SyncDeletion.fromJson(Map<String, Object?> json) =>
      _$SyncDeletionFromJson(json);
}
