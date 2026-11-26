import 'package:chantier_mobile/features/materials/domain/material_settings.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valeurs par defaut = hypotheses du serveur (avant la 1re synchro)', () {
    const settings = MaterialSettings();

    expect(settings.defaultNeededByDays, 3);
    expect(settings.toleranceOrZero, Decimal.zero);
    expect(settings.maxPhotosPerDelivery, 5);
    expect(settings.maxPhotoBytes, 5242880);
    expect(settings.noteMaxLength, 200);
    expect(
      settings.reasons.keys,
      containsAll([
        'rejection',
        'requestCancellation',
        'orderCancellation',
        'settle',
        'deliveryCancellation',
        'reserve',
      ]),
    );
  });

  test('lit la reponse du serveur et l ecrit sans perte', () {
    final settings = MaterialSettings.fromJson({
      'defaultNeededByDays': 5,
      'deliveryTolerancePercent': 1.5,
      'maxPhotosPerDelivery': 4,
      'maxPhotoBytes': 2097152,
      'noteMaxLength': 150,
      'reasons': {
        'rejection': ['StockSufficient', 'Other'],
        'futureCase': ['A', 'B'],
      },
    });

    expect(settings.defaultNeededByDays, 5);
    expect(settings.deliveryTolerancePercent, Decimal.parse('1.5'));
    expect(settings.reasons['rejection'], ['StockSufficient', 'Other']);
    // Une liste ajoutee par le serveur est conservee, les autres gardent leur defaut.
    expect(settings.reasons['futureCase'], ['A', 'B']);
    expect(settings.reasons['reserve'], contains('DamagedProduct'));

    expect(MaterialSettings.fromStorage(settings.toStorage()), settings);
  });

  test('tolerance entiere (1) lue sans erreur', () {
    expect(
      MaterialSettings.fromJson({
        'deliveryTolerancePercent': 1,
      }).deliveryTolerancePercent,
      Decimal.one,
    );
  });

  test(
    'champ absent ou de mauvais type : valeur par defaut, jamais d erreur',
    () {
      final settings = MaterialSettings.fromJson({
        'defaultNeededByDays': 'trois',
        'maxPhotosPerDelivery': null,
        'reasons': {'rejection': 'pas une liste'},
      });

      expect(settings.defaultNeededByDays, 3);
      expect(settings.maxPhotosPerDelivery, 5);
      expect(settings.reasons['rejection'], contains('Other'));
    },
  );

  test('texte stocke absent ou illisible : valeurs par defaut', () {
    expect(MaterialSettings.fromStorage(null), const MaterialSettings());
    expect(
      MaterialSettings.fromStorage('pas du json'),
      const MaterialSettings(),
    );
    expect(MaterialSettings.fromStorage('[1,2]'), const MaterialSettings());
  });
}
