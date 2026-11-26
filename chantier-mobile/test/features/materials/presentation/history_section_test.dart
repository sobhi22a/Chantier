import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/storage/token_pair.dart';
import 'package:chantier_mobile/features/materials/data/history_remote.dart';
import 'package:chantier_mobile/features/materials/data/photo_remote.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/deliveries_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/delivery_detail_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/request_detail_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_http_adapter.dart';
import '../../../support/fixtures.dart';
import '../../../support/materials_harness.dart';
import '../../../support/memory_token_store.dart';
import '../../../support/photo_support.dart';
import '../../../support/pump_app.dart';

/// Historique lu **a la demande** (R2-02) : la synchronisation envoie `history[]` vide ; le detail
/// le lit en ligne, ou dit « Historique indisponible hors ligne ». Jamais ecrit en base, jamais un
/// prix.
const _site = 'site-uv18';

final _events = [
  {
    'id': 'e1',
    'type': 'Created',
    'fromStatus': null,
    'toStatus': 'Requested',
    'occurredAt': '2026-11-25T07:00:00Z',
    'actorName': 'Mourad B.',
    'source': 'Api',
  },
  {
    'id': 'e2',
    'type': 'OrderCommercialEdited',
    'occurredAt': '2026-11-25T08:00:00Z',
    'changes': [
      {'field': 'unitPrice', 'old': '780.00', 'new': '800.00'},
    ],
    'actorName': 'Karim A.',
  },
  {
    'id': 'e3',
    'type': 'Approved',
    'fromStatus': 'Requested',
    'toStatus': 'Validated',
    'occurredAt': '2026-11-25T09:00:00Z',
    'actorName': 'Karim A.',
    'changes': [
      {'field': 'amount', 'old': '1', 'new': '234000.00'},
      {'field': 'quantity', 'old': '300 sac', 'new': '200 sac'},
    ],
  },
];

void screenTest(String name, Future<void> Function(WidgetTester tester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    });

class _Fake implements HistorySource {
  _Fake({this.requestResult, this.error});

  final String? requestResult;
  final ApiException? error;
  final List<String> calls = [];

  @override
  Future<String?> requestHistory(String siteId, String requestId) async {
    calls.add('request:$siteId/$requestId');
    if (error != null) throw error!;
    return requestResult;
  }

  @override
  Future<String?> deliveryHistory(String siteId, String deliveryId) async {
    calls.add('delivery:$siteId/$deliveryId');
    if (error != null) throw error!;
    return requestResult;
  }

  @override
  void clear() {}
}

