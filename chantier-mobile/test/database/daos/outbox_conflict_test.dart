import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

/// Colonnes ajoutees a la file d'envoi par le lot « demandes de materiaux » (ADR 0011) : l'etat du
/// serveur et les champs en desaccord d'un `conflict`, pour l'ecran « A verifier ».
void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await db.sitesDao.upsertIfNewer(siteRow());
  });
  tearDown(() => db.close());

  test(
    'un conflit conserve l etat du serveur et les champs en desaccord',
    () async {
      await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
      final row = (await db.outboxDao.getByClientId('c-1'))!;
      expect(row.conflictJson, isNull);
      expect(row.conflictFields, isNull);

      await db.outboxDao.markFailed(
        row.id,
        status: OutboxStatus.conflict,
        errorCode: 'CONFLIT_VERSION',
        conflictJson: '{"status":"Validated","version":"51010"}',
        conflictFields: '["neededBy"]',
      );

      final failed = (await db.outboxDao.getByClientId('c-1'))!;
      expect(failed.status, OutboxStatus.conflict);
      expect(failed.lastErrorCode, 'CONFLIT_VERSION');
      expect(failed.conflictJson, contains('Validated'));
      expect(failed.conflictFields, '["neededBy"]');
    },
  );

  test('un rejet sans conflit ne porte pas d etat du serveur', () async {
    await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
    final row = (await db.outboxDao.getByClientId('c-1'))!;

    await db.outboxDao.markFailed(
      row.id,
      status: OutboxStatus.rejected,
      errorCode: 'CHANTIER_ARCHIVE',
    );

    final failed = (await db.outboxDao.getByClientId('c-1'))!;
    expect(failed.status, OutboxStatus.rejected);
    expect(failed.conflictJson, isNull);
    expect(failed.conflictFields, isNull);
  });

  test(
    'un conflit reste visible apres purge des donnees synchronisees',
    () async {
      await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
      final row = (await db.outboxDao.getByClientId('c-1'))!;
      await db.outboxDao.markFailed(
        row.id,
        status: OutboxStatus.conflict,
        errorCode: 'TRANSITION_INTERDITE',
        conflictJson: '{"status":"Cancelled"}',
      );

      await db.purgeSyncedData();

      final kept = (await db.outboxDao.getByClientId('c-1'))!;
      expect(kept.conflictJson, '{"status":"Cancelled"}');
    },
  );
}
