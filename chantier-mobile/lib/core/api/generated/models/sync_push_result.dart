// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_push_result.freezed.dart';
part 'sync_push_result.g.dart';

/// Résultat d'une opération, dans l'ordre d'envoi : `applied`, `duplicate` (déjà reçue, éventuellement.
/// `merged` avec une ressource identique), `conflict` (avec `current`) ou `rejected` (avec `code`).
@Freezed()
abstract class SyncPushResult with _$SyncPushResult {
  const factory SyncPushResult({
    /// Identifiant de l'opération côté téléphone.
    required String clientId,

    /// `applied`, `duplicate`, `conflict` ou `rejected`.
    required String status,

    /// Ressource créée ou déjà existante (`applied`, `duplicate`).
    dynamic resource,

    /// État du serveur (`conflict`).
    dynamic current,

    /// Code d'erreur du catalogue (`rejected`) : `INTROUVABLE`, `INTERDIT`, `CHANTIER_ARCHIVE`, `VALIDATION`, `ZONE_EXISTANTE`, `ENTITE_NON_SYNCHRONISABLE`.
    String? code,

    /// Vrai si une ressource identique, créée par un autre téléphone, a été retenue : y rattacher les saisies, sans erreur affichée.
    bool? merged,

    /// Détail par champ (`rejected` avec `VALIDATION`).
    Map<String, List<String>>? errors,
  }) = _SyncPushResult;

  factory SyncPushResult.fromJson(Map<String, Object?> json) =>
      _$SyncPushResultFromJson(json);
}
