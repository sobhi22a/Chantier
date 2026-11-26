import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:decimal/decimal.dart';

// Lectures typees des lignes de la base locale. Les colonnes gardent le **texte recu** ; ces
// accesseurs rendent `null` pour une valeur inconnue de cette version (ajoutee cote serveur) :
// l'ecran affiche alors le texte tel que recu.

extension ProductRowX on ProductRow {
  /// Unites autorisees reconnues, dans l'ordre du catalogue.
  List<MeasureUnit> get allowedMeasureUnits => [
    for (final code in allowedUnits)
      if (MeasureUnit.tryParse(code) case final unit?) unit,
  ];

  MeasureUnit? get defaultMeasureUnit => MeasureUnit.tryParse(defaultUnit);
}

extension MaterialRequestRowX on MaterialRequestRow {
  /// Quantite demandee (nombre + unite) ; `null` si l'unite est inconnue de cette version.
  Quantity? get quantity {
    final unit = MeasureUnit.tryParse(quantityUnit);
    return unit == null ? null : Quantity(quantityValue, unit);
  }

  RequestStatus? get statusValue => RequestStatus.tryParse(status);
  RequestPriority? get priorityValue => RequestPriority.tryParse(priority);

  /// Vrai tant que le numero n'est pas donne par le serveur (« numero en attente »).
  bool get hasNumber => number != null;

  Quantity? get receivedQuantity => _optional(receivedValue);
  Quantity? get remainingQuantity => _optional(remainingValue);
  Quantity? get varianceQuantity => _optional(varianceValue);

  Quantity? _optional(Decimal? value) {
    final unit = MeasureUnit.tryParse(quantityUnit);
    return value == null || unit == null ? null : Quantity(value, unit);
  }
}

extension DeliveryRowX on DeliveryRow {
  Quantity? get quantity {
    final unit = MeasureUnit.tryParse(quantityUnit);
    return unit == null ? null : Quantity(quantityValue, unit);
  }

  /// Quantite exprimee dans l'unite de la demande (10 T = 200 sacs) ; `null` si non rattachee.
  Quantity? get quantityInRequest {
    final value = quantityInRequestValue;
    final unit = MeasureUnit.tryParse(quantityInRequestUnit);
    return value == null || unit == null ? null : Quantity(value, unit);
  }

  DeliveryStatus? get statusValue => DeliveryStatus.tryParse(status);
  Conformity? get conformityValue => Conformity.tryParse(conformity);

  bool get isCancelled => status == DeliveryStatus.cancelled.code;

  /// Livraison non rattachee : fait de chantier sans demande (CA-MAT-011).
  bool get isUnattached => requestId == null;
}
