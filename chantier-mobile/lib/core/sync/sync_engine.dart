import 'dart:async';
import 'dart:convert';

import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/sync_remote.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/converters/material_json_guard.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/data/photo_upload_service.dart';
import 'package:chantier_mobile/features/materials/domain/material_settings.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/sites/data/sync_decoder.dart';
import 'package:logging/logging.dart';

/// Moteur de synchronisation (ADR 0009) : **push** de la file d'envoi, puis **pull** par
/// curseur serveur.
///
/// * **Execution unique** : des appels concurrents (double appui, retour du reseau et minuteur
///   en meme temps) partagent la meme execution ([run]).
/// * Push par lots de [pushBatchSize] (50) **dans l'ordre de creation**, seulement les lignes de
///   l'utilisateur connecte. Chaque operation est traitee selon son resultat : `applied`,
///   `duplicate`, `conflict` ou `rejected` ; un lot peut reussir partiellement.
/// * `conflict` et `rejected` sont conserves avec leur code et **jamais rejoues seuls**.
/// * Pull jusqu'a `hasMore = false`, une page = une transaction (curseur compris) ; le curseur
///   est celui du serveur, jamais l'horloge du telephone.
/// * Fichiers des photos de bons : envoyes **apres** le push des metadonnees et le pull, un a la
///   fois ([PhotoUploadService], ADR 0013).
/// * `CURSEUR_INVALIDE` ou changement de `permissionsVersion` : reprise a zero **sans toucher a
///   la file d'envoi**.
/// * Echec : l'operation reste a envoyer, reprise avec delai exponentiel ([Backoff]).
class SyncEngine {
  SyncEngine({
    required AppDatabase database,
    required SyncRemote remote,
    required SitesRepository sites,
    required MaterialsRepository materials,
    PhotoUploadService? photoUploads,
    required String? Function() currentUserId,
    required ConnectivityMonitor connectivity,
    Backoff? backoff,
    DateTime Function()? now,
    this.onProfile,
    this.pushBatchSize = 50,
    this.pullPageSize = 200,
    this.fullReloadAfterDays = 60,
  }) : _db = database,
       _remote = remote,
       _sites = sites,
       _materials = materials,
       _photoUploads = photoUploads,
       _currentUserId = currentUserId,
       _connectivity = connectivity,
       _backoff = backoff ?? Backoff(),
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final SyncRemote _remote;
  final SitesRepository _sites;
  final MaterialsRepository _materials;
  final PhotoUploadService? _photoUploads;
  final String? Function() _currentUserId;
  final ConnectivityMonitor _connectivity;
  final Backoff _backoff;
  final DateTime Function() _now;

  /// Appele avec le profil recu de `GET /auth/me` a chaque execution (permissions, mot de passe
  /// provisoire, langue).
  final Future<void> Function(MeResponse me)? onProfile;

  final int pushBatchSize;
  final int pullPageSize;

  /// Jours sans synchronisation reussie au-dela desquels tout est recharge (R3-05) ; `0` : jamais.
  final int fullReloadAfterDays;

  static final Logger _log = Logger('SyncEngine');

  final StreamController<SyncEngineState> _states =
      StreamController<SyncEngineState>.broadcast();
  SyncEngineState _state = const SyncEngineState();
  Future<SyncOutcome>? _inFlight;

  SyncEngineState get state => _state;

  Stream<SyncEngineState> get states => _states.stream;

  /// Lance une synchronisation, ou rejoint celle qui est en cours.
  Future<SyncOutcome> run() {
    final running = _inFlight;
    if (running != null) return running;
    final future = _execute().whenComplete(() => _inFlight = null);
    _inFlight = future;
    return future;
  }

  Future<void> dispose() => _states.close();

  void _emit(SyncEngineState next) {
    _state = next;
    if (!_states.isClosed) _states.add(next);
  }