void main() {
  late MaterialsHarness h;
  late PhotoTestBed bed;

  setUp(() {
    h = MaterialsHarness();
    bed = PhotoTestBed();
  });
  tearDown(() async {
    await h.dispose();
    bed.dispose();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  Future<void> openRequest(
    WidgetTester tester, {
    HistorySource? history,
    bool pending = false,
    Locale locale = const Locale('fr'),
    String? localJson,
  }) async {
    tester.view.physicalSize = const Size(800, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final user = chefChantier();
    await tester.runAsync(() async {
      await h.seed();
      await h.db.materialRequestsDao.upsertIfNewer(
        pending
            ? pendingRequestRow(clientId: 'r-off')
            : requestRow(id: 'r1', status: 'Validated', historyJson: localJson),
      );
    });
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: BlocProvider(
          create: (_) => RequestDetailCubit(
            repository: h.materials,
            requestId: pending ? 'r-off' : 'r1',
            userId: user.id,
          ),
          child: RequestDetailScreen(
            user: user,
            repository: h.materials,
            zones: h.zones.watchZones(harnessSite),
            onEdit: (_) {},
            history: history,
          ),
        ),
      ),
    );
    await tester.pump();
    await settle(tester);
  }

  group('detail d une demande', () {
    final json = '[${_events.map(_jsonOf).join(',')}]';

    screenTest('en ligne : historique lu par GET /requests/{id}', (
      tester,
    ) async {
      final source = _Fake(requestResult: json);
      await openRequest(tester, history: source);
      expect(source.calls, ['request:$_site/r1']);
      expect(find.text('Historique'), findsOneWidget);
      expect(find.text('Demande créée'), findsOneWidget);
      expect(find.text('Validée'), findsWidgets);
      expect(
        findTextContaining('Quantité : 300 sac → 200 sac'),
        findsOneWidget,
      );
    });

    screenTest('jamais un prix : evenement et champs commerciaux ecartes', (
      tester,
    ) async {
      // La source de production assainit ; le faux rend le texte deja assaini ou brut selon le cas.
      final source = _Fake(requestResult: json);
      await openRequest(tester, history: source);
      // Le detail n'affiche que ce que la source rend : ici, le test de production ci-dessous
      // verifie l'assainissement ; on verifie aussi que rien n'est ecrit en base.
      final stored = await tester.runAsync(
        () => h.db.materialRequestsDao.getById('r1'),
      );
      expect(stored!.historyJson, isNull);
    });

    screenTest(
      'hors ligne : « Historique indisponible hors ligne », reste de la fiche intact',
      (tester) async {
        final source = _Fake(error: const NetworkApiException());
        await openRequest(tester, history: source);
        expect(find.text('Historique'), findsOneWidget);
        expect(
          find.text('Historique indisponible hors ligne.'),
          findsOneWidget,
        );
        expect(find.text('DEM-009'), findsWidgets);
        expect(
          find.text('Annuler la demande'),
          findsOneWidget,
        ); // la fiche reste utilisable
      },
    );

    screenTest(
      'hors ligne avec l ancien historique local : affiche ce que le telephone sait',
      (tester) async {
        final source = _Fake(error: const NetworkApiException());
        await openRequest(tester, history: source, localJson: json);
        expect(find.text('Demande créée'), findsOneWidget);
        expect(find.text('Historique indisponible hors ligne.'), findsNothing);
      },
    );

    screenTest('demande jamais envoyee : aucune lecture, aucun message', (
      tester,
    ) async {
      final source = _Fake(requestResult: json);
      await openRequest(tester, history: source, pending: true);
      expect(source.calls, isEmpty);
      expect(find.text('Historique'), findsNothing);
      expect(find.text('Historique indisponible hors ligne.'), findsNothing);
    });

    screenTest('arabe : message traduit', (tester) async {
      final source = _Fake(error: const NetworkApiException());
      await openRequest(tester, history: source, locale: const Locale('ar'));
      expect(find.text('السجل غير متاح دون اتصال.'), findsOneWidget);
      expect(find.text('Historique indisponible hors ligne.'), findsNothing);
    });

    screenTest(
      'un serveur qui refuse (404) : indisponible, pas d erreur technique',
      (tester) async {
        final source = _Fake(error: const NotFoundApiException(status: 404));
        await openRequest(tester, history: source);
        expect(
          find.text('Historique indisponible hors ligne.'),
          findsOneWidget,
        );
      },
    );
  });

  group('detail d une livraison', () {
    screenTest('en ligne : historique lu par GET /deliveries/{id}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 3600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final user = chefChantier();
      await tester.runAsync(() async {
        await h.seed();
        await h.db.deliveriesDao.upsertIfNewer(deliveryRow(id: 'l6'));
      });
      final source = _Fake(
        requestResult:
            '[{"id":"e1","type":"DeliveryRegistered","occurredAt":"2026-11-04T08:10:00Z","actorName":"Mourad B."}]',
      );
      await tester.pumpWidget(
        testApp(
          home: BlocProvider(
            create: (_) => DeliveryDetailCubit(
              repository: h.deliveries,
              deliveryId: 'l6',
              userId: user.id,
            ),
            child: DeliveryDetailScreen(
              user: user,
              deliveries: h.deliveries,
              materials: h.materials,
              capture: FakePhotoCapture(bed),
              files: bed.files,
              viewer: PhotoViewer(FakePhotoRemote()),
              onEdit: (_) {},
              history: source,
            ),
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
      expect(source.calls, ['delivery:$_site/l6']);
      expect(find.text('Livraison enregistrée'), findsOneWidget);
    });

    screenTest('hors ligne : message d indisponibilite', (tester) async {
      tester.view.physicalSize = const Size(800, 3600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final user = chefChantier();
      await tester.runAsync(() async {
        await h.seed();
        await h.db.deliveriesDao.upsertIfNewer(deliveryRow(id: 'l6'));
      });
      await tester.pumpWidget(
        testApp(
          home: BlocProvider(
            create: (_) => DeliveryDetailCubit(
              repository: h.deliveries,
              deliveryId: 'l6',
              userId: user.id,
            ),
            child: DeliveryDetailScreen(
              user: user,
              deliveries: h.deliveries,
              materials: h.materials,
              capture: FakePhotoCapture(bed),
              files: bed.files,
              viewer: PhotoViewer(FakePhotoRemote()),
              onEdit: (_) {},
              history: _Fake(error: const TimeoutApiException()),
            ),
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
      expect(find.text('Historique indisponible hors ligne.'), findsOneWidget);
    });
  });

  group('HistoryRemoteSource (production)', () {
    late FakeHttpAdapter adapter;
    late HistoryRemoteSource source;

    setUp(() {
      adapter = FakeHttpAdapter();
      source = HistoryRemoteSource(
        DioClient(
          config: const AppConfig(
            apiBaseUrl: 'https://api.exemple.test/api/v1',
          ),
          tokenStore: MemoryTokenStore(
            const TokenPair(accessToken: 'A', refreshToken: 'R'),
          ),
          events: SessionEvents(),
          languageCode: () => 'fr',
          adapter: adapter,
        ),
      );
    });

    test(
      'jamais un prix : evenement sensible et champs commerciaux retires',
      () async {
        adapter.respond(
          'GET /sites/s/requests/r',
          FakeResponse.ok({'id': 'r', 'history': _events}),
        );
        final text = (await source.requestHistory('s', 'r'))!;
        expect(text, isNot(contains('OrderCommercialEdited')));
        expect(text, isNot(contains('780')));
        expect(text, isNot(contains('234000')));
        expect(text, isNot(contains('unitPrice')));
        expect(text, contains('Approved'));
        expect(text, contains('200 sac'));
      },
    );

    test(
      'hors ligne apres une lecture : copie en memoire ; jamais lue : erreur',
      () async {
        adapter.respond(
          'GET /sites/s/deliveries/d',
          FakeResponse.ok({'id': 'd', 'history': _events}),
        );
        final first = await source.deliveryHistory('s', 'd');
        adapter.on('GET /sites/s/deliveries/d', (_) => throw connectionError());
        expect(await source.deliveryHistory('s', 'd'), first);

        adapter.on('GET /sites/s/requests/r', (_) => throw connectionError());
        await expectLater(
          source.requestHistory('s', 'r'),
          throwsA(isA<NetworkApiException>()),
        );

        source.clear();
        await expectLater(
          source.deliveryHistory('s', 'd'),
          throwsA(isA<NetworkApiException>()),
        );
      },
    );

    test('un historique absent de la reponse : null', () async {
      adapter.respond(
        'GET /sites/s/requests/r',
        const FakeResponse.ok({'id': 'r'}),
      );
      expect(await source.requestHistory('s', 'r'), isNull);
    });
  });
}

String _jsonOf(Map<String, Object?> event) => _encode(event);

String _encode(Object? value) {
  if (value == null) return 'null';
  if (value is String) return '"${value.replaceAll('"', r'\"')}"';
  if (value is Map) {
    return '{${value.entries.map((e) => '${_encode(e.key)}:${_encode(e.value)}').join(',')}}';
  }
  if (value is List) return '[${value.map(_encode).join(',')}]';
  return '$value';
}
