import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/material_requests.dart';
import 'package:chantier_mobile/database/tables/zones.dart';
import 'package:drift/drift.dart';

part 'zones_dao.g.dart';

/// Acces aux zones (bloc, cote, local), y compris celles creees hors ligne.
@DriftAccessor(tables: [Zones, MaterialRequests])
class ZonesDao extends DatabaseAccessor<AppDatabase> with _$ZonesDaoMixin {
  ZonesDao(super.attachedDatabase);

  /// Flux reactif des zones d'un chantier, du bloc le plus bas a la cote la plus haute
  /// (« du plus bas au plus haut », CT-17). Archivees masquees par defaut.
  ///
  /// Le tri sur la cote est **numerique** : la cote est stockee en texte (`-1.90`), un tri
  /// alphabetique placerait `-1.90` apres `3.40`.
  Stream<List<ZoneRow>> watchBySite(
    String siteId, {
    bool includeArchived = false,
  }) {
    final query = select(zones)..where((t) => t.siteId.equals(siteId));
    if (!includeArchived) {
      query.where((t) => t.archivedAt.isNull());
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.block.collate(Collate.noCase)),
      (t) => OrderingTerm.asc(t.elevation.cast<double>()),
      (t) => OrderingTerm.asc(t.roomType),
      (t) => OrderingTerm.asc(t.roomNumber),
      (t) => OrderingTerm.asc(t.roomLabel),
    ]);
    return query.watch();
  }

  Future<ZoneRow?> getById(String id) =>
      (select(zones)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<ZoneRow?> findByClientId(String siteId, String clientId) =>
      (select(zones)..where(
            (t) => t.siteId.equals(siteId) & t.clientId.equals(clientId),
          ))
          .getSingleOrNull();

  Future<int> countBySite(String siteId) async {
    final count = zones.id.count();
    final query = selectOnly(zones)
      ..addColumns([count])
      ..where(zones.siteId.equals(siteId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Zone creee **hors ligne** : `id = clientId`, `version = 0`, `isPending = true`.
  /// A appeler dans la meme transaction que l'ajout a la file d'envoi (`OutboxDao.enqueue`).
  Future<void> insertPending(ZoneRow row) async {
    assert(row.isPending && row.version == 0 && row.clientId == row.id);
    await into(zones).insert(row);
  }

  /// Applique une zone recue du serveur (pull ou resultat `applied`/`duplicate` d'un push).
  ///
  /// * meme identifiant deja present : ecrite seulement si la version est plus recente ;
  /// * zone locale en attente de meme `clientId` (identifiant different) : **remplacee** par
  ///   la zone du serveur, sans doublon.
  /// Retourne `true` si une ligne a ete ecrite.
  Future<bool> upsertIfNewer(
    ZoneRow row, {
    bool overwrite = false,
  }) => transaction(() async {
    final existing = await getById(row.id);
    if (existing != null) {
      if (existing.version > row.version) return false;
      if (existing.version == row.version && !overwrite) return false;
      // toCompanion(false) : un `null` recu (zone restauree, cote retiree) ECRASE l'ancienne valeur.
      await into(zones).insertOnConflictUpdate(row.toCompanion(false));
      return true;
    }
    final clientId = row.clientId;
    if (clientId != null) {
      final local = await findByClientId(row.siteId, clientId);
      if (local != null) {
        // Les demandes saisies hors ligne pour cette zone la designaient par son `clientId` :
        // elles pointent maintenant vers l'identifiant du serveur (aucune zone « inconnue »).
        await (update(materialRequests)
              ..where((t) => t.zoneId.equals(local.id)))
            .write(MaterialRequestsCompanion(zoneId: Value(row.id)));
        await deleteZone(local.id);
      }
    }
    await into(zones).insert(row);
    return true;
  });

  /// Les demandes saisies pour la zone locale [from] designent maintenant la zone [to] du serveur
  /// (zone fusionnee avec une zone identique creee par un autre telephone).
  Future<void> reattachRequests({required String from, required String to}) =>
      (update(materialRequests)..where((t) => t.zoneId.equals(from))).write(
        MaterialRequestsCompanion(zoneId: Value(to)),
      );

  /// Pierre tombale `deleted: zone`, ou abandon d'une zone locale en attente.
  Future<int> deleteZone(String id) =>
      (delete(zones)..where((t) => t.id.equals(id))).go();
}
