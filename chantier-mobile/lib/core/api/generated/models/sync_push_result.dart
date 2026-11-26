// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_push_result.freezed.dart';
part 'sync_push_result.g.dart';

/// Résultat d'une opération, dans l'ordre d'envoi : `applied`, `duplicate` (déjà reçue, éventuellement.
/// `merged` avec une ressource identique), `conflict` (avec `current`), `rejected` (avec `code`) ou `retry` (echec momentane du serveur, rien n'est ecrit : renvoyer.
/// l'operation telle quelle plus tard ; un client qui ne connait pas ce statut la renvoie comme une operation sans reponse).
@Freezed()
abstract class SyncPushResult with _$SyncPushResult {
  const factory SyncPushResult({
    /// Identifiant de l'opération côté téléphone.
    required String clientId,

    /// `applied`, `duplicate`, `conflict`, `rejected` ou `retry`.
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

    /// Champs en désaccord (`conflict` avec `CONFLIT_VERSION`) : la valeur saisie et celle du serveur diffèrent de la valeur de départ.
    List<String>? conflictFields,
  }) = _SyncPushResult;

  factory SyncPushResult.fromJson(Map<String, Object?> json) =>
      _$SyncPushResultFromJson(json);
}
