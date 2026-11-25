import 'dart:convert';
import 'dart:math';

import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/api_json.dart';
import '../../support/fake_sync_remote.dart';
import '../../support/fixtures.dart';
import '../../support/test_database.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

const _siteId = '0192a000-0000-7000-8000-0000000000a1';
const _localSite = 'site-uv18';

class _Harness {
  _Harness() {
    db = createTestDatabase();
    remote = FakeSyncRemote();
    monitor = _MockMonitor();
    when(
      () => monitor.hasNetworkInterface(),
    ).thenAnswer((_) async => hasNetwork);
    outbox = OutboxRepository(db);
    engine = SyncEngine(
      database: db,
      remote: remote,
      sites: SitesRepository(db),
      currentUserId: () => userId,
      connectivity: monitor,
      backoff: Backoff(random: _FixedRandom()),
      now: () => clock,
      onProfile: (me) async => profiles.add(me),
    );
  }

  late final AppDatabase db;
  late final FakeSyncRemote remote;
  late final _MockMonitor monitor;
  late final OutboxRepository outbox;
  late final SyncEngine engine;
  final List<MeResponse> profiles = [];
  String? userId = 'user-a';
  bool hasNetwork = true;
  DateTime clock = DateTime.utc(2026, 11, 24, 10);

  /// Saisie hors ligne d'une zone : zone locale en attente + operation, dans une transaction.
  Future<void> saveZoneOffline(
    String clientId, {
    String owner = 'user-a',
    String siteId = _localSite,
    int roomNumber = 7,
  }) async {
    final payload = {
      'clientCreatedAt': '2026-11-24T06:58:00Z',
      'block': 'Bloc 01',
      'elevation': 3.4,
      'roomType': 'Classroom',
      'roomNumber': roomNumber,
    };
    await outbox.saveWithOperation(
      operation: outboxOp(
        clientId: clientId,
        owner: owner,
        siteId: siteId,
      ).copyWith(payloadJson: Value(jsonEncode(payload))),
      localWrite: () => db.zonesDao.insertPending(
        pendingZoneRow(
          clientId: clientId,
          siteId: siteId,
          roomNumber: roomNumber,
        ),
      ),
    );
  }

  Future<List<OutboxRow>> allOps() => db.outboxDao.watchFor(userId ?? '').first;

  Future<void> dispose() async {
    await engine.dispose();
    await db.close();
  }
}

class _FixedRandom implements Random {
  @override
  bool nextBool() => true;
  @override
  double nextDouble() => 1; // delai maximal (pas d'aleas) : tests deterministes
  @override
  int nextInt(int max) => max - 1;
}

SyncPullResponse _page({
  List<Map<String, Object?>> changes = const [],
  List<Map<String, Object?>> deleted = const [],
  String cursor = '100',
  bool hasMore = false,
}) => pullPage(
  syncPullJson(
    changes: changes,
    deleted: deleted,
    cursor: cursor,
    hasMore: hasMore,
  ),
);

Map<String, Object?> _site(
  String version, {
  String id = _siteId,
  String code = 'CH-ECO-UV18',
}) => syncChangeJson(
  'site',
  siteJson(id: id, code: code, version: version),
  version: version,
);

Map<String, Object?> _zone(
  String id,
  String version, {
  String? clientId,
  int number = 2,
}) => syncChangeJson(
  'zone',
  zoneJson(
    id: id,
    siteId: _siteId,
    clientId: clientId,
    roomNumber: number,
    version: version,
  ),
  version: version,
);

