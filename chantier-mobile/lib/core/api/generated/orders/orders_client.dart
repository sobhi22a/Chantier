// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_order_request.dart';
import '../models/material_request_detail_response.dart';
import '../models/reason_body.dart';
import '../models/update_order_request.dart';

part 'orders_client.g.dart';

@RestApi()
abstract class OrdersClient {
  factory OrdersClient(Dio dio, {String? baseUrl}) = _OrdersClient;

  /// Commander une demande validée : elle passe à `Ordered`, puis son statut est recalculé d'après les livraisons déjà retenues (livraison reçue avant la commande).
  /// Montant = quantité × prix unitaire, arrondi au centime (300 sacs × 780,00 = 234 000,00 DZD). Un même `clientId` renvoyé donne 200 et la même commande.
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/order')
  Future<MaterialRequestDetailResponse> ordersCreate({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() required CreateOrderRequest body,
  });

  /// Modifier la commande (fournisseur, livraison prévue, prix, n° de bon de commande, remarque) tant que la demande n'est pas livrée. 409 `CONFLIT_VERSION` si la version est périmée.
  @PUT('/api/v1/sites/{siteId}/requests/{requestId}/order')
  Future<MaterialRequestDetailResponse> ordersUpdate({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() required UpdateOrderRequest body,
  });

  /// Annuler la commande d'une demande sans livraison non annulée, avec un motif : la demande redevient `Validated`. Avec une livraison : 422 `TRANSITION_INTERDITE`.
  @POST('/api/v1/sites/{siteId}/requests/{requestId}/order/cancel')
  Future<MaterialRequestDetailResponse> ordersCancel({
    @Path('siteId') required String siteId,
    @Path('requestId') required String requestId,
    @Body() required ReasonBody body,
  });
}
