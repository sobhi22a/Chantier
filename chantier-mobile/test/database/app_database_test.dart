import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/database/tables/user_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import '../support/test_database.dart';

Future<void> _fillLocalData(AppDatabase db) async {
  await db.sitesDao.upsertIfNewer(siteRow());
  await db.zonesDao.upsertIfNewer(zoneRow());
  await db.siteMembersDao.upsertIfNewer(memberRow());
  await db.userPrefsDao.set('user-a', UserPrefKeys.currentSiteId, 'site-uv18');
  await db.syncStateDao.setAll({
    SyncStateKeys.cursor: '48301',
    SyncStateKeys.ownerUserId: 'user-a',
    SyncStateKeys.initialSyncDone: 'true',
  });
}

Future<int> _count(AppDatabase db, String table) async {
  final row = await db
      .customSelect('SELECT COUNT(*) AS n FROM $table')
      .getSingle();
  return row.read<int>('n');
}

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  group('purgeSyncedData : deconnexion sur un telephone partage (CT-23)', () {
    test(
      'efface chantiers, zones, affectations, preferences et etat de synchro',
      () async {
        await _fillLocalData(db);

        await db.purgeSyncedData();

        for (final table in [
          'sites',
          'zones',
          'site_members',
          'user_prefs',
          'sync_state',
        ]) {
          expect(await _count(db, table), 0, reason: table);
        }
      },
    );

    test('CONSERVE la file d\'envoi de A, pour A seul', () async {
      await _fillLocalData(db);
      await db.transaction(() async {
        await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1'));
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-1', owner: 'user-a'));
      });
      await db.outboxDao.enqueue(outboxOp(clientId: 'c-2', owner: 'user-a'));
      final failed = (await db.outboxDao.getByClientId('c-2'))!;
      await db.outboxDao.markFailed(
        failed.id,
        status: OutboxStatus.rejected,
        errorCode: 'CHANTIER_ARCHIVE',
      );

      await db.purgeSyncedData();

      // A retrouve ses saisies apres reconnexion.
      expect((await db.outboxDao.pendingFor('user-a')).map((r) => r.clientId), [
        'c-1',
      ]);
      expect(
        (await db.outboxDao.getByClientId('c-2'))!.status,
        OutboxStatus.rejected,
      );
      // B ne voit rien de A.
      expect(await db.outboxDao.pendingFor('user-b'), isEmpty);
      expect(await db.outboxDao.watchFor('user-b').first, isEmpty);
      expect(await db.sitesDao.watchSites().first, isEmpty);
      expect(await db.zonesDao.watchBySite('site-uv18').first, isEmpty);
      expect(
        await db.userPrefsDao.get('user-b', UserPrefKeys.currentSiteId),
        isNull,
      );
    });

    test('la purge est atomique et repetable', () async {
      await _fillLocalData(db);

      await db.purgeSyncedData();
      await db.purgeSyncedData();

      expect(await _count(db, 'sites'), 0);
    });

    test(
      'apres la purge, une nouvelle synchro repart de zero (curseur absent)',
      () async {
        await _fillLocalData(db);

        await db.purgeSyncedData();

        expect(await db.syncStateDao.get(SyncStateKeys.cursor), isNull);
        expect(await db.syncStateDao.get(SyncStateKeys.ownerUserId), isNull);
      },
    );
  });

  test('schema : toutes les tables du plan M3 existent', () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
        )
        .get();

    expect(
      rows.map((r) => r.read<String>('name')),
      containsAll([
        'sites',
        'zones',
        'site_members',
        'outbox_operations',
        'sync_state',
        'user_prefs',
      ]),
    );
  });
}