  Future<SyncOutcome> _execute() async {
    final userId = _currentUserId();
    if (userId == null) return SyncOutcome.notSignedIn;

    _emit(
      SyncEngineState(
        phase: SyncPhase.syncing,
        consecutiveFailures: _state.consecutiveFailures,
      ),
    );

    try {
      if (!await _connectivity.hasNetworkInterface()) {
        throw const NetworkApiException();
      }
      await _protectOtherUsersData(userId);
      await _refreshProfile();
      await _refreshMaterialSettings();
      final toRetry = await _push(userId);
      await _reloadIfTooOld();
      final received = await _pull(userId);
      await _markSuccess();
      _emit(SyncEngineState(itemsReceived: received));
      // Les fichiers des photos partent en dernier, un a la fois : une coupure en cours de route
      // ne fait pas perdre les donnees deja synchronisees, et les fichiers restants repartent
      // a la prochaine synchronisation (delai exponentiel).
      await _photoUploads?.uploadPending(userId);
      if (toRetry > 0) {
        // Echec momentane du serveur sur certaines operations : rien n'est perdu, reprise avec
        // delai exponentiel.
        return _fail(
          SyncPhase.failed,
          const ServerApiException(status: 503, code: 'ERREUR_TEMPORAIRE'),
          SyncOutcome.failed,
        );
      }
      return SyncOutcome.completed;
    } on _AuthRequired {
      return _fail(SyncPhase.authRequired, null, SyncOutcome.authRequired);
    } on ApiException catch (error) {
      return _failFrom(error);
    } on SyncDecodeException catch (error) {
      // Reponse du serveur illisible : le curseur n'a pas avance, rien n'est perdu.
      _log.warning('Ligne de synchronisation illisible (${error.entity}).');
      return _fail(
        SyncPhase.failed,
        const UnknownApiException(),
        SyncOutcome.failed,
      );
    }
  }

  SyncOutcome _failFrom(ApiException error) {
    switch (error) {
      case NetworkApiException() || TimeoutApiException():
        return _fail(SyncPhase.offline, error, SyncOutcome.offline);
      case UnauthorizedApiException():
        return _fail(SyncPhase.authRequired, error, SyncOutcome.authRequired);
      case ForbiddenApiException(isPasswordChangeRequired: true):
        return _fail(SyncPhase.authRequired, error, SyncOutcome.authRequired);
      default:
        return _fail(SyncPhase.failed, error, SyncOutcome.failed);
    }
  }

  SyncOutcome _fail(SyncPhase phase, ApiException? error, SyncOutcome outcome) {
    final failures = _state.consecutiveFailures + 1;
    final retryAfter = error is TooManyRequestsApiException
        ? error.retryAfter
        : null;
    final delay = _backoff.delay(failures, minimum: retryAfter);
    _log.info(
      'Synchronisation interrompue (${outcome.name}) ; reprise dans ${delay.inSeconds} s.',
    );
    _emit(
      SyncEngineState(
        phase: phase,
        lastError: error,
        consecutiveFailures: failures,
        nextRetryAt: _now().add(delay),
      ),
    );
    return outcome;
  }

  /// Telephone partage : si les donnees locales appartiennent a un autre compte, elles sont
  /// purgees avant tout appel (la file d'envoi est conservee, chaque ligne a son proprietaire).
  Future<void> _protectOtherUsersData(String userId) async {
    final owner = await _db.syncStateDao.get(SyncStateKeys.ownerUserId);
    if (owner != null && owner != userId) {
      _log.warning(
        'Donnees locales d\'un autre compte : purge avant synchronisation.',
      );
      await _db.purgeSyncedData();
    }
  }

  /// `GET /auth/me` : confirme que le serveur repond, met a jour le profil et detecte un
  /// changement de permissions (les champs visibles ont pu changer : repart de zero).
  Future<void> _refreshProfile() async {
    final me = await _remote.me();
    final previous = await _db.syncStateDao.get(
      SyncStateKeys.permissionsVersion,
    );
    if (previous != null && previous != me.permissionsVersion) {
      _log.info('Permissions modifiees : rechargement complet des donnees.');
      // Le montant du marche stocke est efface tout de suite (R1-03), puis rendu par le
      // rechargement a ceux qui y ont encore droit. La file d'envoi n'est pas touchee.
      await _db.startFullReload(clearRestrictedFields: true);
    }
    await _db.syncStateDao.set(
      SyncStateKeys.permissionsVersion,
      me.permissionsVersion,
    );
    await _db.syncStateDao.set(
      SyncStateKeys.lastServerContactAt,
      _now().toUtc().toIso8601String(),
    );
    await onProfile?.call(me);
    if (me.mustChangePassword) {
      // Mot de passe provisoire : le serveur refuse tout le reste (403). Rien n'est perdu.
      throw const _AuthRequired();
    }
  }

