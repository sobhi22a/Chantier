// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'deliveries.dart';
import 'history2.dart';
import 'order.dart';
import 'possible_duplicate_of2.dart';
import 'product2.dart';
import 'quantity.dart';
import 'request_sync_data_priority.dart';
import 'request_sync_data_status.dart';
import 'status_reason.dart';
import 'variance.dart';

part 'request_sync_data.freezed.dart';
part 'request_sync_data.g.dart';

/// Ligne de la synchronisation `request` : le detail sans le code du chantier ni aucun champ commercial (ADR 0012).
@Freezed()
abstract class RequestSyncData with _$RequestSyncData {
  const factory RequestSyncData({
    List<History2>? history,

    /// Livraisons de la demande, annulees comprises ; absentes de la synchronisation (l'entite `delivery` les porte).
    List<Deliveries>? deliveries,
    String? id,
    String? siteId,

    /// Code du chantier (liste transversale et REST) ; absent de la synchronisation.
    String? siteCode,

    /// Identifiant genere par le telephone qui a cree la demande (creation hors ligne), sinon `null`.
    String? clientId,
    DateTime? clientCreatedAt,

    /// Numero `DEM-nnn`, donne par le serveur.
    String? number,

    /// Produit d'une demande : du catalogue (`productId`, `name`) et/ou le nom libre saisi (`freeName`, conserve apres un rattachement).
    Product2? product,
    Quantity? quantity,
    String? zoneId,

    /// Date de besoin (« pour le »), date complete sans fuseau.
    DateTime? neededBy,

    /// Urgence : `Normal` par defaut ; `Blocking` = le chantier s'arrete (H-MAT-06).
    RequestSyncDataPriority? priority,
    String? note,

    /// Statut d'une demande de materiaux : calcule et change par le serveur seulement (le client ne fixe jamais un statut).
    RequestSyncDataStatus? status,

    /// Motif d'un refus ou d'une annulation.
    StatusReason? statusReason,
    Quantity? receivedQuantity,
    Quantity? remainingQuantity,

    /// Ecart entre le recu et le demande dans l'unite de la demande : negatif = manque, positif = surplus.
    Variance? variance,

    /// Manque definitif accepte (« solde »).
    bool? isSettled,

    /// Jours de retard par rapport a la date de besoin (date d'Algerie), pour une demande ouverte ; 0 sinon.
    int? overdueDays,

    /// Demande semblable deja ouverte (avertissement, jamais un blocage).
    PossibleDuplicateOf2? possibleDuplicateOf,

    /// Commande active d'une demande (une seule, sans numero propre) : fournisseur, date de commande, livraison prevue. Une commande annulee n'apparait plus ici.
    /// (elle reste dans l'historique de la demande). Quantite et unite sont celles de la demande.
    Order? order,

    /// Demande validee qui a deja une livraison rattachee non annulee (badge « Livraison recue sans commande enregistree »).
    bool? hasDeliveryWithoutOrder,
    String? requestedById,
    String? requestedByName,
    DateTime? archivedAt,
    String? archivedByName,

    /// Jeton de concurrence (entier decimal en chaine), a renvoyer a la modification.
    String? version,
    DateTime? createdAt,
    String? createdByName,
    DateTime? updatedAt,
    String? updatedByName,
  }) = _RequestSyncData;

  factory RequestSyncData.fromJson(Map<String, Object?> json) =>
      _$RequestSyncDataFromJson(json);
}
