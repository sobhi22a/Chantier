// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_push_operation.freezed.dart';
part 'sync_push_operation.g.dart';

/// Une opération saisie hors ligne. Le chantier visé est vérifié à l'envoi (affectation, sinon `INTROUVABLE`).
@Freezed()
abstract class SyncPushOperation with _$SyncPushOperation {
  const factory SyncPushOperation({
    /// Identifiant généré par le téléphone : rend l'envoi idempotent (un renvoi donne `duplicate`).
    required String clientId,

    /// Entité visée (`zone` au socle) ; une autre entité reçoit `rejected` `ENTITE_NON_SYNCHRONISABLE`.
    required String entity,

    /// `create`, `update` ou `transition` (au socle : `create` d'une zone).
    required String operation,

    /// Chantier visé.
    String? siteId,

    /// Contenu de l'opération : les champs de la ressource (pour une zone : `block`, `elevation`, `roomType`, `roomNumber`, `roomLabel`, `clientCreatedAt`).
    dynamic payload,

    /// Version serveur lue par le téléphone (modifications) ; inutilisée pour une création.
    String? baseVersion,
  }) = _SyncPushOperation;

  factory SyncPushOperation.fromJson(Map<String, Object?> json) =>
      _$SyncPushOperationFromJson(json);
}
