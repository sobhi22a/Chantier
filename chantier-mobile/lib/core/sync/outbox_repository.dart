import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/outbox_dao.dart';

/// File d'envoi (outbox) vue par l'interface et les formulaires.
///
/// Regle d'or (ADR 0009) : **une ecriture locale et son operation d'envoi sont creees dans la
/// meme transaction**, jamais l'une sans l'autre ([saveWithOperation]).
class OutboxRepository {
  OutboxRepository(this._db);

  final AppDatabase _db;

  /// Ecrit la saisie locale ([localWrite]) ET l'ajoute a la file d'envoi, dans UNE transaction :
  /// si l'une des deux echoue, rien n'est enregistre.
  ///
  /// Anti-doublon : le `clientId` est cree a l'ouverture du formulaire. Si une operation de meme
  /// `clientId` existe deja (double appui, renvoi), **rien n'est ecrit** et la methode retourne
  /// `false`.
  Future<bool> saveWithOperation({
    required OutboxOperationsCompanion operation,
    required Future<void> Function() localWrite,
  }) => _db.transaction(() async {
    final existing = await _db.outboxDao.getByClientId(
      operation.clientId.value,
    );
    if (existing != null) return false;
    await localWrite();
    return _db.outboxDao.enqueue(operation);
  });

  /// Toutes les operations de l'utilisateur, les plus anciennes d'abord (liste « Envois en attente »).
  Stream<List<OutboxRow>> watch(String ownerUserId) =>
      _db.outboxDao.watchFor(ownerUserId);

  /// Compteurs exacts « a envoyer » / « a verifier » de l'utilisateur seulement (CA-013.9).
  Stream<OutboxCounts> watchCounts(String ownerUserId) =>
      _db.outboxDao.watchCounts(ownerUserId);

  Future<int> countFor(String ownerUserId) async =>
      (await _db.outboxDao.watchCounts(ownerUserId).first).total;

  /// « Abandonner » (apres confirmation de l'utilisateur) : supprime l'operation et, pour une
  /// zone creee hors ligne, la zone locale en attente. Rien n'est supprime sans cette decision
  /// (CA-013.7).
  Future<void> abandon(OutboxRow row) => _db.transaction(() async {
    if (row.entity == 'zone' && row.operation == 'create') {
      final local = await _db.zonesDao.getById(row.clientId);
      if (local != null && local.isPending) {
        await _db.zonesDao.deleteZone(row.clientId);
      }
    }
    await _db.outboxDao.deleteOperation(row.id);
  });
}
