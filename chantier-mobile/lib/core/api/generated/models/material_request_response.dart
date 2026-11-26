// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'duplicate_ref_response.dart';
import 'order_response.dart';
import 'priority.dart';
import 'product_ref_response.dart';
import 'quantity.dart';
import 'request_status.dart';
import 'status_reason_response.dart';
import 'variance_response.dart';

part 'material_request_response.freezed.dart';
part 'material_request_response.g.dart';

/// Demande de materiaux telle que renvoyee par l'API (liste, detail, actions). Les clés absentes ne sont pas ecrites.
/// Le statut, le recu, le reste et l'ecart sont calcules par le serveur : un client ne les envoie jamais.
@Freezed()
abstract class MaterialRequestResponse with _$MaterialRequestResponse {
  const factory MaterialRequestResponse({
    required String id,
    required String siteId,

    /// Numero `DEM-nnn`, donne par le serveur.
    required String number,
    required ProductRefResponse product,

    /// Quantite demandee et son unite.
    required Quantity quantity,

    /// Date de besoin (« pour le »), date complete sans fuseau.
    required DateTime neededBy,
    required Priority priority,
    required RequestStatus status,

    /// Manque definitif accepte (« solde »).
    required bool isSettled,

    /// Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon.
    required int overdueDays,
    required String requestedById,

    /// Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification.
    required String version,
    required DateTime createdAt,

    /// Code du chantier (liste transversale et REST) ; absent de la synchronisation.
    String? siteCode,

    /// Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon `null`.
    String? clientId,
    DateTime? clientCreatedAt,
    String? zoneId,
    String? note,

    /// Motif du refus ou de l'annulation.
    StatusReasonResponse? statusReason,

    /// Recu cumule dans l'unite de la demande ; absent tant que la demande n'est pas commandee.
    Quantity? receivedQuantity,

    /// Reste a livrer, jamais negatif ; absent tant que la demande n'est pas commandee.
    Quantity? remainingQuantity,
    VarianceResponse? variance,
    DuplicateRefResponse? possibleDuplicateOf,

    /// Commande active ; `null` sans commande. Ses champs commerciaux sont absents sans `Prices.View` et de la synchronisation.
    OrderResponse? order,

    /// Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »).
    bool? hasDeliveryWithoutOrder,
    String? requestedByName,
    DateTime? archivedAt,
    String? archivedByName,
    String? createdByName,
    DateTime? updatedAt,
    String? updatedByName,
  }) = _MaterialRequestResponse;

  factory MaterialRequestResponse.fromJson(Map<String, Object?> json) =>
      _$MaterialRequestResponseFromJson(json);
}
