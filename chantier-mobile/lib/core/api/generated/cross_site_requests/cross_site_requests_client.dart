// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/paged_result_of_material_request_response.dart';
import '../models/priority.dart';
import '../models/request_status.dart';

part 'cross_site_requests_client.g.dart';

@RestApi()
abstract class CrossSiteRequestsClient {
  factory CrossSiteRequestsClient(Dio dio, {String? baseUrl}) =
      _CrossSiteRequestsClient;

  /// Demandes de mes chantiers (mêmes filtres que la liste d'un chantier, avec le code du chantier).
  ///
  /// [siteId] - Limiter à un chantier (404 s'il n'est pas affecté).
  ///
  /// [view] - `toFollow` (défaut), `toApprove`, `toOrder`, `expected`, `late` (date de besoin ou livraison prévue dépassée), `toReceive`, `received`, `closed` ou `archived`.
  ///
  /// [mine] - Seulement mes demandes.
  ///
  /// [status] - Limiter à un statut.
  ///
  /// [priority] - Limiter à une urgence.
  ///
  /// [zoneId] - Limiter à une zone.
  ///
  /// [productId] - Limiter à un produit du catalogue.
  ///
  /// [supplierId] - Limiter aux demandes dont la commande active est chez ce fournisseur.
  ///
  /// [from] - Date de besoin à partir de (incluse).
  ///
  /// [to] - Date de besoin jusqu'à (incluse).
  ///
  /// [q] - Recherche dans le numéro, le produit et la remarque.
  ///
  /// [sort] - `neededBy`, `-neededBy`, `number`, `-number`, `createdAt`, `-createdAt`, `priority`.
  ///
  /// [page] - Numéro de page, à partir de 1.
  ///
  /// [pageSize] - Taille de page (1 à 200).
  @GET('/api/v1/requests')
  Future<PagedResultOfMaterialRequestResponse> crossSiteRequestsList({
    @Query('page') int? page = 1,
    @Query('pageSize') int? pageSize = 50,
    @Query('siteId') String? siteId,
    @Query('view') String? view,
    @Query('mine') bool? mine,
    @Query('status') RequestStatus? status,
    @Query('priority') Priority? priority,
    @Query('zoneId') String? zoneId,
    @Query('productId') String? productId,
    @Query('supplierId') String? supplierId,
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
    @Query('q') String? q,
    @Query('sort') String? sort,
  });
}
