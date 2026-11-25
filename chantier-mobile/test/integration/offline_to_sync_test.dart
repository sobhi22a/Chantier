import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_json.dart';
import '../support/fake_sync_remote.dart';
import '../support/test_database.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

const _siteId = '0192a000-0000-7000-8000-0000000000a1';
const _user = 'user-a';

/// Scenarios de bout en bout, **sans reseau reel** : vraie base locale, vrai moteur, vrai depot de
/// zones ; seul le serveur est simule (idempotent par `clientId`).
///   * creation hors ligne, puis retour du reseau : element synchronise UNE seule fois ;
///   * application tuee pendant l'envoi : reprise sans doublon.
/// (Les photos, envoyees par une file separee, arrivent avec leur fonctionnalite : lot suivant.)
void main() {
  late AppDatabase db;
  late FakeSyncRemote server;
  late _MockMonitor monitor;
  late bool online;
  late SyncEngine engine;
  late ZonesRepository zones;
  late OutboxRepository outbox;
  SyncStatusCubit? status;

  SyncEngine newEngine() => SyncEngine(
    database: db,
    remote: server,
    sites: SitesRepository(db),
    currentUserId: () => _user,
    connectivity: monitor,
    backoff: Backoff(),
    now: () => DateTime.utc(2026, 11, 24, 10),
  );

  NewZone zone(String clientId, int number) => NewZone(
    clientId: clientId,
    siteId: _siteId,
    userId: _user,
    block: 'Bloc 01',
    elevation: Decimal.parse('3.40'),
    roomType: 'Classroom',
    roomNumber: number,
    label: 'Bloc 01 · +3,40 m · Classe ${number.toString().padLeft(2, '0')}',
  );

  setUp(() async {
    db = createTestDatabase();
    server = FakeSyncRemote();
    monitor = _MockMonitor();
    online = true;
    when(() => monitor.hasNetworkInterface()).thenAnswer((_) async => online);
    engine = newEngine();
    outbox = OutboxRepository(db);
    zones = ZonesRepository(database: db, outbox: outbox);

    // Premiere synchronisation, en ligne : le chantier arrive sur le telephone.
    server.pullScript.add(
      pullPage(
        syncPullJson(
          changes: [
            syncChangeJson('site', siteJson(version: '10'), version: '10'),
          ],
          cursor: '10',
        ),
      ),
    );
    await engine.run();
    expect(await db.sitesDao.getSite(_siteId), isNotNull);
  });

  tearDown(() async {
    await status?.close();
    await engine.dispose();
    await db.close();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test(
    'creation hors ligne puis retour du reseau : chaque zone existe UNE seule fois cote serveur (CT-21)',
    () async {
      online = false;
      status = SyncStatusCubit(
        engine: engine,
        database: db,
        userId: _user,
        now: () => DateTime.utc(2026, 11, 24, 10),
      );

      // Mode avion : trois zones saisies, aucune erreur, aucune attente reseau.
      for (var i = 1; i <= 3; i++) {
        expect(await zones.save(zone('c-$i', i)), isA<ZoneSaved>());
      }
      expect(await engine.run(), SyncOutcome.offline);
      await settle();

      expect(status!.state.indicator, SyncIndicator.offline);
      expect(
        status!.state.toSend,
        3,
        reason: '« 3 a envoyer » exact (CA-013.2)',
      );
      expect(
        (await db.zonesDao.watchBySite(_siteId).first).where(
          (z) => z.isPending,
        ),
        hasLength(3),
      );
      expect(server.createdZoneCount, 0);

      // Le reseau revient.
      online = true;
      expect(await engine.run(), SyncOutcome.completed);
      await settle();

      expect(server.createdZoneCount, 3);
      expect(status!.state.indicator, SyncIndicator.upToDate);
      expect(status!.state.toSend, 0);
      final local = await db.zonesDao.watchBySite(_siteId).first;
      expect(local, hasLength(3), reason: 'aucun doublon local');
      expect(
        local.where((z) => z.isPending),
        isEmpty,
        reason: 'toutes confirmees par le serveur',
      );

      // Une synchronisation de plus ne renvoie rien et ne cree rien.
      await engine.run();
      expect(server.createdZoneCount, 3);
      expect(server.pushedClientIds, ['c-1', 'c-2', 'c-3']);
    },
  );

  test(
    'application tuee pendant l\'envoi : reprise sans doublon (meme clientId)',
    () async {
      expect(await zones.save(zone('c-1', 1)), isA<ZoneSaved>());

      // Le serveur recoit et applique le lot, mais la reponse n'arrive jamais (processus tue).
      server.loseNextPushResponse = true;
      expect(await engine.run(), SyncOutcome.offline);
      expect(
        server.createdZoneCount,
        1,
        reason: 'le serveur a bien recu l\'envoi',
      );
      var op = (await outbox.watch(_user).first).single;
      expect(op.attempts, 1);

      // Nouveau processus : meme base, nouveau moteur, l'operation est restee `sending`.
      await db.outboxDao.markSending([op.id]);
      final restarted = newEngine();
      addTearDown(restarted.dispose);
      expect(await restarted.run(), SyncOutcome.completed);

      expect(
        server.createdZoneCount,
        1,
        reason: 'toujours une seule zone cote serveur',
      );
      expect(await outbox.watch(_user).first, isEmpty);
      final local = await db.zonesDao.watchBySite(_siteId).first;
      expect(local, hasLength(1));
      expect(local.single.isPending, isFalse);
      expect(server.pushedClientIds, [
        'c-1',
        'c-1',
      ], reason: 'renvoi avec le meme identifiant');
    },
  );

  test(
    'reseau instable : plusieurs coupures, une seule zone au final',
    () async {
      expect(await zones.save(zone('c-1', 1)), isA<ZoneSaved>());

      online = false;
      expect(await engine.run(), SyncOutcome.offline);
      online = true;
      server.meError = const TimeoutApiException();
      expect(await engine.run(), SyncOutcome.offline);
      server.meError = null;
      expect(await engine.run(), SyncOutcome.completed);
      expect(await engine.run(), SyncOutcome.completed);

      expect(server.createdZoneCount, 1);
      expect(await db.zonesDao.countBySite(_siteId), 1);
    },
  );
}
