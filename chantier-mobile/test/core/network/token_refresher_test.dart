import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/network/token_refresher.dart';
import 'package:chantier_mobile/core/storage/token_pair.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/api_json.dart';
import '../../support/fake_http_adapter.dart';
import '../../support/memory_token_store.dart';

const _tokens = TokenPair(accessToken: 'A1', refreshToken: 'R1');

void main() {
  late FakeHttpAdapter adapter;
  late MemoryTokenStore store;
  late SessionEvents events;
  late List<SessionEvent> emitted;
  late TokenRefresher refresher;

  setUp(() {
    adapter = FakeHttpAdapter();
    store = MemoryTokenStore(_tokens);
    events = SessionEvents();
    emitted = [];
    events.stream.listen(emitted.add);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.exemple.test/api/v1'))
      ..httpClientAdapter = adapter;
    refresher = TokenRefresher(
      anonymousAuth: AuthClient(dio, baseUrl: 'https://api.exemple.test'),
      tokenStore: store,
      events: events,
    );
  });

  tearDown(() => events.dispose());

  test('succes : nouvelle paire enregistree', () async {
    adapter.respond(
      'POST /api/v1/auth/refresh',
      FakeResponse.ok(authResultJson(accessToken: 'A2', refreshToken: 'R2')),
    );

    final result = await refresher.refresh();

    expect(result, isA<RefreshSucceeded>());
    expect(
      store.current,
      const TokenPair(accessToken: 'A2', refreshToken: 'R2'),
    );
  });

  test(
    'jetons deja renouveles depuis la requete refusee : aucun appel serveur',
    () async {
      store = MemoryTokenStore(
        const TokenPair(accessToken: 'A2', refreshToken: 'R2'),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      refresher = TokenRefresher(
        anonymousAuth: AuthClient(dio, baseUrl: 'https://api.exemple.test'),
        tokenStore: store,
        events: events,
      );

      final result = await refresher.refresh(staleAccessToken: 'A1');

      expect(result, isA<RefreshSucceeded>());
      expect(
        adapter.requests,
        isEmpty,
        reason: 'rejouer R1 revoquerait la chaine',
      );
    },
  );

  test('appels simultanes : une seule requete serveur', () async {
    adapter.respond(
      'POST /api/v1/auth/refresh',
      FakeResponse.ok(authResultJson(accessToken: 'A2', refreshToken: 'R2')),
    );

    final results = await Future.wait([
      refresher.refresh(staleAccessToken: 'A1'),
      refresher.refresh(staleAccessToken: 'A1'),
    ]);

    expect(results, everyElement(isA<RefreshSucceeded>()));
    expect(adapter.callsTo('POST /api/v1/auth/refresh'), hasLength(1));
  });

  test('apres un echec, un nouvel essai est possible', () async {
    var calls = 0;
    adapter.on('POST /api/v1/auth/refresh', (_) {
      calls++;
      if (calls == 1) throw connectionError();
      return FakeResponse.ok(
        authResultJson(accessToken: 'A2', refreshToken: 'R2'),
      );
    });

    final first = await refresher.refresh();
    final second = await refresher.refresh();

    expect(first, isA<RefreshFailedTemporarily>());
    expect(second, isA<RefreshSucceeded>());
  });

  test('pas de jeton : session terminee, evenement authRequired', () async {
    store = MemoryTokenStore();
    final dio = Dio()..httpClientAdapter = adapter;
    refresher = TokenRefresher(
      anonymousAuth: AuthClient(dio, baseUrl: 'https://api.exemple.test'),
      tokenStore: store,
      events: events,
    );

    final result = await refresher.refresh();
    await Future<void>.delayed(Duration.zero);

    expect(result, isA<RefreshSessionEnded>());
    expect(emitted, [SessionEvent.authRequired]);
  });

  test(
    'reponse sans jetons exploitables : echec temporaire, jetons conserves',
    () async {
      adapter.respond(
        'POST /api/v1/auth/refresh',
        FakeResponse.ok(authResultJson(accessToken: '')),
      );

      final result = await refresher.refresh();

      expect(result, isA<RefreshFailedTemporarily>());
      expect(store.current, _tokens);
      expect(store.saveCount, 0);
    },
  );

  test('echec temporaire : la cause typee est transmise', () async {
    adapter.respond(
      'POST /api/v1/auth/refresh',
      FakeResponse.problem(500, 'ERREUR_INTERNE'),
    );

    final result = await refresher.refresh();

    expect(result, isA<RefreshFailedTemporarily>());
    expect(
      (result as RefreshFailedTemporarily).cause,
      isA<ServerApiException>(),
    );
  });
}
