// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'cancel_reason.dart';
import 'commercial.dart';
import 'delivery_sync_data_conformity.dart';
import 'delivery_sync_data_status.dart';
import 'delivery_sync_data_unattached_reason.dart';
import 'history.dart';
import 'photos.dart';
import 'possible_duplicate_of.dart';
import 'product.dart';
import 'quantity.dart';
import 'reserve.dart';

part 'delivery_sync_data.freezed.dart';
part 'delivery_sync_data.g.dart';

/// Ligne de la synchronisation `delivery` : le detail sans montant, sans photos et sans « BL manquant » (deduits de l'entite `photo`).
@Freezed()
abstract class DeliverySyncData with _$DeliverySyncData {
  const factory DeliverySyncData({
    List<History>? history,
    String? id,
    String? siteId,
    String? clientId,
    DateTime? clientCreatedAt,

    /// Numero `LIV-nnn`, donne par le serveur ; jamais reutilise, meme apres une annulation.
    String? number,

    /// Demande liee ; `null` = non rattachee (voir `unattachedReason`).
    String? requestId,
    String? requestNumber,
    DeliverySyncDataUnattachedReason? unattachedReason,
    String? supplierId,
    String? supplierName,
    String? freeSupplierName,

    /// Produit d'une demande : du catalogue (`productId`, `name`) et/ou le nom libre saisi (`freeName`, conserve apres un rattachement).
    Product? product,
    Quantity? quantity,
    Quantity? quantityInRequestUnit,
    DateTime? deliveryDate,
    String? deliveryNoteNumber,

    /// Ni n° de BL ni photo (badge « BL manquant »). Absent de la synchronisation (deduit de l'entite `photo`).
    bool? missingNote,

    /// Conformite a la reception : « Avec reserve » exige un motif de la liste (quantite manquante, produit abime...).
    DeliverySyncDataConformity? conformity,

    /// Reserve a la reception : un motif de la liste (`QuantityMissing`, `DamagedProduct`...) et une remarque.
    Reserve? reserve,

    /// Etat d'une livraison : enregistree, ou annulee (elle reste visible mais n'entre plus dans aucun total).
    DeliverySyncDataStatus? status,

    /// Motif d'un refus ou d'une annulation.
    CancelReason? cancelReason,

    /// Demande semblable deja ouverte (avertissement, jamais un blocage).
    PossibleDuplicateOf? possibleDuplicateOf,

    /// Nombre de photos du bon.
    int? photoCount,

    /// Photos du bon ; absentes sans `DeliveryPhotos.View` et de la synchronisation.
    List<Photos>? photos,

    /// Montant d'une livraison : prix de la commande x quantite convertie, arrondi au centime (DZD). Absent sans `Prices.View`.
    Commercial? commercial,

    /// Jeton de concurrence (entier decimal en chaine), a renvoyer a la correction.
    String? version,
    DateTime? createdAt,
    String? createdByName,
    DateTime? updatedAt,
    String? updatedByName,
  }) = _DeliverySyncData;

  factory DeliverySyncData.fromJson(Map<String, Object?> json) =>
      _$DeliverySyncDataFromJson(json);
}
