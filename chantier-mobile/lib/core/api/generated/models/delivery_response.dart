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
import 'reserve_response.dart';
import 'status_reason_response.dart';
import 'unattached_reason.dart';

part 'delivery_response.freezed.dart';
part 'delivery_response.g.dart';

/// Livraison telle que renvoyee par l'API (liste, detail, actions). Les cles absentes ne sont pas ecrites. Le montant (`commercial`) n'est rendu.
/// qu'avec `Prices.View` ; la livraison n'a pas de prix propre : prix de la commande x quantite convertie.
@Freezed()
abstract class DeliveryResponse with _$DeliveryResponse {
  const factory DeliveryResponse({
    required String id,
    required String siteId,

    /// Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation.
    required String number,
    required ProductRefResponse product,

    /// Quantite recue, dans l'unite saisie.
    required Quantity quantity,
    required DateTime deliveryDate,
    required Conformity conformity,
    required DeliveryStatus status,

    /// Nombre de photos du bon.
    required int photoCount,

    /// Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.
    required String version,
    required DateTime createdAt,
    String? clientId,
    DateTime? clientCreatedAt,

    /// Demande liee ; `null` = non rattachee (voir `unattachedReason`).
    String? requestId,
    String? requestNumber,
    UnattachedReason? unattachedReason,
    String? supplierId,
    String? supplierName,
    String? freeSupplierName,

    /// Quantite convertie dans l'unite de la demande ; seulement si la livraison est rattachee.
    Quantity? quantityInRequestUnit,
    String? deliveryNoteNumber,

    /// Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`).
    bool? missingNote,
    ReserveResponse? reserve,

    /// Motif de l'annulation.
    StatusReasonResponse? cancelReason,

    /// Livraison du meme fournisseur, du meme produit et du meme n° de BL deja enregistree (avertissement, jamais un blocage).
    DuplicateRefResponse? possibleDuplicateOf,

    /// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
    List<DeliveryPhotoItem>? photos,

    /// Montant de la livraison ; absent sans `Prices.View` ou sans prix de commande, et de la synchronisation.
    DeliveryCommercialResponse? commercial,
    String? createdByName,
    DateTime? updatedAt,
    String? updatedByName,
  }) = _DeliveryResponse;

  factory DeliveryResponse.fromJson(Map<String, Object?> json) =>
      _$DeliveryResponseFromJson(json);
}
