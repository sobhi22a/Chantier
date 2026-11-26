// Q1 : CA-017.1 / CT-14 cote mobile. Parcours complet (connexion refusee, connexion, synchronisation avec noms
// de personnes et ligne illisible, envoi d'une zone, deconnexion, second compte, session expiree) avec TOUS les
// journaux captures : aucun identifiant, nom, telephone, mot de passe ni jeton ne doit y figurer.
import 'package:chantier_mobile/core/api/api_clients.dart';
import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/api_json.dart';
import '../support/fake_http_adapter.dart';
import '../support/fake_sync_remote.dart';
import '../support/memory_token_store.dart';
import '../support/test_database.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

const _siteId = '0192a000-0000-7000-8000-0000000000a1';
const _userA = '0192a000-0000-7000-8000-00000000000a';
const _userB = '0192a000-0000-7000-8000-00000000000b';
const _password = 'MotDePasse-Secret-QA-1';
const _config = AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1');

void main() {
  test(
    'un parcours complet ne laisse ni nom, ni identifiant, ni telephone, ni mot de passe, ni jeton dans les journaux',
    () async {
      final records = <LogRecord>[];
      final previousLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      final subscription = Logger.root.onRecord.listen(records.add);
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = previousLevel;
      });

      final db = createTestDatabase();
      final adapter = FakeHttpAdapter();
      final store = MemoryTokenStore();
      final events = SessionEvents();
      addTearDown(() async {
        await events.dispose();
        await db.close();
      });
      final dioClient = DioClient(
        config: _config,
        tokenStore: store,
        events: events,
        languageCode: () => 'fr',
        adapter: adapter,
      );
      final api = ApiClients(config: _config, dioClient: dioClient);
      var clock = DateTime.utc(2026, 11, 24, 10);
      SharedPreferences.setMockInitialValues({});
      final repository = AuthRepositoryImpl(
        api: api,
        tokenStore: store,
        database: db,
        preferences: await SharedPreferences.getInstance(),
        config: _config,
        now: () => clock,
        logoutTimeout: const Duration(seconds: 5),
      );

      void serverFor(String id, String userName, String fullName) => adapter
        ..respond(
          'POST /api/v1/auth/login',
          FakeResponse.ok({
            ...authResultJson(),
            'user': userJson(id: id, userName: userName, fullName: fullName),
          }),
        )
        ..respond(
          'GET /api/v1/auth/me',
          FakeResponse.ok(
            meJson(id: id, userName: userName, fullName: fullName),
          ),
        )
        ..respond('POST /api/v1/auth/logout', const FakeResponse(204));

      // 1. Connexion refusee (mauvais mot de passe).
      adapter.respond(
        'POST /api/v1/auth/login',
        FakeResponse.problem(401, 'IDENTIFIANTS_INVALIDES'),
      );
      await repository
          .login(userName: 'chef.dev', password: _password)
          .then<void>((_) {}, onError: (Object _) {});

      // 2. Connexion reussie, puis synchronisation : noms de personnes, ligne illisible, zone saisie hors ligne.
      serverFor(_userA, 'chef.dev', 'Mourad B.');
      await repository.login(userName: 'chef.dev', password: _password);

      final monitor = _MockMonitor();
      when(() => monitor.hasNetworkInterface()).thenAnswer((_) async => true);
      final server = FakeSyncRemote()
        ..pullScript.add(
          pullPage(
            syncPullJson(
              changes: [
                syncChangeJson('site', siteJson(version: '10'), version: '10'),
                syncChangeJson(
                  'member',
                  memberJson(fullName: 'Toufik G.'),
                  version: '11',
                ),
                syncChangeJson(
                  'member',
                  memberJson(
                    id: '0192a000-0000-7000-8000-0000000000c2',
                    fullName: 'Slimane H.',
                  ),
                  version: '12',
                ),
              ],
              cursor: '12',
            ),
          ),
        );
      final engine = SyncEngine(
        database: db,
        remote: server,
        sites: SitesRepository(db),
        materials: MaterialsRepository(
          database: db,
          outbox: OutboxRepository(db),
        ),
        currentUserId: () => _userA,
        connectivity: monitor,
        backoff: Backoff(),
        now: () => clock,
      );
      addTearDown(engine.dispose);
      await engine.run(); // premiere synchronisation : le chantier arrive
      final zones = ZonesRepository(database: db, outbox: OutboxRepository(db));
      await zones.save(
        NewZone(
          clientId: 'c-1',
          siteId: _siteId,
          userId: _userA,
          block: 'Bloc 01',
          elevation: Decimal.parse('3.40'),
          roomType: 'Classroom',
          roomNumber: 1,
          label: 'Bloc 01 · +3,40 m · Classe 01',
        ),
      );
      await engine.run();
      // Deuxieme passage : une ligne illisible (avertissement journalise) puis un passage normal.
      server.pullScript.add(
        pullPage(
          syncPullJson(
            changes: [
              syncChangeJson('zone', {
                'id': '0192a000-0000-7000-8000-0000000000d9',
                'siteId': _siteId,
              }, version: '13'),
            ],
            cursor: '13',
          ),
        ),
      );
      await engine.run();
      await engine.run();

      // 3. Deconnexion, second compte, session expiree.
      await repository.logout();
      serverFor(_userB, 'equipe.dev', 'Toufik G.');
      await repository.login(userName: 'equipe.dev', password: _password);
      clock = clock.add(const Duration(days: 20));
      final reopened = AuthRepositoryImpl(
        api: api,
        tokenStore: store,
        database: db,
        preferences: await SharedPreferences.getInstance(),
        config: _config,
        now: () => clock,
        logoutTimeout: const Duration(seconds: 5),
      );
      await reopened.restoreSession();

      final text = records
          .map(
            (r) =>
                '${r.loggerName} ${r.message} ${r.error ?? ''} ${r.stackTrace ?? ''}',
          )
          .join('\n');
      expect(
        records,
        isNotEmpty,
        reason: 'le parcours journalise bien quelque chose',
      );
      expect(
        text,
        contains('illisible'),
        reason: 'le chemin d erreur du moteur a bien journalise',
      );
      for (final secret in [
        'chef.dev',
        'equipe.dev',
        'Mourad',
        'Toufik',
        'Slimane',
        'Farid',
        '0550 00 00',
        _password,
        'ACCESS-',
        'REFRESH-',
        'Bearer',
      ]) {
        expect(text, isNot(contains(secret)), reason: 'journal : « $secret »');
      }
    },
  );
}
