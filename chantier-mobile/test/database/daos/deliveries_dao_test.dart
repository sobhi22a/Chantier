import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
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

  group('livraisons', () {
    test('idempotent par version', () async {
      final dao = db.deliveriesDao;
      expect(await dao.upsertIfNewer(deliveryRow(version: 9)), isTrue);
      expect(await dao.upsertIfNewer(deliveryRow(version: 9)), isFalse);
      expect(await dao.upsertIfNewer(deliveryRow(version: 8)), isFalse);
      expect(
        await dao.upsertIfNewer(deliveryRow(version: 10, status: 'Cancelled')),
        isTrue,
      );

      final row = (await dao.getById('liv-006'))!;
      expect(row.isCancelled, isTrue);
      expect(await dao.countBySite('site-uv18'), 1);
    });

    test(
      '10 T livrees pour 200 sacs : les deux quantites avec leur unite',
      () async {
        await db.deliveriesDao.upsertIfNewer(deliveryRow());

        final row = (await db.deliveriesDao.getById('liv-006'))!;
        expect(row.quantity, Quantity.parse('10', 't'));
        expect(row.quantityInRequest, Quantity.parse('200', 'sac'));
        expect(row.isUnattached, isFalse);
      },
    );

    test('non rattachee : motif conserve, aucune quantite convertie', () async {
      await db.deliveriesDao.upsertIfNewer(
        deliveryRow(
          id: 'liv-023',
          number: 'LIV-023',
          requestId: null,
          unattachedReason: 'RequestNotOpen',
          inRequestQuantity: null,
          inRequestUnit: null,
        ),
      );

      final row = (await db.deliveriesDao.getById('liv-023'))!;
      expect(row.isUnattached, isTrue);
      expect(row.unattachedReason, 'RequestNotOpen');
      expect(row.quantityInRequest, isNull);
      expect(
        (await db.deliveriesDao
                .watchBySite('site-uv18', unattachedOnly: true)
                .first)
            .map((d) => d.id),
        ['liv-023'],
      );
    });

    test('les plus recentes d abord ; annulees conservees', () async {
      final dao = db.deliveriesDao;
      await dao.upsertIfNewer(
        deliveryRow(
          id: 'a',
          number: 'LIV-001',
          deliveryDate: DateTime.utc(2026, 11, 1),
        ),
      );
      await dao.upsertIfNewer(
        deliveryRow(
          id: 'b',
          number: 'LIV-002',
          deliveryDate: DateTime.utc(2026, 11, 9),
        ),
      );
      await dao.upsertIfNewer(
        deliveryRow(
          id: 'c',
          number: 'LIV-003',
          deliveryDate: DateTime.utc(2026, 11, 5),
          status: 'Cancelled',
        ),
      );

      expect((await dao.watchBySite('site-uv18').first).map((d) => d.id), [
        'b',
        'c',
        'a',
      ]);
    });

    test(
      'livraisons d une demande, annulees comprises (elles restent visibles)',
      () async {
        final dao = db.deliveriesDao;
        await dao.upsertIfNewer(deliveryRow(id: 'a', number: 'LIV-001'));
        await dao.upsertIfNewer(
          deliveryRow(id: 'b', number: 'LIV-002', status: 'Cancelled'),
        );
        await dao.upsertIfNewer(
          deliveryRow(id: 'c', number: 'LIV-003', requestId: 'autre-demande'),
        );

        expect(
          (await dao.watchByRequest('req-009').first).map((d) => d.id).toSet(),
          {'a', 'b'},
        );
      },
    );

    test(
      'saisie hors ligne : numero en attente, remplacee sans doublon',
      () async {
        final dao = db.deliveriesDao;
        await dao.insertPending(pendingDeliveryRow(clientId: 'd-1'));
        expect((await dao.getById('d-1'))!.number, isNull);

        await dao.upsertIfNewer(
          deliveryRow(id: 'srv-d1', clientId: 'd-1', number: 'LIV-023'),
        );

        expect(await dao.getById('d-1'), isNull);
        expect((await dao.getById('srv-d1'))!.number, 'LIV-023');
        expect(await dao.countBySite('site-uv18'), 1);
      },
    );

    test('ecriture locale et file d envoi : une seule transaction', () async {
      await expectLater(
        db.transaction(() async {
          await db.deliveriesDao.insertPending(
            pendingDeliveryRow(clientId: 'd-1'),
          );
          await db.outboxDao.enqueue(outboxOp(clientId: 'd-1'));
          throw StateError('echec');
        }),
        throwsStateError,
      );

      expect(await db.deliveriesDao.getById('d-1'), isNull);
      expect(await db.outboxDao.getByClientId('d-1'), isNull);
    });

    test(
      'l historique stocke est passe au garde (aucun evenement de prix)',
      () async {
        await db.deliveriesDao.upsertIfNewer(
          deliveryRow(
            historyJson:
                '[{"id":"e","type":"OrderCommercialEdited"},{"id":"f","type":"DeliveryRegistered"}]',
          ),
        );

        final stored = (await db.deliveriesDao.getById(
          'liv-006',
        ))!.historyJson!;
        expect(stored, contains('DeliveryRegistered'));
        expect(stored, isNot(contains('OrderCommercialEdited')));
      },
    );
  });

  group('photos de bons de livraison', () {
    setUp(() => db.deliveriesDao.upsertIfNewer(deliveryRow()));

    test('metadonnees seulement : jamais les octets', () async {
      await db.deliveryPhotosDao.upsertIfNewer(photoRow());

      final row = (await db.deliveryPhotosDao.getById('photo-1'))!;
      expect(row.contentType, 'image/jpeg');
      expect(row.sizeBytes, 1480000);
      expect(await db.deliveryPhotosDao.countByDelivery('liv-006'), 1);
    });

    test('idempotent par version ; comptage par livraison', () async {
      final dao = db.deliveryPhotosDao;
      expect(await dao.upsertIfNewer(photoRow(version: 9)), isTrue);
      expect(await dao.upsertIfNewer(photoRow(version: 9)), isFalse);
      await dao.upsertIfNewer(photoRow(id: 'photo-2'));
      await dao.upsertIfNewer(photoRow(id: 'photo-3', deliveryId: 'autre'));

      expect(await dao.countByDelivery('liv-006'), 2);
      expect(await dao.countByDelivery('autre'), 1);
    });

    test(
      'photo prise hors ligne remplacee par celle du serveur, sans doublon',
      () async {
        final dao = db.deliveryPhotosDao;
        await dao.insertPending(
          photoRow(
            id: 'p-1',
            clientId: 'p-1',
            version: 0,
            isPending: true,
            contentStatus: 'Pending',
          ),
        );

        await dao.upsertIfNewer(photoRow(id: 'srv-p1', clientId: 'p-1'));

        expect(await dao.getById('p-1'), isNull);
        expect((await dao.getById('srv-p1'))!.contentStatus, 'Uploaded');
        expect(await dao.countByDelivery('liv-006'), 1);
      },
    );

    test(
      'livraison confirmee : photos et fichiers en attente rattaches a son identifiant',
      () async {
        await db.deliveriesDao.insertPending(
          pendingDeliveryRow(clientId: 'd-1'),
        );
        await db.deliveryPhotosDao.insertPending(
          photoRow(
            id: 'p-1',
            clientId: 'p-1',
            deliveryId: 'd-1',
            version: 0,
            isPending: true,
          ),
        );
        await db.deliveryPhotosDao.enqueueFile(
          pendingPhotoFile(clientId: 'p-1', deliveryId: 'd-1'),
        );

        await db.deliveriesDao.upsertIfNewer(
          deliveryRow(id: 'srv-d1', clientId: 'd-1', number: 'LIV-023'),
        );

        expect(
          (await db.deliveryPhotosDao.getById('p-1'))!.deliveryId,
          'srv-d1',
        );
        expect(
          (await db.deliveryPhotosDao.getFile('p-1'))!.deliveryId,
          'srv-d1',
        );
        expect(await db.deliveryPhotosDao.countByDelivery('d-1'), 0);
      },
    );
  });

  group('fichiers de photos en attente', () {
    test('idempotent sur clientId : deux appuis, un fichier', () async {
      final dao = db.deliveryPhotosDao;
      expect(await dao.enqueueFile(pendingPhotoFile(clientId: 'p-1')), isTrue);
      expect(await dao.enqueueFile(pendingPhotoFile(clientId: 'p-1')), isFalse);

      expect((await dao.filesFor('user-a')).length, 1);
    });

    test('filtres par proprietaire, dans l ordre de prise', () async {
      final dao = db.deliveryPhotosDao;
      await dao.enqueueFile(
        pendingPhotoFile(
          clientId: 'p-2',
          createdAt: DateTime.utc(2026, 11, 4, 9),
        ),
      );
      await dao.enqueueFile(
        pendingPhotoFile(
          clientId: 'p-1',
          createdAt: DateTime.utc(2026, 11, 4, 8),
        ),
      );
      await dao.enqueueFile(pendingPhotoFile(clientId: 'p-3', owner: 'user-b'));

      expect((await dao.filesFor('user-a')).map((f) => f.clientId), [
        'p-1',
        'p-2',
      ]);
      expect((await dao.filesFor('user-b')).map((f) => f.clientId), ['p-3']);
      expect(await dao.watchFileCount('user-a').first, 2);
    });

    test('echec d envoi : fichier conserve, tentative comptee', () async {
      final dao = db.deliveryPhotosDao;
      await dao.enqueueFile(pendingPhotoFile(clientId: 'p-1'));

      await dao.markFileAttempt('p-1', errorCode: 'ERREUR_INTERNE');
      await dao.markFileAttempt('p-1', errorCode: 'ERREUR_INTERNE');

      final file = (await dao.getFile('p-1'))!;
      expect(file.attempts, 2);
      expect(file.lastErrorCode, 'ERREUR_INTERNE');
    });

    test('supprime seulement a la confirmation', () async {
      final dao = db.deliveryPhotosDao;
      await dao.enqueueFile(pendingPhotoFile(clientId: 'p-1'));

      expect(await dao.deleteFile('p-1'), 1);
      expect(await dao.getFile('p-1'), isNull);
    });

    test('150 fichiers, envoi par lots de 20', () async {
      final dao = db.deliveryPhotosDao;
      for (var i = 0; i < 150; i++) {
        await dao.enqueueFile(
          pendingPhotoFile(
            clientId: 'p-$i',
            createdAt: DateTime.utc(2026, 11, 4, 8).add(Duration(seconds: i)),
          ),
        );
      }

      expect((await dao.filesFor('user-a')).length, 20);
      expect((await dao.filesFor('user-a', limit: 200)).length, 150);
      expect((await dao.filesFor('user-a')).first.clientId, 'p-0');
    });
  });
}
