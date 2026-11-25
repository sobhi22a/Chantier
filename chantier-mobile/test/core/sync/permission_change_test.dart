import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/api_json.dart';
import '../../support/fake_sync_remote.dart';
import '../../support/fixtures.dart';
import '../../support/test_database.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

const _siteId = '0192a000-0000-7000-8000-0000000000a1';

/// R1-03 / CT-20 : le montant du marche ne survit jamais a un retrait de permission, y compris
/// quand la ligne n'a pas change cote serveur (meme version).
void main() {
  late AppDatabase db;
  late FakeSyncRemote remote;
  late SyncEngine engine;

  setUp(() {
    db = createTestDatabase();
    remote = FakeSyncRemote();
    final monitor = _MockMonitor();
    when(monitor.hasNetworkInterface).thenAnswer((_) async => true);
    engine = SyncEngine(
      database: db,
      remote: remote,
      sites: SitesRepository(db),
      currentUserId: () => 'user-a',
      connectivity: monitor,
      backoff: Backoff(),
      now: () => DateTime.utc(2026, 11, 24, 10),
    );
  });
  tearDown(() async {
    await engine.dispose();
    await db.close();
  });

  /// Chantier `version` tel que le serveur l'envoie, avec ou sans montant.
  SyncPullResponse page({
    bool withAmount = false,
    String version = '10',
    String cursor = '10',
    bool hasMore = false,
    List<Map<String, Object?>> more = const [],
  }) => pullPage(
    syncPullJson(
      changes: [
        syncChangeJson(
          'site',
          siteJson(
            contractAmount: withAmount ? 185000000 : null,
            version: version,
          ),
          version: version,
        ),
        ...more,
      ],
      cursor: cursor,
      hasMore: hasMore,
    ),
  );

  Future<Decimal?> storedAmount() async =>
      (await db.sitesDao.getSite(_siteId))?.contractAmount;

  /// Telephone deja synchronise avec la permission : montant en base, version de permissions `v1`.
  Future<void> syncedWithAmount() async {
    remote.meResponse = MeResponse.fromJson(meJson(permissionsVersion: 'v1'));
    remote.pullScript.add(page(withAmount: true));
    await engine.run();
    expect(await storedAmount(), Decimal.parse('185000000.00'));
  }

  test(
    'montant efface apres retrait de permission (meme version de chantier)',
    () async {
      await syncedWithAmount();

      // La permission est retiree : permissionsVersion change, le chantier, lui, n'a pas bouge
      // (version 10) et revient sans montant.
      remote.meResponse = MeResponse.fromJson(meJson(permissionsVersion: 'v2'));
      remote.pullScript.add(page());
      final outcome = await engine.run();

      expect(outcome, SyncOutcome.completed);
      expect(remote.pullSinces.last, isNull, reason: 'rechargement complet');
      expect(await storedAmount(), isNull);
      final site = (await db.sitesDao.getSite(_siteId))!;
      expect(
        site.version,
        10,
        reason: 'version inchangee : seul le champ reserve a disparu',
      );
      expect(site.name, 'École UV18');
    },
  );

  test(
    'montant efface IMMEDIATEMENT, meme si le rechargement echoue (hors ligne)',
    () async {
      await syncedWithAmount();

      remote.meResponse = MeResponse.fromJson(meJson(permissionsVersion: 'v2'));
      remote.pullScript.add(const NetworkApiException());
      final outcome = await engine.run();

      expect(outcome, SyncOutcome.offline);
      expect(
        await storedAmount(),
        isNull,
        reason: 'jamais lisible apres la perte du droit',
      );
    },
  );

  test(
    'rechargement interrompu : repris plus tard, le drapeau survit a l\'interruption',
    () async {
      await syncedWithAmount();
      remote.meResponse = MeResponse.fromJson(meJson(permissionsVersion: 'v2'));
      remote.pullScript.add(const NetworkApiException());
      await engine.run();

      expect(await db.syncStateDao.get(SyncStateKeys.fullReload), 'true');
      expect(await db.syncStateDao.get(SyncStateKeys.cursor), isNull);

      remote.pullScript.add(page());
      await engine.run();

      expect(
        await db.syncStateDao.get(SyncStateKeys.fullReload),
        isNull,
        reason: 'termine',
      );
      expect(await storedAmount(), isNull);
    },
  );

  test(
    'permission ACCORDEE : le montant apparait malgre la meme version du chantier',
    () async {
      remote.meResponse = MeResponse.fromJson(meJson(permissionsVersion: 'v1'));
      remote.pullScript.add(page());
      await engine.run();
      expect(await storedAmount(), isNull);

      remote.meResponse = MeResponse.fromJson(meJson(permissionsVersion: 'v2'));
      remote.pullScript.add(page(withAmount: true));
      await engine.run();

      expect(await storedAmount(), Decimal.parse('185000000.00'));
    },
  );

  test(
    'permission conservee mais permissionsVersion modifiee : le montant revient apres le rechargement',
    () async {
      await syncedWithAmount();

      remote.meResponse = MeResponse.fromJson(meJson(permissionsVersion: 'v2'));
      remote.pullScript.add(page(withAmount: true));
      await engine.run();

      expect(await storedAmount(), Decimal.parse('185000000.00'));
    },
  );

  test(
    'rechargement sur plusieurs pages : toutes les pages ecrasent, le drapeau tombe a la derniere',
    () async {
      await syncedWithAmount();
      await db.siteMembersDao.upsertIfNewer(
        memberRow(id: 'm1', siteId: _siteId, version: 12),
      );
      remote.meResponse = MeResponse.fromJson(meJson(permissionsVersion: 'v2'));
      remote.pullScript.addAll([
        page(cursor: '10', hasMore: true),
        pullPage(
          syncPullJson(
            changes: [
              syncChangeJson(
                'member',
                memberJson(id: 'm1', siteId: _siteId, fullName: 'Nom corrige'),
                version: '12',
              ),
            ],
            cursor: '12',
          ),
        ),
      ]);

      await engine.run();

      expect(await db.syncStateDao.get(SyncStateKeys.fullReload), isNull);
      expect(
        (await db.siteMembersDao.getById('m1'))!.fullName,
        'Nom corrige',
        reason: 'meme version : ecrasee pendant le rechargement',
      );
    },
  );

  test(
    'sans changement de permissions : une ligne de meme version reste ignoree (idempotence)',
    () async {
      await syncedWithAmount();
      final before = await db.sitesDao.getSite(_siteId);

      remote.pullScript.add(
        pullPage(
          syncPullJson(
            changes: [
              syncChangeJson(
                'site',
                siteJson(name: 'Autre nom', version: '10'),
                version: '10',
              ),
            ],
            cursor: '11',
          ),
        ),
      );
      await engine.run();

      expect(await db.sitesDao.getSite(_siteId), before);
      expect(await db.syncStateDao.get(SyncStateKeys.fullReload), isNull);
    },
  );

  test(
    'une version plus ancienne n\'ecrase jamais, meme pendant un rechargement',
    () async {
      await syncedWithAmount();
      await db.syncStateDao.set(SyncStateKeys.fullReload, 'true');

      remote.pullScript.add(
        pullPage(
          syncPullJson(
            changes: [
              syncChangeJson(
                'site',
                siteJson(name: 'Ancien', version: '9'),
                version: '9',
              ),
            ],
            cursor: '11',
          ),
        ),
      );
      await engine.run();

      expect((await db.sitesDao.getSite(_siteId))!.name, 'École UV18');
    },
  );

  test('CURSEUR_INVALIDE : rechargement complet aussi (meme ecrasement)', () async {
    await syncedWithAmount();
    remote.pullScript.addAll([
      const ValidationApiException(status: 400, code: 'CURSEUR_INVALIDE'),
      page(),
    ]);
    // Une page sans montant revient pour la meme version : le curseur invalide ne change pas les
    // permissions, mais le rechargement ecrase quand meme (le serveur fait foi).
    await engine.run();

    expect(await storedAmount(), isNull);
    expect(await db.syncStateDao.get(SyncStateKeys.fullReload), isNull);
  });

  test(
    'la file d\'envoi n\'est jamais touchee par le changement de permissions',
    () async {
      await syncedWithAmount();
      await db.zonesDao.insertPending(
        pendingZoneRow(clientId: 'c-1', siteId: _siteId),
      );
      await db.outboxDao.enqueue(
        outboxOp(clientId: 'c-1', owner: 'user-a', siteId: _siteId),
      );
      remote.meResponse = MeResponse.fromJson(meJson(permissionsVersion: 'v2'));
      remote.pushHandler = (ops) => SyncPushResponse(
        results: [
          SyncPushResult(
            clientId: ops.first.clientId,
            status: 'rejected',
            code: 'INTERDIT',
          ),
        ],
      );
      remote.pullScript.add(page());

      await engine.run();

      expect(await db.outboxDao.getByClientId('c-1'), isNotNull);
    },
  );

  group('DAO', () {
    test('clearRestrictedFields : efface le montant, rien d\'autre', () async {
      await db.sitesDao.upsertIfNewer(
        siteRow(contractAmount: Decimal.parse('185000000.00')),
      );

      final changed = await db.sitesDao.clearRestrictedFields();

      final row = (await db.sitesDao.getSite('site-uv18'))!;
      expect(changed, 1);
      expect(row.contractAmount, isNull);
      expect(row.name, 'École UV18');
      expect(row.code, 'CH-ECO-UV18');
      expect(row.version, 100);
    });

    test(
      'overwrite : meme version ecrite, version plus ancienne refusee',
      () async {
        await db.sitesDao.upsertIfNewer(
          siteRow(contractAmount: Decimal.parse('1.00')),
        );

        expect(await db.sitesDao.upsertIfNewer(siteRow()), isFalse);
        expect(
          await db.sitesDao.upsertIfNewer(siteRow(), overwrite: true),
          isTrue,
        );
        expect(
          await db.sitesDao.upsertIfNewer(
            siteRow(version: 99),
            overwrite: true,
          ),
          isFalse,
        );
        expect(
          (await db.sitesDao.getSite('site-uv18'))!.contractAmount,
          isNull,
        );
      },
    );

    test('zones : overwrite ecrase une ligne de meme version', () async {
      await db.sitesDao.upsertIfNewer(siteRow());
      await db.zonesDao.upsertIfNewer(zoneRow(version: 200));

      expect(
        await db.zonesDao.upsertIfNewer(
          zoneRow(version: 200, block: 'Bloc 09'),
        ),
        isFalse,
      );
      expect(
        await db.zonesDao.upsertIfNewer(
          zoneRow(version: 200, block: 'Bloc 09'),
          overwrite: true,
        ),
        isTrue,
      );
      expect((await db.zonesDao.getById('zone-1'))!.block, 'Bloc 09');
    });

    test(
      'startFullReload : efface le montant seulement si demande, pose le drapeau, garde la file',
      () async {
        await db.sitesDao.upsertIfNewer(
          siteRow(contractAmount: Decimal.parse('1.00')),
        );
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
        await db.syncStateDao.set(SyncStateKeys.cursor, '42');

        await db.startFullReload();
        expect(
          (await db.sitesDao.getSite('site-uv18'))!.contractAmount,
          isNotNull,
        );
        expect(await db.syncStateDao.get(SyncStateKeys.cursor), isNull);
        expect(await db.syncStateDao.get(SyncStateKeys.fullReload), 'true');

        await db.startFullReload(clearRestrictedFields: true);
        expect(
          (await db.sitesDao.getSite('site-uv18'))!.contractAmount,
          isNull,
        );
        expect(await db.outboxDao.getByClientId('c-1'), isNotNull);
      },
    );
  });
}
