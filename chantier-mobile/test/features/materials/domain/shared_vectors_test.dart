import 'dart:convert';
import 'dart:io';

import 'package:chantier_mobile/features/materials/domain/algeria_date.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/quantity_mirror.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vecteurs de calcul **partages** avec le serveur (.NET) et le web (TypeScript) : CT-MAT-01,
/// ADR 0014. Le fichier `docs/api/vecteurs-materiaux.json` est lu tel quel, jamais copie.
///
/// Un calcul qui change commence par ce fichier ; si un test echoue ici, c'est le miroir mobile
/// qui a derive du serveur.
Map<String, Object?> _loadVectors() {
  final file = File('../docs/api/vecteurs-materiaux.json');
  if (!file.existsSync()) {
    throw StateError('vecteurs introuvables : ${file.absolute.path}');
  }
  return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
}

List<Map<String, Object?>> _section(
  Map<String, Object?> vectors,
  String name,
) => (vectors[name]! as List).cast<Map<String, Object?>>();

Quantity _quantity(Object? json) {
  final map = json! as Map<String, Object?>;
  return Quantity.parse(map['value']! as String, map['unit']! as String);
}

Decimal? _decimal(Object? text) =>
    text == null ? null : Decimal.parse(text as String);

/// Chaine de scale fixe (`0.00`) : les vecteurs ecrivent les pourcentages avec 2 decimales.
String _fixed(Decimal value, int digits) => value.toStringAsFixed(digits);

