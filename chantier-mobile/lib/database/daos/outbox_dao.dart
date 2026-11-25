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
  Future<void> markFailed(
    int id, {
    required OutboxStatus status,
    required String? errorCode,
  }) {
    assert(status == OutboxStatus.conflict || status == OutboxStatus.rejected);
    return (update(outboxOperations)..where((t) => t.id.equals(id))).write(
      OutboxOperationsCompanion(
        status: Value(status),
        lastErrorCode: Value(errorCode),
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
