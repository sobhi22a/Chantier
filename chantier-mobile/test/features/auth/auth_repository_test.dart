import 'dart:async';
import 'dart:convert';

import 'package:chantier_mobile/core/api/api_clients.dart';
import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/storage/token_pair.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/api_json.dart';
import '../../support/fake_http_adapter.dart';
import '../../support/fixtures.dart';
import '../../support/memory_token_store.dart';
import '../../support/test_database.dart';

const _userA = '0192a000-0000-7000-8000-00000000000a';
const _userB = '0192a000-0000-7000-8000-00000000000b';

class _Harness {
  _Harness() : clock = DateTime.utc(2026, 11, 24, 10) {
    db = createTestDatabase();
    store = MemoryTokenStore();
    events = SessionEvents();
    const config = AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1');
    final dioClient = DioClient(
      config: config,
      tokenStore: store,
      events: events,
      languageCode: () => 'fr',
      adapter: adapter,
    );
    api = ApiClients(config: config, dioClient: dioClient);
  }

  final DateTime clock;
  final adapter = FakeHttpAdapter();
  late final AppDatabase db;
  late final MemoryTokenStore store;
  late final SessionEvents events;
  late final ApiClients api;

  /// [now] : horloge du telephone a l'ouverture (meme base, memes jetons : application rouverte).
  Future<AuthRepositoryImpl> repository({
    Map<String, Object> prefs = const {},
    Duration logoutTimeout = const Duration(seconds: 5),
    DateTime? now,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    return AuthRepositoryImpl(
      api: api,
      tokenStore: store,
      database: db,
      preferences: await SharedPreferences.getInstance(),
      config: const AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1'),
      now: () => now ?? clock,
      logoutTimeout: logoutTimeout,
    );
  }

  /// Serveur : connexion de [userId] puis `me`.
  void serverFor(
    String userId, {
    String userName = 'chef.dev',
    bool mustChange = false,
    String permissionsVersion = 'v1',
  }) {
    adapter
      ..respond(
        'POST /api/v1/auth/login',
        FakeResponse.ok({
          ...authResultJson(mustChangePassword: mustChange),
          'user': userJson(
            id: userId,
            userName: userName,
            mustChangePassword: mustChange,
          ),
        }),
      )
      ..respond(
        'GET /api/v1/auth/me',
        FakeResponse.ok(
          meJson(
            id: userId,
            userName: userName,
            mustChangePassword: mustChange,
            permissionsVersion: permissionsVersion,
          ),
        ),
      )
      ..respond('POST /api/v1/auth/logout', const FakeResponse(204))
      ..respond('PUT /api/v1/auth/me/language', const FakeResponse(204));
  }

  Future<void> dispose() async {
    await events.dispose();
    await db.close();
  }
}

void main() {
  late _Harness h;

  setUp(() => h = _Harness());
  tearDown(() => h.dispose());

  group('Connexion', () {
    test(
      'succes : jetons, profil et dernier identifiant enregistres',
      () async {
        h.serverFor(_userA);
        final repository = await h.repository();

        final user = await repository.login(
          userName: 'chef.dev',
          password: 'secret',
        );

        expect(user.id, _userA);
        expect(user.can('Zones.Create'), isTrue);
        expect(
          h.store.current,
          const TokenPair(
            accessToken: 'ACCESS-NEW-SECRET',
            refreshToken: 'REFRESH-NEW-SECRET',
          ),
        );
        expect(
          repository.lastUserName,
          'chef.dev',
          reason: 'prerempli a la prochaine ouverture (CA-001.2)',
        );
        expect(repository.currentUser, user);
        expect(await h.db.syncStateDao.get(SyncStateKeys.profile), isNotNull);
        expect(
          await h.db.syncStateDao.get(SyncStateKeys.lastServerContactAt),
          h.clock.toIso8601String(),
        );
        expect(
          await h.db.syncStateDao.get(SyncStateKeys.permissionsVersion),
          'v1',
        );
      },
    );

    test('demande mobile anonyme : isAppMobile vrai, sans Bearer', () async {
      h.serverFor(_userA);
      final repository = await h.repository();

      await repository.login(userName: 'chef.dev', password: 'secret');

      final call = h.adapter.callsTo('POST /api/v1/auth/login').single;
      expect(call.header('Authorization'), isNull);
      expect(jsonDecode(jsonEncode(call.body)), {
        'userName': 'chef.dev',
        'password': 'secret',
        'isAppMobile': true,
      });
    });

    test(
      'le profil enregistre ne contient ni telephone ni jeton ni mot de passe (CA-017.4)',
      () async {
        h.serverFor(_userA);
        final repository = await h.repository();

        await repository.login(
          userName: 'chef.dev',
          password: 'MotDePasse-Secret',
        );

        final stored = (await h.db.syncStateDao.get(SyncStateKeys.profile))!;
        expect(stored, isNot(contains('0550')));
        expect(stored, isNot(contains('phone')));
        expect(stored, isNot(contains('MotDePasse-Secret')));
        expect(stored, isNot(contains('SECRET')));
      },
    );

    test(
      'identifiants invalides : 401 IDENTIFIANTS_INVALIDES, rien d\'enregistre',
      () async {
        h.adapter.respond(
          'POST /api/v1/auth/login',
          FakeResponse.problem(401, 'IDENTIFIANTS_INVALIDES'),
        );
        final repository = await h.repository();

        await expectLater(
          repository.login(userName: 'x', password: 'y'),
          throwsA(
            isA<UnauthorizedApiException>().having(
              (e) => e.code,
              'code',
              'IDENTIFIANTS_INVALIDES',
            ),
          ),
        );

        expect(h.store.current, isNull);
        expect(repository.currentUser, isNull);
        expect(repository.lastUserName, isNull);
      },
    );

    test(
      'premiere connexion hors ligne : erreur reseau, aucune session',
      () async {
        h.adapter.on('POST /api/v1/auth/login', (_) => throw connectionError());
        final repository = await h.repository();

        await expectLater(
          repository.login(userName: 'chef.dev', password: 'x'),
          throwsA(isA<NetworkApiException>()),
        );

        expect(h.store.current, isNull);
      },
    );

    test(
      'profil impossible a lire apres la connexion : jetons effaces',
      () async {
        h.serverFor(_userA);
        h.adapter.on('GET /api/v1/auth/me', (_) => throw connectionError());
        final repository = await h.repository();

        await expectLater(
          repository.login(userName: 'chef.dev', password: 'x'),
          throwsA(isA<NetworkApiException>()),
        );

        expect(h.store.current, isNull);
        expect(repository.currentUser, isNull);
      },
    );

    test('mot de passe provisoire : le profil le dit', () async {
      h.serverFor(_userA, mustChange: true);
      final repository = await h.repository();

      final user = await repository.login(
        userName: 'chef.dev',
        password: 'provisoire',
      );

      expect(user.mustChangePassword, isTrue);
    });
  });

  group('Session hors ligne (CA-002.1, CA-002.2)', () {
    Future<AuthRepositoryImpl> signedInRepository() async {
      h.serverFor(_userA);
      final repository = await h.repository();
      await repository.login(userName: 'chef.dev', password: 'x');
      return repository;
    }

    test(
      'moins de 14 jours : ouverte sans reseau, aucun appel serveur',
      () async {
        await signedInRepository();
        h.adapter.requests.clear();
        final reopened = await h.repository(
          now: h.clock.add(const Duration(days: 13)),
        );

        final restored = await reopened.restoreSession();

        expect(restored.user?.id, _userA);
        expect(h.adapter.requests, isEmpty, reason: 'lecture locale seulement');
      },
    );

    test(
      'plus de 14 jours : reconnexion demandee, jetons effaces, saisies CONSERVEES',
      () async {
        await signedInRepository();
        await h.db.outboxDao.enqueue(outboxOp(clientId: 'c-1', owner: _userA));
        final reopened = await h.repository(
          now: h.clock.add(const Duration(days: 15)),
        );

        final restored = await reopened.restoreSession();

        expect(restored.user, isNull);
        expect(restored.ended, SessionEnd.expired);
        expect(h.store.current, isNull);
        expect(await h.db.outboxDao.pendingFor(_userA), hasLength(1));
      },
    );

    test('exactement 14 jours : encore valide', () async {
      await signedInRepository();
      final reopened = await h.repository(
        now: h.clock.add(const Duration(days: 14)),
      );

      expect((await reopened.restoreSession()).user, isNotNull);
    });

    test('rien en memoire : pas de session', () async {
      final repository = await h.repository();

      final restored = await repository.restoreSession();

      expect(restored.user, isNull);
      expect(restored.ended, isNull);
    });

    test('jetons presents mais profil absent : reconnexion', () async {
      await h.store.save(const TokenPair(accessToken: 'a', refreshToken: 'r'));
      final repository = await h.repository();

      expect((await repository.restoreSession()).user, isNull);
    });

    test('profil local illisible : reconnexion, jetons effaces', () async {
      await h.store.save(const TokenPair(accessToken: 'a', refreshToken: 'r'));
      await h.db.syncStateDao.setAll({
        SyncStateKeys.profile: '{pas du json',
        SyncStateKeys.lastServerContactAt: h.clock.toIso8601String(),
      });
      final repository = await h.repository();

      expect((await repository.restoreSession()).user, isNull);
      expect(h.store.current, isNull);
    });

    test(
      'la duree de session est parametrable (OFFLINE_SESSION_DAYS)',
      () async {
        await signedInRepository();
        SharedPreferences.setMockInitialValues({});
        final repository = AuthRepositoryImpl(
          api: h.api,
          tokenStore: h.store,
          database: h.db,
          preferences: await SharedPreferences.getInstance(),
          config: const AppConfig(
            apiBaseUrl: 'https://api.exemple.test/api/v1',
            offlineSessionDays: 3,
          ),
          now: () => h.clock.add(const Duration(days: 4)),
        );

        expect((await repository.restoreSession()).ended, SessionEnd.expired);
      },
    );
  });

  group('Telephone partage (CT-23, CA-002.4)', () {
    test(
      'A se deconnecte, B se connecte : B ne voit rien de A ; la file de A est conservee pour A seul',
      () async {
        // A se connecte, recoit des donnees et saisit hors ligne.
        h.serverFor(_userA);
        final repository = await h.repository();
        await repository.login(userName: 'a.dev', password: 'x');
        await h.db.sitesDao.upsertIfNewer(siteRow());
        await h.db.zonesDao.upsertIfNewer(zoneRow());
        await h.db.syncStateDao.set(SyncStateKeys.ownerUserId, _userA);
        await h.db.userPrefsDao.set(_userA, 'current_site_id', 'site-uv18');
        await h.db.transaction(() async {
          await h.db.zonesDao.insertPending(
            pendingZoneRow(clientId: 'a-1', roomNumber: 5),
          );
          await h.db.outboxDao.enqueue(
            outboxOp(clientId: 'a-1', owner: _userA),
          );
        });

        await repository.logout();

        expect(await h.db.sitesDao.watchSites().first, isEmpty);
        expect(await h.db.zonesDao.watchBySite('site-uv18').first, isEmpty);
        expect(await h.db.userPrefsDao.get(_userA, 'current_site_id'), isNull);
        expect(h.store.current, isNull);
        expect(repository.currentUser, isNull);

        // B se connecte sur le meme telephone.
        h.serverFor(_userB, userName: 'b.dev');
        await repository.login(userName: 'b.dev', password: 'y');

        expect(
          await h.db.sitesDao.watchSites().first,
          isEmpty,
          reason: 'B ne voit aucun chantier de A',
        );
        expect(
          await h.db.outboxDao.pendingFor(_userB),
          isEmpty,
          reason: 'ni saisie de A',
        );
        expect(await h.db.outboxDao.watchFor(_userB).first, isEmpty);

        // A revient : ses saisies l'attendent.
        await repository.logout();
        h.serverFor(_userA, userName: 'a.dev');
        await repository.login(userName: 'a.dev', password: 'x');

        expect(
          (await h.db.outboxDao.pendingFor(_userA)).map((r) => r.clientId),
          ['a-1'],
        );
      },
    );

    test(
      'session de A expiree puis B se connecte : donnees de A effacees avant l\'ouverture',
      () async {
        h.serverFor(_userA);
        final repository = await h.repository();
        await repository.login(userName: 'a.dev', password: 'x');
        await h.db.sitesDao.upsertIfNewer(siteRow());
        await h.db.syncStateDao.set(SyncStateKeys.ownerUserId, _userA);
        await h.db.outboxDao.enqueue(outboxOp(clientId: 'a-1', owner: _userA));

        h.serverFor(_userB, userName: 'b.dev');
        await repository.login(userName: 'b.dev', password: 'y');

        expect(await h.db.sitesDao.watchSites().first, isEmpty);
        expect(
          await h.db.outboxDao.getByClientId('a-1'),
          isNotNull,
          reason: 'file de A intacte',
        );
      },
    );

    test(
      'le meme utilisateur se reconnecte : ses donnees sont gardees',
      () async {
        h.serverFor(_userA);
        final repository = await h.repository();
        await repository.login(userName: 'a.dev', password: 'x');
        await h.db.sitesDao.upsertIfNewer(siteRow());
        await h.db.syncStateDao.set(SyncStateKeys.ownerUserId, _userA);

        await repository.login(userName: 'a.dev', password: 'x');

        expect(await h.db.sitesDao.watchSites().first, hasLength(1));
      },
    );

    test(
      'permissions modifiees pendant l\'absence : rechargement complet a la reconnexion',
      () async {
        h.serverFor(_userA, permissionsVersion: 'v1');
        final repository = await h.repository();
        await repository.login(userName: 'a.dev', password: 'x');
        await h.db.syncStateDao.set(SyncStateKeys.cursor, '999');
        await h.db.outboxDao.enqueue(outboxOp(clientId: 'a-1', owner: _userA));

        h.serverFor(_userA, permissionsVersion: 'v2');
        await repository.login(userName: 'a.dev', password: 'x');

        expect(await h.db.syncStateDao.get(SyncStateKeys.cursor), isNull);
        expect(await h.db.outboxDao.getByClientId('a-1'), isNotNull);
      },
    );
  });

  group(
    'R1-03 : montant du marche et changement de permissions a la connexion',
    () {
      test(
        'permission retiree pendant labsence : montant efface des la reconnexion, avant tout reseau de synchro',
        () async {
          h.serverFor(_userA, permissionsVersion: 'v1');
          final repository = await h.repository();
          await repository.login(userName: 'a.dev', password: 'x');
          await h.db.sitesDao.upsertIfNewer(
            siteRow(contractAmount: Decimal.parse('185000000.00')),
          );

          h.serverFor(_userA, permissionsVersion: 'v2');
          await repository.login(userName: 'a.dev', password: 'x');

          expect(
            (await h.db.sitesDao.getSite('site-uv18'))!.contractAmount,
            isNull,
          );
          expect(await h.db.syncStateDao.get(SyncStateKeys.fullReload), 'true');
          expect(await h.db.syncStateDao.get(SyncStateKeys.cursor), isNull);
        },
      );

      test(
        'memes permissions : montant conserve, aucun rechargement',
        () async {
          h.serverFor(_userA, permissionsVersion: 'v1');
          final repository = await h.repository();
          await repository.login(userName: 'a.dev', password: 'x');
          await h.db.sitesDao.upsertIfNewer(
            siteRow(contractAmount: Decimal.parse('185000000.00')),
          );
          await h.db.syncStateDao.set(SyncStateKeys.cursor, '42');

          await repository.login(userName: 'a.dev', password: 'x');

          expect(
            (await h.db.sitesDao.getSite('site-uv18'))!.contractAmount,
            isNotNull,
          );
          expect(await h.db.syncStateDao.get(SyncStateKeys.cursor), '42');
        },
      );
    },
  );

  group('Deconnexion', () {
    test('revoque le jeton cote serveur', () async {
      h.serverFor(_userA);
      final repository = await h.repository();
      await repository.login(userName: 'chef.dev', password: 'x');

      await repository.logout();

      final call = h.adapter.callsTo('POST /api/v1/auth/logout').single;
      expect(jsonDecode(jsonEncode(call.body)), {
        'refreshToken': 'REFRESH-NEW-SECRET',
      });
      expect(h.store.current, isNull);
    });

    test('hors ligne : deconnexion locale quand meme', () async {
      h.serverFor(_userA);
      final repository = await h.repository();
      await repository.login(userName: 'chef.dev', password: 'x');
      h.adapter.on('POST /api/v1/auth/logout', (_) => throw connectionError());

      await repository.logout();

      expect(h.store.current, isNull);
      expect(repository.currentUser, isNull);
    });

    test('serveur trop lent : n\'attend pas indefiniment', () async {
      h.serverFor(_userA);
      final repository = await h.repository(
        logoutTimeout: const Duration(milliseconds: 50),
      );
      await repository.login(userName: 'chef.dev', password: 'x');
      h.adapter.on(
        'POST /api/v1/auth/logout',
        (_) => Completer<FakeResponse>().future,
      );

      await repository.logout().timeout(const Duration(seconds: 2));

      expect(h.store.current, isNull);
    });
  });

  group('Mot de passe provisoire (CA-001.7)', () {
    test('changement puis reconnexion avec le nouveau mot de passe', () async {
      h.serverFor(_userA, mustChange: true);
      final repository = await h.repository();
      await repository.login(userName: 'chef.dev', password: 'provisoire');
      h.adapter.respond(
        'POST /api/v1/auth/change-password',
        const FakeResponse(204),
      );
      h.serverFor(_userA);

      final user = await repository.changePassword(
        userName: 'chef.dev',
        currentPassword: 'provisoire',
        newPassword: 'NouveauMotDePasse-1',
      );

      expect(user.mustChangePassword, isFalse);
      final login = h.adapter.callsTo('POST /api/v1/auth/login').last;
      expect(
        jsonDecode(jsonEncode(login.body))['password'],
        'NouveauMotDePasse-1',
      );
    });

    test(
      'mot de passe faible : 422 MOT_DE_PASSE_FAIBLE, pas de reconnexion',
      () async {
        h.serverFor(_userA, mustChange: true);
        final repository = await h.repository();
        await repository.login(userName: 'chef.dev', password: 'provisoire');
        h.adapter.respond(
          'POST /api/v1/auth/change-password',
          FakeResponse.problem(422, 'MOT_DE_PASSE_FAIBLE'),
        );
        final loginsBefore = h.adapter
            .callsTo('POST /api/v1/auth/login')
            .length;

        await expectLater(
          repository.changePassword(
            userName: 'chef.dev',
            currentPassword: 'a',
            newPassword: 'b',
          ),
          throwsA(
            isA<BusinessRuleApiException>().having(
              (e) => e.code,
              'code',
              'MOT_DE_PASSE_FAIBLE',
            ),
          ),
        );

        expect(
          h.adapter.callsTo('POST /api/v1/auth/login'),
          hasLength(loginsBefore),
        );
      },
    );
  });

  group('Profil et langue', () {
    test(
      'profil recu de la synchro : memorise et diffuse seulement s\'il change',
      () async {
        h.serverFor(_userA);
        final repository = await h.repository();
        await repository.login(userName: 'chef.dev', password: 'x');
        final received = <AuthUser>[];
        final subscription = repository.profileUpdates.listen(received.add);

        await repository.applyProfile(
          MeResponse.fromJson(meJson(id: _userA, permissionsVersion: 'v1')),
        );
        await repository.applyProfile(
          MeResponse.fromJson(
            meJson(
              id: _userA,
              permissions: const ['Sites.View'],
              permissionsVersion: 'v9',
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(received, hasLength(1));
        expect(received.single.permissionsVersion, 'v9');
        expect(repository.currentUser?.can('Zones.Create'), isFalse);
        await subscription.cancel();
      },
    );

    test('profil d\'un autre utilisateur : ignore', () async {
      h.serverFor(_userA);
      final repository = await h.repository();
      await repository.login(userName: 'chef.dev', password: 'x');

      await repository.applyProfile(
        MeResponse.fromJson(meJson(id: _userB, permissionsVersion: 'zzz')),
      );

      expect(repository.currentUser?.permissionsVersion, 'v1');
    });

    test(
      'langue du compte : envoyee au serveur, jamais bloquante hors ligne',
      () async {
        h.serverFor(_userA);
        final repository = await h.repository();
        await repository.login(userName: 'chef.dev', password: 'x');

        await repository.updateLanguage('ar');
        expect(
          jsonDecode(
            jsonEncode(
              h.adapter.callsTo('PUT /api/v1/auth/me/language').single.body,
            ),
          ),
          {'language': 'ar'},
        );

        h.adapter.on(
          'PUT /api/v1/auth/me/language',
          (_) => throw connectionError(),
        );
        await repository.updateLanguage('fr');
      },
    );

    test(
      'purgeLocalData (compte retire) : jetons et donnees effaces, file conservee',
      () async {
        h.serverFor(_userA);
        final repository = await h.repository();
        await repository.login(userName: 'chef.dev', password: 'x');
        await h.db.sitesDao.upsertIfNewer(siteRow());
        await h.db.outboxDao.enqueue(outboxOp(clientId: 'a-1', owner: _userA));

        await repository.purgeLocalData();

        expect(h.store.current, isNull);
        expect(await h.db.sitesDao.watchSites().first, isEmpty);
        expect(await h.db.outboxDao.getByClientId('a-1'), isNotNull);
      },
    );
  });
}
