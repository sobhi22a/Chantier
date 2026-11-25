import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late OutboxRepository outbox;

  setUp(() async {
    db = createTestDatabase();
    outbox = OutboxRepository(db);
    await db.sitesDao.upsertIfNewer(siteRow());
  });
  tearDown(() => db.close());

  test('ecriture locale et operation : enregistrees ensemble', () async {
    final saved = await outbox.saveWithOperation(
      operation: outboxOp(clientId: 'c-1'),
      localWrite: () =>
          db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1')),
    );

    expect(saved, isTrue);
    expect(await db.zonesDao.getById('c-1'), isNotNull);
    expect(await db.outboxDao.getByClientId('c-1'), isNotNull);
  });

  test(
    'rollback : si l\'ecriture locale echoue, aucune operation n\'est creee',
    () async {
      await expectLater(
        outbox.saveWithOperation(
          operation: outboxOp(clientId: 'c-1'),
          localWrite: () async => throw StateError('disque plein'),
        ),
        throwsStateError,
      );

      expect(await db.outboxDao.getByClientId('c-1'), isNull);
    },
  );

  test(
    'rollback : une panne apres la saisie locale annule aussi la saisie',
    () async {
      await db.zonesDao.insertPending(
        pendingZoneRow(clientId: 'c-1', roomNumber: 1),
      );

      await expectLater(
        outbox.saveWithOperation(
          operation: outboxOp(clientId: 'c-2'),
          localWrite: () async {
            await db.zonesDao.insertPending(
              pendingZoneRow(clientId: 'c-2', roomNumber: 2),
            );
            throw StateError('panne apres la saisie locale');
          },
        ),
        throwsStateError,
      );

      expect(await db.zonesDao.getById('c-2'), isNull);
      expect(await db.outboxDao.getByClientId('c-2'), isNull);
      expect(
        await db.zonesDao.getById('c-1'),
        isNotNull,
        reason: 'les autres saisies ne bougent pas',
      );
    },
  );

  test(
    'double appui : meme clientId, une seule saisie et une seule operation',
    () async {
      var localWrites = 0;
      Future<bool> tap() => outbox.saveWithOperation(
        operation: outboxOp(clientId: 'c-1'),
        localWrite: () async {
          localWrites++;
          await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1'));
        },
      );

      final results = await Future.wait([tap(), tap()]);

      expect(results.where((saved) => saved), hasLength(1));
      expect(localWrites, 1);
      expect(await db.zonesDao.countBySite('site-uv18'), 1);
      expect(await outbox.countFor('user-a'), 1);
    },
  );

  test(
    'abandon : supprime l\'operation et la zone locale en attente, rien d\'autre',
    () async {
      await outbox.saveWithOperation(
        operation: outboxOp(clientId: 'c-1'),
        localWrite: () =>
            db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1')),
      );
      await db.zonesDao.upsertIfNewer(zoneRow(id: 'confirmee', roomNumber: 1));
      final op = (await outbox.watch('user-a').first).single;

      await outbox.abandon(op);

      expect(await db.outboxDao.getByClientId('c-1'), isNull);
      expect(await db.zonesDao.getById('c-1'), isNull);
      expect(await db.zonesDao.getById('confirmee'), isNotNull);
    },
  );

  test('compteurs de l\'utilisateur seulement (CA-013.9)', () async {
    await db.outboxDao.enqueue(outboxOp(clientId: 'a-1', owner: 'user-a'));
    await db.outboxDao.enqueue(outboxOp(clientId: 'b-1', owner: 'user-b'));

    expect(await outbox.countFor('user-a'), 1);
    expect(await outbox.countFor('user-b'), 1);
    expect(await outbox.countFor('user-c'), 0);
  });
}
