import 'dart:async';

import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/outbox_dao.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Etat de synchronisation montre en haut de **tous** les ecrans (CA-013) : compteurs exacts
/// lus dans la file d'envoi de l'utilisateur connecte, phase du moteur, derniere reussite.
///
/// Cree **par utilisateur** (il ne compte que ses saisies, CA-013.9).
class SyncStatusCubit extends Cubit<SyncStatusSnapshot> {
  SyncStatusCubit({
    required SyncEngine engine,
    required AppDatabase database,
    required String userId,
    DateTime Function()? now,
    this.staleAfter = const Duration(hours: 24),
    Duration staleCheckEvery = const Duration(minutes: 1),
  }) : _engine = engine,
       _now = now ?? DateTime.now,
       super(const SyncStatusSnapshot(indicator: SyncIndicator.upToDate)) {
    _engineState = engine.state;
    _subscriptions.addAll([
      engine.states.listen((value) => _update(() => _engineState = value)),
      database.outboxDao
          .watchCounts(userId)
          .listen((value) => _update(() => _counts = value)),
      database.syncStateDao
          .watch(SyncStateKeys.lastSuccessAt)
          .listen((value) => _update(() => _lastSuccessAt = _parse(value))),
      database.syncStateDao
          .watch(SyncStateKeys.initialSyncDone)
          .listen((value) => _update(() => _initialDone = value == 'true')),
    ]);
    // L'obsolescence depend de l'heure : reevaluee meme sans nouvel evenement.
    _ticker = Timer.periodic(staleCheckEvery, (_) => _recompute());
    _recompute();
  }

  final SyncEngine _engine;
  final DateTime Function() _now;

  /// Au-dela, bandeau « Donnees du JJ/MM/AAAA HH:MM » (H-12).
  final Duration staleAfter;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  Timer? _ticker;
  late SyncEngineState _engineState;
  OutboxCounts _counts = const OutboxCounts(toSend: 0, toCheck: 0);
  DateTime? _lastSuccessAt;
  bool _initialDone = false;

  /// « Synchroniser maintenant » : un double appui lance une seule synchronisation (CA-013.5),
  /// car le moteur partage son execution en cours.
  Future<SyncOutcome> syncNow() => _engine.run();

  void _update(void Function() change) {
    change();
    _recompute();
  }

  void _recompute() {
    if (isClosed) return;
    final last = _lastSuccessAt;
    emit(
      SyncStatusSnapshot(
        indicator: deriveIndicator(
          phase: _engineState.phase,
          toSend: _counts.toSend,
          toCheck: _counts.toCheck,
        ),
        toSend: _counts.toSend,
        toCheck: _counts.toCheck,
        lastSuccessAt: last,
        initialSyncDone: _initialDone,
        itemsReceived: _engineState.itemsReceived,
        isStale: last != null && _now().difference(last) > staleAfter,
        error: _engineState.lastError,
      ),
    );
  }

  static DateTime? _parse(String? value) =>
      value == null ? null : DateTime.tryParse(value)?.toUtc();

  @override
  Future<void> close() async {
    _ticker?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
