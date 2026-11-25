import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/database/converters/decimal_text.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecimalTextConverter (cotes et montants, 2 decimales)', () {
    const converter = DecimalTextConverter();

    String roundTrip(String text) => converter.toSql(converter.fromSql(text));

    test('aller-retour sans perte : -1.90, 0.00, 185000000.00', () {
      expect(roundTrip('-1.90'), '-1.90');
      expect(roundTrip('0.00'), '0.00');
      expect(roundTrip('185000000.00'), '185000000.00');
      expect(roundTrip('3.40'), '3.40');
      expect(roundTrip('-20.00'), '-20.00');
      expect(roundTrip('60.00'), '60.00');
    });

    test('le JSON du serveur perd les zeros finaux : ils sont retablis', () {
      // 3.40 arrive en `3.4`, 185000000.00 en `185000000.0`, 0.00 en `0` ou `0.0`.
      expect(converter.toSql(Decimal.parse('3.4')), '3.40');
      expect(converter.toSql(Decimal.parse('185000000.0')), '185000000.00');
      expect(converter.toSql(Decimal.parse('0')), '0.00');
      expect(converter.toSql(Decimal.parse('-1.9')), '-1.90');
    });

    test('grand montant : aucune perte (pas de double)', () {
      expect(roundTrip('99999999999999.99'), '99999999999999.99');
      expect(roundTrip('0.01'), '0.01');
    });

    test('la valeur lue est exacte (decimal, pas flottant)', () {
      expect(
        converter.fromSql('0.10') + converter.fromSql('0.20'),
        Decimal.parse('0.30'),
      );
      expect(converter.fromSql('-1.90') < Decimal.zero, isTrue);
    });

    test(
      'plus precis que l echelle : conserve tel quel, jamais arrondi en silence',
      () {
        expect(roundTrip('1.2345'), '1.2345');
      },
    );

    test('texte non decimal refuse', () {
      expect(() => converter.fromSql('abc'), throwsFormatException);
      expect(() => converter.fromSql(''), throwsFormatException);
    });
  });

  group('DecimalTextConverter(scale: 6) pour les coordonnees', () {
    const converter = DecimalTextConverter(scale: 6);

    test('latitude 36.575 -> 36.575000', () {
      expect(converter.toSql(Decimal.parse('36.575')), '36.575000');
      expect(converter.toSql(converter.fromSql('2.912000')), '2.912000');
    });
  });

  group('DateOnlyTextConverter (yyyy-MM-dd, sans fuseau)', () {
    const converter = DateOnlyTextConverter();

    test('aller-retour', () {
      for (final text in [
        '2026-11-24',
        '2027-08-24',
        '2028-03-01',
        '2026-01-15',
      ]) {
        expect(converter.toSql(converter.fromSql(text)), text);
      }
    });

    test('lit une date UTC a minuit', () {
      expect(converter.fromSql('2026-03-02'), DateTime.utc(2026, 3, 2));
    });

    test('ecrit annee, mois, jour : heure et fuseau ignores', () {
      expect(converter.toSql(DateTime(2026, 11, 24, 23, 59, 59)), '2026-11-24');
      expect(converter.toSql(DateTime.utc(2026, 1, 5, 0, 0, 1)), '2026-01-05');
    });

    test('annee bissextile', () {
      expect(converter.fromSql('2028-02-29'), DateTime.utc(2028, 2, 29));
      expect(() => converter.fromSql('2027-02-29'), throwsFormatException);
    });

    test('date incomplete ou impossible refusee (regle metier n°2)', () {
      for (final bad in [
        '../03/2026',
        '2026-03',
        '24/11/2026',
        '2026-13-01',
        '2026-02-30',
        '2026-00-10',
        '',
      ]) {
        expect(
          () => converter.fromSql(bad),
          throwsFormatException,
          reason: bad,
        );
      }
    });
  });
}
