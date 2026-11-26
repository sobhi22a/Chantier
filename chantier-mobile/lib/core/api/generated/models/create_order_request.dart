// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_order_request.freezed.dart';
part 'create_order_request.g.dart';

/// Commande d'une demande validée. Quantité et unité sont celles de la demande (non modifiables) ; le montant est calculé par le serveur ; le client ne fixe ni le statut.
/// ni l'auteur. Réservé aux rôles qui voient les prix (Achats, Admin).
@Freezed()
abstract class CreateOrderRequest with _$CreateOrderRequest {
  const factory CreateOrderRequest({
    /// Fournisseur du catalogue, actif (422 `FOURNISSEUR_INACTIF` sinon).
    required String supplierId,

    /// Identifiant généré par le client : un renvoi donne 200 et la même commande, sans nouvel effet.
    String? clientId,

    /// Date de commande complète, pas dans le futur (heure d'Algérie).
    DateTime? orderDate,

    /// Livraison prévue, complète et pas avant la date de commande. Au-delà de la date de besoin : avertissement (`plannedAfterNeedDays`), jamais un blocage.
    DateTime? expectedDeliveryDate,

    /// Prix unitaire hors taxes par unité de commande, en DZD, supérieur à 0, 2 décimales au plus. Facultatif (« à renseigner »).
    double? unitPrice,

    /// N° du bon de commande (50 caractères au plus).
    String? purchaseOrderNumber,

    /// Remarque (200 caractères au plus).
    String? note,
  }) = _CreateOrderRequest;

  factory CreateOrderRequest.fromJson(Map<String, Object?> json) =>
      _$CreateOrderRequestFromJson(json);
}
