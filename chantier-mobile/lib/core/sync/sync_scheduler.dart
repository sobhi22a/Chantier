import 'dart:async';

import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';

/// Declencheurs de la synchronisation (ADR 0009, CA-013.4). **Premier plan seulement** : pas de
/// boucle ni de travail en arriere-plan (batterie et donnees) ; WorkManager est un lot ulterieur.
///
/// * demarrage et retour au premier plan ([start], [resume]) ;
/// * retour du reseau (`ConnectivityMonitor.onNetworkAvailable`) : le moteur confirme par un
///   appel leger (`GET /auth/me`) qu'internet est bien joignable ;
/// * 2 s apres un enregistrement local ([notifyLocalWrite]) ;
/// * a intervalle regulier (5 min, parametrable) ;
/// * reprise apres un echec, au delai du moteur (exponentiel avec aleas) ; **pas** de reprise
///   automatique quand une reconnexion est necessaire.
/// Le bouton « Synchroniser maintenant » appelle directement `SyncEngine.run()` (execution unique).
class SyncScheduler {
  SyncScheduler({
    required SyncEngine engine,
    required ConnectivityMonitor connectivity,
    this.interval = const Duration(minutes: 5),
    this.localWriteDelay = const Duration(seconds: 2),
    DateTime Function()? now,
  }) : _engine = engine,
       _connectivity = connectivity,
       _now = now ?? DateTime.now;

  final SyncEngine _engine;
  final ConnectivityMonitor _connectivity;
  final Duration interval;
  final Duration localWriteDelay;
  final DateTime Function() _now;

  Timer? _periodic;
  Timer? _retry;
  Timer? _debounce;
  StreamSubscription<void>? _network;
  StreamSubscription<SyncEngineState>? _engineStates;

  bool get isActive => _periodic != null;

  /// Demarre les declencheurs et lance une synchronisation tout de suite.
  void start() {
    if (isActive) return;
    _periodic = Timer.periodic(interval, (_) => _trigger());
    _network = _connectivity.onNetworkAvailable.listen((_) => _trigger());
    _engineStates = _engine.states.listen(_scheduleRetry);
    _trigger();
  }

  /// Application passee en arriere-plan : plus aucun minuteur.
  void pause() {
    _periodic?.cancel();
    _periodic = null;
    _retry?.cancel();
    _debounce?.cancel();
    unawaited(_network?.cancel());
    unawaited(_engineStates?.cancel());
    _network = null;
    _engineStates = null;
  }

  /// Retour au premier plan : redemarre et synchronise.
  void resume() => start();

  /// Une saisie vient d'etre enregistree localement : envoi dans [localWriteDelay] (les
  /// enregistrements rapproches partent ensemble, dans un seul lot).
  void notifyLocalWrite() {
    if (!isActive) return;
    _debounce?.cancel();
    _debounce = Timer(localWriteDelay, _trigger);
  }

  void _trigger() => unawaited(_engine.run());

  void _scheduleRetry(SyncEngineState state) {
    _retry?.cancel();
    final retryAt = state.nextRetryAt;
    final retryable =
        state.phase == SyncPhase.offline || state.phase == SyncPhase.failed;
    if (!retryable || retryAt == null) return;
    final wait = retryAt.difference(_now());
    _retry = Timer(wait.isNegative ? Duration.zero : wait, _trigger);
  }
}
