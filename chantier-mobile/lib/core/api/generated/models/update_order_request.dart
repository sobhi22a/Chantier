// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_order_request.freezed.dart';
part 'update_order_request.g.dart';

/// Modification d'une commande : seuls les champs présents changent (la date de commande, la quantité et l'unité ne se modifient pas ; une valeur déjà posée se remplace,.
/// elle ne s'efface pas). `version` détecte une modification concurrente (409 `CONFLIT_VERSION`).
@Freezed()
abstract class UpdateOrderRequest with _$UpdateOrderRequest {
  const factory UpdateOrderRequest({
    /// Version de la commande, lue dans `order.version`.
    required String version,
    String? supplierId,
    DateTime? expectedDeliveryDate,

    /// Nouveau prix : recalcule le montant de la commande et de chaque livraison (événement sensible `OrderCommercialEdited`).
    double? unitPrice,
    String? purchaseOrderNumber,
    String? note,
  }) = _UpdateOrderRequest;

  factory UpdateOrderRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateOrderRequestFromJson(json);
}
