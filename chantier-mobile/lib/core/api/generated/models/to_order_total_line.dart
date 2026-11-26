// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'quantity.dart';

part 'to_order_total_line.freezed.dart';
part 'to_order_total_line.g.dart';

/// Total d'une ligne de « A commander » : par produit et par famille d'unites convertibles, jamais d'unites incompatibles additionnees.
/// (400 sacs = 20 T ; 24 m3 et 10 T de sable = deux lignes).
@Freezed()
abstract class ToOrderTotalLine with _$ToOrderTotalLine {
  const factory ToOrderTotalLine({
    /// Produit du catalogue ; `null` pour un nom libre.
    required String? productId,
    required String name,
    required Quantity total,

    /// Nombre de demandes comptees dans cette ligne.
    required int requestCount,

    /// Masse en tonnes d'un total en sacs ; absente sinon.
    Quantity? massEquivalent,
  }) = _ToOrderTotalLine;

  factory ToOrderTotalLine.fromJson(Map<String, Object?> json) =>
      _$ToOrderTotalLineFromJson(json);
}
