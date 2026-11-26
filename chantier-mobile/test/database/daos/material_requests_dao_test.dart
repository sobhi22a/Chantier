import 'dart:convert';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await db.sitesDao.upsertIfNewer(siteRow());
    await db.sitesDao.upsertIfNewer(
      siteRow(
        id: 'site-ol40',
        code: 'CH-LOG-OL40',
        name: 'Logements OL40',
        version: 101,
      ),
    );
  });
  tearDown(() => db.close());

  group('upsertIfNewer', () {
    test('idempotent par version, comparee numeriquement', () async {
      final dao = db.materialRequestsDao;
      expect(await dao.upsertIfNewer(requestRow(version: 9)), isTrue);
      expect(await dao.upsertIfNewer(requestRow(version: 9)), isFalse);
      expect(await dao.upsertIfNewer(requestRow(version: 8)), isFalse);
      expect(
        await dao.upsertIfNewer(requestRow(version: 10, status: 'Validated')),
        isTrue,
      );

      expect((await dao.getById('req-009'))!.status, 'Validated');
      expect(await dao.countBySite('site-uv18'), 1);
    });

    test(
      'un null recu ecrase l ancienne valeur (commande annulee, motif efface)',
      () async {
        final dao = db.materialRequestsDao;
        await dao.upsertIfNewer(
          requestRow(
            version: 9,
            status: 'Ordered',
            orderJson: jsonEncode({'id': 'o-1', 'supplierName': 'Sigma'}),
          ),
        );

        await dao.upsertIfNewer(requestRow(version: 10, status: 'Validated'));

        final row = (await dao.getById('req-009'))!;
        expect(row.orderJson, isNull);
        expect(row.status, 'Validated');
      },
    );

    test('quantite et unite : 300 sac, 2,5 kg, 0,125 T sans perte', () async {
      final dao = db.materialRequestsDao;
      await dao.upsertIfNewer(
        requestRow(id: 'a', quantity: '300', unit: 'sac'),
      );
      await dao.upsertIfNewer(requestRow(id: 'b', quantity: '2.5', unit: 'kg'));
      await dao.upsertIfNewer(
        requestRow(id: 'c', quantity: '0.125', unit: 't'),
      );

      expect((await dao.getById('a'))!.quantity, Quantity.parse('300', 'sac'));
      expect((await dao.getById('b'))!.quantity, Quantity.parse('2.5', 'kg'));
      final c = (await dao.getById('c'))!;
      expect(c.quantity, Quantity.parse('0.125', 't'));
      expect(c.quantityValue, Decimal.parse('0.125'));
    });

    test('date de besoin complete : yyyy-MM-dd, sans fuseau', () async {
      await db.materialRequestsDao.upsertIfNewer(
        requestRow(neededBy: DateTime.utc(2026, 12, 1)),
      );

      final stored = await db
          .customSelect('SELECT needed_by AS d FROM material_requests')
          .getSingle();
      expect(stored.read<String>('d'), '2026-12-01');
    });
  });

  group('demande creee hors ligne', () {
    test('numero en attente, version 0, sans doublon au renvoi', () async {
      await db.materialRequestsDao.insertPending(
        pendingRequestRow(clientId: 'c-1'),
      );

      final row = (await db.materialRequestsDao.getById('c-1'))!;
      expect(row.isPending, isTrue);
      expect(row.number, isNull);
      expect(row.hasNumber, isFalse);
      expect(row.version, 0);
      expect(row.status, 'Requested');
    });

    test('remplacee par la version du serveur, sans doublon', () async {
      final dao = db.materialRequestsDao;
      await dao.insertPending(pendingRequestRow(clientId: 'c-1'));

      final written = await dao.upsertIfNewer(
        requestRow(id: 'srv-1', clientId: 'c-1', number: 'DEM-014'),
      );

      expect(written, isTrue);
      expect(await dao.getById('c-1'), isNull);
      expect((await dao.getById('srv-1'))!.number, 'DEM-014');
      expect(await dao.countBySite('site-uv18'), 1);
    });

    test('des demandes sans clientId ne s excluent pas entre elles', () async {
      final dao = db.materialRequestsDao;
      await dao.upsertIfNewer(requestRow(id: 'a', number: 'DEM-001'));
      await dao.upsertIfNewer(requestRow(id: 'b', number: 'DEM-002'));

      expect(await dao.countBySite('site-uv18'), 2);
    });

    test(
      'les livraisons saisies pour elle sont rattachees a l identifiant du serveur',
      () async {
        await db.materialRequestsDao.insertPending(
          pendingRequestRow(clientId: 'c-1'),
        );
        await db.deliveriesDao.insertPending(
          pendingDeliveryRow(clientId: 'd-1', requestId: 'c-1'),
        );

        await db.materialRequestsDao.upsertIfNewer(
          requestRow(id: 'srv-1', clientId: 'c-1', number: 'DEM-014'),
        );

        expect((await db.deliveriesDao.getById('d-1'))!.requestId, 'srv-1');
        expect(await db.deliveriesDao.getByRequest('c-1'), isEmpty);
      },
    );

    test(
      'zone creee hors ligne confirmee : la demande pointe vers la zone du serveur',
      () async {
        await db.zonesDao.insertPending(pendingZoneRow(clientId: 'z-1'));
        await db.materialRequestsDao.insertPending(
          pendingRequestRow(
            clientId: 'c-1',
          ).copyWith(zoneId: const Value('z-1')),
        );
        // Une demande d'une autre zone ne bouge pas.
        await db.materialRequestsDao.upsertIfNewer(
          requestRow(id: 'autre', number: 'DEM-002', zoneId: 'zone-1'),
        );

        await db.zonesDao.upsertIfNewer(
          zoneRow(id: 'zone-srv', clientId: 'z-1', version: 300),
        );

        expect(
          (await db.materialRequestsDao.getById('c-1'))!.zoneId,
          'zone-srv',
        );
        expect(
          (await db.materialRequestsDao.getById('autre'))!.zoneId,
          'zone-1',
        );
      },
    );

    test(
      'ecriture locale annulee avec la file : rien n est garde (une transaction)',
      () async {
        await expectLater(
          db.transaction(() async {
            await db.materialRequestsDao.insertPending(
              pendingRequestRow(clientId: 'c-1'),
            );
            await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
            throw StateError('echec apres l ecriture');
          }),
          throwsStateError,
        );

        expect(await db.materialRequestsDao.getById('c-1'), isNull);
        expect(await db.outboxDao.getByClientId('c-1'), isNull);
      },
    );
  });

  group('vues de la liste', () {
    Future<void> fill() async {
      final dao = db.materialRequestsDao;
      await dao.upsertIfNewer(
        requestRow(
          id: 'normal-tot',
          number: 'DEM-001',
          neededBy: DateTime.utc(2026, 11, 26),
        ),
      );
      await dao.upsertIfNewer(
        requestRow(
          id: 'normal-tard',
          number: 'DEM-002',
          neededBy: DateTime.utc(2026, 12, 5),
        ),
      );
      await dao.upsertIfNewer(
        requestRow(
          id: 'urgent',
          number: 'DEM-003',
          priority: 'Urgent',
          neededBy: DateTime.utc(2026, 12, 9),
        ),
      );
      await dao.upsertIfNewer(
        requestRow(
          id: 'bloquante',
          number: 'DEM-004',
          priority: 'Blocking',
          status: 'Validated',
          neededBy: DateTime.utc(2026, 12, 20),
        ),
      );
      await dao.upsertIfNewer(
        requestRow(id: 'commandee', number: 'DEM-005', status: 'Ordered'),
      );
      await dao.upsertIfNewer(
        requestRow(
          id: 'partielle',
          number: 'DEM-006',
          status: 'PartiallyDelivered',
        ),
      );
      await dao.upsertIfNewer(
        requestRow(id: 'livree', number: 'DEM-007', status: 'Delivered'),
      );
      await dao.upsertIfNewer(
        requestRow(id: 'recue', number: 'DEM-008', status: 'Received'),
      );
      await dao.upsertIfNewer(
        requestRow(id: 'refusee', number: 'DEM-009', status: 'Rejected'),
      );
      await dao.upsertIfNewer(
        requestRow(id: 'annulee', number: 'DEM-010', status: 'Cancelled'),
      );
      await dao.upsertIfNewer(
        requestRow(
          id: 'archivee',
          number: 'DEM-011',
          status: 'Received',
          archivedAt: DateTime.utc(2026, 11, 20),
        ),
      );
      await dao.upsertIfNewer(
        requestRow(
          id: 'autre-chantier',
          siteId: 'site-ol40',
          number: 'DEM-001',
        ),
      );
    }

    Future<List<String>> ids(
      RequestListView view, {
      String? requestedById,
    }) async => [
      for (final row
          in await db.materialRequestsDao
              .watchView('site-uv18', view, requestedById: requestedById)
              .first)
        row.id,
    ];

    test(
      'A suivre : urgence puis date de besoin (Bloquante, Urgente, Normale)',
      () async {
        await fill();

        final list = await ids(RequestListView.toFollow);

        expect(list, hasLength(7));
        expect(list.take(3), ['bloquante', 'urgent', 'normal-tot']);
        // Meme date de besoin (28/11) : seul l'ensemble compte, avant la plus tardive.
        expect(list.skip(3).take(3).toSet(), {
          'commandee',
          'partielle',
          'livree',
        });
        expect(list.last, 'normal-tard');
      },
    );

    test(
      'Terminees, refusees et annulees, archivees : chacune sa vue',
      () async {
        await fill();

        expect(await ids(RequestListView.received), ['recue']);
        expect((await ids(RequestListView.closed)).toSet(), {
          'refusee',
          'annulee',
        });
        expect(await ids(RequestListView.archived), ['archivee']);
      },
    );

    test('A valider, A recevoir, A receptionner', () async {
      await fill();

      // Urgence d'abord, puis date de besoin.
      expect(await ids(RequestListView.toApprove), [
        'urgent',
        'normal-tot',
        'normal-tard',
      ]);
      expect((await ids(RequestListView.expected)).toSet(), {
        'commandee',
        'partielle',
      });
      expect(await ids(RequestListView.toReception), ['livree']);
    });

    test('une demande archivee n apparait jamais dans une autre vue', () async {
      await fill();

      for (final view in RequestListView.values) {
        if (view == RequestListView.archived) continue;
        expect(await ids(view), isNot(contains('archivee')), reason: view.name);
      }
    });

    test('Mes demandes : seulement celles du demandeur', () async {
      await fill();
      await db.materialRequestsDao.upsertIfNewer(
        requestRow(
          id: 'collegue',
          number: 'DEM-012',
          requestedById: 'user-equipe',
        ),
      );

      expect(
        await ids(RequestListView.toFollow, requestedById: 'user-equipe'),
        ['collegue'],
      );
    });

    test('un chantier ne voit jamais les demandes d un autre', () async {
      await fill();

      for (final view in RequestListView.values) {
        expect(await ids(view), isNot(contains('autre-chantier')));
      }
    });

    test(
      'une demande creee hors ligne est dans « A suivre » des l ecriture locale',
      () async {
        await db.materialRequestsDao.insertPending(
          pendingRequestRow(clientId: 'c-1'),
        );

        expect(await ids(RequestListView.toFollow), ['c-1']);
      },
    );

    test(
      'statut inconnu (version future du serveur) : absent des vues, present en base',
      () async {
        await db.materialRequestsDao.upsertIfNewer(
          requestRow(id: 'futur', status: 'OnHold'),
        );

        for (final view in RequestListView.values) {
          expect(await ids(view), isNot(contains('futur')), reason: view.name);
        }
        expect(
          (await db.materialRequestsDao.getById('futur'))!.statusValue,
          isNull,
        );
      },
    );

    test('le flux reagit : une validation recue met la liste a jour', () async {
      final dao = db.materialRequestsDao;
      await dao.upsertIfNewer(requestRow(version: 9));
      final seen = <List<String>>[];
      final sub = dao
          .watchView('site-uv18', RequestListView.toApprove)
          .listen((rows) => seen.add([for (final r in rows) r.id]));
      addTearDown(sub.cancel);
      await pumpEventQueue();

      await dao.upsertIfNewer(requestRow(version: 10, status: 'Validated'));
      await pumpEventQueue();

      expect(seen.first, ['req-009']);
      expect(seen.last, isEmpty);
    });
  });

  group('tuiles : produits les plus demandes du chantier', () {
    Future<void> add(
      String id,
      String? productId, {
      String status = 'Requested',
      DateTime? at,
    }) => db.materialRequestsDao.upsertIfNewer(
      requestRow(
        id: id,
        number: id,
        productId: productId,
        status: status,
        createdAt: at,
      ),
    );

    test(
      'par nombre de demandes, au plus 6, le plus recent departage',
      () async {
        for (var i = 0; i < 3; i++) {
          await add('c$i', 'ciment');
        }
        for (var i = 0; i < 2; i++) {
          await add('r$i', 'rond-12');
        }
        await add('b1', 'brique', at: DateTime.utc(2026, 11, 20));
        await add('s1', 'sable', at: DateTime.utc(2026, 11, 24));
        for (var i = 0; i < 4; i++) {
          await add('x$i', 'autre-$i');
        }

        final top = await db.materialRequestsDao.topProductIds('site-uv18');

        expect(top, hasLength(6));
        expect(top.first, 'ciment');
        expect(top[1], 'rond-12');
      },
    );

    test(
      'ignore les demandes refusees, annulees et les produits libres',
      () async {
        await add('a', 'ciment', status: 'Cancelled');
        await add('b', 'ciment', status: 'Rejected');
        await add('c', null);
        await add('d', 'sable');

        expect(await db.materialRequestsDao.topProductIds('site-uv18'), [
          'sable',
        ]);
      },
    );

    test('compte les demandes en attente d envoi', () async {
      await db.materialRequestsDao.insertPending(
        pendingRequestRow(clientId: 'c-1', productId: 'ciment'),
      );
      await db.materialRequestsDao.insertPending(
        pendingRequestRow(clientId: 'c-2', productId: 'ciment'),
      );
      await add('d', 'sable');

      expect(await db.materialRequestsDao.topProductIds('site-uv18'), [
        'ciment',
        'sable',
      ]);
    });

    test('limite aux demandes du chantier', () async {
      await db.materialRequestsDao.upsertIfNewer(
        requestRow(id: 'x', siteId: 'site-ol40', productId: 'brique'),
      );

      expect(await db.materialRequestsDao.topProductIds('site-uv18'), isEmpty);
    });
  });

  group('ni prix ni telephone dans la commande et l historique stockes', () {
    test('la commande incorporee est ecrite sans `commercial`', () async {
      await db.materialRequestsDao.upsertIfNewer(
        requestRow(
          status: 'Ordered',
          orderJson: jsonEncode({
            'id': 'o-1',
            'supplierName': 'Cimenterie Sigma (fictive)',
            'orderDate': '2026-11-25',
            'commercial': {'unitPrice': 780.0, 'amount': 234000.0},
          }),
        ),
      );

      final row = (await db.materialRequestsDao.getById('req-009'))!;
      expect(row.orderJson, contains('Sigma'));
      expect(row.orderJson, isNot(contains('commercial')));
      expect(row.orderJson, isNot(contains('780')));
    });

    test('la demande creee hors ligne passe aussi par le garde', () async {
      await db.materialRequestsDao.insertPending(
        pendingRequestRow(clientId: 'c-1').copyWith(
          historyJson: Value(
            jsonEncode([
              {'id': 'e', 'type': 'OrderCommercialEdited'},
            ]),
          ),
        ),
      );

      expect((await db.materialRequestsDao.getById('c-1'))!.historyJson, '[]');
    });

    test('statut lu en enumeration : valeur connue seulement', () {
      expect(requestRow(status: 'Ordered').statusValue, RequestStatus.ordered);
      expect(requestRow(status: 'Autre').statusValue, isNull);
      expect(
        requestRow(priority: 'Blocking').priorityValue,
        RequestPriority.blocking,
      );
    });
  });

  test(
    'supprimer le chantier supprime ses demandes et ses livraisons (cascade)',
    () async {
      await db.materialRequestsDao.upsertIfNewer(requestRow());
      await db.deliveriesDao.upsertIfNewer(deliveryRow());
      await db.materialRequestsDao.upsertIfNewer(
        requestRow(id: 'autre', siteId: 'site-ol40', number: 'DEM-001'),
      );

      await db.sitesDao.deleteSite('site-uv18');

      expect(await db.materialRequestsDao.countBySite('site-uv18'), 0);
      expect(await db.deliveriesDao.countBySite('site-uv18'), 0);
      expect(await db.materialRequestsDao.countBySite('site-ol40'), 1);
    },
  );
}
