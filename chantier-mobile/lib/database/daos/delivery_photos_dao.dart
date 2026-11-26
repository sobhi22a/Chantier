import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/delivery_photos.dart';
import 'package:chantier_mobile/database/tables/pending_photo_files.dart';
import 'package:drift/drift.dart';

part 'delivery_photos_dao.g.dart';

/// Codes d'echec **definitifs** d'un fichier de photo : le serveur a refuse ce fichier (ou il a
/// disparu du telephone), le renvoyer tel quel donnerait toujours le meme refus. Le fichier est
/// conserve et signale dans « Envois en attente » jusqu'a la decision de l'utilisateur ; il ne
/// bloque jamais l'envoi des autres.
abstract final class PhotoFileErrors {
  static const Set<String> permanent = {
    'INTROUVABLE',
    'PHOTO_DEJA_ENVOYEE',
    'FICHIER_TROP_GROS',
    'TYPE_FICHIER_REFUSE',
    'VALIDATION',
  };

  static bool isPermanent(String? code) =>
      code != null && permanent.contains(code);
}

/// Metadonnees des photos de bons de livraison et fichiers en attente d'envoi (ADR 0013).
///
/// Les **octets** d'une photo ne sont jamais en base. Les fichiers en attente
/// (`pending_photo_files`) sont filtres par proprietaire : un autre compte du meme telephone ne
/// les voit ni ne les envoie.
@DriftAccessor(tables: [DeliveryPhotos, PendingPhotoFiles])
class DeliveryPhotosDao extends DatabaseAccessor<AppDatabase>
    with _$DeliveryPhotosDaoMixin {
  DeliveryPhotosDao(super.attachedDatabase);

  Stream<List<DeliveryPhotoRow>> watchByDelivery(String deliveryId) =>
      (select(deliveryPhotos)
            ..where((t) => t.deliveryId.equals(deliveryId))
            ..orderBy([(t) => OrderingTerm.asc(t.takenAt)]))
          .watch();

  /// Photos d'un chantier (envoyees ou en attente) : donne le nombre de photos de chaque livraison.
  Stream<List<DeliveryPhotoRow>> watchBySite(String siteId) =>
      (select(deliveryPhotos)..where((t) => t.siteId.equals(siteId))).watch();

  Future<DeliveryPhotoRow?> getById(String id) =>
      (select(deliveryPhotos)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<DeliveryPhotoRow?> findByClientId(String siteId, String clientId) =>
      (select(deliveryPhotos)..where(
            (t) => t.siteId.equals(siteId) & t.clientId.equals(clientId),
          ))
          .getSingleOrNull();

  /// Nombre de photos d'une livraison (« 3 photos », limite de 5, badge « BL manquant »).
  Future<int> countByDelivery(String deliveryId) async {
    final count = deliveryPhotos.id.count();
    final query = selectOnly(deliveryPhotos)
      ..addColumns([count])
      ..where(deliveryPhotos.deliveryId.equals(deliveryId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Photo prise **hors ligne** : `id = clientId`, `version = 0`, `isPending = true`.
  Future<void> insertPending(DeliveryPhotoRow row) async {
    assert(row.isPending && row.version == 0 && row.clientId == row.id);
    await into(deliveryPhotos).insert(row);
  }

  /// Voir `MaterialRequestsDao.upsertIfNewer` : version plus recente seulement ; une photo
  /// locale de meme `clientId` est remplacee par celle du serveur (sans doublon).
  Future<bool> upsertIfNewer(DeliveryPhotoRow row, {bool overwrite = false}) =>
      transaction(() async {
        final existing = await getById(row.id);
        if (existing != null) {
          if (existing.version > row.version) return false;
          if (existing.version == row.version && !overwrite) return false;
          await into(
            deliveryPhotos,
          ).insertOnConflictUpdate(row.toCompanion(false));
          return true;
        }
        final clientId = row.clientId;
        if (clientId != null) {
          final local = await findByClientId(row.siteId, clientId);
          if (local != null) await deletePhoto(local.id);
        }
        await into(deliveryPhotos).insert(row);
        return true;
      });

  Future<int> deletePhoto(String id) =>
      (delete(deliveryPhotos)..where((t) => t.id.equals(id))).go();

  // --- Fichiers en attente d'envoi ----------------------------------------------------------

  /// Enregistre un fichier a envoyer. Idempotent sur `clientId` : un second appel ne change
  /// rien et retourne `false`.
  Future<bool> enqueueFile(PendingPhotoFilesCompanion file) =>
      transaction(() async {
        final existing = await getFile(file.clientId.value);
        if (existing != null) return false;
        await into(pendingPhotoFiles).insert(file);
        return true;
      });

  Future<PendingPhotoFileRow?> getFile(String clientId) => (select(
    pendingPhotoFiles,
  )..where((t) => t.clientId.equals(clientId))).getSingleOrNull();

  /// Fichiers du proprietaire, dans l'ordre de prise, par lot (un fichier a la fois a l'envoi).
  Future<List<PendingPhotoFileRow>> filesFor(
    String ownerUserId, {
    int limit = 20,
  }) =>
      (select(pendingPhotoFiles)
            ..where((t) => t.ownerUserId.equals(ownerUserId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(limit))
          .get();

  /// Fichiers **prets a partir** : leurs metadonnees sont deja confirmees par le serveur (l'operation
  /// `photo` / `create` a ete appliquee), hors echecs definitifs, dans l'ordre de prise. Un fichier
  /// dont les metadonnees attendent encore (ou ont ete refusees) ne bloque pas les suivants.
  Future<List<({PendingPhotoFileRow file, DeliveryPhotoRow photo})>>
  readyFilesFor(String ownerUserId, {int limit = 20}) async {
    final query =
        select(pendingPhotoFiles).join([
            innerJoin(
              deliveryPhotos,
              deliveryPhotos.clientId.equalsExp(pendingPhotoFiles.clientId) &
                  deliveryPhotos.siteId.equalsExp(pendingPhotoFiles.siteId) &
                  deliveryPhotos.isPending.equals(false),
            ),
          ])
          ..where(
            pendingPhotoFiles.ownerUserId.equals(ownerUserId) &
                (pendingPhotoFiles.lastErrorCode.isNull() |
                    pendingPhotoFiles.lastErrorCode.isNotIn(
                      PhotoFileErrors.permanent,
                    )),
          )
          ..orderBy([OrderingTerm.asc(pendingPhotoFiles.createdAt)])
          ..limit(limit);
    return [
      for (final row in await query.get())
        (
          file: row.readTable(pendingPhotoFiles),
          photo: row.readTable(deliveryPhotos),
        ),
    ];
  }

  /// Tous les fichiers du proprietaire (« Photo en attente d'envoi », echecs a verifier).
  Stream<List<PendingPhotoFileRow>> watchFiles(String ownerUserId) =>
      (select(pendingPhotoFiles)
            ..where((t) => t.ownerUserId.equals(ownerUserId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  /// Chemins relatifs connus de tous les proprietaires : le reste du dossier est orphelin.
  Future<Set<String>> knownRelativePaths(String ownerUserId) async {
    final rows = await (select(
      pendingPhotoFiles,
    )..where((t) => t.ownerUserId.equals(ownerUserId))).get();
    return {for (final row in rows) row.relativePath};
  }

  /// « Photo en attente d'envoi (2) » : nombre de fichiers du proprietaire.
  Stream<int> watchFileCount(String ownerUserId) {
    final count = pendingPhotoFiles.clientId.count();
    final query = selectOnly(pendingPhotoFiles)
      ..addColumns([count])
      ..where(pendingPhotoFiles.ownerUserId.equals(ownerUserId));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Echec d'envoi : le fichier est conserve, la tentative comptee.
  Future<void> markFileAttempt(String clientId, {String? errorCode}) =>
      (update(
        pendingPhotoFiles,
      )..where((t) => t.clientId.equals(clientId))).write(
        PendingPhotoFilesCompanion.custom(
          attempts: pendingPhotoFiles.attempts + const Constant(1),
          lastErrorCode: Variable<String>(errorCode),
        ),
      );

  /// A appeler **apres** la confirmation du serveur (et la suppression du fichier du disque).
  Future<int> deleteFile(String clientId) => (delete(
    pendingPhotoFiles,
  )..where((t) => t.clientId.equals(clientId))).go();
}
