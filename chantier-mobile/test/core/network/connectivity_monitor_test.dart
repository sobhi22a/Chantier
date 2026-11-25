import 'dart:async';

import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fake_http_adapter.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;
  late FakeHttpAdapter adapter;
  late ConnectivityMonitor monitor;
  late StreamController<List<ConnectivityResult>> changes;

  setUp(() {
    connectivity = _MockConnectivity();
    adapter = FakeHttpAdapter();
    changes = StreamController<List<ConnectivityResult>>.broadcast();
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => changes.stream);
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.exemple.test/api/v1'))
      ..httpClientAdapter = adapter;
    monitor = ConnectivityMonitor(
      connectivity: connectivity,
      bareDio: dio,
      config: const AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1'),
    );
  });

  tearDown(() => changes.close());

  group('interface reseau', () {
    test('aucune interface', () async {
      when(
        () => connectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.none]);

      expect(await monitor.hasNetworkInterface(), isFalse);
    });

    test('Wi-Fi ou mobile', () async {
      expect(await monitor.hasNetworkInterface(), isTrue);
    });

    test(
      'onNetworkAvailable emet au retour du reseau, pas a la perte',
      () async {
        var emissions = 0;
        final subscription = monitor.onNetworkAvailable.listen(
          (_) => emissions++,
        );

        changes.add([ConnectivityResult.none]);
        await Future<void>.delayed(Duration.zero);
        expect(emissions, 0);

        changes.add([ConnectivityResult.mobile]);
        await Future<void>.delayed(Duration.zero);
        expect(emissions, 1);

        // Meme etat « connecte » : pas de nouvelle emission.
        changes.add([ConnectivityResult.mobile, ConnectivityResult.wifi]);
        await Future<void>.delayed(Duration.zero);
        expect(emissions, 1);

        await subscription.cancel();
      },
    );
  });

  group('serveur joignable (un reseau detecte ne garantit pas internet)', () {
    test('GET /health/live a la racine, anonyme', () async {
      adapter.respond(
        'GET /health/live',
        const FakeResponse.ok({'status': 'Healthy'}),
      );

      expect(await monitor.isServerReachable(), isTrue);

      final call = adapter.callsTo('GET /health/live').single;
      expect(call.uri.toString(), 'https://api.exemple.test/health/live');
      expect(call.header('Authorization'), isNull);
    });

    test(
      'Wi-Fi sans acces internet : interface presente mais serveur injoignable',
      () async {
        adapter.on('GET /health/live', (_) => throw connectionError());

        expect(await monitor.hasNetworkInterface(), isTrue);
        expect(await monitor.isServerReachable(), isFalse);
        expect(await monitor.confirmOnline(), isFalse);
      },
    );

    test('503 : serveur considere injoignable', () async {
      adapter.respond('GET /health/live', const FakeResponse(503));

      expect(await monitor.isServerReachable(), isFalse);
    });

    test('confirmOnline : interface et serveur', () async {
      adapter.respond(
        'GET /health/live',
        const FakeResponse.ok({'status': 'Healthy'}),
      );

      expect(await monitor.confirmOnline(), isTrue);
    });

    test('confirmOnline sans interface : aucun appel reseau', () async {
      when(
        () => connectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.none]);

      expect(await monitor.confirmOnline(), isFalse);
      expect(adapter.requests, isEmpty);
    });
  });
}
