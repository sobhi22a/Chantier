import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/outbox_dao.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await db.sitesDao.upsertIfNewer(siteRow());
  });
  tearDown(() => db.close());

  group('enqueue', () {
    test('ajoute une operation en attente', () async {
      final created = await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));

      final row = (await db.outboxDao.getByClientId('c-1'))!;
      expect(created, isTrue);
      expect(row.status, OutboxStatus.pending);
      expect(row.attempts, 0);
      expect(row.lastErrorCode, isNull);
      expect(row.entity, 'zone');
      expect(row.operation, 'create');
    });

    test(
      'double appui : meme clientId, une seule operation (anti-doublon)',
      () async {
        final first = await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
        final second = await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));

        expect(first, isTrue);
        expect(second, isFalse);
        expect((await db.outboxDao.pendingFor('user-a')).length, 1);
      },
    );
  });

  group('ecriture locale + file d\'envoi dans UNE transaction (CT-21)', () {
    test('succes : la zone et l\'operation existent ensemble', () async {
      await db.transaction(() async {
        await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1'));
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
      });

      expect(await db.zonesDao.getById('c-1'), isNotNull);
      expect(await db.outboxDao.getByClientId('c-1'), isNotNull);
    });

    test(
      'echec de la file : la zone locale est annulee (jamais l\'une sans l\'autre)',
      () async {
        await expectLater(
          db.transaction(() async {
            await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1'));
            await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
            throw StateError('panne apres l\'ecriture');
          }),
          throwsStateError,
        );

        expect(await db.zonesDao.getById('c-1'), isNull);
        expect(await db.outboxDao.getByClientId('c-1'), isNull);
      },
    );

    test('echec de la zone : l\'operation est annulee', () async {
      await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1'));

      await expectLater(
        db.transaction(() async {
          await db.outboxDao.enqueue(outboxOp(clientId: 'c-2'));
          // meme clientId que la zone existante : contrainte d'unicite
          await db.into(db.zones).insert(zoneRow(id: 'autre', clientId: 'c-1'));
        }),
        throwsA(anything),
      );

      expect(await db.outboxDao.getByClientId('c-2'), isNull);
    });
  });

  group('pendingFor : ordre de creation, par lot, par proprietaire', () {
    test('ordre de creation conserve', () async {
      for (final id in ['c-1', 'c-2', 'c-3']) {
        await db.outboxDao.enqueue(outboxOp(clientId: id));
      }

      final rows = await db.outboxDao.pendingFor('user-a');

      expect(rows.map((r) => r.clientId), ['c-1', 'c-2', 'c-3']);
    });

    test(
      '200 envois en attente : 4 lots de 50, dans l\'ordre de creation (CT-24)',
      () async {
        for (var i = 0; i < 200; i++) {
          await db.outboxDao.enqueue(
            outboxOp(clientId: 'c-${i.toString().padLeft(3, '0')}'),
          );
        }

        final sent = <String>[];
        var batches = 0;
        while (true) {
          final batch = await db.outboxDao.pendingFor('user-a', limit: 50);
          if (batch.isEmpty) break;
          batches++;
          expect(batch.length, 50);
          await db.outboxDao.markSending([for (final r in batch) r.id]);
          sent.addAll(batch.map((r) => r.clientId));
          for (final row in batch) {
            await db.outboxDao.deleteOperation(row.id);
          }
        }

        expect(batches, 4);
        expect(sent.length, 200);
        expect(sent, [
          for (var i = 0; i < 200; i++) 'c-${i.toString().padLeft(3, '0')}',
        ]);
      },
    );

    test(
      'telephone partage : B ne voit ni n\'envoie rien de A (CT-23)',
      () async {
        await db.outboxDao.enqueue(outboxOp(clientId: 'a-1', owner: 'user-a'));
        await db.outboxDao.enqueue(outboxOp(clientId: 'a-2', owner: 'user-a'));
        await db.outboxDao.enqueue(outboxOp(clientId: 'b-1', owner: 'user-b'));

        expect(
          (await db.outboxDao.pendingFor('user-b')).map((r) => r.clientId),
          ['b-1'],
        );
        expect(
          (await db.outboxDao.pendingFor('user-a')).map((r) => r.clientId),
          ['a-1', 'a-2'],
        );
        expect(await db.outboxDao.pendingFor('user-inconnu'), isEmpty);
        expect(
          (await db.outboxDao.watchFor('user-b').first).map((r) => r.clientId),
          ['b-1'],
        );
        expect(
          await db.outboxDao.watchCounts('user-inconnu').first,
          const OutboxCounts(toSend: 0, toCheck: 0),
        );
      },
    );
  });

  group('cycle de vie d\'une operation', () {
    test(
      'markSending puis markRetry : tentative comptee, de nouveau a envoyer',
      () async {
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
        final id = (await db.outboxDao.getByClientId('c-1'))!.id;

        await db.outboxDao.markSending([id]);
        expect(
          (await db.outboxDao.getByClientId('c-1'))!.status,
          OutboxStatus.sending,
        );
        expect(await db.outboxDao.pendingFor('user-a'), isEmpty);

        await db.outboxDao.markRetry(id, errorCode: 'TROP_DE_REQUETES');
        await db.outboxDao.markSending([id]);
        await db.outboxDao.markRetry(id);

        final row = (await db.outboxDao.getByClientId('c-1'))!;
        expect(row.status, OutboxStatus.pending);
        expect(row.attempts, 2);
        expect(
          row.lastErrorCode,
          isNull,
          reason: 'le dernier echec n\'avait pas de code',
        );
        expect((await db.outboxDao.pendingFor('user-a')).length, 1);
      },
    );

    test(
      'rejected et conflict : conservees avec leur code, jamais rejouees seules',
      () async {
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-2'));
        final id1 = (await db.outboxDao.getByClientId('c-1'))!.id;
        final id2 = (await db.outboxDao.getByClientId('c-2'))!.id;

        await db.outboxDao.markFailed(
          id1,
          status: OutboxStatus.rejected,
          errorCode: 'CHANTIER_ARCHIVE',
        );
        await db.outboxDao.markFailed(
          id2,
          status: OutboxStatus.conflict,
          errorCode: 'CONFLIT_VERSION',
        );

        expect(await db.outboxDao.pendingFor('user-a'), isEmpty);
        final rejected = (await db.outboxDao.getByClientId('c-1'))!;
        expect(rejected.status, OutboxStatus.rejected);
        expect(rejected.lastErrorCode, 'CHANTIER_ARCHIVE');
        expect(
          (await db.outboxDao.getByClientId('c-2'))!.status,
          OutboxStatus.conflict,
        );
      },
    );

    test(
      'application tuee pendant l\'envoi : reprise sans perte ni doublon',
      () async {
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-2'));
        final ids = [
          for (final r in await db.outboxDao.pendingFor('user-a')) r.id,
        ];
        await db.outboxDao.markSending(ids);

        final recovered = await db.outboxDao.recoverInterrupted();

        expect(recovered, 2);
        final again = await db.outboxDao.pendingFor('user-a');
        expect(
          again.map((r) => r.clientId),
          ['c-1', 'c-2'],
          reason: 'meme clientId : le serveur dedoublonne',
        );
      },
    );

    test(
      'recoverInterrupted ne touche pas les operations a verifier',
      () async {
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
        final id = (await db.outboxDao.getByClientId('c-1'))!.id;
        await db.outboxDao.markFailed(
          id,
          status: OutboxStatus.rejected,
          errorCode: 'INTERDIT',
        );

        await db.outboxDao.recoverInterrupted();

        expect(
          (await db.outboxDao.getByClientId('c-1'))!.status,
          OutboxStatus.rejected,
        );
      },
    );

    test('abandon confirme : l\'operation disparait', () async {
      await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
      final id = (await db.outboxDao.getByClientId('c-1'))!.id;

      expect(await db.outboxDao.deleteOperation(id), 1);
      expect(await db.outboxDao.getByClientId('c-1'), isNull);
    });
  });

  group('compteurs exacts (CT-24)', () {
    test('X a envoyer, Y a verifier, mis a jour en direct', () async {
      final seen = <OutboxCounts>[];
      final subscription = db.outboxDao.watchCounts('user-a').listen(seen.add);
      await Future<void>.delayed(Duration.zero);

      for (final id in ['c-1', 'c-2', 'c-3', 'c-4', 'c-5']) {
        await db.outboxDao.enqueue(outboxOp(clientId: id));
      }
      final rows = await db.outboxDao.pendingFor('user-a');
      await db.outboxDao.markSending([rows[0].id]);
      await db.outboxDao.markFailed(
        rows[1].id,
        status: OutboxStatus.conflict,
        errorCode: 'CONFLIT_VERSION',
      );
      await db.outboxDao.markFailed(
        rows[2].id,
        status: OutboxStatus.rejected,
        errorCode: 'INTERDIT',
      );
      await Future<void>.delayed(Duration.zero);

      // pending (2) + sending (1) = 3 a envoyer ; conflict + rejected = 2 a verifier
      expect(seen.last, const OutboxCounts(toSend: 3, toCheck: 2));
      expect(seen.last.total, 5);

      await db.outboxDao.deleteOperation(rows[1].id);
      await Future<void>.delayed(Duration.zero);
      expect(seen.last, const OutboxCounts(toSend: 3, toCheck: 1));
      await subscription.cancel();
    });
  });
}