void main() {
  final vectors = _loadVectors();

  test('le fichier est lu en entier : toutes les sections attendues', () {
    expect(vectors['version'], 1);
    expect(vectors['rounding'], 'AwayFromZero');
    expect(
      vectors.keys.where((k) => !k.startsWith(r'$')).toSet(),
      containsAll([
        'version',
        'rounding',
        'conversions',
        'quantityRules',
        'status',
        'amounts',
        'receivedValue',
        'overdue',
        'defaultNeededBy',
        'aggregates',
      ]),
    );
    // Garde-fou : un vecteur ajoute doit etre couvert par un test ci-dessous.
    expect(_section(vectors, 'conversions'), hasLength(12));
    expect(_section(vectors, 'status'), hasLength(11));
  });

  group('conversions (sac / kg / T, arrondi a 3 decimales)', () {
    for (final vector in _section(vectors, 'conversions')) {
      test(vector['name'] as String, () {
        final from = _quantity(vector['from']);
        final to = MeasureUnit.tryParse(vector['to'] as String)!;
        final bagMass = _decimal(vector['bagMassKg']);

        if (vector.containsKey('error')) {
          expect(
            () => QuantityMirror.convert(from, to, bagMassKg: bagMass),
            throwsA(
              isA<QuantityException>().having(
                (e) => e.code,
                'code',
                vector['error'],
              ),
            ),
          );
          return;
        }
        expect(
          QuantityMirror.convert(from, to, bagMassKg: bagMass),
          _quantity(vector['expected']),
        );
      });
    }
  });

  group('regles de quantite (> 0, 3 decimales, entiers pour sac et u)', () {
    for (final vector in _section(vectors, 'quantityRules')) {
      test(vector['name'] as String, () {
        final quantity = _quantity(vector['quantity']);
        final code = QuantityMirror.check(quantity);
        if (vector.containsKey('error')) {
          expect(code, vector['error']);
        } else {
          expect(vector['valid'], isTrue);
          expect(code, isNull);
        }
      });
    }
  });

  group('statut calcule : recu, reste, ecart, ecart %', () {
    for (final vector in _section(vectors, 'status')) {
      test(vector['name'] as String, () {
        final ordered = _quantity(vector['ordered']);
        final deliveries = [
          for (final d in (vector['deliveries']! as List)) _quantity(d),
        ];
        final bagMass = _decimal(vector['bagMassKg']);
        final tolerance = _decimal(vector['tolerancePercent']);

        if (vector.containsKey('error')) {
          expect(
            () => QuantityMirror.computeStatus(
              ordered: ordered,
              deliveries: deliveries,
              bagMassKg: bagMass,
              tolerancePercent: tolerance,
            ),
            throwsA(
              isA<QuantityException>().having(
                (e) => e.code,
                'code',
                vector['error'],
              ),
            ),
          );
          return;
        }

        final expected = vector['expected']! as Map<String, Object?>;
        final state = QuantityMirror.computeStatus(
          ordered: ordered,
          deliveries: deliveries,
          bagMassKg: bagMass,
          tolerancePercent: tolerance,
        );
        expect(state.received, _decimal(expected['received']));
        expect(state.remaining, _decimal(expected['remaining']));
        expect(state.variance, _decimal(expected['variance']));
        expect(
          _fixed(state.variancePercent, 2),
          expected['variancePercent'],
          reason: 'ecart % a 2 decimales',
        );
        expect(state.status.code, expected['status']);
        expect(state.unit, ordered.unit, reason: 'dans l unite de la commande');
        expect(state.isProvisional, isFalse);
      });
    }
  });

  // Aucun prix n'existe sur le telephone (ADR 0012) : le mobile ne calcule ni montant ni valeur
  // recue. Ces vecteurs ne verifient donc que la primitive d'arrondi « loin de zero » partagee
  // par les conversions et les pourcentages : 613,125 -> 613,13, jamais 613,12 (arrondi bancaire).
  group('arrondi loin de zero (vecteurs de montants)', () {
    for (final vector in _section(vectors, 'amounts')) {
      test(vector['name'] as String, () {
        final exact =
            Decimal.parse(vector['quantity']! as String) *
            Decimal.parse(vector['unitPrice']! as String);
        final rounded = QuantityMirror.roundAwayFromZero(exact, Decimal.one, 2);
        expect(_fixed(rounded, 2), vector['expected']);
      });
    }

    for (final vector in _section(vectors, 'receivedValue')) {
      test(vector['name'] as String, () {
        final price = Decimal.parse(vector['unitPrice']! as String);
        var total = Decimal.zero;
        for (final quantity in (vector['deliveries']! as List)) {
          total += QuantityMirror.roundAwayFromZero(
            Decimal.parse(quantity as String) * price,
            Decimal.one,
            2,
          );
        }
        expect(_fixed(total, 2), vector['expected']);
      });
    }

    test('negatif : -613,125 donne -613,13 (loin de zero)', () {
      expect(
        _fixed(
          QuantityMirror.roundAwayFromZero(
            Decimal.parse('-613.125'),
            Decimal.one,
            2,
          ),
          2,
        ),
        '-613.13',
      );
    });
  });

  group('retard (jours calendaires, heure d Algerie)', () {
    for (final vector in _section(vectors, 'overdue')) {
      test(vector['name'] as String, () {
        expect(
          AlgeriaDate.overdueDays(
            DateTime.parse('${vector['due']}T00:00:00Z'),
            DateTime.parse('${vector['today']}T00:00:00Z'),
          ),
          vector['expected'],
        );
      });
    }
  });

  group('date de besoin par defaut (aujourd hui + N jours)', () {
    for (final vector in _section(vectors, 'defaultNeededBy')) {
      test('${vector['today']} + ${vector['days']} j', () {
        final today = DateTime.parse('${vector['today']}T00:00:00Z');
        final result = AlgeriaDate.defaultNeededBy(
          today,
          vector['days']! as int,
        );
        expect(result, DateTime.parse('${vector['expected']}T00:00:00Z'));
      });
    }
  });

  group('totaux par produit : jamais d unites differentes additionnees', () {
    for (final vector in _section(vectors, 'aggregates')) {
      test(vector['name'] as String, () {
        final lines = QuantityMirror.aggregate(
          [for (final item in (vector['items']! as List)) _quantity(item)],
          defaultUnit: MeasureUnit.tryParse(vector['defaultUnit']! as String)!,
          bagMassKg: _decimal(vector['bagMassKg']),
        );
        final expected = (vector['expected']! as List)
            .cast<Map<String, Object?>>();

        expect(lines, hasLength(expected.length));
        for (var i = 0; i < expected.length; i++) {
          expect(lines[i].total, _quantity(expected[i]['total']));
          final mass = expected[i]['massEquivalent'];
          expect(
            lines[i].massEquivalent,
            mass == null ? isNull : _quantity(mass),
          );
        }
      });
    }
  });
}
