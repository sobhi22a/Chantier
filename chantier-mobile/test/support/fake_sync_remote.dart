import 'dart:async';

import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/sync/sync_remote.dart';

import 'api_json.dart';
import 'fake_deliveries_server.dart';
import 'fake_materials_server.dart';

typedef PushHandler =
    FutureOr<SyncPushResponse> Function(List<SyncPushOperation> operations);

/// Faux client de synchronisation (aucun appel reseau reel). Simule un serveur idempotent :
/// la premiere operation d'un `clientId` est `applied`, les suivantes `duplicate`.
class FakeSyncRemote implements SyncRemote {
  FakeSyncRemote({MeResponse? me})
    : meResponse = me ?? MeResponse.fromJson(meJson());

  MeResponse meResponse;

  /// Erreur a lever par `me()` (sinon [meResponse]).
  ApiException? meError;

  /// Pages du pull, consommees dans l'ordre. Un element [ApiException] est leve. Une fois la
  /// liste vide : page vide, `hasMore = false`.
  final List<Object> pullScript = [];

  /// Remplace le comportement par defaut du push.
  PushHandler? pushHandler;

  /// Simule une coupure apres traitement : le serveur applique le lot, mais la reponse se perd
  /// (le telephone ne saura jamais que l'envoi a reussi).
  bool loseNextPushResponse = false;

  /// Serveur des demandes de materiaux : traite les operations `request` du lot.
  final FakeMaterialsServer materials = FakeMaterialsServer();

  /// Serveur des livraisons et de leurs photos : traite les operations `delivery` et `photo`.
  late final FakeDeliveriesServer deliveries = FakeDeliveriesServer(materials);

  /// Reponse de `GET /settings/materials` (ou [settingsError]).
  MaterialSettingsResponse settingsResponse = MaterialSettingsResponse.fromJson(
    materialSettingsJson(),
  );
  ApiException? settingsError;
  int settingsCalls = 0;

  /// Version attribuee aux zones creees par le faux serveur.
  int nextVersion = 50000;

  // Enregistrements.
  int meCalls = 0;
  final List<String?> pullSinces = [];
  final List<List<SyncPushOperation>> pushBatches = [];
  final Map<String, Map<String, Object?>> _zonesByClientId = {};

  /// Zones creees par le faux serveur (une par `clientId`) : prouve l'idempotence.
  int get createdZoneCount => _zonesByClientId.length;

  List<String> get pushedClientIds => [
    for (final batch in pushBatches) ...batch.map((o) => o.clientId),
  ];

  @override
  Future<MeResponse> me() async {
    meCalls++;
    final error = meError;
    if (error != null) throw error;
    return meResponse;
  }

  @override
  Future<MaterialSettingsResponse> materialSettings() async {
    settingsCalls++;
    final error = settingsError;
    if (error != null) throw error;
    return settingsResponse;
  }

  @override
  Future<SyncPullResponse> pull({String? since, int? limit}) async {
    pullSinces.add(since);
    if (pullScript.isEmpty) {
      return SyncPullResponse.fromJson(syncPullJson(cursor: since ?? '0'));
    }
    final next = pullScript.removeAt(0);
    if (next is ApiException) throw next;
    return next as SyncPullResponse;
  }

  @override
  Future<SyncPushResponse> push(List<SyncPushOperation> operations) async {
    pushBatches.add(List.of(operations));
    if (loseNextPushResponse) {
      loseNextPushResponse = false;
      operations.forEach(_defaultResult);
      throw const NetworkApiException();
    }
    final handler = pushHandler;
    if (handler != null) return handler(operations);
    return SyncPushResponse(
      results: [for (final op in operations) _defaultResult(op)],
    );
  }

  /// Resultat du faux serveur pour [op] (le meme que sans `pushHandler`).
  SyncPushResult handle(SyncPushOperation op) => _defaultResult(op);

  SyncPushResult _defaultResult(SyncPushOperation op) {
    if (op.entity == 'request') return materials.handle(op);
    if (op.entity == 'delivery' || op.entity == 'photo') {
      return deliveries.handle(op);
    }
    final known = _zonesByClientId[op.clientId];
    if (known != null) {
      return SyncPushResult(
        clientId: op.clientId,
        status: 'duplicate',
        resource: known,
      );
    }
    final payload = Map<String, Object?>.from(op.payload as Map);
    final zone = zoneJson(
      id: 'srv-${op.clientId}',
      siteId: op.siteId!,
      clientId: op.clientId,
      block: payload['block']! as String,
      elevation: payload['elevation'] as num?,
      roomType: payload['roomType'] as String?,
      roomNumber: payload['roomNumber'] as int?,
      roomLabel: payload['roomLabel'] as String?,
      version: '${nextVersion++}',
    );
    _zonesByClientId[op.clientId] = zone;
    return SyncPushResult(
      clientId: op.clientId,
      status: 'applied',
      resource: zone,
    );
  }
}

SyncPullResponse pullPage(Map<String, Object?> json) =>
    SyncPullResponse.fromJson(json);
