// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'duplicate_ref_response.dart';
import 'order_response.dart';
import 'priority.dart';
import 'product_ref_response.dart';
import 'quantity.dart';
import 'request_delivery_item.dart';
import 'request_history_item.dart';
import 'request_status.dart';
import 'status_reason_response.dart';
import 'variance_response.dart';

part 'material_request_detail_response.freezed.dart';
part 'material_request_detail_response.g.dart';

/// Demande et son historique (le detail d'une demande).
@Freezed()
abstract class MaterialRequestDetailResponse
    with _$MaterialRequestDetailResponse {
  const factory MaterialRequestDetailResponse({
    List<RequestHistoryItem>? history,

    /// Livraisons de la demande, annulees comprises ; absentes de la synchronisation (l'entite `delivery` les porte).
    List<RequestDeliveryItem>? deliveries,
    String? id,
    String? siteId,

    /// Code du chantier (liste transversale et REST) ; absent de la synchronisation.
    String? siteCode,

    /// Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon `null`.
    String? clientId,
    DateTime? clientCreatedAt,

    /// Numero `DEM-nnn`, donne par le serveur.
    String? number,
    ProductRefResponse? product,

    /// Quantite demandee et son unite.
    Quantity? quantity,
    String? zoneId,

    /// Date de besoin (« pour le »), date complete sans fuseau.
    DateTime? neededBy,
    Priority? priority,
    String? note,
    RequestStatus? status,

    /// Motif du refus ou de l'annulation.
    StatusReasonResponse? statusReason,

    /// Recu cumule dans l'unite de la demande ; absent tant que la demande n'est pas commandee.
    Quantity? receivedQuantity,

    /// Reste a livrer, jamais negatif ; absent tant que la demande n'est pas commandee.
    Quantity? remainingQuantity,
    VarianceResponse? variance,

    /// Manque definitif accepte (« solde »).
    bool? isSettled,

    /// Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon.
    int? overdueDays,
    DuplicateRefResponse? possibleDuplicateOf,

    /// Commande active ; `null` sans commande. Ses champs commerciaux sont absents sans `Prices.View` et de la synchronisation.
    OrderResponse? order,

    /// Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »).
    bool? hasDeliveryWithoutOrder,
    String? requestedById,
    String? requestedByName,
    DateTime? archivedAt,
    String? archivedByName,

    /// Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification.
    String? version,
    DateTime? createdAt,
    String? createdByName,
    DateTime? updatedAt,
    String? updatedByName,
  }) = _MaterialRequestDetailResponse;

  factory MaterialRequestDetailResponse.fromJson(Map<String, Object?> json) =>
      _$MaterialRequestDetailResponseFromJson(json);
}
