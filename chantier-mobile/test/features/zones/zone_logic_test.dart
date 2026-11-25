import 'dart:math';

import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:chantier_mobile/core/utils/client_id.dart';
import 'package:chantier_mobile/features/zones/domain/zone_format.dart';
import 'package:chantier_mobile/features/zones/domain/zone_rules.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  group('Cote signee (CA-009.2)', () {
    test('+3,40 / −1,90 / ±0,00, deux decimales, virgule', () {
      expect(signedElevation(Decimal.parse('3.40')), '+3,40');
      expect(signedElevation(Decimal.parse('-1.90')), '−1,90');
      expect(signedElevation(Decimal.zero), '±0,00');
      expect(signedElevation(Decimal.parse('0.00')), '±0,00');
    });

    test('jamais « 3,40+ » : le signe precede le nombre', () {
      expect(signedElevation(Decimal.parse('6.8')), '+6,80');
      expect(signedElevation(Decimal.parse('10.20')), '+10,20');
      expect(signedElevation(Decimal.parse('-20')), '−20,00');
      expect(signedElevation(Decimal.parse('60')), '+60,00');
    });

    test('meme texte en francais et en arabe, chiffres 0-9', () {
      final text = elevationWithUnit(Decimal.parse('3.4'));

      expect(text, '+3,40 m');
      expect(RegExp(r'[٠-٩]').hasMatch(text), isFalse);
    });
  });

  group('Libelle de zone : « Bloc 01 · +3,40 m · Classe 02 »', () {
    test('francais', () {
      expect(zoneLabel(fr, zoneRow()), 'Bloc 01 · +3,40 m · Classe 02');
    });

    test('arabe : local traduit', () {
      expect(zoneLabel(ar, zoneRow()), 'Bloc 01 · +3,40 m · قسم 02');
    });

    test('parties absentes omises : bloc seul, bloc et cote', () {
      expect(
        zoneLabel(
          fr,
          zoneRow(elevation: null, roomType: null, roomNumber: null),
        ),
        'Bloc 01',
      );
      expect(
        zoneLabel(fr, zoneRow(roomType: null, roomNumber: null)),
        'Bloc 01 · +3,40 m',
      );
    });

    test('type « Autre » : libelle libre', () {
      expect(
        zoneLabel(
          fr,
          zoneRow(
            roomType: 'Other',
            roomNumber: null,
            roomLabel: 'Salle des archives',
          ),
        ),
        'Bloc 01 · +3,40 m · Salle des archives',
      );
    });

    test('type de local sans numero', () {
      expect(
        roomLabelText(fr, zoneRow(roomType: 'Canteen', roomNumber: null)),
        'Cantine',
      );
    });

    test(
      'type de local inconnu (ajoute cote serveur) : affiche tel que recu',
      () {
        expect(
          roomLabelText(fr, zoneRow(roomType: 'Gymnasium', roomNumber: 3)),
          'Gymnasium 03',
        );
      },
    );

    test(
      'affichage : bloc et cote isoles de gauche a droite, le local suit la langue',
      () {
        final text = zoneLabelForDisplay(ar, zoneRow());

        expect(text, contains(Formatters.isolateLtr('Bloc 01')));
        expect(text, contains(Formatters.isolateLtr('+3,40 m')));
        expect(text.endsWith('قسم 02'), isTrue);
      },
    );
  });

  group('Saisie de la cote (CA-011.2, CA-011.3)', () {
    test('« 3,4 » et « 3.4 » donnent +3,40', () {
      expect(ZoneRules.parseElevation('3,4').value, Decimal.parse('3.40'));
      expect(ZoneRules.parseElevation('3.4').value, Decimal.parse('3.40'));
      expect(ZoneRules.parseElevation('+3,4').value, Decimal.parse('3.40'));
    });

    test('negatif, avec le signe moins typographique', () {
      expect(ZoneRules.parseElevation('-1,9').value, Decimal.parse('-1.90'));
      expect(ZoneRules.parseElevation('−1.90').value, Decimal.parse('-1.90'));
    });

    test('bornes -20,00 et +60,00 incluses', () {
      expect(ZoneRules.parseElevation('-20').value, isNotNull);
      expect(ZoneRules.parseElevation('60').value, isNotNull);
      expect(ZoneRules.parseElevation('0').value, Decimal.zero);
    });

    test('hors plage refusee avec un message dedie', () {
      for (final input in ['-20,01', '60,01', '100', '-45']) {
        expect(
          ZoneRules.parseElevation(input).problem,
          ElevationProblem.outOfRange,
          reason: input,
        );
      }
    });

    test('lettres, vide, trois decimales, deux separateurs : invalide', () {
      for (final input in [
        'abc',
        '',
        ' ',
        '3,4m',
        '1,234',
        '1.2.3',
        '--1',
        '3,',
        ',5',
      ]) {
        expect(
          ZoneRules.parseElevation(input).problem,
          ElevationProblem.invalid,
          reason: input,
        );
      }
    });

    test('libelles des bornes pour le message', () {
      expect(ZoneRules.minLabel, '−20,00');
      expect(ZoneRules.maxLabel, '+60,00');
    });
  });

  group('clientId (anti-doublon)', () {
    test('GUID version 4 valide', () {
      final id = generateClientId();

      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(id),
        isTrue,
        reason: id,
      );
    });

    test('1000 identifiants, aucun doublon', () {
      expect({for (var i = 0; i < 1000; i++) generateClientId()}.length, 1000);
    });

    test('graine fixe : resultat reproductible', () {
      expect(generateClientId(Random(1)), generateClientId(Random(1)));
    });
  });
}
