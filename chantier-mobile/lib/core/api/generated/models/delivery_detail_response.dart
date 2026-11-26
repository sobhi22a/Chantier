// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'conformity.dart';
import 'delivery_commercial_response.dart';
import 'delivery_photo_item.dart';
import 'delivery_status.dart';
import 'duplicate_ref_response.dart';
import 'product_ref_response.dart';
import 'quantity.dart';
import 'request_history_item.dart';
import 'reserve_response.dart';
import 'status_reason_response.dart';
import 'unattached_reason.dart';

part 'delivery_detail_response.freezed.dart';
part 'delivery_detail_response.g.dart';

/// Livraison et son historique.
@Freezed()
abstract class DeliveryDetailResponse with _$DeliveryDetailResponse {
  const factory DeliveryDetailResponse({
    List<RequestHistoryItem>? history,
    String? id,
    String? siteId,
    String? clientId,
    DateTime? clientCreatedAt,

    /// Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation.
    String? number,

    /// Demande liee ; `null` = non rattachee (voir `unattachedReason`).
    String? requestId,
    String? requestNumber,
    UnattachedReason? unattachedReason,
    String? supplierId,
    String? supplierName,
    String? freeSupplierName,
    ProductRefResponse? product,

    /// Quantite recue, dans l'unite saisie.
    Quantity? quantity,

    /// Quantite convertie dans l'unite de la demande ; seulement si la livraison est rattachee.
    Quantity? quantityInRequestUnit,
    DateTime? deliveryDate,
    String? deliveryNoteNumber,

    /// Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`).
    bool? missingNote,
    Conformity? conformity,
    ReserveResponse? reserve,
    DeliveryStatus? status,

    /// Motif de l'annulation.
    StatusReasonResponse? cancelReason,

    /// Livraison du meme fournisseur, du meme produit et du meme n° de BL deja enregistree (avertissement, jamais un blocage).
    DuplicateRefResponse? possibleDuplicateOf,

    /// Nombre de photos du bon.
    int? photoCount,

    /// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
    List<DeliveryPhotoItem>? photos,

    /// Montant de la livraison ; absent sans `Prices.View` ou sans prix de commande, et de la synchronisation.
    DeliveryCommercialResponse? commercial,

    /// Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.
    String? version,
    DateTime? createdAt,
    String? createdByName,
    DateTime? updatedAt,
    String? updatedByName,
  }) = _DeliveryDetailResponse;

  factory DeliveryDetailResponse.fromJson(Map<String, Object?> json) =>
      _$DeliveryDetailResponseFromJson(json);
}