  /// `GET /settings/materials` : copie locale des reglages (date de besoin par defaut, motifs,
  /// tolerance) pour le hors ligne. Une panne reseau ou une session refusee interrompt la
  /// synchronisation comme partout ; toute autre reponse d'erreur laisse la derniere copie
  /// (valeurs par defaut au premier lancement) : les reglages ne bloquent jamais l'envoi.
  Future<void> _refreshMaterialSettings() async {
    try {
      final response = await _remote.materialSettings();
      await _materials.saveSettings(_toSettings(response));
    } on ApiException catch (error) {
      switch (error) {
        case NetworkApiException() ||
            TimeoutApiException() ||
            UnauthorizedApiException() ||
            ForbiddenApiException():
          rethrow;
        default:
          _log.warning('Reglages des materiaux indisponibles (${error.code}).');
      }
    }
  }

  static MaterialSettings _toSettings(MaterialSettingsResponse response) =>
      MaterialSettings.fromJson({
        'defaultNeededByDays': response.defaultNeededByDays,
        'deliveryTolerancePercent': response.deliveryTolerancePercent,
        'maxPhotosPerDelivery': response.maxPhotosPerDelivery,
        'maxPhotoBytes': response.maxPhotoBytes,
        'noteMaxLength': response.noteMaxLength,
        'reasons': {
          'rejection': response.reasons.rejection,
          'requestCancellation': response.reasons.requestCancellation,
          'orderCancellation': response.reasons.orderCancellation,
          'settle': response.reasons.settle,
          'deliveryCancellation': response.reasons.deliveryCancellation,
          'reserve': response.reasons.reserve,
        },
      });

  // --- Push ----------------------------------------------------------------------------------

  /// Retourne le nombre d'operations a **renvoyer plus tard** (resultat `retry`, ou aucune reponse
  /// du serveur pour elles) : elles restent en file et ne sont **pas** renvoyees dans la meme
  /// execution (un serveur qui repond toujours `retry` ne doit pas provoquer de boucle).
  Future<int> _push(String userId) async {
    // Une operation restee `sending` (application tuee pendant l'envoi) repart : le `clientId`
    // rend le renvoi sans danger. L'execution unique garantit qu'aucun envoi n'est en cours.
    await _db.outboxDao.recoverInterrupted();
    final retried = <int>{};
    // `clientId` des operations a renvoyer plus tard : celles qui les visent (correction ou
    // validation d'une demande creee hors ligne, livraison, photo) **restent en file** elles aussi
    // (R3-01) : leur parent sera applique au rejeu, elles ne doivent ni partir ni etre rejetees.
    final blocked = <String>{};
    while (true) {
      var limit = pushBatchSize + retried.length;
      late List<OutboxRow> batch;
      while (true) {
        final fetched = await _db.outboxDao.pendingFor(userId, limit: limit);
        batch = [
          for (final row in fetched)
            if (!retried.contains(row.id) && !_dependsOn(row, blocked)) row,
        ];
        // Les operations ecartees comptent aussi comme « a renvoyer plus tard ».
        for (final row in fetched) {
          if (!retried.contains(row.id) && _dependsOn(row, blocked)) {
            retried.add(row.id);
            blocked.add(row.clientId);
          }
        }
        batch = batch.take(pushBatchSize).toList();
        if (batch.isNotEmpty || fetched.length < limit) break;
        limit += pushBatchSize;
      }
      if (batch.isEmpty) return retried.length;
      await _db.outboxDao.markSending([for (final row in batch) row.id]);

      final SyncPushResponse response;
      try {
        response = await _remote.push([
          for (final row in batch) _toOperation(row),
        ]);
      } on ApiException catch (error) {
        await _afterBatchFailure(batch, error);
        rethrow;
      }
      retried.addAll(await _applyResults(batch, response, blocked));
    }
  }

