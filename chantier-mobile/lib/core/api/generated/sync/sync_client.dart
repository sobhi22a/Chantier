// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/sync_pull_response.dart';
import '../models/sync_push_request.dart';
import '../models/sync_push_response.dart';

part 'sync_client.g.dart';

@RestApi()
abstract class SyncClient {
  factory SyncClient(Dio dio, {String? baseUrl}) = _SyncClient;

  /// Changements depuis le curseur (lecture).
  ///
  /// `since` est le curseur renvoyé par le serveur (jamais l'horloge du téléphone) ; absent ou `0` = première synchronisation.
  /// `siteId` est facultatif : absent = tous les chantiers visibles. Répéter l'appel tant que `hasMore` vaut vrai.
  /// Une ligne n'est à appliquer que si sa `version` est plus grande que celle déjà connue.
  ///
  /// [since] - Curseur reçu du serveur ; absent ou `0` = première synchronisation.
  ///
  /// [siteId] - Limiter à un chantier (404 s'il n'est pas affecté) ; absent = tous les chantiers visibles.
  ///
  /// [limit] - Nombre de lignes par page (1 à 500, 200 par défaut).
  @GET('/api/v1/sync/changes')
  Future<SyncPullResponse> syncChanges({
    @Query('limit') int? limit = 200,
    @Query('since') String? since,
    @Query('siteId') String? siteId,
  });

  /// Envoyer un lot d'opérations saisies hors ligne.
  ///
  /// Réponse 200 avec un résultat par opération, dans l'ordre : `applied`, `duplicate` (déjà reçue, éventuellement.
  /// `merged`), `conflict` ou `rejected` (avec `code`). Un lot peut réussir partiellement : ne rejouer que ce qui doit l'être.
  @POST('/api/v1/sync/push')
  Future<SyncPushResponse> syncPush({@Body() required SyncPushRequest body});
}
