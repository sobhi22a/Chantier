import 'package:chantier_mobile/core/api/generated/export.dart';

/// Ce dont le moteur de synchronisation a besoin du serveur. L'implementation de production
/// (`SitesRemoteSource`) appelle les clients generes ; les tests utilisent un faux serveur.
///
/// Chaque methode leve une `ApiException` typee en cas d'echec.
abstract interface class SyncRemote {
  /// `GET /auth/me` : profil, permissions et `permissionsVersion`. Sert aussi d'appel leger qui
  /// confirme que le serveur est joignable (un reseau detecte ne garantit pas internet).
  Future<MeResponse> me();

  /// `GET /sync/changes` : une page de changements depuis le curseur serveur.
  Future<SyncPullResponse> pull({String? since, int? limit});

  /// `POST /sync/push` : un lot d'operations ; un resultat par operation.
  Future<SyncPushResponse> push(List<SyncPushOperation> operations);
}