  /// Vrai si [row] vise (par `requestClientId`, `deliveryClientId` ou `zoneClientId`) une
  /// operation de [clientIds].
  static bool _dependsOn(OutboxRow row, Set<String> clientIds) {
    if (clientIds.isEmpty) return false;
    final Object? decoded;
    try {
      decoded = jsonDecode(row.payloadJson);
    } on FormatException {
      return false;
    }
    if (decoded is! Map) return false;
    final payload = decoded;
    return const [
      'requestClientId',
      'deliveryClientId',
      'zoneClientId',
    ].any((key) => payload[key] is String && clientIds.contains(payload[key]));
  }

  SyncPushOperation _toOperation(OutboxRow row) => SyncPushOperation(
    clientId: row.clientId,
    entity: row.entity,
    operation: row.operation,
    siteId: row.siteId,
    payload: jsonDecode(row.payloadJson),
    baseVersion: row.baseVersion?.toString(),
  );

  /// Lot en echec : les operations repartent a l'etat `pending` (tentative comptee), sauf un lot
  /// que le serveur juge mal forme (400) ou trop gros (413) : rejoue tel quel il echouerait
  /// toujours, il passe donc « a verifier » avec son code.
  Future<void> _afterBatchFailure(
    List<OutboxRow> batch,
    ApiException error,
  ) async {
    for (final row in batch) {
      switch (error) {
        case ValidationApiException() || PayloadTooLargeApiException():
          await _db.outboxDao.markFailed(
            row.id,
            status: OutboxStatus.rejected,
            errorCode: error.code ?? 'VALIDATION',
          );
        default:
          await _db.outboxDao.markRetry(row.id, errorCode: error.code);
      }
    }
  }

  /// Retourne les identifiants des operations a renvoyer plus tard.
  Future<Set<int>> _applyResults(
    List<OutboxRow> batch,
    SyncPushResponse response,
    Set<String> blocked,
  ) async {
    final byClientId = {for (final r in response.results) r.clientId: r};
    final retry = <int>{};
    for (final row in batch) {
      final result = byClientId[row.clientId];
      if (result == null) {
        // Le serveur n'a pas repondu pour cette operation : elle sera renvoyee (idempotent).
        await _db.outboxDao.markRetry(row.id);
        retry.add(row.id);
        blocked.add(row.clientId);
        continue;
      }
      // Une operation qui vise une operation a renvoyer ne peut pas etre jugee : si le serveur
      // l'a refusee (parent introuvable) ou mise en conflit, elle reste en file, intacte.
      final parentWaiting =
          _dependsOn(row, blocked) &&
          (result.status == 'rejected' || result.status == 'conflict');
      if (parentWaiting) {
        await _db.outboxDao.markRetry(row.id);
        retry.add(row.id);
        blocked.add(row.clientId);
        continue;
      }
      if (await _applyResult(row, result)) {
        retry.add(row.id);
        blocked.add(row.clientId);
      }
    }
    return retry;
  }

  /// Vrai si l'operation doit etre renvoyee plus tard (`retry` : echec momentane du serveur,
  /// `ERREUR_TEMPORAIRE`, rien n'a ete ecrit ; ou statut inconnu).
  Future<bool> _applyResult(OutboxRow row, SyncPushResult result) async {
    switch (result.status) {
      case 'applied' || 'duplicate':
        try {
          switch (row.entity) {
            case 'zone':
              await _sites.applyPushedZone(
                operationClientId: row.clientId,
                resource: result.resource,
                merged: result.merged ?? false,
              );
            case 'request':
              await _materials.applyPushedRequest(result.resource);
            case 'delivery':
              await _materials.applyPushedDelivery(result.resource);
            case 'photo':
              await _materials.applyPushedPhoto(result.resource);
          }
          await _db.outboxDao.deleteOperation(row.id);
        } on SyncDecodeException {
          await _db.outboxDao.markFailed(
            row.id,
            status: OutboxStatus.rejected,
            errorCode: 'ERREUR_INTERNE',
          );
        }
        return false;
      case 'conflict':
        // Le serveur gagne : sa version est gardee avec la saisie pour l'ecran « A verifier »
        // (rien n'est applique, rien n'est supprime) et la ligne locale la suit.
        if (row.entity == 'request') {
          await _materials.applyServerState(result.current);
        } else if (row.entity == 'delivery') {
          await _materials.applyServerDelivery(result.current);
        }
        await _db.outboxDao.markFailed(
          row.id,
          status: OutboxStatus.conflict,
          errorCode: result.code ?? 'CONFLIT_VERSION',
          conflictJson: _conflictJson(row, result),
          conflictFields: result.conflictFields == null
              ? null
              : jsonEncode(result.conflictFields),
        );
        return false;
      case 'rejected':
        await _db.outboxDao.markFailed(
          row.id,
          status: OutboxStatus.rejected,
          errorCode: result.code ?? 'VALIDATION',
        );
        return false;
      default:
        await _db.outboxDao.markRetry(row.id, errorCode: result.code);
        return true;
    }
  }

