// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'conformity.dart';
import 'quantity_body.dart';

part 'create_delivery_request.freezed.dart';
part 'create_delivery_request.g.dart';

/// Enregistrement d'une livraison, y compris hors ligne : `clientId` rend l'envoi idempotent. Le client ne fixe ni le numéro, ni le statut, ni le montant, ni le motif de.
/// non-rattachement. Une livraison est un fait de chantier : elle n'est jamais refusée à cause du statut de la demande (elle est alors enregistrée non rattachée).
@Freezed()
abstract class CreateDeliveryRequest with _$CreateDeliveryRequest {
  const factory CreateDeliveryRequest({
    /// Quantité reçue, dans l'unité de la demande ou une unité convertible (sac, kg, T) ; sinon 422 `UNITES_INCOMPATIBLES`.
    required QuantityBody? quantity,

    /// Identifiant généré par le téléphone : un renvoi donne 200 et la même livraison, sans nouveau numéro.
    String? clientId,

    /// Heure du téléphone (« saisi le ») : information seulement.
    DateTime? clientCreatedAt,

    /// Demande livrée ; absente = livraison non rattachée. Une demande d'un autre chantier : 404.
    String? requestId,

    /// Fournisseur du catalogue (par défaut celui de la commande) ; exactement un de `supplierId` et `freeSupplierName`.
    String? supplierId,

    /// « Autre fournisseur » : nom libre de 3 à 100 caractères.
    String? freeSupplierName,

    /// Produit du catalogue ; sans demande seulement (avec une demande, c'est celui de la demande : un autre produit donne 422 `PRODUIT_DIFFERENT`).
    String? productId,
    String? freeProductName,

    /// Date de livraison complète, pas dans le futur (heure d'Algérie).
    DateTime? deliveryDate,

    /// N° du bon de livraison (30 caractères au plus), mis en majuscules.
    String? deliveryNoteNumber,

    /// `Conform` (défaut) ou `WithReserve` (exige `reserveReasonCode`).
    Conformity? conformity,

    /// Motif de réserve, de la liste de `GET /settings/materials` ; `Other` impose une remarque.
    String? reserveReasonCode,
    String? reserveNote,
  }) = _CreateDeliveryRequest;

  factory CreateDeliveryRequest.fromJson(Map<String, Object?> json) =>
      _$CreateDeliveryRequestFromJson(json);
}
