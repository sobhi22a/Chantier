import 'dart:convert';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

part 'outbox_dao.g.dart';

/// Compteurs de l'indicateur de synchronisation (CA-013) pour un utilisateur.
class OutboxCounts extends Equatable {
  const OutboxCounts({required this.toSend, required this.toCheck});

  /// Operations a envoyer : `pending` et `sending`.
  final int toSend;

  /// Operations « a verifier » : `conflict` et `rejected`.
  final int toCheck;

  int get total => toSend + toCheck;

  @override
  List<Object?> get props => [toSend, toCheck];
}

/// File d'envoi. **Toutes** les lectures sont filtrees par proprietaire : un autre compte
/// connecte sur le meme telephone ne voit ni n'envoie les saisies de A (CA-002.4).
@DriftAccessor(tables: [OutboxOperations])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.attachedDatabase);

  /// Ajoute une operation. A appeler **dans la meme transaction** que l'ecriture locale
  /// correspondante : `db.transaction(() async { ...saisie...; await outboxDao.enqueue(...); })`.
  ///
  /// Idempotent sur `clientId` : un second appui (meme `clientId`, cree a l'ouverture du
  /// formulaire) n'ajoute rien et retourne `false`.
  Future<bool> enqueue(OutboxOperationsCompanion operation) =>
      transaction(() async {
        final clientId = operation.clientId.value;
        final existing = await getByClientId(clientId);
        if (existing != null) return false;
        await into(outboxOperations).insert(operation);
        return true;
      });

  Future<OutboxRow?> getByClientId(String clientId) => (select(
    outboxOperations,
  )..where((t) => t.clientId.equals(clientId))).getSingleOrNull();

  Future<OutboxRow?> getById(int id) => (select(
    outboxOperations,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Toutes les operations du proprietaire, les plus anciennes d'abord (lecture ponctuelle).
  Future<List<OutboxRow>> allFor(String ownerUserId) =>
      (select(outboxOperations)
            ..where((t) => t.ownerUserId.equals(ownerUserId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  /// Remplace le contenu (et le libelle) d'une operation **pas encore envoyee** : correction
  /// d'une saisie qui attend son envoi, sans operation supplementaire. Retourne `false` si
  /// l'operation n'est plus `pending` (envoi en cours ou termine).
  Future<bool> replacePendingPayload(
    int id, {
    required String payloadJson,
    required String label,
  }) async {
    final updated =
        await (update(outboxOperations)..where(
              (t) =>
                  t.id.equals(id) & t.status.equals(OutboxStatus.pending.name),
            ))
            .write(
              OutboxOperationsCompanion(
                payloadJson: Value(payloadJson),
                label: Value(label),
              ),
            );
    return updated > 0;
  }

  /// Une zone creee hors ligne a ete fusionnee avec une zone identique du serveur : les demandes
  /// en attente qui designaient l'ancienne par `zoneClientId` designent maintenant la zone
  /// retenue (`zoneId`). Rien n'est perdu, aucune erreur n'est affichee.
  Future<void> rewriteZoneReference({
    required String fromClientId,
    required String toZoneId,
  }) async {
    final rows =
        await (select(outboxOperations)..where(
              (t) =>
                  t.entity.equals('request') &
                  t.operation.equals('create') &
                  t.status.isIn([
                    OutboxStatus.pending.name,
                    OutboxStatus.sending.name,
                  ]),
            ))
            .get();
    for (final row in rows) {
      final payload = jsonDecode(row.payloadJson);
      if (payload is! Map || payload['zoneClientId'] != fromClientId) continue;
      final next = Map<String, Object?>.from(payload)
        ..remove('zoneClientId')
        ..['zoneId'] = toZoneId;
      await (update(outboxOperations)..where((t) => t.id.equals(row.id))).write(
        OutboxOperationsCompanion(payloadJson: Value(jsonEncode(next))),
      );
    }
  }

  /// Operations `pending` du proprietaire, **dans l'ordre de creation**, par lot.
  Future<List<OutboxRow>> pendingFor(String ownerUserId, {int limit = 50}) =>
      (select(outboxOperations)
            ..where(
              (t) =>
                  t.ownerUserId.equals(ownerUserId) &
                  t.status.equals(OutboxStatus.pending.name),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.id)])
            ..limit(limit))
          .get();

  /// Toutes les operations du proprietaire (ecran « Envois en attente »), les plus anciennes d'abord.
  Stream<List<OutboxRow>> watchFor(String ownerUserId) =>
      (select(outboxOperations)
            ..where((t) => t.ownerUserId.equals(ownerUserId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  /// Compteurs exacts « X a envoyer » / « Y a verifier » (CT-24).
  Stream<OutboxCounts> watchCounts(String ownerUserId) =>
      watchFor(ownerUserId).map((rows) {
        var toSend = 0;
        var toCheck = 0;
        for (final row in rows) {
          switch (row.status) {
            case OutboxStatus.pending || OutboxStatus.sending:
              toSend++;
            case OutboxStatus.conflict || OutboxStatus.rejected:
              toCheck++;
          }
        }
        return OutboxCounts(toSend: toSend, toCheck: toCheck);
      });

  Future<void> markSending(List<int> ids) =>
      _setStatus(ids, OutboxStatus.sending);

  /// Echec temporaire (reseau, 5xx, 429) : l'operation reste a envoyer, tentative comptee.
  Future<void> markRetry(int id, {String? errorCode}) =>
      (update(outboxOperations)..where((t) => t.id.equals(id))).write(
        OutboxOperationsCompanion.custom(
          status: Variable<String>(OutboxStatus.pending.name),
          attempts: outboxOperations.attempts + const Constant(1),
          lastErrorCode: Variable<String>(errorCode),
        ),
      );

  /// Reponse `conflict` ou `rejected` : conservee avec son code, **jamais rejouee seule**.
  ///
  /// Pour un `conflict`, [conflictJson] garde l'etat du serveur (`current`, sans prix) et
  /// [conflictFields] la liste des champs en desaccord, pour l'ecran « A verifier » (ADR 0011).
  Future<void> markFailed(
    int id, {
    required OutboxStatus status,
    required String? errorCode,
    String? conflictJson,
    String? conflictFields,
  }) {
    assert(status == OutboxStatus.conflict || status == OutboxStatus.rejected);
    return (update(outboxOperations)..where((t) => t.id.equals(id))).write(
      OutboxOperationsCompanion(
        status: Value(status),
        lastErrorCode: Value(errorCode),
        conflictJson: Value(conflictJson),
        conflictFields: Value(conflictFields),
      ),
    );
  }

  /// Au demarrage : une operation restee `sending` (application tuee pendant l'envoi) repasse
  /// `pending`. Le renvoi est sans danger : le serveur reconnait le `clientId` (`duplicate`).
  Future<int> recoverInterrupted() =>
      (update(
        outboxOperations,
      )..where((t) => t.status.equals(OutboxStatus.sending.name))).write(
        const OutboxOperationsCompanion(status: Value(OutboxStatus.pending)),
      );

  /// Apres `applied`/`duplicate`, ou « Abandonner » confirme par l'utilisateur.
  Future<int> deleteOperation(int id) =>
      (delete(outboxOperations)..where((t) => t.id.equals(id))).go();

  Future<void> _setStatus(List<int> ids, OutboxStatus status) =>
      (update(outboxOperations)..where((t) => t.id.isIn(ids))).write(
        OutboxOperationsCompanion(status: Value(status)),
      );
}
