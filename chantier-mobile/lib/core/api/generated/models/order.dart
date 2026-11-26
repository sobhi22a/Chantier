// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'commercial2.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@Freezed()
abstract class Order with _$Order {
  const factory Order({
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

    /// Donnees commerciales d'une commande : prix unitaire HT (par unite de commande), montant (quantite x prix, arrondi au centime), valeur recue (somme des montants.
    /// arrondis des livraisons) et n° de bon de commande, en DZD. <b>Absent sans `Prices.View`</b> et de toute synchronisation (ADR 0012).
    Commercial2? commercial,
  }) = _Order;

  factory Order.fromJson(Map<String, Object?> json) => _$OrderFromJson(json);
}
