import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart'
    as domain;
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/quantity_mirror.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Etat annonce **en toutes lettres** avant d'enregistrer une livraison (CA-MAT-006.3).
enum DeliveryOutcome { partial, complete, surplus }

class DeliveryAnnouncement extends Equatable {
  const DeliveryAnnouncement({
    required this.outcome,
    required this.amount,
    this.percent,
  });

  final DeliveryOutcome outcome;

  /// Partielle : ce qu'il restera ; surplus : l'exces ; complete : zero.
  final Quantity amount;

  /// Surplus : pourcentage de la quantite commandee (deux decimales).
  final Decimal? percent;

  @override
  List<Object?> get props => [outcome, amount, percent];
}

/// Regles du formulaire « Recevoir » (fonctions pures, testees). Le serveur reste seul juge :
/// ces controles guident la saisie hors ligne, sans jamais calculer de montant.
abstract final class DeliveryFormRules {
  /// Longueur maximale du n° de bon de livraison (CA-MAT-007.6).
  static const int noteNumberMaxLength = 30;

  /// N° de BL : sans espace en debut ni en fin, en majuscules, 30 caracteres au plus ; vide : `null`.
  static String? normalizeNoteNumber(String text) {
    final normalized = domain.normalizeNoteNumber(text);
    if (normalized == null) return null;
    return normalized.length > noteNumberMaxLength
        ? normalized.substring(0, noteNumberMaxLength)
        : normalized;
  }

  /// Unites proposees pour une livraison : celle de la commande d'abord, puis les unites du
  /// catalogue **convertibles** vers elle (sac, kg, T avec la masse du sac). Aucune autre : un
  /// sable commande en m3 ne se saisit pas en T (`UNITES_INCOMPATIBLES`, CA-MAT-006.4).
  static List<MeasureUnit> unitsFor(
    MeasureUnit orderUnit,
    ProductRow? product,
  ) {
    final units = <MeasureUnit>[orderUnit];
    for (final unit in product?.allowedMeasureUnits ?? const <MeasureUnit>[]) {
      if (unit == orderUnit) continue;
      try {
        QuantityMirror.convert(
          Quantity(Decimal.one, orderUnit),
          unit,
          bagMassKg: product?.bagMassKg,
        );
        units.add(unit);
      } on QuantityException {
        continue;
      }
    }
    return units;
  }

  /// Equivalence affichee pendant la frappe (« 10 T = 200 sacs »), dans l'unite de la commande.
  static Quantity? equivalenceInOrderUnit(
    Quantity? received,
    MeasureUnit orderUnit,
    ProductRow? product,
  ) {
    if (received == null || received.unit == orderUnit) return null;
    try {
      return QuantityMirror.convert(
        received,
        orderUnit,
        bagMassKg: product?.bagMassKg,
      );
    } on QuantityException {
      return null;
    }
  }

  /// « Livraison partielle : il restera 100 sacs » · « Livraison complete » · « Surplus de +20
  /// sacs (+5,00 %) ». [alreadyReceived] : les livraisons non annulees deja connues de la demande
  /// (saisies en attente comprises) ; [receiving] : la quantite en cours de saisie.
  static DeliveryAnnouncement? announce({
    required Quantity ordered,
    required Iterable<Quantity> alreadyReceived,
    required Quantity receiving,
    Decimal? bagMassKg,
    Decimal? tolerancePercent,
    bool isSettled = false,
  }) {
    final ReceptionState state;
    try {
      state = QuantityMirror.computeStatus(
        ordered: ordered,
        deliveries: [...alreadyReceived, receiving],
        bagMassKg: bagMassKg,
        tolerancePercent: tolerancePercent,
        isSettled: isSettled,
      );
    } on QuantityException {
      return null;
    }
    if (state.variance > Decimal.zero) {
      return DeliveryAnnouncement(
        outcome: DeliveryOutcome.surplus,
        amount: state.varianceQuantity,
        percent: state.variancePercent,
      );
    }
    if (state.status == RequestStatus.delivered) {
      return DeliveryAnnouncement(
        outcome: DeliveryOutcome.complete,
        amount: Quantity(Decimal.zero, ordered.unit),
      );
    }
    return DeliveryAnnouncement(
      outcome: DeliveryOutcome.partial,
      amount: state.remainingQuantity,
    );
  }

