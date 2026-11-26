import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/outbox_dao.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';

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

  /// Comme [saveWithOperation] pour une saisie qui produit **plusieurs** operations (une livraison
  /// et ses photos) : tout ou rien, dans l'ordre. Le `clientId` de la **premiere** operation est la
  /// cle anti-doublon du formulaire.
  Future<bool> saveWithOperations({
    required List<OutboxOperationsCompanion> operations,
    required Future<void> Function() localWrite,
  }) => _db.transaction(() async {
    final existing = await _db.outboxDao.getByClientId(
      operations.first.clientId.value,
    );
    if (existing != null) return false;
    await localWrite();
    for (final operation in operations) {
      await _db.outboxDao.enqueue(operation);
    }
    return true;
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
  /// zone ou une demande creee hors ligne, la ligne locale en attente (avec les saisies
  /// suivantes qui la designaient : corriger, annuler). Rien n'est supprime sans cette decision
  /// (CA-013.7).
  Future<void> abandon(OutboxRow row) => _db.transaction(() async {
    if (row.entity == 'zone' && row.operation == 'create') {
      final local = await _db.zonesDao.getById(row.clientId);
      if (local != null && local.isPending) {
        await _db.zonesDao.deleteZone(row.clientId);
      }
    }
    if (row.isRequestOperation && row.operation == RequestEntity.create) {
      final local = await _db.materialRequestsDao.getById(row.clientId);
      if (local != null && local.isPending) {
        await _db.materialRequestsDao.deleteRequest(row.clientId);
      }
      // Les saisies de cette demande qui n'ont pas encore ete envoyees n'ont plus d'objet.
      for (final dependent in await _db.outboxDao.allFor(row.ownerUserId)) {
        if (dependent.id != row.id &&
            dependent.status != OutboxStatus.sending &&
            dependent.requestRef?.requestClientId == row.clientId) {
          await _db.outboxDao.deleteOperation(dependent.id);
        }
      }
    }
    if (row.isDeliveryOperation && row.operation == DeliveryEntity.create) {
      final local = await _db.deliveriesDao.getById(row.clientId);
      if (local != null && local.isPending) {
        await _db.deliveriesDao.deleteDelivery(row.clientId);
      }
      // Les photos et corrections de cette livraison n'ont plus d'objet : leurs metadonnees et
      // leurs fichiers en attente partent avec elle (le fichier est retire du dossier prive par le
      // nettoyage des orphelins).
      for (final dependent in await _db.outboxDao.allFor(row.ownerUserId)) {
        if (dependent.id != row.id &&
            dependent.status != OutboxStatus.sending &&
            dependent.deliveryRef?.deliveryClientId == row.clientId) {
          await _discardPhotoOf(dependent);
          await _db.outboxDao.deleteOperation(dependent.id);
        }
      }
    }
    await _discardPhotoOf(row);
    await _db.outboxDao.deleteOperation(row.id);
  });

  /// Une photo abandonnee emporte sa ligne locale en attente et son fichier a envoyer.
  Future<void> _discardPhotoOf(OutboxRow row) async {
    if (!row.isPhotoOperation) return;
    final local = await _db.deliveryPhotosDao.getById(row.clientId);
    if (local != null && local.isPending) {
      await _db.deliveryPhotosDao.deletePhoto(row.clientId);
    }
    await _db.deliveryPhotosDao.deleteFile(row.clientId);
  }
}
