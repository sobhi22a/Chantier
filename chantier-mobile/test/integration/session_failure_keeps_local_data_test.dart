import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/storage/token_pair.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http_adapter.dart';
import '../support/fixtures.dart';
import '../support/memory_token_store.dart';
import '../support/test_database.dart';

/// CT-12 : « un refresh echoue ne supprime ni base ni file ».
/// Verifie la couche reseau branchee a une VRAIE base locale (en memoire).
void main() {
  late AppDatabase db;
  late FakeHttpAdapter adapter;
  late MemoryTokenStore store;
  late SessionEvents events;
  late List<SessionEvent> emitted;
  late DioClient client;

  setUp(() async {
    db = createTestDatabase();
    await db.sitesDao.upsertIfNewer(siteRow());
    await db.zonesDao.upsertIfNewer(zoneRow());
    await db.transaction(() async {
      await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1'));
      await db.outboxDao.enqueue(outboxOp(clientId: 'c-1', owner: 'user-a'));
    });

    adapter = FakeHttpAdapter();
    store = MemoryTokenStore(
      const TokenPair(accessToken: 'ACCESS-OLD', refreshToken: 'REFRESH-OLD'),
    );
    events = SessionEvents();
    emitted = [];
    events.stream.listen(emitted.add);
    client = DioClient(
      config: const AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1'),
      tokenStore: store,
      events: events,
      languageCode: () => 'fr',
      adapter: adapter,
    );
    adapter.respond(
      'GET /sync/changes',
      FakeResponse.problem(401, 'NON_AUTHENTIFIE'),
    );
  });

  tearDown(() async {
    await events.dispose();
    await db.close();
  });

  Future<void> expectLocalDataIntact() async {
    expect(await db.sitesDao.getSite('site-uv18'), isNotNull);
    expect(await db.zonesDao.getById('zone-1'), isNotNull);
    expect(await db.zonesDao.getById('c-1'), isNotNull);
    expect((await db.outboxDao.pendingFor('user-a')).map((r) => r.clientId), [
      'c-1',
    ]);
  }

  test('refresh refuse : jetons effaces, base et file intactes', () async {
    adapter.respond(
      'POST /api/v1/auth/refresh',
      FakeResponse.problem(401, 'REFRESH_INVALIDE'),
    );

    await expectLater(
      client.get<dynamic>('/sync/changes'),
      throwsA(isA<UnauthorizedApiException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(store.current, isNull);
    expect(emitted, [SessionEvent.authRequired]);
    await expectLocalDataIntact();
  });

  test(
    'refresh impossible (hors ligne) : jetons, base et file intacts',
    () async {
      adapter.on('POST /api/v1/auth/refresh', (_) => throw connectionError());

      await expectLater(
        client.get<dynamic>('/sync/changes'),
        throwsA(isA<NetworkApiException>()),
      );

      expect(store.current, isNotNull);
      expect(emitted, isEmpty);
      await expectLocalDataIntact();
    },
  );

  test(
    'ACCES_RETIRE : la couche reseau n\'efface que les jetons ; la purge est decidee plus haut',
    () async {
      adapter.respond(
        'POST /api/v1/auth/refresh',
        FakeResponse.problem(401, 'ACCES_RETIRE'),
      );

      await expectLater(
        client.get<dynamic>('/sync/changes'),
        throwsA(isA<UnauthorizedApiException>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [SessionEvent.accessRevoked]);
      // Le consommateur de l'evenement (M6) purge les donnees chantier : la file reste.
      await db.purgeSyncedData();
      expect(await db.sitesDao.getSite('site-uv18'), isNull);
      expect((await db.outboxDao.pendingFor('user-a')).length, 1);
    },
  );
}
