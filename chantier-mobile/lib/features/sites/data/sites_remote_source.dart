import 'package:chantier_mobile/core/api/api_clients.dart';
import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/sync/sync_remote.dart';

/// Acces reseau de la synchronisation, par les clients generes (ADR 0006).
class SitesRemoteSource implements SyncRemote {
  SitesRemoteSource(this._clients);

  final ApiClients _clients;

  @override
  Future<MeResponse> me() => ApiClients.guard(_clients.auth.authMe);

  @override
  Future<SyncPullResponse> pull({String? since, int? limit}) =>
      ApiClients.guard(
        () => _clients.sync.syncChanges(since: since, limit: limit ?? 200),
      );

  @override
  Future<SyncPushResponse> push(List<SyncPushOperation> operations) =>
      ApiClients.guard(
        () => _clients.sync.syncPush(
          body: SyncPushRequest(operations: operations),
        ),
      );
}
