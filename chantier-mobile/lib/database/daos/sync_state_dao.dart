import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:drift/drift.dart';

part 'sync_state_dao.g.dart';

/// Etat de synchronisation (curseur, proprietaire, dates de contact), cles dans [SyncStateKeys].
@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.attachedDatabase);

  Future<String?> get(String key) async {
    final row = await (select(
      syncState,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watch(String key) =>
      (select(syncState)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  Future<void> set(String key, String value) => into(
    syncState,
  ).insertOnConflictUpdate(SyncStateCompanion.insert(key: key, value: value));

  /// Ecrit plusieurs cles **d'un coup** : le curseur n'avance qu'avec la page appliquee.
  Future<void> setAll(Map<String, String> values) => transaction(() async {
    for (final entry in values.entries) {
      await set(entry.key, entry.value);
    }
  });

  Future<int> remove(String key) =>
      (delete(syncState)..where((t) => t.key.equals(key))).go();

  /// Repart de zero (curseur invalide, `permissionsVersion` change) **sans toucher a la
  /// file d'envoi** : seules les cles de lecture sont remises a zero. Pose le drapeau
  /// [SyncStateKeys.fullReload] : le rechargement ecrase les lignes de meme version.
  Future<void> resetCursor() => transaction(() async {
    await remove(SyncStateKeys.cursor);
    await remove(SyncStateKeys.initialSyncDone);
    await set(SyncStateKeys.fullReload, 'true');
  });
}
