import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fake_sync_remote.dart';
import '../../support/fixtures.dart';
import '../../support/test_database.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

void main() {
  late AppDatabase db;
  late FakeSyncRemote remote;
  late SyncEngine engine;
  late SyncStatusCubit cubit;
  late DateTime clock;
  late bool hasNetwork;

  setUp(() async {
    db = createTestDatabase();
    remote = FakeSyncRemote();
    hasNetwork = true;
    clock = DateTime.utc(2026, 11, 24, 10);
    final monitor = _MockMonitor();
    when(
      () => monitor.hasNetworkInterface(),
    ).thenAnswer((_) async => hasNetwork);
    engine = SyncEngine(
      database: db,
      remote: remote,
      sites: SitesRepository(db),
      materials: MaterialsRepository(
        database: db,
        outbox: OutboxRepository(db),
      ),
      currentUserId: () => 'user-a',
      connectivity: monitor,
      backoff: Backoff(),
      now: () => clock,
    );
    cubit = SyncStatusCubit(
      engine: engine,
      database: db,
      userId: 'user-a',
      now: () => clock,
    );
    await db.sitesDao.upsertIfNewer(siteRow());
  });

  tearDown(() async {
    await cubit.close();
    await engine.dispose();
    await db.close();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 20));

  test(
    'indicateur calcule : priorite en cours > reconnexion > probleme > hors ligne > attente > a jour',
    () {
      SyncIndicator of(SyncPhase p, {int toSend = 0, int toCheck = 0}) =>
          deriveIndicator(phase: p, toSend: toSend, toCheck: toCheck);

      expect(of(SyncPhase.idle), SyncIndicator.upToDate);
      expect(of(SyncPhase.idle, toSend: 3), SyncIndicator.pending);
      expect(of(SyncPhase.offline, toSend: 3), SyncIndicator.offline);
      expect(of(SyncPhase.idle, toCheck: 1), SyncIndicator.problem);
      expect(of(SyncPhase.offline, toCheck: 1), SyncIndicator.problem);
      expect(of(SyncPhase.failed), SyncIndicator.problem);
      expect(of(SyncPhase.authRequired, toSend: 2), SyncIndicator.authRequired);
      expect(
        of(SyncPhase.syncing, toSend: 2, toCheck: 1),
        SyncIndicator.syncing,
      );
    },
  );

  test(
    '3 zones creees hors ligne : « 3 a envoyer » exact (CA-013.2)',
    () async {
      for (var i = 0; i < 3; i++) {
        await db.outboxDao.enqueue(outboxOp(clientId: 'c-$i'));
      }
      await settle();

      expect(cubit.state.indicator, SyncIndicator.pending);
      expect(cubit.state.toSend, 3);
      expect(cubit.state.toCheck, 0);
    },
  );

  test(
    'apres l\'envoi reussi : « A jour » avec l\'heure de la derniere synchro',
    () async {
      await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
      await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1'));

      final outcome = await cubit.syncNow();
      await settle();

      expect(outcome, SyncOutcome.completed);
      expect(cubit.state.indicator, SyncIndicator.upToDate);
      expect(cubit.state.toSend, 0);
      expect(cubit.state.lastSuccessAt, clock);
      expect(cubit.state.initialSyncDone, isTrue);
    },
  );

  test('hors ligne : indicateur « Hors ligne » et compteur conserve', () async {
    hasNetwork = false;
    await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));

    await cubit.syncNow();
    await settle();

    expect(cubit.state.indicator, SyncIndicator.offline);
    expect(cubit.state.toSend, 1);
  });

  test(
    'operations refusees : « Probleme » avec le nombre a verifier',
    () async {
      await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
      await db.outboxDao.enqueue(outboxOp(clientId: 'c-2'));
      final rows = await db.outboxDao.pendingFor('user-a');
      await db.outboxDao.markFailed(
        rows[0].id,
        status: OutboxStatus.rejected,
        errorCode: 'INTERDIT',
      );
      await db.outboxDao.markFailed(
        rows[1].id,
        status: OutboxStatus.conflict,
        errorCode: 'CONFLIT_VERSION',
      );
      await settle();

      expect(cubit.state.indicator, SyncIndicator.problem);
      expect(cubit.state.toCheck, 2);
      expect(cubit.state.toSend, 0);
    },
  );

  test(
    'ne compte que les saisies de l\'utilisateur connecte (CA-013.9)',
    () async {
      await db.outboxDao.enqueue(outboxOp(clientId: 'a-1', owner: 'user-a'));
      await db.outboxDao.enqueue(outboxOp(clientId: 'b-1', owner: 'user-b'));
      await db.outboxDao.enqueue(outboxOp(clientId: 'b-2', owner: 'user-b'));
      await settle();

      expect(cubit.state.toSend, 1);
    },
  );

  test(
    'reconnexion necessaire (401) : etat dedie, saisies conservees',
    () async {
      await db.outboxDao.enqueue(outboxOp(clientId: 'c-1'));
      remote.meError = const UnauthorizedApiException(
        status: 401,
        code: 'REFRESH_INVALIDE',
      );

      await cubit.syncNow();
      await settle();

      expect(cubit.state.indicator, SyncIndicator.authRequired);
      expect(cubit.state.toSend, 1);
    },
  );

  test(
    'plus de 24 h sans synchro : donnees anciennes (bandeau, H-12)',
    () async {
      await db.syncStateDao.set(
        SyncStateKeys.lastSuccessAt,
        DateTime.utc(2026, 11, 23, 9).toIso8601String(),
      );
      await settle();

      expect(cubit.state.isStale, isTrue);
      expect(cubit.state.lastSuccessAt, DateTime.utc(2026, 11, 23, 9));
    },
  );

  test('moins de 24 h : pas de bandeau', () async {
    await db.syncStateDao.set(
      SyncStateKeys.lastSuccessAt,
      DateTime.utc(2026, 11, 24, 8).toIso8601String(),
    );
    await settle();

    expect(cubit.state.isStale, isFalse);
  });

  test(
    'double appui sur « Synchroniser maintenant » : une seule synchronisation (CA-013.5)',
    () async {
      final results = await Future.wait([cubit.syncNow(), cubit.syncNow()]);

      expect(results, everyElement(SyncOutcome.completed));
      expect(remote.meCalls, 1);
    },
  );

  test(
    'preparation initiale : pas terminee tant que la premiere synchro n\'a pas abouti',
    () async {
      await settle();

      expect(cubit.state.initialSyncDone, isFalse);
      expect(cubit.state.isPreparing, isTrue);
    },
  );
}
