import 'dart:async';
import 'dart:convert';

import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/storage/token_pair.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import '../../support/api_json.dart';
import '../../support/fake_http_adapter.dart';
import '../../support/memory_token_store.dart';

const _oldTokens = TokenPair(
  accessToken: 'ACCESS-OLD-SECRET',
  refreshToken: 'REFRESH-OLD-SECRET',
);
const _newTokens = TokenPair(
  accessToken: 'ACCESS-NEW-SECRET',
  refreshToken: 'REFRESH-NEW-SECRET',
);

class _Harness {
  _Harness({TokenPair? tokens = _oldTokens}) {
    store = MemoryTokenStore(tokens);
    client = DioClient(
      config: const AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1'),
      tokenStore: store,
      events: events,
      languageCode: () => language,
      adapter: adapter,
    );
    subscription = events.stream.listen(emitted.add);
  }

  final adapter = FakeHttpAdapter();
  final events = SessionEvents();
  final emitted = <SessionEvent>[];
  late final MemoryTokenStore store;
  late final DioClient client;
  late final StreamSubscription<SessionEvent> subscription;
  String language = 'fr';

  /// `/sites` accepte seulement le nouveau jeton ; `/auth/refresh` en delivre un.
  void serverWithExpiredAccessToken() {
    adapter
      ..on('GET /sites', (request) {
        return request.header('Authorization') ==
                'Bearer ${_newTokens.accessToken}'
            ? const FakeResponse.ok({'items': []})
            : FakeResponse.problem(401, 'NON_AUTHENTIFIE');
      })
      ..respond('POST /api/v1/auth/refresh', FakeResponse.ok(authResultJson()));
  }

