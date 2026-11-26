import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/quantity_mirror.dart';
import 'package:decimal/decimal.dart';

/// Regles du formulaire « Nouvelle demande » (fonctions pures, testees). Le serveur reste seul
/// juge : ces controles evitent un aller-retour et guident la saisie hors ligne.
abstract final class RequestFormRules {
  static const int freeNameMinLength = 3;
  static const int freeNameMaxLength = 100;

  /// Quantite tapee + unite choisie : `(valeur, code d'erreur)`.
  ///
  /// * unite absente : `UNITE_OBLIGATOIRE` (jamais une quantite sans unite, regle n°1) ;
  /// * texte vide ou illisible, zero, negatif, plus de 3 decimales : `QUANTITE_INVALIDE` ;
  /// * decimale avec `sac` ou `u` : `QUANTITE_ENTIERE_REQUISE`.
  /// Une saisie encore vide n'est pas une erreur a afficher : `(null, null)`.
  static ({Quantity? quantity, String? error}) checkQuantity(
    String text,
    MeasureUnit? unit,
  ) {
    if (text.trim().isEmpty) return (quantity: null, error: null);
    final value = QuantityMirror.parseInput(text);
    if (value == null) return (quantity: null, error: 'QUANTITE_INVALIDE');
    if (unit == null) return (quantity: null, error: 'UNITE_OBLIGATOIRE');
    final quantity = Quantity(value, unit);
    final error = QuantityMirror.check(quantity);
    return (quantity: error == null ? quantity : null, error: error);
  }

  /// Nom libre (« Autre produit ») : 3 a 100 caracteres, espaces de bord retires.
  static bool isFreeNameValid(String text) {
    final length = text.trim().length;
    return length >= freeNameMinLength && length <= freeNameMaxLength;
  }

  /// Date passee : avertissement, jamais un blocage (CA-MAT-001.7).
  static bool isPast(DateTime date, DateTime today) => date.isBefore(today);

  /// Dates proposees en pastilles : demain, aujourd'hui + [defaultDays] (reglage du serveur),
  /// lundi prochain. Sans doublon, dans l'ordre.
  static List<DateTime> neededByChoices(DateTime today, int defaultDays) {
    DateTime plus(int days) =>
        DateTime.utc(today.year, today.month, today.day + days);
    final untilMonday = (DateTime.monday - today.weekday + 7) % 7;
    final nextMonday = plus(untilMonday == 0 ? 7 : untilMonday);
    final choices = <DateTime>[];
    for (final date in [plus(1), plus(defaultDays), nextMonday]) {
      if (!choices.contains(date)) choices.add(date);
    }
    return choices;
  }

  /// Unites proposees pour [product] : celles du catalogue, l'unite par defaut d'abord. Produit
  /// libre : toutes les unites du referentiel (le serveur controlera avec le produit rattache).
  static List<MeasureUnit> unitsFor(ProductRow? product) {
    if (product == null) return MeasureUnit.values;
    final allowed = product.allowedMeasureUnits;
    final defaultUnit = product.defaultMeasureUnit;
    if (defaultUnit == null || !allowed.contains(defaultUnit)) return allowed;
    return [defaultUnit, ...allowed.where((unit) => unit != defaultUnit)];
  }

  /// Equivalence affichee sous la quantite (« 300 sacs = 15 T »), sans reseau.
  static Quantity? equivalence(Quantity? quantity, ProductRow? product) =>
      quantity == null
      ? null
      : QuantityMirror.equivalence(quantity, bagMassKg: product?.bagMassKg);
}

/// Droits de l'utilisateur sur une demande, d'apres les permissions du serveur (« la sienne
/// seulement » pour modifier et annuler). Le serveur refuse de toute facon ; ici on **masque**.
extension RequestRights on AuthUser {
  bool _isAuthor(MaterialRequestRow row) => row.requestedById == id;

  /// Corriger : tant que la demande est `Requested` (sa propre demande ou `UpdateAny`), puis
  /// seulement date, urgence et remarque avec `UpdateAny` jusqu'a la livraison.
  bool canEditRequest(MaterialRequestRow row) {
    final status = row.statusValue;
    if (row.archivedAt != null || status == null) return false;
    if (can(Permissions.requestsUpdateAny)) {
      return const {
        RequestStatus.requested,
        RequestStatus.validated,
        RequestStatus.ordered,
        RequestStatus.partiallyDelivered,
      }.contains(status);
    }
    return status == RequestStatus.requested &&
        can(Permissions.requestsUpdate) &&
        _isAuthor(row);
  }

  /// Produit, quantite, unite et zone ne changent plus apres la validation.
  bool canEditLockedFields(MaterialRequestRow row) =>
      row.statusValue == RequestStatus.requested;

  bool canCancelRequest(MaterialRequestRow row) {
    final status = row.statusValue;
    if (row.archivedAt != null) return false;
    if (status != RequestStatus.requested &&
        status != RequestStatus.validated) {
      return false;
    }
    return can(Permissions.requestsCancelAny) ||
        (can(Permissions.requestsCancel) && _isAuthor(row));
  }

  bool canApproveRequest(MaterialRequestRow row) =>
      can(Permissions.requestsApprove) &&
      row.archivedAt == null &&
      row.statusValue == RequestStatus.requested;
}

/// Valeur decimale d'une quantite ajustee a la validation : meme unite, strictement positive.
Decimal? parseAdjustedValue(String text) {
  final value = QuantityMirror.parseInput(text);
  return value == null || value <= Decimal.zero ? null : value;
}
