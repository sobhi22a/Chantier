// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/attach_body.dart';
import '../models/create_delivery_request.dart';
import '../models/delivery_detail_response.dart';
import '../models/delivery_status.dart';
import '../models/paged_result_of_delivery_response.dart';
import '../models/reason_body.dart';
import '../models/update_delivery_request.dart';

part 'deliveries_client.g.dart';

@RestApi()
abstract class DeliveriesClient {
  factory DeliveriesClient(Dio dio, {String? baseUrl}) = _DeliveriesClient;

  /// Livraisons du chantier, avec filtres, recherche, tri et pagination avec total.
  ///
  /// [requestId] - Livraisons d'une demande.
  ///
  /// [unattached] - `true` : seulement les livraisons non rattachées (à traiter).
  ///
  /// [withReserve] - `true` : seulement les livraisons reçues avec réserve.
  ///
  /// [missingNote] - `true` : seulement les livraisons sans n° de BL ni photo (« à compléter »).
  ///
  /// [status] - `Recorded` ou `Cancelled`.
  ///
  /// [supplierId] - Limiter à un fournisseur du catalogue.
  ///
  /// [productId] - Limiter à un produit du catalogue.
  ///
  /// [q] - Recherche dans le numéro (`LIV-006`), le n° de BL, le produit et le fournisseur.
  ///
  /// [from] - Date de livraison à partir de (incluse).
  ///
  /// [to] - Date de livraison jusqu'à (incluse).
  ///
  /// [sort] - `deliveryDate`, `-deliveryDate`, `number`, `-number` ; par défaut les plus récentes d'abord.
  ///
  /// [page] - Numéro de page, à partir de 1.
  ///
  /// [pageSize] - Taille de page (1 à 200).
  @GET('/api/v1/sites/{siteId}/deliveries')
  Future<PagedResultOfDeliveryResponse> deliveriesList({
    @Path('siteId') required String siteId,
    @Query('page') int? page = 1,
    @Query('pageSize') int? pageSize = 50,
    @Query('requestId') String? requestId,
    @Query('unattached') bool? unattached,
    @Query('withReserve') bool? withReserve,
    @Query('missingNote') bool? missingNote,
    @Query('status') DeliveryStatus? status,
    @Query('supplierId') String? supplierId,
    @Query('productId') String? productId,
    @Query('q') String? q,
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
    @Query('sort') String? sort,
  });

  /// Enregistrer une livraison. Le numéro `LIV-nnn` est donné par le serveur. Un même `clientId` renvoyé donne 200 et la même livraison.
  /// 422 : `UNITES_INCOMPATIBLES` (sable en m³ livré en T), `PRODUIT_DIFFERENT`, `UNITE_OBLIGATOIRE`, `QUANTITE_INVALIDE`. 400 `DATE_INVALIDE` : date dans le futur.
  @POST('/api/v1/sites/{siteId}/deliveries')
  Future<DeliveryDetailResponse> deliveriesCreate({
    @Path('siteId') required String siteId,
    @Body() required CreateDeliveryRequest body,
  });

  /// Une livraison avec son historique (qui, quand, ancienne et nouvelle valeur, motif).
  @GET('/api/v1/sites/{siteId}/deliveries/{deliveryId}')
  Future<DeliveryDetailResponse> deliveriesGet({
    @Path('siteId') required String siteId,
    @Path('deliveryId') required String deliveryId,
  });

  /// Corriger quantité, unité, date, n° de BL ou conformité tant que la demande n'est pas réceptionnée (422 `DEMANDE_NON_OUVERTE` sinon). Le numéro ne change jamais. 409 si la version est périmée.
  @PUT('/api/v1/sites/{siteId}/deliveries/{deliveryId}')
  Future<DeliveryDetailResponse> deliveriesUpdate({
    @Path('siteId') required String siteId,
    @Path('deliveryId') required String deliveryId,
    @Body() required UpdateDeliveryRequest body,
  });

  /// Rattacher une livraison non rattachée à une demande validée, commandée ou livrée partiellement du même chantier et du même produit. 422 : `PRODUIT_DIFFERENT`,.
  /// `UNITES_INCOMPATIBLES`, `DEMANDE_NON_OUVERTE`, `LIVRAISON_DEJA_RATTACHEE`. Réseau exigé (jamais en synchronisation). Pas de détachement : annuler puis ressaisir.
  @POST('/api/v1/sites/{siteId}/deliveries/{deliveryId}/attach')
  Future<DeliveryDetailResponse> deliveriesAttach({
    @Path('siteId') required String siteId,
    @Path('deliveryId') required String deliveryId,
    @Body() required AttachBody body,
  });

  /// Annuler une livraison avec un motif : elle reste visible mais n'entre plus dans aucun total, le statut de la demande est recalculé. Déjà annulée : 200, le premier motif est conservé.
  @POST('/api/v1/sites/{siteId}/deliveries/{deliveryId}/cancel')
  Future<DeliveryDetailResponse> deliveriesCancel({
    @Path('siteId') required String siteId,
    @Path('deliveryId') required String deliveryId,
    @Body() required ReasonBody body,
  });
}
