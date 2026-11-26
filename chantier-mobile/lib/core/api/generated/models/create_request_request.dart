// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'priority.dart';
import 'quantity_body.dart';

part 'create_request_request.freezed.dart';
part 'create_request_request.g.dart';

/// Création d'une demande, y compris hors ligne : `clientId` rend l'envoi idempotent. Le client ne fixe jamais le statut, le numéro, l'auteur,.
/// les dates d'audit ni le doublon possible : le serveur les calcule.
@Freezed()
abstract class CreateRequestRequest with _$CreateRequestRequest {
  const factory CreateRequestRequest({
    /// Quantité demandée avec son unité (une unité autorisée du produit).
    required QuantityBody? quantity,

    /// Identifiant généré par le téléphone : un renvoi avec le même `clientId` donne 200 et la même demande, sans nouveau numéro.
    String? clientId,

    /// Heure du téléphone à la saisie (« saisi le ») : information seulement, jamais utilisée pour trier ou décider.
    DateTime? clientCreatedAt,

    /// Produit du catalogue (actif). Exactement un de `productId` et `freeProductName`.
    String? productId,

    /// « Autre produit » : nom libre de 3 à 100 caractères.
    String? freeProductName,

    /// Zone du chantier (facultative) ; 422 `ZONE_HORS_CHANTIER` si elle appartient à un autre chantier.
    String? zoneId,

    /// Date de besoin complète (« pour le ») ; une date passée est acceptée (avertissement côté client).
    DateTime? neededBy,

    /// `Normal` (défaut), `Urgent` ou `Blocking` (le chantier s'arrête).
    Priority? priority,

    /// Usage ou remarque (200 caractères au plus).
    String? note,
  }) = _CreateRequestRequest;

  factory CreateRequestRequest.fromJson(Map<String, Object?> json) =>
      _$CreateRequestRequestFromJson(json);
}