  /// Etat du serveur d'un `conflict`, garde pour l'ecran « A verifier ». Une demande ou une
  /// livraison passe par la liste blanche : jamais un prix, un montant ni un telephone (ADR 0012).
  static String? _conflictJson(OutboxRow row, SyncPushResult result) {
    final current = result.current;
    if (current == null) return null;
    return switch (row.entity) {
      'request' => MaterialJsonGuard.sanitizeRequestState(current),
      'delivery' => MaterialJsonGuard.sanitizeDeliveryState(current),
      _ => jsonEncode(current),
    };
  }

  // --- Pull ----------------------------------------------------------------------------------

  /// Retourne le nombre de lignes recues.
  Future<int> _pull(String userId) async {
    var received = 0;
    var restarted = false;
    var since = await _db.syncStateDao.get(SyncStateKeys.cursor);
    while (true) {
      final SyncPullResponse page;
      try {
        page = await _remote.pull(since: since, limit: pullPageSize);
      } on ValidationApiException catch (error) {
        if (error.code != 'CURSEUR_INVALIDE' || restarted) rethrow;
        // Curseur illisible : repart de zero, sans toucher a la file d'envoi.
        restarted = true;
        await _db.syncStateDao.resetCursor();
        since = null;
        continue;
      }
      // Signal du serveur (R3-05) : des lignes sont sorties de la fenetre depuis ce curseur, le
      // telephone en garde peut-etre une version perimee. Rechargement complet, saisies en attente
      // gardees ; le signal est ignore jusqu'a la fin de ce rechargement (drapeau `full_reload`).
      if (page.resetRequired &&
          await _db.syncStateDao.get(SyncStateKeys.fullReload) != 'true') {
        _log.info(
          'Fenetre de synchronisation depassee : rechargement complet.',
        );
        await _db.startWindowReload();
        since = null;
        continue;
      }
      final result = await _sites.applyPullPage(page, ownerUserId: userId);
      received += result.applied;
      _emit(
        SyncEngineState(
          phase: SyncPhase.syncing,
          itemsReceived: received,
          consecutiveFailures: _state.consecutiveFailures,
        ),
      );
      if (!page.hasMore) return received;
      since = page.cursor;
    }
  }

  /// Plus de [fullReloadAfterDays] jours sans synchronisation reussie : le serveur n'a pas pu
  /// signaler les changements sortis de sa fenetre (aucune pierre tombale) ; tout est recharge.
  Future<void> _reloadIfTooOld() async {
    if (fullReloadAfterDays <= 0) return;
    final text = await _db.syncStateDao.get(SyncStateKeys.lastSuccessAt);
    final last = text == null ? null : DateTime.tryParse(text);
    if (last == null) return; // premiere synchronisation : rien de perime
    if (await _db.syncStateDao.get(SyncStateKeys.fullReload) == 'true') return;
    if (_now().toUtc().difference(last.toUtc()).inDays < fullReloadAfterDays) {
      return;
    }
    _log.info('Derniere synchronisation trop ancienne : rechargement complet.');
    await _db.startWindowReload();
  }

  Future<void> _markSuccess() async {
    final now = _now().toUtc().toIso8601String();
    await _db.syncStateDao.setAll({
      SyncStateKeys.lastSuccessAt: now,
      SyncStateKeys.lastServerContactAt: now,
    });
  }
}

/// Session a renouveler : interrompt l'execution sans erreur reseau.
class _AuthRequired implements Exception {
  const _AuthRequired();
}
