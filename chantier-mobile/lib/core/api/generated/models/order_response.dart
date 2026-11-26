// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'order_commercial_response.dart';

part 'order_response.freezed.dart';
part 'order_response.g.dart';

/// Commande active d'une demande (une seule, sans numero propre) : fournisseur, date de commande, livraison prevue. Une commande annulee n'apparait plus ici.
/// (elle reste dans l'historique de la demande). Quantite et unite sont celles de la demande.
@Freezed()
abstract class OrderResponse with _$OrderResponse {
  const factory OrderResponse({
    required String id,
    required String supplierId,
    required String? supplierName,
    required DateTime orderDate,
    required DateTime? expectedDeliveryDate,

    /// Jours entre la date de besoin et la livraison prevue quand elle la depasse (avertissement, jamais un blocage) ; 0 sinon.
    required int plannedAfterNeedDays,

    /// Remarque libre de la commande (200 caracteres), visible de tous les roles qui voient la demande, ChefChantier et ChefEquipe compris, et copiee sur leur telephone :.
    /// ne jamais y saisir de prix, de remise ni de condition commerciale (le prix a son champ reserve a `Prices.View`). Aucun controle automatique ne peut le garantir sur un texte libre.
    required String? note,

    /// Jeton de concurrence de la commande (entier decimal en chaine).
    required String version,

    /// Prix, montant, valeur recue et n° de bon de commande ; absent sans `Prices.View` (construit uniquement par CommercialProjection).
    OrderCommercialResponse? commercial,
  }) = _OrderResponse;

  factory OrderResponse.fromJson(Map<String, Object?> json) =>
      _$OrderResponseFromJson(json);
}
