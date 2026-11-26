import 'dart:convert';

import 'package:chantier_mobile/core/api/generated/export.dart'
    show
        MaterialSettingsResponse,
        SyncPullResponse,
        SyncPushResponse,
        SyncPushResult;
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/material_settings.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/api_json.dart';
import '../../../support/fake_sync_remote.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_database.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

const _siteId = '0192a000-0000-7000-8000-0000000000a1';
const _productId = '0192a000-0000-7000-8000-0000000000d1';
const _user = 'user-a';
final _neededBy = DateTime.utc(2026, 11, 28);

class _Harness {
  _Harness() {
    db = createTestDatabase();
    remote = FakeSyncRemote();
    monitor = _MockMonitor();
    when(() => monitor.hasNetworkInterface()).thenAnswer((_) async => true);
    outbox = OutboxRepository(db);
    repo = MaterialsRepository(
      database: db,
      outbox: outbox,
      now: () => DateTime.utc(2026, 11, 25, 7),
    );
    engine = SyncEngine(
      database: db,
      remote: remote,
      sites: SitesRepository(db),
      materials: repo,
      currentUserId: () => _user,
      connectivity: monitor,
      backoff: Backoff(),
      now: () => DateTime.utc(2026, 11, 25, 8),
      pushBatchSize: 50,
    );
  }

  late final AppDatabase db;
  late final FakeSyncRemote remote;
  late final _MockMonitor monitor;
  late final OutboxRepository outbox;
  late final MaterialsRepository repo;
  late final SyncEngine engine;

  Future<void> prepare() async {
    await db.sitesDao.upsertIfNewer(siteRow(id: _siteId));
    await db.productsDao.upsertIfNewer(
      productRow(id: _productId, version: 400),
    );
  }

  RequestDraft draft({
    num quantity = 300,
    DateTime? neededBy,
    String? zoneId,
    bool zoneIsPending = false,
    RequestPriority priority = RequestPriority.normal,
  }) => RequestDraft(
    productId: _productId,
    quantity: Quantity(Decimal.parse('$quantity'), MeasureUnit.bag),
    neededBy: neededBy ?? _neededBy,
    zoneId: zoneId,
    zoneIsPending: zoneIsPending,
    priority: priority,
  );

  Future<RequestSaveResult> create(
    String clientId, {
    RequestDraft? input,
    String name = 'Ciment',
  }) async => repo.createRequest(
    clientId: clientId,
    siteId: _siteId,
    userId: _user,
    requesterName: 'Mourad B.',
    draft: input ?? draft(),
    label: 'Demande $name',
  );

  Future<MaterialRequestRow> row(String clientId) async =>
      (await db.materialRequestsDao.findByClientId(_siteId, clientId))!;

  Future<RequestView> view(String clientId) async {
    final stored = await row(clientId);
    return overlayRequest(stored, await db.outboxDao.allFor(_user));
  }

  Future<OutboxRow> operation(String clientId) async =>
      (await db.outboxDao.getByClientId(clientId))!;

  Future<void> dispose() async {
    await engine.dispose();
    await db.close();
  }
}

