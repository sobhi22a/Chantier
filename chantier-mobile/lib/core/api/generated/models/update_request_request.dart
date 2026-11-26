// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'priority.dart';
import 'quantity_body.dart';

part 'update_request_request.freezed.dart';
part 'update_request_request.g.dart';

/// Modification : seuls les champs présents changent. `version` détecte une modification concurrente (409 `CONFLIT_VERSION`).
@Freezed()
abstract class UpdateRequestRequest with _$UpdateRequestRequest {
  const factory UpdateRequestRequest({
    /// Version lue avec la demande.
    required String version,

    /// Produit du catalogue ; écarte le nom libre. Verrouillé après la validation (422 `DEMANDE_VERROUILLEE`).
    String? productId,

    /// Nom libre ; écarte le produit du catalogue. Verrouillé après la validation.
    String? freeProductName,

    /// Quantité et unité. Verrouillées après la validation.
    QuantityBody? quantity,

    /// Zone. Verrouillée après la validation.
    String? zoneId,

    /// Date de besoin : modifiable jusqu'à la livraison (droit `Requests.UpdateAny` après la validation).
    DateTime? neededBy,
    Priority? priority,

    /// Remarque ; une chaîne vide l'efface.
    String? note,
  }) = _UpdateRequestRequest;

  factory UpdateRequestRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateRequestRequestFromJson(json);
}
