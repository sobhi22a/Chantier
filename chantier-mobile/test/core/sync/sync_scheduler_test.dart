import 'dart:async';

import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_scheduler.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockEngine extends Mock implements SyncEngine {}

class _MockMonitor extends Mock implements ConnectivityMonitor {}

void main() {
  late _MockEngine engine;
  late _MockMonitor monitor;
  late StreamController<SyncEngineState> states;
  late StreamController<void> network;
  late DateTime clock;
  var runs = 0;

  setUp(() {
    runs = 0;
    clock = DateTime.utc(2026, 11, 24, 10);
    engine = _MockEngine();
    monitor = _MockMonitor();
    states = StreamController<SyncEngineState>.broadcast(sync: true);
    network = StreamController<void>.broadcast(sync: true);
    when(() => engine.states).thenAnswer((_) => states.stream);
    when(() => monitor.onNetworkAvailable).thenAnswer((_) => network.stream);
    when(() => engine.run()).thenAnswer((_) async {
      runs++;
      return SyncOutcome.completed;
    });
  });

  tearDown(() async {
    await states.close();
    await network.close();
  });

  SyncScheduler build() =>
      SyncScheduler(engine: engine, connectivity: monitor, now: () => clock);

  test('demarrage : synchronise tout de suite', () {
    fakeAsync((async) {
      final scheduler = build()..start();

      async.flushMicrotasks();

      expect(runs, 1);
      scheduler.pause();
    });
  });

  test('toutes les 5 minutes au premier plan (CA-013.4)', () {
    fakeAsync((async) {
      final scheduler = build()..start();
      async.flushMicrotasks();

      async.elapse(const Duration(minutes: 5));
      async.elapse(const Duration(minutes: 5));

      expect(runs, 3);
      scheduler.pause();
    });
  });

  test('retour du reseau : synchronise', () {
    fakeAsync((async) {
      final scheduler = build()..start();
      async.flushMicrotasks();

      network.add(null);
      async.flushMicrotasks();

      expect(runs, 2);
      scheduler.pause();
    });
  });

  test('enregistrements rapproches : un seul envoi, 2 s apres le dernier', () {
    fakeAsync((async) {
      final scheduler = build()..start();
      async.flushMicrotasks();

      scheduler.notifyLocalWrite();
      async.elapse(const Duration(seconds: 1));
      scheduler.notifyLocalWrite();
      async.elapse(const Duration(seconds: 1));
      expect(
        runs,
        1,
        reason: 'pas encore : 2 s apres le dernier enregistrement',
      );
      async.elapse(const Duration(seconds: 1));

      expect(runs, 2);
      scheduler.pause();
    });
  });

  test('arriere-plan (pause) : plus aucun minuteur ni declencheur', () {
    fakeAsync((async) {
      final scheduler = build()..start();
      async.flushMicrotasks();
      scheduler.pause();

      async.elapse(const Duration(minutes: 30));
      network.add(null);
      scheduler.notifyLocalWrite();
      async.elapse(const Duration(seconds: 10));

      expect(runs, 1);
      expect(scheduler.isActive, isFalse);
    });
  });

  test('retour au premier plan : repart', () {
    fakeAsync((async) {
      final scheduler = build()..start();
      async.flushMicrotasks();
      scheduler.pause();

      scheduler.resume();
      async.flushMicrotasks();

      expect(runs, 2);
      scheduler.pause();
    });
  });

  test('demarrage double : un seul jeu de minuteurs', () {
    fakeAsync((async) {
      final scheduler = build()
        ..start()
        ..start();
      async.flushMicrotasks();

      expect(runs, 1);
      scheduler.pause();
    });
  });

  test('echec : reprise au delai fixe par le moteur (delai exponentiel)', () {
    fakeAsync((async) {
      final scheduler = build()..start();
      async.flushMicrotasks();

      states.add(
        SyncEngineState(
          phase: SyncPhase.failed,
          lastError: const ServerApiException(status: 503),
          consecutiveFailures: 1,
          nextRetryAt: clock.add(const Duration(seconds: 20)),
        ),
      );
      async.elapse(const Duration(seconds: 19));
      expect(runs, 1);
      async.elapse(const Duration(seconds: 2));

      expect(runs, 2);
      scheduler.pause();
    });
  });

  test('hors ligne : meme reprise avec delai', () {
    fakeAsync((async) {
      final scheduler = build()..start();
      async.flushMicrotasks();

      states.add(
        SyncEngineState(
          phase: SyncPhase.offline,
          consecutiveFailures: 1,
          nextRetryAt: clock.add(const Duration(seconds: 5)),
        ),
      );
      async.elapse(const Duration(seconds: 6));

      expect(runs, 2);
      scheduler.pause();
    });
  });

  test(
    'reconnexion necessaire : aucune reprise automatique (pas de boucle)',
    () {
      fakeAsync((async) {
        final scheduler = build()..start();
        async.flushMicrotasks();

        states.add(
          SyncEngineState(
            phase: SyncPhase.authRequired,
            consecutiveFailures: 1,
            nextRetryAt: clock.add(const Duration(seconds: 5)),
          ),
        );
        async.elapse(const Duration(minutes: 2));

        expect(runs, 1);
        scheduler.pause();
      });
    },
  );

  test('succes apres un echec : la reprise planifiee est annulee', () {
    fakeAsync((async) {
      final scheduler = build()..start();
      async.flushMicrotasks();

      states
        ..add(
          SyncEngineState(
            phase: SyncPhase.failed,
            consecutiveFailures: 1,
            nextRetryAt: clock.add(const Duration(seconds: 30)),
          ),
        )
        ..add(const SyncEngineState());
      async.elapse(const Duration(seconds: 40));

      expect(runs, 1);
      scheduler.pause();
    });
  });
}
