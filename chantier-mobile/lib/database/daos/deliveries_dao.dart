import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/converters/material_json_guard.dart';
import 'package:chantier_mobile/database/tables/deliveries.dart';
import 'package:chantier_mobile/database/tables/delivery_photos.dart';
import 'package:chantier_mobile/database/tables/pending_photo_files.dart';
import 'package:drift/drift.dart';

part 'deliveries_dao.g.dart';

/// Acces aux livraisons, y compris celles saisies hors ligne. **Aucun prix** (ADR 0012).
@DriftAccessor(tables: [Deliveries, DeliveryPhotos, PendingPhotoFiles])
class DeliveriesDao extends DatabaseAccessor<AppDatabase>
    with _$DeliveriesDaoMixin {
  DeliveriesDao(super.attachedDatabase);

  /// Livraisons d'un chantier, les plus recentes d'abord. [unattachedOnly] : « Non rattachees ».
  Stream<List<DeliveryRow>> watchBySite(
    String siteId, {
    bool unattachedOnly = false,
  }) {
    final query = select(deliveries)..where((t) => t.siteId.equals(siteId));
    if (unattachedOnly) query.where((t) => t.requestId.isNull());
    query.orderBy([
      (t) => OrderingTerm.desc(t.deliveryDate),
      (t) => OrderingTerm.desc(t.createdAt),
    ]);
    return query.watch();
  }

  /// Comme [watchBySite] sans `history_json` (jamais lu par une liste, R2-07).
  Stream<List<DeliveryRow>> watchBySiteLight(String siteId) {
    final columns = [
      for (final column in deliveries.$columns)
        column.$name == 'history_json'
            ? 'NULL AS ${column.$name}'
            : column.$name,
    ];
    return customSelect(
      'SELECT ${columns.join(', ')} FROM deliveries WHERE site_id = ?1',
      variables: [Variable<String>(siteId)],
      readsFrom: {deliveries},
    ).map((row) => deliveries.map(row.data)).watch();
  }

  /// Livraisons d'une demande (annulees comprises : elles restent visibles, hors totaux).
  Stream<List<DeliveryRow>> watchByRequest(String requestId) =>
      (select(deliveries)
            ..where((t) => t.requestId.equals(requestId))
            ..orderBy([
              (t) => OrderingTerm.asc(t.deliveryDate),
              (t) => OrderingTerm.asc(t.createdAt),
            ]))
          .watch();

  Future<List<DeliveryRow>> getByRequest(String requestId) =>
      (select(deliveries)..where((t) => t.requestId.equals(requestId))).get();

  Stream<DeliveryRow?> watchById(String id) =>
      (select(deliveries)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<DeliveryRow?> getById(String id) =>
      (select(deliveries)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<DeliveryRow?> findByClientId(String siteId, String clientId) =>
      (select(deliveries)..where(
            (t) => t.siteId.equals(siteId) & t.clientId.equals(clientId),
          ))
          .getSingleOrNull();

  Future<int> countBySite(String siteId) async {
    final count = deliveries.id.count();
    final query = selectOnly(deliveries)
      ..addColumns([count])
      ..where(deliveries.siteId.equals(siteId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Livraison saisie **hors ligne** : `id = clientId`, `version = 0`, `isPending = true`.
  /// A appeler dans la meme transaction que l'ajout a la file d'envoi.
  Future<void> insertPending(DeliveryRow row) async {
    assert(row.isPending && row.version == 0 && row.clientId == row.id);
    await into(deliveries).insert(_guarded(row));
  }

  /// Correction d'une livraison **jamais envoyee** (meme transaction que la modification de sa
  /// saisie dans la file d'envoi).
  Future<void> replacePending(DeliveryRow row) async {
    assert(row.isPending && row.version == 0 && row.clientId == row.id);
    await into(
      deliveries,
    ).insertOnConflictUpdate(_guarded(row).toCompanion(false));
  }

  /// Applique une livraison recue du serveur ; meme regles que
  /// `MaterialRequestsDao.upsertIfNewer`. Quand elle remplace une livraison locale de meme
  /// `clientId`, les photos (metadonnees et fichiers en attente) qui la designaient par son
  /// `clientId` sont rattachees a l'identifiant du serveur.
  Future<bool> upsertIfNewer(DeliveryRow row, {bool overwrite = false}) =>
      transaction(() async {
        final existing = await getById(row.id);
        if (existing != null) {
          if (existing.version > row.version) return false;
          if (existing.version == row.version && !overwrite) return false;
          await into(
            deliveries,
          ).insertOnConflictUpdate(_guarded(row).toCompanion(false));
          return true;
        }
        final clientId = row.clientId;
        if (clientId != null) {
          final local = await findByClientId(row.siteId, clientId);
          if (local != null) {
            await _reattachPhotos(from: local.id, to: row.id);
            await deleteDelivery(local.id);
          }
        }
        await into(deliveries).insert(_guarded(row));
        return true;
      });

  Future<void> _reattachPhotos({
    required String from,
    required String to,
  }) async {
    if (from == to) return;
    await (update(deliveryPhotos)..where((t) => t.deliveryId.equals(from)))
        .write(DeliveryPhotosCompanion(deliveryId: Value(to)));
    await (update(pendingPhotoFiles)..where((t) => t.deliveryId.equals(from)))
        .write(PendingPhotoFilesCompanion(deliveryId: Value(to)));
  }

  /// Pierre tombale ou abandon d'une livraison locale en attente.
  Future<int> deleteDelivery(String id) =>
      (delete(deliveries)..where((t) => t.id.equals(id))).go();

  DeliveryRow _guarded(DeliveryRow row) => row.copyWith(
    historyJson: Value(MaterialJsonGuard.sanitizeHistory(row.historyJson)),
  );
}