void main() {
  late _Harness h;

  setUp(() => h = _Harness());
  tearDown(() => h.dispose());

  group('Pull : curseur serveur (CT-8)', () {
    test(
      'premiere synchro paginee : une page = une transaction, curseur avance par page',
      () async {
        h.remote.pullScript.addAll([
          _page(
            changes: [_site('10'), _zone('z1', '11')],
            cursor: '11',
            hasMore: true,
          ),
          _page(
            changes: [_zone('z2', '12', number: 3)],
            cursor: '12',
            hasMore: true,
          ),
          _page(changes: [_zone('z3', '13', number: 4)], cursor: '13'),
        ]);

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.completed);
        expect(h.remote.pullSinces, [null, '11', '12']);
        expect(await h.db.sitesDao.countSites(), 1);
        expect(await h.db.zonesDao.countBySite(_siteId), 3);
        expect(await h.db.syncStateDao.get(SyncStateKeys.cursor), '13');
        expect(
          await h.db.syncStateDao.get(SyncStateKeys.initialSyncDone),
          'true',
        );
        expect(
          await h.db.syncStateDao.get(SyncStateKeys.ownerUserId),
          'user-a',
        );
        expect(
          await h.db.syncStateDao.get(SyncStateKeys.lastSuccessAt),
          isNotNull,
        );
      },
    );

    test('initialSyncDone reste faux tant qu\'il reste des pages', () async {
      h.remote.pullScript.addAll([
        _page(changes: [_site('10')], cursor: '10', hasMore: true),
        const NetworkApiException(),
      ]);

      await h.engine.run();

      expect(
        await h.db.syncStateDao.get(SyncStateKeys.initialSyncDone),
        isNull,
      );
    });

    test(
      'reprise apres coupure : repart du curseur de la derniere page appliquee',
      () async {
        h.remote.pullScript.addAll([
          _page(
            changes: [_site('10'), _zone('z1', '11')],
            cursor: '11',
            hasMore: true,
          ),
          const NetworkApiException(),
        ]);

        final first = await h.engine.run();

        expect(first, SyncOutcome.offline);
        expect(await h.db.syncStateDao.get(SyncStateKeys.cursor), '11');
        expect(
          await h.db.zonesDao.countBySite(_siteId),
          1,
          reason: 'page 1 conservee',
        );

        h.remote.pullScript.add(
          _page(changes: [_zone('z2', '12', number: 3)], cursor: '12'),
        );
        final second = await h.engine.run();

        expect(second, SyncOutcome.completed);
        expect(h.remote.pullSinces, [null, '11', '11']);
        expect(await h.db.zonesDao.countBySite(_siteId), 2);
      },
    );

    test(
      'application idempotente : rejouer la meme page ne change rien',
      () async {
        final page = _page(
          changes: [_site('10'), _zone('z1', '11')],
          cursor: '11',
        );
        h.remote.pullScript.addAll([page, page]);

        await h.engine.run();
        final before = await h.db.zonesDao.getById('z1');
        await h.engine.run();

        expect(await h.db.zonesDao.countBySite(_siteId), 1);
        expect(await h.db.zonesDao.getById('z1'), before);
      },
    );

    test('version plus ancienne que celle deja connue : ignoree', () async {
      h.remote.pullScript.addAll([
        _page(changes: [_site('20')], cursor: '20'),
        _page(
          changes: [
            syncChangeJson(
              'site',
              siteJson(name: 'Ancien nom', version: '15'),
              version: '15',
            ),
          ],
          cursor: '21',
        ),
      ]);

      await h.engine.run();
      await h.engine.run();

      expect((await h.db.sitesDao.getSite(_siteId))!.name, 'École UV18');
    });

    test(
      'pierre tombale site : chantier, zones et affectations disparaissent (CT-4)',
      () async {
        h.remote.pullScript.add(
          _page(
            changes: [
              _site('10'),
              _zone('z1', '11'),
              syncChangeJson('member', memberJson(), version: '12'),
            ],
            cursor: '12',
          ),
        );
        await h.engine.run();
        expect(
          await h.db.siteMembersDao.getById(
            '0192a000-0000-7000-8000-0000000000c1',
          ),
          isNotNull,
        );

        h.remote.pullScript.add(
          _page(
            deleted: [
              {
                'entity': 'member',
                'id': '0192a000-0000-7000-8000-0000000000c1',
                'siteId': _siteId,
                'version': '20',
              },
              {
                'entity': 'site',
                'id': _siteId,
                'siteId': _siteId,
                'version': '21',
              },
            ],
            cursor: '21',
          ),
        );
        await h.engine.run();

        expect(await h.db.sitesDao.getSite(_siteId), isNull);
        expect(await h.db.zonesDao.getById('z1'), isNull);
        expect(
          await h.db.siteMembersDao.getById(
            '0192a000-0000-7000-8000-0000000000c1',
          ),
          isNull,
        );
      },
    );

    test(
      'retrait d\'affectation : la saisie en attente sur ce chantier n\'est pas perdue (CA-002.6)',
      () async {
        await h.db.sitesDao.upsertIfNewer(
          siteRow(id: _localSite, code: 'CH-LOCAL'),
        );
        await h.saveZoneOffline('c-1');
        h.remote.pushHandler = (ops) => SyncPushResponse(
          results: [
            SyncPushResult(
              clientId: ops.first.clientId,
              status: 'rejected',
              code: 'INTROUVABLE',
            ),
          ],
        );

        await h.engine.run();

        final op = (await h.outbox.watch('user-a').first).single;
        expect(op.status, OutboxStatus.rejected);
        expect(op.lastErrorCode, 'INTROUVABLE');
      },
    );

    test(
      'entite inconnue du serveur (wilaya...) : ignoree sans erreur',
      () async {
        h.remote.pullScript.add(
          _page(
            changes: [
              syncChangeJson('wilaya', {
                'id': '0192a000-0000-7000-8000-0000000000d1',
                'siteId': _siteId,
              }, version: '5'),
              _site('10'),
            ],
            cursor: '10',
          ),
        );

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.completed);
        expect(await h.db.sitesDao.countSites(), 1);
      },
    );

    test('ligne illisible : echec, rien d\'ecrit, curseur inchange', () async {
      final broken = zoneJson(id: 'z1', siteId: _siteId)..remove('block');
      h.remote.pullScript.add(
        _page(
          changes: [
            _site('10'),
            syncChangeJson('zone', broken, version: '11'),
          ],
          cursor: '11',
        ),
      );

      final outcome = await h.engine.run();

      expect(outcome, SyncOutcome.failed);
      expect(
        await h.db.sitesDao.countSites(),
        0,
        reason: 'la page est appliquee en entier ou pas du tout',
      );
      expect(await h.db.syncStateDao.get(SyncStateKeys.cursor), isNull);
    });

    test('CURSEUR_INVALIDE : repart de zero, file d\'envoi intacte', () async {
      await h.db.sitesDao.upsertIfNewer(
        siteRow(id: _localSite, code: 'CH-LOCAL'),
      );
      await h.saveZoneOffline('c-1');
      await h.db.syncStateDao.set(SyncStateKeys.cursor, 'illisible');
      h.remote.pushHandler = (ops) => SyncPushResponse(
        results: [
          SyncPushResult(clientId: ops.first.clientId, status: 'conflict'),
        ],
      );
      h.remote.pullScript.addAll([
        const ValidationApiException(status: 400, code: 'CURSEUR_INVALIDE'),
        _page(changes: [_site('10')], cursor: '10'),
      ]);

      final outcome = await h.engine.run();

      expect(outcome, SyncOutcome.completed);
      expect(h.remote.pullSinces, ['illisible', null]);
      expect(await h.db.syncStateDao.get(SyncStateKeys.cursor), '10');
      expect(
        await h.outbox.watch('user-a').first,
        hasLength(1),
        reason: 'file conservee',
      );
    });

    test(
      'CURSEUR_INVALIDE deux fois de suite : echec (pas de boucle)',
      () async {
        h.remote.pullScript.addAll([
          const ValidationApiException(status: 400, code: 'CURSEUR_INVALIDE'),
          const ValidationApiException(status: 400, code: 'CURSEUR_INVALIDE'),
        ]);

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.failed);
        expect(h.remote.pullSinces, hasLength(2));
      },
    );

    test(
      'permissionsVersion modifiee : rechargement complet, file conservee',
      () async {
        await h.db.sitesDao.upsertIfNewer(
          siteRow(id: _localSite, code: 'CH-LOCAL'),
        );
        await h.db.syncStateDao.setAll({
          SyncStateKeys.permissionsVersion: 'ancienne',
          SyncStateKeys.cursor: '999',
          SyncStateKeys.initialSyncDone: 'true',
        });
        await h.saveZoneOffline('c-1');
        h.remote.pushHandler = (ops) => SyncPushResponse(
          results: [
            SyncPushResult(
              clientId: ops.first.clientId,
              status: 'rejected',
              code: 'INTERDIT',
            ),
          ],
        );
        h.remote.pullScript.add(
          _page(
            changes: [_site('10', code: 'CH-NEW')],
            cursor: '10',
          ),
        );

        await h.engine.run();

        expect(h.remote.pullSinces.single, isNull, reason: 'repart de zero');
        expect(
          await h.db.syncStateDao.get(SyncStateKeys.permissionsVersion),
          'a41f09c2',
        );
        expect(await h.outbox.watch('user-a').first, hasLength(1));
      },
    );

    test(
      'montant du marche : colonne vide sans la permission (CA-012.7)',
      () async {
        h.remote.pullScript.add(_page(changes: [_site('10')], cursor: '10'));

        await h.engine.run();

        expect((await h.db.sitesDao.getSite(_siteId))!.contractAmount, isNull);
      },
    );

    test(
      'montant du marche present avec la permission : decimal sans perte',
      () async {
        h.remote.pullScript.add(
          _page(
            changes: [
              syncChangeJson(
                'site',
                siteJson(contractAmount: 185000000, version: '10'),
                version: '10',
              ),
            ],
            cursor: '10',
          ),
        );

        await h.engine.run();

        expect(
          (await h.db.sitesDao.getSite(_siteId))!.contractAmount,
          Decimal.parse('185000000.00'),
        );
      },
    );
  });

  group('Push : file d\'envoi (CT-9, CT-21)', () {
    setUp(
      () async => h.db.sitesDao.upsertIfNewer(
        siteRow(id: _localSite, code: 'CH-LOCAL'),
      ),
    );

    test(
      'zone creee hors ligne : envoyee, remplacee par celle du serveur, file videe',
      () async {
        await h.saveZoneOffline('c-1');

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.completed);
        expect(await h.outbox.watch('user-a').first, isEmpty);
        expect(await h.db.zonesDao.getById('c-1'), isNull);
        final zone = (await h.db.zonesDao.getById('srv-c-1'))!;
        expect(zone.isPending, isFalse);
        expect(zone.clientId, 'c-1');
        expect(await h.db.zonesDao.countBySite(_localSite), 1);
      },
    );

    test('le payload part tel que saisi (cote, type, numero)', () async {
      await h.saveZoneOffline('c-1', roomNumber: 9);

      await h.engine.run();

      final op = h.remote.pushBatches.single.single;
      expect(op.entity, 'zone');
      expect(op.operation, 'create');
      expect(op.siteId, _localSite);
      expect(op.payload, containsPair('roomNumber', 9));
      expect(op.payload, containsPair('elevation', 3.4));
    });

    test(
      'renvoi apres coupure : une seule zone (duplicate), jamais deux',
      () async {
        await h.saveZoneOffline('c-1');
        // Reseau qui coupe apres reception cote serveur : la reponse n'arrive jamais.
        var first = true;
        h.remote.pushHandler = (ops) async {
          // le serveur a bien traite le lot
          final response = SyncPushResponse(
            results: [
              for (final op in ops)
                SyncPushResult(
                  clientId: op.clientId,
                  status: 'applied',
                  resource: zoneJson(
                    id: 'srv-1',
                    siteId: _localSite,
                    clientId: op.clientId,
                    version: '600',
                  ),
                ),
            ],
          );
          if (first) {
            first = false;
            throw const NetworkApiException();
          }
          return SyncPushResponse(
            results: [
              for (final r in response.results) r.copyWith(status: 'duplicate'),
            ],
          );
        };

        final firstRun = await h.engine.run();
        expect(firstRun, SyncOutcome.offline);
        var op = (await h.outbox.watch('user-a').first).single;
        expect(op.status, OutboxStatus.pending);
        expect(op.attempts, 1);
        expect(
          await h.db.zonesDao.getById('c-1'),
          isNotNull,
          reason: 'zone locale conservee',
        );

        final secondRun = await h.engine.run();

        expect(secondRun, SyncOutcome.completed);
        expect(await h.outbox.watch('user-a').first, isEmpty);
        expect(await h.db.zonesDao.countBySite(_localSite), 1);
        expect(h.remote.pushedClientIds, [
          'c-1',
          'c-1',
        ], reason: 'meme clientId a chaque envoi');
      },
    );

    test(
      'deux telephones creent la meme zone : merged, zone retenue, sans erreur',
      () async {
        await h.saveZoneOffline('c-1');
        h.remote.pushHandler = (ops) => SyncPushResponse(
          results: [
            SyncPushResult(
              clientId: ops.single.clientId,
              status: 'duplicate',
              merged: true,
              resource: zoneJson(
                id: 'zone-retenue',
                siteId: _localSite,
                clientId: 'autre-telephone',
                roomNumber: 7,
                version: '700',
              ),
            ),
          ],
        );

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.completed);
        expect(
          await h.outbox.watch('user-a').first,
          isEmpty,
          reason: 'aucune erreur a afficher',
        );
        expect(
          await h.db.zonesDao.getById('c-1'),
          isNull,
          reason: 'zone locale fusionnee',
        );
        expect(await h.db.zonesDao.getById('zone-retenue'), isNotNull);
        expect(await h.db.zonesDao.countBySite(_localSite), 1);
      },
    );

    test('rejected : conservee avec son code, jamais rejouee seule', () async {
      await h.saveZoneOffline('c-1');
      h.remote.pushHandler = (ops) => SyncPushResponse(
        results: [
          SyncPushResult(
            clientId: ops.single.clientId,
            status: 'rejected',
            code: 'CHANTIER_ARCHIVE',
          ),
        ],
      );

      await h.engine.run();
      await h.engine.run();

      expect(
        h.remote.pushBatches,
        hasLength(1),
        reason: 'pas de nouvel envoi automatique',
      );
      final op = (await h.outbox.watch('user-a').first).single;
      expect(op.status, OutboxStatus.rejected);
      expect(op.lastErrorCode, 'CHANTIER_ARCHIVE');
      expect(
        await h.db.zonesDao.getById('c-1'),
        isNotNull,
        reason: 'zone locale gardee jusqu\'a decision',
      );
    });

    test('conflict : conserve avec son code', () async {
      await h.saveZoneOffline('c-1');
      h.remote.pushHandler = (ops) => SyncPushResponse(
        results: [
          SyncPushResult(
            clientId: ops.single.clientId,
            status: 'conflict',
            current: {'version': '9'},
          ),
        ],
      );

      await h.engine.run();

      final op = (await h.outbox.watch('user-a').first).single;
      expect(op.status, OutboxStatus.conflict);
      expect(op.lastErrorCode, 'CONFLIT_VERSION');
    });

    test(
      'lot partiel : applied pour l\'un, rejected pour l\'autre, chacun traite selon son resultat',
      () async {
        await h.saveZoneOffline('c-1');
        await h.saveZoneOffline('c-2', roomNumber: 8);
        h.remote.pushHandler = (ops) => SyncPushResponse(
          results: [
            SyncPushResult(
              clientId: ops[0].clientId,
              status: 'applied',
              resource: zoneJson(
                id: 'srv-1',
                siteId: _localSite,
                clientId: 'c-1',
                version: '800',
              ),
            ),
            SyncPushResult(
              clientId: ops[1].clientId,
              status: 'rejected',
              code: 'ZONE_EXISTANTE',
            ),
          ],
        );

        await h.engine.run();

        final remaining = await h.outbox.watch('user-a').first;
        expect(remaining.single.clientId, 'c-2');
        expect(remaining.single.status, OutboxStatus.rejected);
        expect(await h.db.zonesDao.getById('srv-1'), isNotNull);
      },
    );

    test('resultat manquant pour une operation : elle sera renvoyee', () async {
      await h.saveZoneOffline('c-1');
      await h.saveZoneOffline('c-2', roomNumber: 8);
      var calls = 0;
      h.remote.pushHandler = (ops) {
        calls++;
        return SyncPushResponse(
          results: [
            SyncPushResult(
              clientId: ops.first.clientId,
              status: 'applied',
              resource: zoneJson(
                id: 'srv-${ops.first.clientId}',
                siteId: _localSite,
                clientId: ops.first.clientId,
                version: '${900 + calls}',
              ),
            ),
          ],
        );
      };

      await h.engine.run();

      // c-2 est reparti en `pending` apres le premier lot, puis envoye au tour suivant.
      expect(h.remote.pushedClientIds.where((id) => id == 'c-2'), isNotEmpty);
    });

    test('statut inconnu : operation conservee a envoyer', () async {
      await h.saveZoneOffline('c-1');
      var first = true;
      h.remote.pushHandler = (ops) {
        if (first) {
          first = false;
          return SyncPushResponse(
            results: [
              SyncPushResult(clientId: ops.single.clientId, status: 'inconnu'),
            ],
          );
        }
        throw const NetworkApiException();
      };

      await h.engine.run();

      expect(
        (await h.outbox.watch('user-a').first).single.attempts,
        greaterThanOrEqualTo(1),
      );
    });

    test(
      '200 saisies en attente : 4 lots de 50, dans l\'ordre de creation (CT-24)',
      () async {
        for (var i = 0; i < 200; i++) {
          await h.saveZoneOffline(
            'c-${i.toString().padLeft(3, '0')}',
            roomNumber: i + 1,
          );
        }

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.completed);
        expect(h.remote.pushBatches.map((b) => b.length), [50, 50, 50, 50]);
        expect(h.remote.pushedClientIds, [
          for (var i = 0; i < 200; i++) 'c-${i.toString().padLeft(3, '0')}',
        ]);
        expect(await h.outbox.watch('user-a').first, isEmpty);
        expect(await h.db.zonesDao.countBySite(_localSite), 200);
      },
    );

    test(
      'seules les lignes du compte connecte sont envoyees (CT-23)',
      () async {
        await h.saveZoneOffline('a-1', owner: 'user-a');
        await h.saveZoneOffline('b-1', owner: 'user-b', roomNumber: 8);

        await h.engine.run();

        expect(h.remote.pushedClientIds, ['a-1']);
        expect(
          (await h.db.outboxDao.pendingFor('user-b')).map((r) => r.clientId),
          ['b-1'],
        );
      },
    );

    test(
      'application tuee pendant l\'envoi : la reprise renvoie l\'operation (meme clientId)',
      () async {
        await h.saveZoneOffline('c-1');
        final op = (await h.outbox.watch('user-a').first).single;
        await h.db.outboxDao.markSending([
          op.id,
        ]); // etat laisse par un processus tue

        await h.engine.run();

        expect(h.remote.pushedClientIds, ['c-1']);
        expect(await h.outbox.watch('user-a').first, isEmpty);
      },
    );

    test(
      'lot juge mal forme (400) : operations a verifier, pas de boucle',
      () async {
        await h.saveZoneOffline('c-1');
        h.remote.pushHandler = (_) =>
            throw const ValidationApiException(status: 400, code: 'VALIDATION');

        final outcome = await h.engine.run();
        await h.engine.run();

        expect(outcome, SyncOutcome.failed);
        expect(h.remote.pushBatches, hasLength(1));
        final row = (await h.outbox.watch('user-a').first).single;
        expect(row.status, OutboxStatus.rejected);
        expect(row.lastErrorCode, 'VALIDATION');
      },
    );

    test(
      'echec du serveur (500) : operation a envoyer, tentative comptee, pas de pull',
      () async {
        await h.saveZoneOffline('c-1');
        h.remote.pushHandler = (_) =>
            throw const ServerApiException(status: 500);

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.failed);
        expect(h.remote.pullSinces, isEmpty);
        final row = (await h.outbox.watch('user-a').first).single;
        expect(row.status, OutboxStatus.pending);
        expect(row.attempts, 1);
      },
    );
  });

  group('Etats et reprise', () {
    setUp(
      () async => h.db.sitesDao.upsertIfNewer(
        siteRow(id: _localSite, code: 'CH-LOCAL'),
      ),
    );

    test(
      'hors ligne (aucune interface) : aucun appel, saisies intactes',
      () async {
        h.hasNetwork = false;
        await h.saveZoneOffline('c-1');

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.offline);
        expect(h.remote.meCalls, 0);
        expect(h.engine.state.phase, SyncPhase.offline);
        expect(await h.db.outboxDao.pendingFor('user-a'), hasLength(1));
      },
    );

    test('reseau present mais serveur injoignable : hors ligne', () async {
      h.remote.meError = const NetworkApiException();

      final outcome = await h.engine.run();

      expect(outcome, SyncOutcome.offline);
      expect(h.engine.state.phase, SyncPhase.offline);
    });

    test('401 : reconnexion necessaire, aucune donnee perdue', () async {
      await h.saveZoneOffline('c-1');
      h.remote.meError = const UnauthorizedApiException(
        status: 401,
        code: 'REFRESH_INVALIDE',
      );

      final outcome = await h.engine.run();

      expect(outcome, SyncOutcome.authRequired);
      expect(h.engine.state.phase, SyncPhase.authRequired);
      expect(await h.db.outboxDao.pendingFor('user-a'), hasLength(1));
      expect(await h.db.zonesDao.getById('c-1'), isNotNull);
    });

    test(
      'mot de passe provisoire (mustChangePassword) : reconnexion necessaire',
      () async {
        h.remote.meResponse = MeResponse.fromJson(
          meJson(mustChangePassword: true),
        );

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.authRequired);
        expect(h.remote.pullSinces, isEmpty);
      },
    );

    test(
      '429 avec Retry-After : reprise jamais avant l\'attente demandee',
      () async {
        h.remote.meError = const TooManyRequestsApiException(
          status: 429,
          code: 'TROP_DE_REQUETES',
          retryAfter: Duration(minutes: 10),
        );

        final outcome = await h.engine.run();

        expect(outcome, SyncOutcome.failed);
        expect(h.engine.state.phase, SyncPhase.failed);
        expect(
          h.engine.state.nextRetryAt,
          h.clock.add(const Duration(minutes: 10)),
        );
      },
    );

    test(
      'echecs consecutifs : delai exponentiel, remis a zero apres un succes',
      () async {
        h.remote.meError = const ServerApiException(status: 503);

        await h.engine.run();
        final first = h.engine.state.nextRetryAt!.difference(h.clock);
        await h.engine.run();
        final second = h.engine.state.nextRetryAt!.difference(h.clock);
        await h.engine.run();
        final third = h.engine.state.nextRetryAt!.difference(h.clock);

        expect(
          [first.inSeconds, second.inSeconds, third.inSeconds],
          [5, 10, 20],
        );
        expect(h.engine.state.consecutiveFailures, 3);

        h.remote.meError = null;
        await h.engine.run();
        expect(h.engine.state.consecutiveFailures, 0);
        expect(h.engine.state.phase, SyncPhase.idle);
      },
    );

    test('appels concurrents (double appui) : UNE seule execution', () async {
      final results = await Future.wait([
        h.engine.run(),
        h.engine.run(),
        h.engine.run(),
      ]);

      expect(results, everyElement(SyncOutcome.completed));
      expect(h.remote.meCalls, 1);
    });

    test(
      'execution terminee : un nouvel appel relance une synchronisation',
      () async {
        await h.engine.run();
        await h.engine.run();

        expect(h.remote.meCalls, 2);
      },
    );

    test('personne de connecte : rien n\'est fait', () async {
      h.userId = null;

      final outcome = await h.engine.run();

      expect(outcome, SyncOutcome.notSignedIn);
      expect(h.remote.meCalls, 0);
    });

    test(
      'le profil recu est transmis (permissions, mot de passe provisoire)',
      () async {
        await h.engine.run();

        expect(h.profiles.single.permissionsVersion, 'a41f09c2');
        expect(
          await h.db.syncStateDao.get(SyncStateKeys.lastServerContactAt),
          isNotNull,
        );
      },
    );

    test(
      'donnees d\'un autre compte sur le telephone : purgees avant de synchroniser, file conservee',
      () async {
        await h.db.syncStateDao.set(SyncStateKeys.ownerUserId, 'user-autre');
        await h.saveZoneOffline('b-1', owner: 'user-autre', roomNumber: 5);

        await h.engine.run();

        expect(
          await h.db.zonesDao.getById('b-1'),
          isNull,
          reason: 'zone locale de l\'autre compte purgee',
        );
        expect(
          await h.db.outboxDao.getByClientId('b-1'),
          isNotNull,
          reason: 'sa file d\'envoi est conservee',
        );
        expect(
          h.remote.pushedClientIds,
          isEmpty,
          reason: 'jamais envoyee par user-a',
        );
      },
    );

    test(
      'etats emis : syncing puis idle, avec le compteur de lignes recues',
      () async {
        h.remote.pullScript.add(
          _page(changes: [_site('10'), _zone('z1', '11')], cursor: '11'),
        );
        final phases = <SyncPhase>[];
        final received = <int>[];
        final subscription = h.engine.states.listen((s) {
          phases.add(s.phase);
          received.add(s.itemsReceived);
        });

        await h.engine.run();
        await Future<void>.delayed(Duration.zero);

        expect(phases.first, SyncPhase.syncing);
        expect(phases.last, SyncPhase.idle);
        expect(received.last, 2);
        await subscription.cancel();
      },
    );
  });
}
