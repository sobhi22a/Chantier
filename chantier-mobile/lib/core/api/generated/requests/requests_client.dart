// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/approve_body.dart';
import '../models/batch_response.dart';
import '../models/create_request_request.dart';
import '../models/link_product_body.dart';
import '../models/material_request_detail_response.dart';
import '../models/paged_result_of_material_request_response.dart';
import '../models/priority.dart';
import '../models/reason_body.dart';
import '../models/receive_body.dart';
import '../models/request_ids_body.dart';
import '../models/request_status.dart';
import '../models/update_request_request.dart';

part 'requests_client.g.dart';

@RestApi()
abstract class RequestsClient {
  factory RequestsClient(Dio dio, {String? baseUrl}) = _RequestsClient;

  /// Demandes du chantier (vue « à suivre » par défaut), avec filtres, recherche, tri et pagination avec total.
  ///
  /// [view] - `toFollow` (défaut), `toApprove`, `toOrder`, `expected`, `late` (date de besoin ou livraison prévue dépassée), `toReceive`, `received`, `closed` ou `archived`. Les demandes archivées ne figurent que dans `archived`.
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
  /// [q] - Recherche dans le numéro (`DEM-014`), le produit et la remarque.
  ///
  /// [sort] - `neededBy`, `-neededBy`, `number`, `-number`, `createdAt`, `-createdAt`, `priority` ; par défaut les plus urgentes d'abord (vue à suivre) ou par date de besoin.
  ///
  /// [page] - Numéro de page, à partir de 1.
  ///
  /// [pageSize] - Taille de page (1 à 200).
  @GET('/api/v1/sites/{siteId}/requests')
  Future<PagedResultOfMaterialRequestResponse> requestsList({
    @Path('siteId') required String siteId,
    @Query('page') int? page = 1,
    @Query('pageSize') int? pageSize = 50,
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

  /// Signaler un besoin. Le numéro `DEM-nnn` est donné par le serveur. Un même `clientId` renvoyé donne 200 et la même demande, sans doublon ni nouveau numéro.
  @POST('/api/v1/sites/{siteId}/requests')
  Future<MaterialRequestDetailResponse> requestsCreate({
    @Path('siteId') required String siteId,
    @Body() required CreateRequestRequest body,
  });

  /// Valider jusqu'à 50 demandes d'un coup : un résultat par demande (`applied`, `duplicate`, `rejected` avec `code`), chacune dans sa propre transaction.
  @POST('/api/v1/sites/{siteId}/requests/batch/approve')
  Future<BatchResponse> requestsApproveBatch({
    @Path('siteId') required String siteId,
    @Body() required RequestIdsBody body,
  });

  /// Archiver jusqu'à 100 demandes d'un coup : un résultat par demande.
  @POST('/api/v1/sites/{siteId}/requests/batch/archive')
  Future<BatchResponse> requestsArchiveBatch({
    @Path('siteId') required String siteId,
    @Body() required RequestIdsBody body,
  });

  /// Une demande avec son historique (qui, quand, ancien et nouveau statut, motif).
  @GET('/api/v1/sites/{siteId}/requests/{requestId}')
  Future<MaterialRequestDetailResponse> requestsGet({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
  });

  /// Modifier une demande. Jusqu'à la validation tous les champs ; après, seulement date, urgence et remarque (droit `Requests.UpdateAny`) :.
  /// 422 `DEMANDE_VERROUILLEE` pour produit, quantité, unité ou zone. 409 `CONFLIT_VERSION` (avec l'état courant) si la version est périmée.
  @PUT('/api/v1/sites/{siteId}/requests/{requestId}')
  Future<MaterialRequestDetailResponse> requestsUpdate({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() required UpdateRequestRequest body,
  });

  /// Valider (conducteur), avec une quantité ajustée facultative. Déjà validée : 200 sans effet ; autre statut : 422 `TRANSITION_INTERDITE`.
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/approve')
  Future<MaterialRequestDetailResponse> requestsApprove({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() ApproveBody? body,
  });

  /// Archiver une demande refusée, annulée ou réceptionnée (conducteur) : jamais d'effacement. Une demande ouverte : 422 `TRANSITION_INTERDITE`.
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/archive')
  Future<MaterialRequestDetailResponse> requestsArchive({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
  });

  /// Annuler une demande demandée ou validée, avec un motif. L'auteur annule la sienne (droit `Requests.Cancel`), le conducteur toutes.
  /// (`Requests.CancelAny`). Déjà annulée : 200, le premier motif est conservé. Commandée ou au-delà : 422 `TRANSITION_INTERDITE` (contacter les Achats).
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/cancel')
  Future<MaterialRequestDetailResponse> requestsCancel({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() required ReasonBody body,
  });

  /// Rattacher un produit du catalogue à une demande en nom libre (Achats) ; le nom libre est conservé, quantité et unité sont revérifiées.
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/link-product')
  Future<MaterialRequestDetailResponse> requestsLinkProduct({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() required LinkProductBody body,
  });

  /// Réceptionner une demande livrée (chef de chantier). Déjà réceptionnée : 200 sans effet ; autre statut : 422 `TRANSITION_INTERDITE`.
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/receive')
  Future<MaterialRequestDetailResponse> requestsReceive({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() ReceiveBody? body,
  });

  /// Refuser (conducteur), avec un motif de la liste. Déjà refusée : 200 sans effet.
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/reject')
  Future<MaterialRequestDetailResponse> requestsReject({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() required ReasonBody body,
  });

  /// Restaurer une demande archivée : elle reprend son statut.
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/restore')
  Future<MaterialRequestDetailResponse> requestsRestore({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
  });

  /// Solder un manque définitif (Achats, conducteur) : livrée partiellement vers livrée, avec un motif. Réseau exigé (jamais en synchronisation).
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/settle')
  Future<MaterialRequestDetailResponse> requestsSettle({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() required ReasonBody body,
  });
}