  /// Date de livraison dans le futur : refusee (`DATE_INVALIDE`, CA-MAT-006.5).
  static bool isFuture(DateTime date, DateTime today) => date.isAfter(today);

  /// Date anterieure a la demande : avertissement seulement.
  static bool isBeforeRequest(DateTime date, DateTime requestDay) =>
      date.isBefore(requestDay);

  /// Un meme n° de BL deja saisi pour le meme fournisseur et le meme produit sur ce chantier
  /// (livraison non annulee) : « Voir LIV-006 » ou « C'est une autre livraison » (CA-MAT-006.9).
  /// Le serveur signale aussi le doublon aux Achats sans le refuser.
  static DeliveryRow? findDuplicateNote(
    Iterable<DeliveryRow> siteDeliveries, {
    required String? noteNumber,
    required String? supplierKey,
    required String? productKey,
    String? ignoringId,
  }) {
    if (noteNumber == null || noteNumber.isEmpty) return null;
    for (final row in siteDeliveries) {
      if (row.id == ignoringId || row.isCancelled) continue;
      if (row.deliveryNoteNumber != noteNumber) continue;
      if (supplierKey != null && supplierKeyOf(row) != supplierKey) continue;
      if (productKey != null && productKeyOf(row) != productKey) continue;
      return row;
    }
    return null;
  }

  /// Identite du fournisseur d'une livraison : identifiant du catalogue ou nom libre normalise.
  static String? supplierKeyOf(DeliveryRow row) =>
      row.supplierId ?? row.freeSupplierName?.trim().toLowerCase();

  static String? productKeyOf(DeliveryRow row) =>
      row.productId ?? row.freeProductName?.trim().toLowerCase();
}

/// Droits de l'utilisateur sur les livraisons, d'apres les permissions du serveur. Le serveur
/// refuse de toute facon ; ici on **masque** (jamais un bouton grise).
extension DeliveryRights on AuthUser {
  /// « Recevoir » et « + Livraison » : ni ChefEquipe, ni Direction.
  bool get canRecordDelivery => can(Permissions.deliveriesCreate);

  /// Reserver l'action « Reception » (statut Livree -> Receptionnee) au ChefChantier.
  bool get canReceiveRequests => can(Permissions.requestsReceive);

  bool get canAddDeliveryPhotos => can(Permissions.deliveryPhotosCreate);

  bool get canViewDeliveryPhotos => can(Permissions.deliveryPhotosView);

  bool get canCallSuppliers => can(Permissions.supplierPhoneView);

  bool get canAttachDeliveries => can(Permissions.deliveriesAttach);

  /// Corriger ou annuler : tant que la livraison n'est pas annulee et que sa demande n'est pas
  /// receptionnee (`DEMANDE_NON_OUVERTE`, CA-MAT-012.4). [request] : la demande liee, si connue.
  bool canCorrectDelivery(DeliveryRow row, MaterialRequestRow? request) =>
      can(Permissions.deliveriesUpdate) &&
      !row.isCancelled &&
      request?.statusValue != RequestStatus.received;
}

/// Une demande peut recevoir une livraison depuis le telephone : commandee, livree partiellement,
/// ou validee (livraison retenue avant la commande, CA-MAT-010.7).
bool canRecordFor(MaterialRequestRow request) {
  if (request.archivedAt != null) return false;
  return switch (request.statusValue) {
    RequestStatus.validated ||
    RequestStatus.ordered ||
    RequestStatus.partiallyDelivered => true,
    _ => false,
  };
}

/// Livraisons non annulees d'une demande, en quantites a cumuler.
List<Quantity> activeQuantities(Iterable<DeliveryView> deliveries) => [
  for (final delivery in deliveries)
    if (!delivery.row.isCancelled && delivery.row.quantity != null)
      delivery.row.quantity!,
];
