// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_zone_request.dart';
import '../models/cursor_page_of_zone_response.dart';
import '../models/update_zone_request.dart';
import '../models/zone_response.dart';

part 'zones_client.g.dart';

@RestApi()
abstract class ZonesClient {
  factory ZonesClient(Dio dio, {String? baseUrl}) = _ZonesClient;

  /// Zones du chantier, du plus bas au plus haut, avec pagination par curseur.
  ///
  /// [block] - Limiter à un bloc.
  ///
  /// [q] - Recherche dans le bloc et le libellé.
  ///
  /// [includeArchived] - Inclure les zones archivées.
  ///
  /// [pageSize] - Taille de page (1 à 200).
  ///
  /// [cursor] - `nextCursor` de la page précédente (opaque).
  @GET('/api/v1/sites/{siteId}/zones')
  Future<CursorPageOfZoneResponse> zonesList({
    @Path('siteId') required String siteId,
    @Query('includeArchived') bool? includeArchived = false,
    @Query('pageSize') int? pageSize = 100,
    @Query('block') String? block,
    @Query('q') String? q,
    @Query('cursor') String? cursor,
  });

  /// Ajouter une zone. Un même `clientId` renvoyé donne 200 et la même zone, sans doublon.
  @POST('/api/v1/sites/{siteId}/zones')
  Future<ZoneResponse> zonesCreate({
    @Path('siteId') required String siteId,
    @Body() required CreateZoneRequest body,
  });

  /// Une zone du chantier.
  @GET('/api/v1/sites/{siteId}/zones/{zoneId}')
  Future<ZoneResponse> zonesGet({
    @Path('siteId') required String siteId,
    @Path('zoneId') required String zoneId,
  });

  /// Modifier une zone. `version` détecte une modification concurrente (409 `CONFLIT_VERSION`) ; 422 `ZONE_EXISTANTE` si la position est prise.
  @PUT('/api/v1/sites/{siteId}/zones/{zoneId}')
  Future<ZoneResponse> zonesUpdate({
    @Path('siteId') required String siteId,
    @Path('zoneId') required String zoneId,
    @Body() required UpdateZoneRequest body,
  });

  /// Archiver une zone (Admin, ConducteurTravaux) : elle disparaît des choix mais pas de l'historique.
  @POST('/api/v1/sites/{siteId}/zones/{zoneId}/archive')
  Future<ZoneResponse> zonesArchive({
    @Path('siteId') required String siteId,
    @Path('zoneId') required String zoneId,
  });

  /// Restaurer une zone archivée (422 `ZONE_EXISTANTE` si une zone identique a été créée depuis).
  @POST('/api/v1/sites/{siteId}/zones/{zoneId}/restore')
  Future<ZoneResponse> zonesRestore({
    @Path('siteId') required String siteId,
    @Path('zoneId') required String zoneId,
  });
}
