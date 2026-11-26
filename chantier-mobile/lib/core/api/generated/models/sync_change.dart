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

    /// Chantier de la ligne (pour un chantier : son propre identifiant) ; `null` pour une entité globale (`product`, `supplier`).
    required String? siteId,

    /// Version serveur (entier décimal en chaîne) : n'appliquer la ligne que si elle est plus grande que celle déjà connue.
    required String version,

    /// Ressource de la ligne, selon `entity` : `SiteResponse` (site), `ZoneResponse` (zone), `SyncMemberData` (member), `ProductResponse` (product), `SupplierSyncData` (supplier, sans téléphone), `RequestSyncData` (request, sans champ commercial), `DeliverySyncData` (delivery, sans montant ni photos) ou `PhotoResponse` (photo, métadonnées seulement).
    required dynamic data,
  }) = _SyncChange;

  factory SyncChange.fromJson(Map<String, Object?> json) =>
      _$SyncChangeFromJson(json);
}
