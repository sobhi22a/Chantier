import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/database/tables/user_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  group('SyncStateDao', () {
    test('lit, ecrit et ecrase une cle', () async {
      expect(await db.syncStateDao.get(SyncStateKeys.cursor), isNull);

      await db.syncStateDao.set(SyncStateKeys.cursor, '48213');
      await db.syncStateDao.set(SyncStateKeys.cursor, '48301');

      expect(await db.syncStateDao.get(SyncStateKeys.cursor), '48301');
    });

    test('le curseur est une chaine opaque : conservee telle quelle', () async {
      await db.syncStateDao.set(SyncStateKeys.cursor, '000123');

      expect(await db.syncStateDao.get(SyncStateKeys.cursor), '000123');
    });

    test('setAll : plusieurs cles d\'un coup', () async {
      await db.syncStateDao.setAll({
        SyncStateKeys.cursor: '10',
        SyncStateKeys.lastSuccessAt: '2026-11-24T10:00:00Z',
      });

      expect(await db.syncStateDao.get(SyncStateKeys.cursor), '10');
      expect(
        await db.syncStateDao.get(SyncStateKeys.lastSuccessAt),
        '2026-11-24T10:00:00Z',
      );
    });

    test('flux reactif de l\'etat', () async {
      final seen = <String?>[];
      final subscription = db.syncStateDao
          .watch(SyncStateKeys.cursor)
          .listen(seen.add);
      await Future<void>.delayed(Duration.zero);

      await db.syncStateDao.set(SyncStateKeys.cursor, '1');
      await db.syncStateDao.set(SyncStateKeys.cursor, '2');
      await Future<void>.delayed(Duration.zero);

      expect(seen, [null, '1', '2']);
      await subscription.cancel();
    });

    test(
      'resetCursor : repart de zero SANS toucher a la file d\'envoi ni aux autres cles',
      () async {
        await db.syncStateDao.setAll({
          SyncStateKeys.cursor: '48301',
          SyncStateKeys.initialSyncDone: 'true',
          SyncStateKeys.permissionsVersion: 'a41f09c2',
          SyncStateKeys.lastServerContactAt: '2026-11-24T10:00:00Z',
        });
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));

        await db.syncStateDao.resetCursor();

        expect(await db.syncStateDao.get(SyncStateKeys.cursor), isNull);
        expect(
          await db.syncStateDao.get(SyncStateKeys.initialSyncDone),
          isNull,
        );
        expect(
          await db.syncStateDao.get(SyncStateKeys.permissionsVersion),
          'a41f09c2',
        );
        expect(
          await db.syncStateDao.get(SyncStateKeys.lastServerContactAt),
          '2026-11-24T10:00:00Z',
          reason: 'la session hors ligne repose sur le dernier contact',
        );
        expect(await db.outboxDao.getByClientId('c-1'), isNotNull);
      },
    );
  });

  group('UserPrefsDao (par utilisateur)', () {
    test('ecrit, lit, ecrase', () async {
      await db.userPrefsDao.set(
        'user-a',
        UserPrefKeys.currentSiteId,
        'site-uv18',
      );
      await db.userPrefsDao.set(
        'user-a',
        UserPrefKeys.currentSiteId,
        'site-ol40',
      );

      expect(
        await db.userPrefsDao.get('user-a', UserPrefKeys.currentSiteId),
        'site-ol40',
      );
    });

    test(
      'isole par utilisateur : B ne voit pas le chantier courant de A',
      () async {
        await db.userPrefsDao.set(
          'user-a',
          UserPrefKeys.currentSiteId,
          'site-uv18',
        );

        expect(
          await db.userPrefsDao.get('user-b', UserPrefKeys.currentSiteId),
          isNull,
        );
      },
    );

    test('supprime une preference', () async {
      await db.userPrefsDao.set('user-a', UserPrefKeys.lastZoneId, 'z-1');

      expect(
        await db.userPrefsDao.remove('user-a', UserPrefKeys.lastZoneId),
        1,
      );
      expect(
        await db.userPrefsDao.get('user-a', UserPrefKeys.lastZoneId),
        isNull,
      );
    });

    test('flux reactif d\'une preference', () async {
      final seen = <String?>[];
      final subscription = db.userPrefsDao
          .watch('user-a', UserPrefKeys.currentSiteId)
          .listen(seen.add);
      await Future<void>.delayed(Duration.zero);

      await db.userPrefsDao.set('user-a', UserPrefKeys.currentSiteId, 's1');
      await Future<void>.delayed(Duration.zero);

      expect(seen, [null, 's1']);
      await subscription.cancel();
    });
  });
}
