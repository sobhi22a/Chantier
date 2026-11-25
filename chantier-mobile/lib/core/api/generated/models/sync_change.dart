// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_change.freezed.dart';
part 'sync_change.g.dart';

/// Ligne créée ou modifiée depuis le curseur.
@Freezed()
abstract class SyncChange with _$SyncChange {
  const factory SyncChange({
    /// `site`, `zone` ou `member` ; un client ignore une entité qu'il ne connaît pas.
    required String entity,

    /// Identifiant de la ligne.
    required String id,

    /// Chantier de la ligne (pour un chantier : son propre identifiant).
    required String siteId,

    /// Version serveur (entier décimal en chaîne) : n'appliquer la ligne que si elle est plus grande que celle déjà connue.
    required String version,

    /// Ressource telle que renvoyée par l'API REST : `SiteResponse` (site), `ZoneResponse` (zone) ou `SyncMemberData` (member).
    required dynamic data,
  }) = _SyncChange;

  factory SyncChange.fromJson(Map<String, Object?> json) =>
      _$SyncChangeFromJson(json);
}
