import 'dart:ui';

import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/l10n/labels.dart';
import 'package:chantier_mobile/core/l10n/quantity_format.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_settings.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  test('tout statut, urgence, etat, conformite a un libelle FR et AR', () {
    for (final l10n in [fr, ar]) {
      for (final status in RequestStatus.values) {
        expect(requestStatusLabel(l10n, status.code), isNot(status.code));
      }
      for (final priority in RequestPriority.values) {
        expect(priorityLabel(l10n, priority.code), isNot(priority.code));
      }
      for (final status in DeliveryStatus.values) {
        expect(deliveryStatusLabel(l10n, status.code), isNot(status.code));
      }
      for (final conformity in Conformity.values) {
        expect(conformityLabel(l10n, conformity.code), isNot(conformity.code));
      }
    }
  });

  test('toute unite du referentiel a un libelle FR et AR', () {
    for (final l10n in [fr, ar]) {
      for (final unit in MeasureUnit.values) {
        expect(unitLabel(l10n, unit.code).trim(), isNotEmpty);
      }
    }
    for (final unit in MeasureUnit.values) {
      expect(
        unitLabel(ar, unit.code),
        matches(RegExp(r'[؀-ۿ]')),
        reason: 'unite ${unit.code} en arabe',
      );
    }
    expect(unitLabel(fr, 'm2'), 'm²');
    expect(unitLabel(fr, 't'), 'T');
    expect(unitLabel(ar, 'sac'), 'كيس');
  });

  test('toute categorie du catalogue a un libelle', () {
    for (final code in [
      'Binders',
      'Steel',
      'Masonry',
      'Aggregates',
      'Admixtures',
      'FinishingWorks',
      'Other',
    ]) {
      for (final l10n in [fr, ar]) {
        expect(productCategoryLabel(l10n, code), isNot(code));
      }
    }
  });

  test('tout motif des six listes par defaut a un libelle FR et AR', () {
    for (final entry in MaterialSettings.defaultReasons.entries) {
      for (final code in entry.value) {
        for (final l10n in [fr, ar]) {
          expect(
            reasonLabel(l10n, code),
            isNot(code),
            reason: '${entry.key} / $code (${l10n.localeName})',
          );
        }
      }
    }
  });

  test(
    'valeur inconnue (ajoutee par le serveur) : affichee telle que recue',
    () {
      expect(requestStatusLabel(fr, 'Archived2027'), 'Archived2027');
      expect(unitLabel(fr, 'barre'), 'barre');
      expect(reasonLabel(ar, 'NewReason'), 'NewReason');
      expect(priorityLabel(fr, '?'), '?');
    },
  );

  test('quantite toujours avec son unite, chiffres 0-9, virgule decimale', () {
    expect(
      formatQuantity(fr, Quantity(Decimal.fromInt(300), MeasureUnit.bag)),
      '300 sac',
    );
    expect(
      formatQuantity(fr, Quantity(Decimal.parse('2.5'), MeasureUnit.kilogram)),
      '2,5 kg',
    );
    expect(
      formatQuantity(
        fr,
        Quantity(Decimal.fromInt(12000), MeasureUnit.linearMeter),
      ),
      '12${Formatters.thousandsSeparator}000 ml',
    );
    expect(
      formatQuantity(ar, Quantity(Decimal.fromInt(15), MeasureUnit.tonne)),
      '15 طن',
    );
  });

  test('marques de l etat local', () {
    expect(fr.materialNumberPending, 'Numéro en attente');
    expect(fr.materialToConfirm, 'À confirmer');
    expect(fr.materialOverdueDays('2'), 'En retard de 2 j');
    expect(ar.materialOverdueDays('2'), contains('2'));
  });
}