void main() {
  late _Harness h;

  setUp(() async {
    h = _Harness();
    await h.prepare();
  });
  tearDown(() => h.dispose());

  group('pull : catalogue et demandes (M2)', () {
    test('produits et fournisseurs globaux (siteId nul) sont ecrits', () async {
      h.remote.pullScript.add(
        SyncPullResponse.fromJson(
          syncPullJson(
            changes: [
              globalSyncChangeJson(
                'product',
                productJson(id: 'p-2', nameFr: 'Sable 0/3'),
                version: '47010',
              ),
              globalSyncChangeJson(
                'supplier',
                supplierJson(id: 's-1'),
                version: '47011',
              ),
            ],
          ),
        ),
      );
      await h.engine.run();

      final product = await h.db.productsDao.getById('p-2');
      expect(product!.nameFr, 'Sable 0/3');
      expect(product.allowedUnits, ['sac', 't', 'kg']);
      expect(product.bagMassKg, Decimal.parse('50'));
      expect((await h.db.suppliersDao.getById('s-1'))!.name, contains('Sigma'));
    });

    test('une demande du pull est decodee avec quantite et unite', () async {
      h.remote.pullScript.add(
        SyncPullResponse.fromJson(
          syncPullJson(
            changes: [
              syncChangeJson(
                'request',
                requestJson(
                  id: 'r-1',
                  siteId: _siteId,
                  zoneId: 'z-1',
                  priority: 'Blocking',
                  note: 'Dalle +10,20',
                  status: 'Validated',
                ),
                version: '51010',
              ),
            ],
          ),
        ),
      );
      await h.engine.run();

      final r = (await h.db.materialRequestsDao.getById('r-1'))!;
      expect(r.number, 'DEM-009');
      expect(r.quantity, Quantity(Decimal.parse('300'), MeasureUnit.bag));
      expect(r.neededBy, DateTime.utc(2026, 11, 28));
      expect(r.priority, 'Blocking');
      expect(r.statusValue, RequestStatus.validated);
      expect(r.isPending, isFalse);
      expect(r.version, 51010);
    });

    test(
      'aucun prix ni telephone en base, meme si le serveur en envoie',
      () async {
        final data = requestJson(
          id: 'r-2',
          siteId: _siteId,
          order: {
            'id': 'o-1',
            'supplierName': 'Sigma',
            'orderDate': '2026-11-25',
            'version': '1',
            'commercial': {'unitPrice': 780.0, 'amount': 234000.0},
          },
          history: [
            {
              'id': 'e-1',
              'type': 'OrderCommercialEdited',
              'changes': [
                {'field': 'unitPrice', 'old': '700', 'new': '780'},
              ],
              'occurredAt': '2026-11-25T09:00:00Z',
            },
            {
              'id': 'e-2',
              'type': 'Created',
              'occurredAt': '2026-11-25T07:00:00Z',
            },
          ],
        )..['commercial'] = {'amount': 1.0};
        final supplier = supplierJson(id: 's-9')..['phone'] = '0550 00 00 21';
        h.remote.pullScript.add(
          SyncPullResponse.fromJson(
            syncPullJson(
              changes: [
                syncChangeJson('request', data, version: '51011'),
                globalSyncChangeJson('supplier', supplier, version: '47012'),
              ],
            ),
          ),
        );
        await h.engine.run();

        final r = (await h.db.materialRequestsDao.getById('r-2'))!;
        final stored = '${r.orderJson} ${r.historyJson}';
        expect(stored, isNot(contains('commercial')));
        expect(stored, isNot(contains('780')));
        expect(stored, isNot(contains('OrderCommercialEdited')));
        expect(r.historyJson, contains('Created'));
        // Le telephone du fournisseur n'a nulle part ou aller.
        final columns = (await h.db.suppliersDao.getById('s-9'))!.toJson();
        expect(jsonEncode(columns), isNot(contains('0550')));
      },
    );

    test('version plus ancienne ignoree, entite inconnue ignoree', () async {
      Map<String, Object?> change(String version, String note) =>
          syncChangeJson(
            'request',
            requestJson(
              id: 'r-3',
              siteId: _siteId,
              note: note,
              version: version,
            ),
            version: version,
          );
      h.remote.pullScript
        ..add(
          SyncPullResponse.fromJson(
            syncPullJson(
              changes: [
                change('60', 'recente'),
                {
                  'entity': 'wilaya',
                  'id': 'w',
                  'siteId': null,
                  'version': '61',
                  'data': {'x': 1},
                },
              ],
            ),
          ),
        )
        ..add(
          SyncPullResponse.fromJson(
            syncPullJson(changes: [change('55', 'ancienne')]),
          ),
        );
      await h.engine.run();
      await h.engine.run();
      expect((await h.db.materialRequestsDao.getById('r-3'))!.note, 'recente');
    });

    test(
      'zone arrivee apres sa demande dans la meme page : pas d erreur',
      () async {
        h.remote.pullScript.add(
          SyncPullResponse.fromJson(
            syncPullJson(
              changes: [
                syncChangeJson(
                  'request',
                  requestJson(id: 'r-4', siteId: 'site-nouveau'),
                  version: '70',
                ),
                syncChangeJson(
                  'site',
                  siteJson(id: 'site-nouveau', version: '71'),
                  version: '71',
                ),
              ],
            ),
          ),
        );
        await h.engine.run();
        expect(await h.db.materialRequestsDao.getById('r-4'), isNotNull);
      },
    );

    test('reglages : copie locale gardee pour le hors ligne', () async {
      h.remote.settingsResponse = MaterialSettingsResponse.fromJson(
        materialSettingsJson(defaultNeededByDays: 5),
      );
      await h.engine.run();
      expect((await h.repo.settings()).defaultNeededByDays, 5);

      // Plus de reseau : la derniere copie reste lisible.
      h.remote.settingsError = const NetworkApiException();
      await h.engine.run();
      expect((await h.repo.settings()).defaultNeededByDays, 5);
      expect(
        (await h.repo.settings()).reasons['rejection'],
        contains('StockSufficient'),
      );
    });

    test('reglages en erreur serveur : la synchronisation continue', () async {
      h.remote.settingsError = const UnknownApiException();
      final outcome = await h.engine.run();
      expect(outcome, SyncOutcome.completed);
      expect((await h.repo.settings()), const MaterialSettings());
    });
  });

  group('push : creation hors ligne (M3)', () {
    test(
      'creation puis synchro : une seule demande, numero du serveur',
      () async {
        await h.create('c-1');
        final pending = await h.row('c-1');
        expect(pending.isPending, isTrue);
        expect(pending.number, isNull);
        expect(pending.version, 0);

        await h.engine.run();

        expect(h.remote.materials.createdCount, 1);
        final confirmed = await h.row('c-1');
        expect(confirmed.isPending, isFalse);
        expect(confirmed.number, 'DEM-001');
        expect(confirmed.id, 'srv-c-1');
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
        // Une seule ligne locale : la ligne en attente a ete remplacee.
        expect(await h.db.materialRequestsDao.countBySite(_siteId), 1);
      },
    );

    test('deux appuis : une seule operation et une seule ligne', () async {
      final first = await h.create('c-2');
      final second = await h.create('c-2');
      expect(first, isA<RequestSaved>());
      expect(second, isA<RequestAlreadySaved>());
      expect((await h.db.outboxDao.allFor(_user)), hasLength(1));
      expect(await h.db.materialRequestsDao.countBySite(_siteId), 1);
    });

    test(
      'reponse perdue puis renvoi : jamais de doublon, un seul numero',
      () async {
        await h.create('c-3');
        h.remote.loseNextPushResponse = true;
        await h.engine.run();
        expect((await h.db.outboxDao.allFor(_user)), hasLength(1));

        await h.engine.run();
        expect(h.remote.materials.createdCount, 1);
        expect(h.remote.materials.numbers, ['DEM-001']);
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
        expect((await h.row('c-3')).number, 'DEM-001');
      },
    );

    test(
      'la charge utile porte unite, date complete et jamais statut ni numero',
      () async {
        await h.create('c-4');
        final payload = (await h.operation('c-4')).payload;
        expect(payload['quantity'], {'value': 300, 'unit': 'sac'});
        expect(payload['neededBy'], '2026-11-28');
        expect(payload['productId'], _productId);
        expect(payload.containsKey('status'), isFalse);
        expect(payload.containsKey('number'), isFalse);
        expect(payload['priority'], 'Normal');
      },
    );

    test(
      '200 saisies : envoyees par lots de 50 dans l ordre de creation',
      () async {
        for (var i = 0; i < 200; i++) {
          await h.create('lot-${i.toString().padLeft(3, '0')}');
        }
        await h.engine.run();

        expect(h.remote.pushBatches.map((b) => b.length), [50, 50, 50, 50]);
        expect(h.remote.pushedClientIds.first, 'lot-000');
        expect(h.remote.pushedClientIds.last, 'lot-199');
        expect(h.remote.materials.createdCount, 200);
        expect(h.remote.materials.numbers.first, 'DEM-001');
        expect(h.remote.materials.numbers.last, 'DEM-200');
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
      },
    );

    test(
      'zone creee hors ligne : la demande la designe par zoneClientId',
      () async {
        await h.db.zonesDao.insertPending(
          pendingZoneRow(clientId: 'zone-c', siteId: _siteId),
        );
        await h.create(
          'c-5',
          input: h.draft(zoneId: 'zone-c', zoneIsPending: true),
        );
        final payload = (await h.operation('c-5')).payload;
        expect(payload['zoneClientId'], 'zone-c');
        expect(payload.containsKey('zoneId'), isFalse);
      },
    );

    test(
      'zone fusionnee avec une zone du serveur : la demande suit la zone retenue',
      () async {
        await h.db.zonesDao.insertPending(
          pendingZoneRow(clientId: 'zone-c', siteId: _siteId),
        );
        await h.create(
          'c-6',
          input: h.draft(zoneId: 'zone-c', zoneIsPending: true),
        );
        await SitesRepository(h.db).applyPushedZone(
          operationClientId: 'zone-c',
          merged: true,
          resource: zoneJson(
            id: 'zone-srv',
            siteId: _siteId,
            clientId: 'autre',
            version: '90',
          ),
        );

        expect((await h.row('c-6')).zoneId, 'zone-srv');
        final payload = (await h.operation('c-6')).payload;
        expect(payload['zoneId'], 'zone-srv');
        expect(payload.containsKey('zoneClientId'), isFalse);
      },
    );

    test(
      'modifier une demande jamais envoyee modifie sa saisie, sans operation en plus',
      () async {
        await h.create('c-7');
        final view = await h.view('c-7');
        final result = await h.repo.editRequest(
          view: view,
          draft: h.draft(quantity: 400, neededBy: DateTime.utc(2026, 12, 1)),
          userId: _user,
          clientId: 'edit-ignored',
          label: 'Demande Ciment',
        );
        expect(result, isA<RequestSaved>());
        final operations = await h.db.outboxDao.allFor(_user);
        expect(operations, hasLength(1));
        expect(operations.single.payload['quantity'], {
          'value': 400,
          'unit': 'sac',
        });
        expect((await h.row('c-7')).quantityValue, Decimal.parse('400'));

        await h.engine.run();
        expect(h.remote.materials.requests.values.single['quantity'], {
          'value': 400,
          'unit': 'sac',
        });
      },
    );

    test(
      'creation, modification puis annulation : ordre respecte, references par clientId',
      () async {
        await h.create('c-8');
        // Une demande deja envoyee ne peut plus se modifier a la main : on chaine deux saisies.
        await h.engine.run();
        final confirmed = await h.view('c-8');
        await h.repo.editRequest(
          view: confirmed,
          draft: h.draft(quantity: 350),
          userId: _user,
          clientId: 'u-8',
          label: 'Demande Ciment',
        );
        await h.repo.cancel(
          view: await h.view('c-8'),
          userId: _user,
          clientId: 't-8',
          label: 'Demande Ciment',
          reasonCode: 'EntryError',
        );
        final ops = await h.db.outboxDao.allFor(_user);
        expect(ops.map((o) => o.operation), ['update', 'transition']);

        await h.engine.run();
        final server = h.remote.materials.requests.values.single;
        expect(server['status'], 'Cancelled');
        expect(server['quantity'], {'value': 350, 'unit': 'sac'});
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
      },
    );

    test(
      'demande modifiee avant son envoi : l operation vise le clientId',
      () async {
        await h.create('c-9');
        await h.repo.cancel(
          view: await h.view('c-9'),
          userId: _user,
          clientId: 't-9',
          label: 'Demande Ciment',
          reasonCode: 'EntryError',
        );
        final payload = (await h.operation('t-9')).payload;
        expect(payload['requestClientId'], 'c-9');
        expect(payload.containsKey('requestId'), isFalse);

        // Creation et annulation dans le meme lot : le serveur resout par clientId.
        await h.engine.run();
        expect(
          h.remote.materials.requests.values.single['status'],
          'Cancelled',
        );
      },
    );

    test(
      'rollback : si l ecriture locale echoue, aucune operation n est ajoutee',
      () async {
        await h.create('c-10');
        // Meme identifiant de ligne locale deja pris par une autre demande : l'insertion echoue.
        await h.db.materialRequestsDao.insertPending(
          pendingRequestRow(clientId: 'c-11', siteId: _siteId),
        );
        await expectLater(h.create('c-11'), throwsA(anything));
        expect(await h.db.outboxDao.getByClientId('c-11'), isNull);
      },
    );
  });

  group('reprise apres arret de l application (CT-MAT-21)', () {
    test('application tuee pendant l envoi : reprise sans doublon', () async {
      for (final id in ['k-a', 'k-b', 'k-c']) {
        await h.create(id);
      }
      // Le serveur applique le lot, mais le telephone ne l'apprend jamais.
      h.remote.loseNextPushResponse = true;
      await h.engine.run();
      // Application tuee : les saisies sont restees « en cours d'envoi ».
      final stuck = await h.db.outboxDao.allFor(_user);
      await h.db.outboxDao.markSending([for (final op in stuck) op.id]);

      await h.engine.run();

      expect(h.remote.materials.createdCount, 3);
      expect(h.remote.materials.numbers, ['DEM-001', 'DEM-002', 'DEM-003']);
      expect(await h.db.outboxDao.allFor(_user), isEmpty);
      expect(await h.db.materialRequestsDao.countBySite(_siteId), 3);
      expect((await h.row('k-b')).number, 'DEM-002');
    });

    test(
      'trois jours sans reseau : 20 demandes puis retour du reseau, une seule fois chacune',
      () async {
        for (var i = 0; i < 20; i++) {
          await h.create('j-${i.toString().padLeft(2, '0')}');
        }
        h.remote.settingsError = const NetworkApiException();
        expect(await h.engine.run(), SyncOutcome.offline);
        expect(await h.db.outboxDao.allFor(_user), hasLength(20));
        expect(h.remote.materials.createdCount, 0);

        h.remote.settingsError = null;
        await h.engine.run();
        await h.engine.run();
        expect(h.remote.materials.createdCount, 20);
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
      },
    );
  });

  group('push : conflits (M3, ADR 0011)', () {
    /// Demande envoyee et confirmee ; retourne son identifiant serveur.
    Future<String> confirmed(String clientId) async {
      await h.create(clientId);
      await h.engine.run();
      return 'srv-$clientId';
    }

    test(
      'CA-MAT-010.2 : 300 -> 400 hors ligne, validee entre-temps : rien applique, conflit garde',
      () async {
        final id = await confirmed('k-1');
        await h.repo.editRequest(
          view: await h.view('k-1'),
          draft: h.draft(quantity: 400),
          userId: _user,
          clientId: 'u-k1',
          label: 'Demande Ciment',
        );
        // Pendant ce temps, le conducteur valide.
        h.remote.materials.setStatus(id, 'Validated');
        await h.engine.run();

        final op = await h.operation('u-k1');
        expect(op.status, OutboxStatus.conflict);
        expect(op.lastErrorCode, 'DEMANDE_VERROUILLEE');
        // L'etat du serveur est garde pour l'ecran « A verifier »...
        final current = jsonDecode(op.conflictJson!) as Map;
        expect(current['status'], 'Validated');
        expect(current['quantity'], {'value': 300, 'unit': 'sac'});
        // ... et la ligne locale le suit : le serveur gagne, 300 sacs.
        final local = await h.row('k-1');
        expect(local.statusValue, RequestStatus.validated);
        expect(local.quantityValue, Decimal.parse('300'));
        // Rien n'est supprime sans decision.
        expect(await h.db.outboxDao.allFor(_user), hasLength(1));
        // La saisie en conflit n'est plus appliquee a l'affichage.
        final view = await h.view('k-1');
        expect(view.needsCheck, isTrue);
        expect(view.row.quantityValue, Decimal.parse('300'));
      },
    );

    test(
      'CA-MAT-010.4 : deux dates differentes : la premiere arrivee est retenue, l autre a verifier',
      () async {
        final id = await confirmed('k-2');
        await h.repo.editRequest(
          view: await h.view('k-2'),
          draft: h.draft(neededBy: DateTime.utc(2026, 12, 10)),
          userId: _user,
          clientId: 'u-k2',
          label: 'Demande Ciment',
        );
        h.remote.materials.changeElsewhere(id, {'neededBy': '2026-12-01'});
        await h.engine.run();

        final op = await h.operation('u-k2');
        expect(op.status, OutboxStatus.conflict);
        expect(op.lastErrorCode, 'CONFLIT_VERSION');
        expect(jsonDecode(op.conflictFields!), ['neededBy']);
        expect(
          (await h.row('k-2')).neededBy,
          DateTime.utc(2026, 12, 1),
          reason: 'la date de l autre utilisateur est retenue',
        );
      },
    );

    test(
      'CA-MAT-010.5 : champs differents : les deux modifications sont appliquees',
      () async {
        final id = await confirmed('k-3');
        await h.repo.editRequest(
          view: await h.view('k-3'),
          draft: h.draft(priority: RequestPriority.urgent),
          userId: _user,
          clientId: 'u-k3',
          label: 'Demande Ciment',
        );
        h.remote.materials.changeElsewhere(id, {'neededBy': '2026-12-01'});
        await h.engine.run();

        expect(await h.db.outboxDao.allFor(_user), isEmpty);
        final local = await h.row('k-3');
        expect(local.priority, 'Urgent');
        expect(local.neededBy, DateTime.utc(2026, 12, 1));
      },
    );

    test(
      'CA-MAT-003.5 : validation apres l annulation par le demandeur : le serveur gagne',
      () async {
        final id = await confirmed('k-4');
        await h.repo.approve(
          view: await h.view('k-4'),
          userId: _user,
          clientId: 't-k4',
          label: 'Demande Ciment',
        );
        h.remote.materials.setStatus(
          id,
          'Cancelled',
          reason: {'code': 'EntryError', 'note': null},
        );
        await h.engine.run();

        final op = await h.operation('t-k4');
        expect(op.status, OutboxStatus.conflict);
        expect(op.lastErrorCode, 'TRANSITION_INTERDITE');
        final local = await h.row('k-4');
        expect(local.statusValue, RequestStatus.cancelled);
        expect(local.statusReasonCode, 'EntryError');
      },
    );

    test(
      'validation deja faite par un collegue : « deja validee », sans erreur',
      () async {
        final id = await confirmed('k-5');
        await h.repo.approve(
          view: await h.view('k-5'),
          userId: _user,
          clientId: 't-k5',
          label: 'Demande Ciment',
        );
        h.remote.materials.setStatus(id, 'Validated');
        await h.engine.run();
        expect(await h.db.outboxDao.allFor(_user), isEmpty);
        expect((await h.row('k-5')).statusValue, RequestStatus.validated);
      },
    );

    test(
      'renvoi d un conflit : meme resultat, jamais de faux conflit',
      () async {
        final id = await confirmed('k-6');
        await h.repo.editRequest(
          view: await h.view('k-6'),
          draft: h.draft(neededBy: DateTime.utc(2026, 12, 10)),
          userId: _user,
          clientId: 'u-k6',
          label: 'Demande Ciment',
        );
        h.remote.materials.changeElsewhere(id, {'neededBy': '2026-12-01'});
        await h.engine.run();
        // Le conflit n'est jamais rejoue seul : un second tour ne change rien.
        await h.engine.run();
        expect((await h.operation('u-k6')).status, OutboxStatus.conflict);
        expect(
          h.remote.pushedClientIds.where((c) => c == 'u-k6'),
          hasLength(1),
        );
      },
    );

    test(
      'operation refusee : gardee avec son code, jamais rejouee seule',
      () async {
        await h.create('k-7');
        h.remote.pushHandler = (ops) => SyncPushResponse(
          results: [
            for (final op in ops)
              SyncPushResult(
                clientId: op.clientId,
                status: 'rejected',
                code: 'ZONE_HORS_CHANTIER',
              ),
          ],
        );
        await h.engine.run();
        final op = await h.operation('k-7');
        expect(op.status, OutboxStatus.rejected);
        expect(op.lastErrorCode, 'ZONE_HORS_CHANTIER');
        expect((await h.row('k-7')).isPending, isTrue);
      },
    );

    test(
      'un conflit ne garde jamais un prix, meme si le serveur en envoie',
      () async {
        final id = await confirmed('k-8');
        await h.repo.editRequest(
          view: await h.view('k-8'),
          draft: h.draft(quantity: 400),
          userId: _user,
          clientId: 'u-k8',
          label: 'Demande Ciment',
        );
        h.remote.materials.setStatus(id, 'Validated');
        h.remote.materials.requests[id]!['commercial'] = {'amount': 1.0};
        h.remote.materials.requests[id]!['order'] = {
          'id': 'o',
          'commercial': {'unitPrice': 780.0},
        };
        await h.engine.run();
        final op = await h.operation('u-k8');
        expect(op.conflictJson, isNot(contains('commercial')));
        expect(op.conflictJson, isNot(contains('780')));
      },
    );
  });

  group('surcouche provisoire (M3)', () {
    test(
      'une validation en attente s affiche « a confirmer » puis disparait',
      () async {
        await h.create('p-1');
        await h.engine.run();
        await h.repo.approve(
          view: await h.view('p-1'),
          userId: _user,
          clientId: 't-p1',
          label: 'Demande Ciment',
          quantity: Quantity(Decimal.parse('200'), MeasureUnit.bag),
        );
        final provisional = await h.view('p-1');
        expect(provisional.row.statusValue, RequestStatus.validated);
        expect(provisional.row.quantityValue, Decimal.parse('200'));
        expect(provisional.isStatusProvisional, isTrue);
        expect(provisional.hasPendingApproval, isTrue);
        // Le stockage reste celui du serveur.
        expect(provisional.stored.statusValue, RequestStatus.requested);

        await h.engine.run();
        final confirmed = await h.view('p-1');
        expect(confirmed.isStatusProvisional, isFalse);
        expect(confirmed.row.statusValue, RequestStatus.validated);
        expect(confirmed.row.quantityValue, Decimal.parse('200'));
      },
    );

    test('double appui sur « Valider » : une seule operation', () async {
      await h.create('p-2');
      await h.engine.run();
      final view = await h.view('p-2');
      final first = await h.repo.approve(
        view: view,
        userId: _user,
        clientId: 't-p2a',
        label: 'x',
      );
      final second = await h.repo.approve(
        view: await h.view('p-2'),
        userId: _user,
        clientId: 't-p2b',
        label: 'x',
      );
      expect(first, QueueResult.queued);
      expect(second, QueueResult.alreadyQueued);
      expect(await h.db.outboxDao.allFor(_user), hasLength(1));
    });

    test(
      'annulation hors ligne : la demande passe tout de suite dans « refusees et annulees »',
      () async {
        await h.create('p-3');
        await h.engine.run();
        await h.repo.cancel(
          view: await h.view('p-3'),
          userId: _user,
          clientId: 't-p3',
          label: 'x',
          reasonCode: 'NoLongerNeeded',
          reasonNote: null,
        );
        final view = await h.view('p-3');
        expect(view.row.statusValue, RequestStatus.cancelled);
        expect(view.row.statusReasonCode, 'NoLongerNeeded');
        expect(view.isStatusProvisional, isTrue);
      },
    );
  });

  test(
    'abandonner une creation supprime la ligne locale et ses saisies suivantes',
    () async {
      await h.create('a-1');
      await h.repo.cancel(
        view: await h.view('a-1'),
        userId: _user,
        clientId: 't-a1',
        label: 'x',
        reasonCode: 'EntryError',
      );
      await h.outbox.abandon(await h.operation('a-1'));
      expect(await h.db.outboxDao.allFor(_user), isEmpty);
      expect(await h.db.materialRequestsDao.countBySite(_siteId), 0);
    },
  );
}
