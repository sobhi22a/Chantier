// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'quantity.dart';
import 'status.dart';
import 'conformity.dart';

part 'deliveries.freezed.dart';
part 'deliveries.g.dart';

@Freezed()
abstract class Deliveries with _$Deliveries {
  const factory Deliveries({
    required String id,
    required String number,
    required DateTime deliveryDate,
    required Quantity quantity,

    /// Etat d'une livraison : enregistree, ou annulee (elle reste visible mais n'entre plus dans aucun total).
    required Status status,
    required String? deliveryNoteNumber,

    /// Conformite a la reception : « Avec reserve » exige un motif de la liste (quantite manquante, produit abime...).
    required Conformity conformity,
    required int photoCount,
    Quantity? quantityInRequestUnit,
  }) = _Deliveries;

  factory Deliveries.fromJson(Map<String, Object?> json) =>
      _$DeliveriesFromJson(json);
}
