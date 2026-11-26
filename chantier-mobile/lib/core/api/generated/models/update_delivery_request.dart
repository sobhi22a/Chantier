// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'conformity.dart';
import 'quantity_body.dart';

part 'update_delivery_request.freezed.dart';
part 'update_delivery_request.g.dart';

/// Correction d'une livraison : seuls les champs présents changent. `version` détecte une correction concurrente (409 `CONFLIT_VERSION`).
@Freezed()
abstract class UpdateDeliveryRequest with _$UpdateDeliveryRequest {
  const factory UpdateDeliveryRequest({
    /// Version lue avec la livraison.
    required String version,
    QuantityBody? quantity,
    DateTime? deliveryDate,

    /// N° de BL ; une valeur déjà posée se remplace, elle ne s'efface pas.
    String? deliveryNoteNumber,
    Conformity? conformity,
    String? reserveReasonCode,
    String? reserveNote,
  }) = _UpdateDeliveryRequest;

  factory UpdateDeliveryRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateDeliveryRequestFromJson(json);
}
