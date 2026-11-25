import 'package:chantier_mobile/core/l10n/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters.date', () {
    test('JJ/MM/AAAA avec zeros', () {
      expect(Formatters.date(DateTime.utc(2026, 3, 2)), '02/03/2026');
      expect(Formatters.date(DateTime.utc(2027, 8, 24)), '24/08/2027');
    });
  });

  group('Formatters.dateTime', () {
    test('heure d Alger (UTC+1), 24 h', () {
      expect(
        Formatters.dateTime(DateTime.utc(2026, 11, 24, 10, 15)),
        '24/11/2026 11:15',
      );
    });

    test('passage de minuit', () {
      expect(
        Formatters.dateTime(DateTime.utc(2026, 12, 31, 23, 30)),
        '01/01/2027 00:30',
      );
    });
  });

  group('Formatters.decimal', () {
    test('virgule decimale et espace pour les milliers', () {
      expect(Formatters.decimal('185000000.00'), '185 000 000,00');
      expect(Formatters.decimal('3.40'), '3,40');
      expect(Formatters.decimal('1000'), '1 000');
      expect(Formatters.decimal('999'), '999');
    });

    test('signe conserve', () {
      expect(Formatters.decimal('-1.90'), '-1,90');
    });

    test('texte non decimal rendu tel quel', () {
      expect(Formatters.decimal('abc'), 'abc');
    });

    test('chiffres latins 0-9 uniquement, quelle que soit la langue', () {
      final out =
          Formatters.decimal('1234567.89') +
          Formatters.date(DateTime.utc(2026, 11, 24));
      final arabicIndic = RegExp(r'[٠-٩۰-۹]');

      expect(arabicIndic.hasMatch(out), isFalse);
    });
  });
}