  Future<void> dispose() async {
    await subscription.cancel();
    await events.dispose();
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _Harness h;

  tearDown(() => h.dispose());

  group('Requete authentifiee', () {
    test('ajoute le Bearer et Accept-Language', () async {
      h = _Harness();
      h.adapter.respond('GET /sites', const FakeResponse.ok({'items': []}));

      await h.client.get<dynamic>('/sites');

      final call = h.adapter.callsTo('GET /sites').single;
      expect(call.header('Authorization'), 'Bearer ACCESS-OLD-SECRET');
      expect(call.header('Accept-Language'), 'fr');
    });

    test('Accept-Language suit la langue courante (ar)', () async {
      h = _Harness()..language = 'ar';
      h.adapter.respond('GET /sites', const FakeResponse.ok({}));

      await h.client.get<dynamic>('/sites');

      expect(
        h.adapter.callsTo('GET /sites').single.header('Accept-Language'),
        'ar',
      );
    });

    test('sans jeton : pas d en-tete Authorization', () async {
      h = _Harness(tokens: null);
      h.adapter.respond('GET /sites', const FakeResponse.ok({}));

      await h.client.get<dynamic>('/sites');

      expect(
        h.adapter.callsTo('GET /sites').single.header('Authorization'),
        isNull,
      );
    });

    test('appel anonyme : ni Bearer ni rejeu (connexion)', () async {
      h = _Harness();
      h.adapter.respond(
        'POST /auth/login',
        FakeResponse.problem(401, 'IDENTIFIANTS_INVALIDES'),
      );

      await expectLater(
        h.client.post<dynamic>(
          '/auth/login',
          data: {'userName': 'chef.dev', 'password': 'x'},
          authenticated: false,
        ),
        throwsA(
          isA<UnauthorizedApiException>().having(
            (e) => e.code,
            'code',
            'IDENTIFIANTS_INVALIDES',
          ),
        ),
      );

      expect(
        h.adapter.callsTo('POST /auth/login').single.header('Authorization'),
        isNull,
      );
      expect(h.adapter.callsTo('POST /api/v1/auth/refresh'), isEmpty);
      expect(h.store.current, _oldTokens, reason: 'jetons existants intacts');
    });
  });

  group('401 puis rafraichissement (CT-2)', () {
    test(
      'rafraichit puis rejoue la requete UNE fois avec le nouveau jeton',
      () async {
        h = _Harness()..serverWithExpiredAccessToken();

        final response = await h.client.get<Map<String, dynamic>>('/sites');

        expect(response.statusCode, 200);
        expect(h.adapter.requests.map((r) => r.toString()), [
          'GET /sites',
          'POST /api/v1/auth/refresh',
          'GET /sites',
        ]);
        expect(
          jsonDecode(
            jsonEncode(
              h.adapter.callsTo('POST /api/v1/auth/refresh').single.body,
            ),
          ),
          {'refreshToken': 'REFRESH-OLD-SECRET'},
        );
        expect(
          h.adapter.callsTo('GET /sites').last.header('Authorization'),
          'Bearer ACCESS-NEW-SECRET',
        );
        expect(
          h.store.current,
          _newTokens,
          reason: 'paire rotative enregistree',
        );
        await _settle();
        expect(h.emitted, isEmpty);
      },
    );

    test(
      'R1-10 : la deconnexion rejouee apres rotation presente le refresh COURANT, pas lancien',
      () async {
        h = _Harness()..serverWithExpiredAccessToken();
        h.adapter.on('POST /auth/logout', (request) {
          return request.header('Authorization') ==
                  'Bearer ${_newTokens.accessToken}'
              ? const FakeResponse(204)
              : FakeResponse.problem(401, 'NON_AUTHENTIFIE');
        });

        await h.client.post<dynamic>(
          '/auth/logout',
          data: {'refreshToken': _oldTokens.refreshToken},
        );

        final calls = h.adapter.callsTo('POST /auth/logout');
        expect(calls, hasLength(2));
        expect(jsonDecode(jsonEncode(calls.first.body)), {
          'refreshToken': 'REFRESH-OLD-SECRET',
        });
        expect(
          jsonDecode(jsonEncode(calls.last.body)),
          {'refreshToken': 'REFRESH-NEW-SECRET'},
          reason:
              'le jeton revoque par la rotation ne doit pas etre represente',
        );
      },
    );

    test('un autre appel rejoue garde son corps tel quel', () async {
      h = _Harness()..serverWithExpiredAccessToken();
      h.adapter.on('POST /sites/s1/zones', (request) {
        return request.header('Authorization') ==
                'Bearer ${_newTokens.accessToken}'
            ? const FakeResponse.ok({})
            : FakeResponse.problem(401, 'NON_AUTHENTIFIE');
      });

      await h.client.post<dynamic>(
        '/sites/s1/zones',
        data: {'block': 'Bloc 01'},
      );

      final replayed = h.adapter.callsTo('POST /sites/s1/zones').last;
      expect(jsonDecode(jsonEncode(replayed.body)), {'block': 'Bloc 01'});
    });

    test('le rafraichissement part sans Bearer (client nu)', () async {
      h = _Harness()..serverWithExpiredAccessToken();

      await h.client.get<dynamic>('/sites');

      expect(
        h.adapter
            .callsTo('POST /api/v1/auth/refresh')
            .single
            .header('Authorization'),
        isNull,
      );
    });

    test(
      'jamais deux rejeux : un second 401 apres rafraichissement est remonte',
      () async {
        h = _Harness();
        h.adapter
          ..respond('GET /sites', FakeResponse.problem(401, 'NON_AUTHENTIFIE'))
          ..respond(
            'POST /api/v1/auth/refresh',
            FakeResponse.ok(authResultJson()),
          );

        await expectLater(
          h.client.get<dynamic>('/sites'),
          throwsA(isA<UnauthorizedApiException>()),
        );

        expect(h.adapter.callsTo('GET /sites'), hasLength(2));
        expect(h.adapter.callsTo('POST /api/v1/auth/refresh'), hasLength(1));
      },
    );

    test('requetes simultanees : UN seul rafraichissement partage', () async {
      h = _Harness()..serverWithExpiredAccessToken();

      final results = await Future.wait([
        h.client.get<dynamic>('/sites'),
        h.client.get<dynamic>('/sites'),
        h.client.get<dynamic>('/sites'),
      ]);

      expect(results.map((r) => r.statusCode), [200, 200, 200]);
      expect(
        h.adapter.callsTo('POST /api/v1/auth/refresh'),
        hasLength(1),
        reason: 'jeton rotatif : une reutilisation revoquerait toute la chaine',
      );
      expect(h.store.saveCount, 1);
    });

    test(
      'refresh refuse (REFRESH_INVALIDE) : seuls les jetons sont effaces',
      () async {
        h = _Harness();
        h.adapter
          ..respond('GET /sites', FakeResponse.problem(401, 'NON_AUTHENTIFIE'))
          ..respond(
            'POST /api/v1/auth/refresh',
            FakeResponse.problem(401, 'REFRESH_INVALIDE'),
          );

        await expectLater(
          h.client.get<dynamic>('/sites'),
          throwsA(isA<UnauthorizedApiException>()),
        );
        await _settle();

        expect(h.store.current, isNull);
        expect(h.store.clearCount, 1);
        expect(h.emitted, [SessionEvent.authRequired]);
      },
    );

    test(
      'refresh refuse avec ACCES_RETIRE : evenement accessRevoked',
      () async {
        h = _Harness();
        h.adapter
          ..respond('GET /sites', FakeResponse.problem(401, 'NON_AUTHENTIFIE'))
          ..respond(
            'POST /api/v1/auth/refresh',
            FakeResponse.problem(401, 'ACCES_RETIRE'),
          );

        await expectLater(
          h.client.get<dynamic>('/sites'),
          throwsA(isA<UnauthorizedApiException>()),
        );
        await _settle();

        expect(h.store.current, isNull);
        expect(h.emitted, [SessionEvent.accessRevoked]);
      },
    );

    test(
      'ACCES_RETIRE sur un appel normal : pas de rafraichissement',
      () async {
        h = _Harness();
        h.adapter.respond(
          'GET /sites',
          FakeResponse.problem(401, 'ACCES_RETIRE'),
        );

        await expectLater(
          h.client.get<dynamic>('/sites'),
          throwsA(
            isA<UnauthorizedApiException>().having(
              (e) => e.isAccessRevoked,
              'revoked',
              true,
            ),
          ),
        );
        await _settle();

        expect(h.adapter.callsTo('POST /api/v1/auth/refresh'), isEmpty);
        expect(h.store.current, isNull);
        expect(h.emitted, [SessionEvent.accessRevoked]);
      },
    );

    test(
      '403 MOT_DE_PASSE_A_CHANGER : evenement dedie, jetons CONSERVES, pas de rafraichissement',
      () async {
        h = _Harness();
        h.adapter.respond(
          'GET /sites',
          FakeResponse.problem(403, 'MOT_DE_PASSE_A_CHANGER'),
        );

        await expectLater(
          h.client.get<dynamic>('/sites'),
          throwsA(
            isA<ForbiddenApiException>().having(
              (e) => e.isPasswordChangeRequired,
              'provisoire',
              true,
            ),
          ),
        );
        await _settle();

        expect(h.emitted, [SessionEvent.passwordChangeRequired]);
        expect(h.store.current, _oldTokens);
        expect(h.adapter.callsTo('POST /api/v1/auth/refresh'), isEmpty);
      },
    );

    test('403 INTERDIT ordinaire : aucun evenement de session', () async {
      h = _Harness();
      h.adapter.respond('GET /sites', FakeResponse.problem(403, 'INTERDIT'));

      await expectLater(
        h.client.get<dynamic>('/sites'),
        throwsA(isA<ForbiddenApiException>()),
      );
      await _settle();

      expect(h.emitted, isEmpty);
    });

    test('401 sans aucun jeton : reconnexion necessaire', () async {
      h = _Harness(tokens: null);
      h.adapter.respond(
        'GET /sites',
        FakeResponse.problem(401, 'NON_AUTHENTIFIE'),
      );

      await expectLater(
        h.client.get<dynamic>('/sites'),
        throwsA(isA<UnauthorizedApiException>()),
      );
      await _settle();

      expect(h.adapter.callsTo('POST /api/v1/auth/refresh'), isEmpty);
      expect(h.emitted, [SessionEvent.authRequired]);
    });

    test(
      'hors ligne pendant le refresh : jetons CONSERVES, erreur reseau',
      () async {
        h = _Harness();
        h.adapter
          ..respond('GET /sites', FakeResponse.problem(401, 'NON_AUTHENTIFIE'))
          ..on('POST /api/v1/auth/refresh', (_) => throw connectionError());

        await expectLater(
          h.client.get<dynamic>('/sites'),
          throwsA(isA<NetworkApiException>()),
        );
        await _settle();

        expect(
          h.store.current,
          _oldTokens,
          reason: 'etre hors ligne n est pas etre deconnecte',
        );
        expect(h.store.clearCount, 0);
        expect(h.emitted, isEmpty);
      },
    );

    test('refresh en 503 : jetons conserves', () async {
      h = _Harness();
      h.adapter
        ..respond('GET /sites', FakeResponse.problem(401, 'NON_AUTHENTIFIE'))
        ..respond(
          'POST /api/v1/auth/refresh',
          FakeResponse.problem(503, 'ERREUR_INTERNE'),
        );

      await expectLater(
        h.client.get<dynamic>('/sites'),
        throwsA(isA<ServerApiException>()),
      );

      expect(h.store.current, _oldTokens);
      expect(h.emitted, isEmpty);
    });

    test('refresh en 429 : jetons conserves, attente transmise', () async {
      h = _Harness();
      h.adapter
        ..respond('GET /sites', FakeResponse.problem(401, 'NON_AUTHENTIFIE'))
        ..respond(
          'POST /api/v1/auth/refresh',
          FakeResponse.problem(
            429,
            'TROP_DE_REQUETES',
            headers: {'retry-after': '30'},
          ),
        );

      await expectLater(
        h.client.get<dynamic>('/sites'),
        throwsA(
          isA<TooManyRequestsApiException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 30),
          ),
        ),
      );

      expect(h.store.current, _oldTokens);
    });
  });

  group('Erreurs typees Problem Details', () {
    test('422 ZONE_EXISTANTE : code, statut et traceId conserves', () async {
      h = _Harness();
      h.adapter.respond(
        'POST /sites/s1/zones',
        FakeResponse.problem(422, 'ZONE_EXISTANTE', traceId: '00-abc'),
      );

      await expectLater(
        h.client.post<dynamic>('/sites/s1/zones', data: {'block': 'Bloc 01'}),
        throwsA(
          isA<BusinessRuleApiException>()
              .having((e) => e.code, 'code', 'ZONE_EXISTANTE')
              .having((e) => e.status, 'status', 422)
              .having((e) => e.traceId, 'traceId', '00-abc'),
        ),
      );
    });

    test('429 TROP_D_ESSAIS avec Retry-After', () async {
      h = _Harness(tokens: null);
      h.adapter.respond(
        'POST /auth/login',
        FakeResponse.problem(
          429,
          'TROP_D_ESSAIS',
          headers: {'retry-after': '900'},
        ),
      );

      await expectLater(
        h.client.post<dynamic>(
          '/auth/login',
          data: const {},
          authenticated: false,
        ),
        throwsA(
          isA<TooManyRequestsApiException>()
              .having((e) => e.code, 'code', 'TROP_D_ESSAIS')
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(minutes: 15),
              ),
        ),
      );
    });

    test('coupure reseau : NetworkApiException, retentable', () async {
      h = _Harness();
      h.adapter.on('GET /sites', (_) => throw connectionError());

      await expectLater(
        h.client.get<dynamic>('/sites'),
        throwsA(
          isA<NetworkApiException>().having(
            (e) => e.isRetryable,
            'retryable',
            true,
          ),
        ),
      );
    });
  });

  group('Journaux sans donnee sensible (CT-14)', () {
    test('ni jeton, ni mot de passe, ni en-tete dans les journaux', () async {
      final records = <LogRecord>[];
      final previousLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      final logSubscription = Logger.root.onRecord.listen(records.add);
      addTearDown(() async {
        await logSubscription.cancel();
        Logger.root.level = previousLevel;
      });

      h = _Harness();
      h.serverWithExpiredAccessToken();
      h.adapter.respond(
        'POST /auth/login',
        FakeResponse.problem(401, 'IDENTIFIANTS_INVALIDES'),
      );

      await h.client.get<dynamic>('/sites'); // 401 puis refresh puis rejeu
      await h.client
          .post<dynamic>(
            '/auth/login',
            data: {'userName': 'chef.dev', 'password': 'MotDePasse-Secret-1'},
            authenticated: false,
          )
          .then<void>((_) {}, onError: (Object _) {});

      expect(records, isNotEmpty);
      final text = records.map((r) => r.message).join('\n');
      for (final secret in [
        'ACCESS-OLD-SECRET',
        'ACCESS-NEW-SECRET',
        'REFRESH-OLD-SECRET',
        'REFRESH-NEW-SECRET',
        'MotDePasse-Secret-1',
        'chef.dev',
        'Bearer',
      ]) {
        expect(text, isNot(contains(secret)), reason: secret);
      }
    });
  });
}
