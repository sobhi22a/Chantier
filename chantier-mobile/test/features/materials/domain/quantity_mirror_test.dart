import 'package:chantier_mobile/features/materials/domain/algeria_date.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/quantity_mirror.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

Quantity q(String value, MeasureUnit unit) =>
    Quantity(Decimal.parse(value), unit);

final Decimal bag50 = Decimal.fromInt(50);

void main() {
  group('equivalence affichee pendant la frappe (CA-MAT-001.3)', () {
    test('300 sacs = 15 T', () {
      expect(
        QuantityMirror.equivalence(q('300', MeasureUnit.bag), bagMassKg: bag50),
        q('15', MeasureUnit.tonne),
      );
    });

    test('15 sacs = 750 kg (moins d une tonne : en kilogrammes)', () {
      expect(
        QuantityMirror.equivalence(q('15', MeasureUnit.bag), bagMassKg: bag50),
        q('750', MeasureUnit.kilogram),
      );
    });

    test('20 sacs = 1 T (la limite est incluse)', () {
      expect(
        QuantityMirror.equivalence(q('20', MeasureUnit.bag), bagMassKg: bag50),
        q('1', MeasureUnit.tonne),
      );
    });

    test('3000 au lieu de 300 saute aux yeux : 150 T', () {
      expect(
        QuantityMirror.equivalence(
          q('3000', MeasureUnit.bag),
          bagMassKg: bag50,
        ),
        q('150', MeasureUnit.tonne),
      );
    });

    test('17,5 T = 350 sacs', () {
      expect(
        QuantityMirror.equivalence(
          q('17.5', MeasureUnit.tonne),
          bagMassKg: bag50,
        ),
        q('350', MeasureUnit.bag),
      );
    });

    test('monocouche (sac de 25 kg) : 1,2 T = 48 sacs', () {
      expect(
        QuantityMirror.equivalence(
          q('1.2', MeasureUnit.tonne),
          bagMassKg: Decimal.fromInt(25),
        ),
        q('48', MeasureUnit.bag),
      );
    });

    test('aucune equivalence pour m3, u, L ni sans masse de sac', () {
      expect(
        QuantityMirror.equivalence(q('24', MeasureUnit.cubicMeter)),
        isNull,
      );
      expect(QuantityMirror.equivalence(q('100', MeasureUnit.piece)), isNull);
      expect(QuantityMirror.equivalence(q('200', MeasureUnit.liter)), isNull);
      expect(QuantityMirror.equivalence(q('300', MeasureUnit.bag)), isNull);
      expect(QuantityMirror.equivalence(q('2', MeasureUnit.tonne)), isNull);
    });
  });

  group('saisie au clavier numerique', () {
    test('virgule et point acceptes', () {
      expect(QuantityMirror.parseInput('2,5'), Decimal.parse('2.5'));
      expect(QuantityMirror.parseInput('2.5'), Decimal.parse('2.5'));
      expect(QuantityMirror.parseInput(' 300 '), Decimal.fromInt(300));
    });

    test('texte incomplet ou invalide : pas de valeur', () {
      for (final text in ['', '2,', ',5', 'abc', '2,5,1', '1 000', '--2']) {
        expect(QuantityMirror.parseInput(text), isNull, reason: text);
      }
    });

    test('negatif lu puis refuse par la regle de quantite', () {
      final value = QuantityMirror.parseInput('-5')!;
      expect(
        QuantityMirror.check(Quantity(value, MeasureUnit.kilogram)),
        'QUANTITE_INVALIDE',
      );
    });

    test('2,5 sac refuse (entier requis), 2,5 kg accepte', () {
      final value = QuantityMirror.parseInput('2,5')!;
      expect(
        QuantityMirror.check(Quantity(value, MeasureUnit.bag)),
        'QUANTITE_ENTIERE_REQUISE',
      );
      expect(
        QuantityMirror.check(Quantity(value, MeasureUnit.kilogram)),
        isNull,
      );
    });
  });

  group('statut provisoire hors ligne (a confirmer)', () {
    final ordered = q('600', MeasureUnit.bag);

    test('une livraison saisie hors ligne : 10 T = 200 sacs, a confirmer', () {
      final state = QuantityMirror.provisionalReception(
        status: RequestStatus.ordered,
        ordered: ordered,
        deliveries: [
          DeliveryFact(quantity: q('10', MeasureUnit.tonne), isPending: true),
        ],
        bagMassKg: bag50,
      )!;

      expect(state.status, RequestStatus.partiallyDelivered);
      expect(state.receivedQuantity, q('200', MeasureUnit.bag));
      expect(state.remainingQuantity, q('400', MeasureUnit.bag));
      expect(state.isProvisional, isTrue);
    });

    test('livraisons deja confirmees : pas de marque « a confirmer »', () {
      final state = QuantityMirror.provisionalReception(
        status: RequestStatus.partiallyDelivered,
        ordered: ordered,
        deliveries: [DeliveryFact(quantity: q('10', MeasureUnit.tonne))],
        bagMassKg: bag50,
      )!;

      expect(state.isProvisional, isFalse);
      expect(state.status, RequestStatus.partiallyDelivered);
    });

    test('la 3e livraison complete la commande : Livree', () {
      final state = QuantityMirror.provisionalReception(
        status: RequestStatus.partiallyDelivered,
        ordered: ordered,
        deliveries: [
          DeliveryFact(quantity: q('10', MeasureUnit.tonne)),
          DeliveryFact(quantity: q('10', MeasureUnit.tonne)),
          DeliveryFact(quantity: q('10', MeasureUnit.tonne), isPending: true),
        ],
        bagMassKg: bag50,
      )!;

      expect(state.status, RequestStatus.delivered);
      expect(state.remaining, Decimal.zero);
      expect(state.isProvisional, isTrue);
    });

    test('annuler une livraison fait redescendre le statut (deux sens)', () {
      final state = QuantityMirror.provisionalReception(
        status: RequestStatus.delivered,
        ordered: ordered,
        deliveries: [
          DeliveryFact(quantity: q('10', MeasureUnit.tonne)),
          DeliveryFact(quantity: q('10', MeasureUnit.tonne)),
          DeliveryFact(
            quantity: q('10', MeasureUnit.tonne),
            isCancelled: true,
            isPending: true,
          ),
        ],
        bagMassKg: bag50,
      )!;

      expect(state.status, RequestStatus.partiallyDelivered);
      expect(state.receivedQuantity, q('400', MeasureUnit.bag));
      expect(
        state.isProvisional,
        isFalse,
        reason: 'une annulation en attente n entre pas dans le calcul du recu',
      );
    });

    test(
      'toutes les livraisons annulees : retour a Commandee, meme soldee',
      () {
        final state = QuantityMirror.provisionalReception(
          status: RequestStatus.delivered,
          ordered: ordered,
          deliveries: [
            DeliveryFact(
              quantity: q('10', MeasureUnit.tonne),
              isCancelled: true,
            ),
          ],
          bagMassKg: bag50,
          isSettled: true,
        )!;

        expect(state.status, RequestStatus.ordered);
      },
    );

    test('demande validee : livraison retenue, le statut reste Validee', () {
      final state = QuantityMirror.provisionalReception(
        status: RequestStatus.validated,
        ordered: ordered,
        deliveries: [
          DeliveryFact(quantity: q('10', MeasureUnit.tonne), isPending: true),
        ],
        bagMassKg: bag50,
      )!;

      expect(state.status, RequestStatus.validated);
      expect(state.receivedQuantity, q('200', MeasureUnit.bag));
      expect(state.isProvisional, isTrue);
    });

    test('demande soldee : le manque definitif compte comme livre', () {
      final state = QuantityMirror.provisionalReception(
        status: RequestStatus.partiallyDelivered,
        ordered: ordered,
        deliveries: [DeliveryFact(quantity: q('10', MeasureUnit.tonne))],
        bagMassKg: bag50,
        isSettled: true,
      )!;

      expect(state.status, RequestStatus.delivered);
      expect(state.remaining, Decimal.fromInt(400));
    });

    test('tolerance du serveur : 1 % de manque compte comme complet', () {
      final state = QuantityMirror.provisionalReception(
        status: RequestStatus.ordered,
        ordered: q('20', MeasureUnit.tonne),
        deliveries: [
          DeliveryFact(
            quantity: q('19.85', MeasureUnit.tonne),
            isPending: true,
          ),
        ],
        tolerancePercent: Decimal.one,
      )!;

      expect(state.status, RequestStatus.delivered);
    });

    test('statuts non recalcules : aucun etat provisoire', () {
      for (final status in [
        RequestStatus.requested,
        RequestStatus.rejected,
        RequestStatus.cancelled,
        RequestStatus.received,
      ]) {
        expect(
          QuantityMirror.provisionalReception(
            status: status,
            ordered: ordered,
            deliveries: [DeliveryFact(quantity: q('10', MeasureUnit.tonne))],
            bagMassKg: bag50,
          ),
          isNull,
          reason: status.code,
        );
      }
    });

    test('unite non convertible : rien n est invente', () {
      expect(
        QuantityMirror.provisionalReception(
          status: RequestStatus.ordered,
          ordered: q('24', MeasureUnit.cubicMeter),
          deliveries: [DeliveryFact(quantity: q('30', MeasureUnit.tonne))],
        ),
        isNull,
      );
    });

    test(
      'un manque de 0,004 % n est pas « complet » avec 0 % de tolerance',
      () {
        final state = QuantityMirror.computeStatus(
          ordered: q('100000', MeasureUnit.kilogram),
          deliveries: [q('99999.996', MeasureUnit.kilogram)],
        );

        expect(state.status, RequestStatus.partiallyDelivered);
      },
    );
  });

  group('totaux par produit', () {
    test('sans masse de sac, des sacs et des tonnes restent separes', () {
      final lines = QuantityMirror.aggregate([
        q('100', MeasureUnit.bag),
        q('5', MeasureUnit.tonne),
      ], defaultUnit: MeasureUnit.bag);

      expect(lines.map((l) => l.total).toList(), [
        q('100', MeasureUnit.bag),
        q('5', MeasureUnit.tonne),
      ]);
      expect(lines.every((l) => l.massEquivalent == null), isTrue);
    });

    test('aucune unite a additionner : liste vide', () {
      expect(
        QuantityMirror.aggregate(const [], defaultUnit: MeasureUnit.bag),
        isEmpty,
      );
    });
  });

  group('dates d Algerie', () {
    test('aujourd hui : UTC+1 sans heure d ete', () {
      // 23 h 30 a Paris en hiver = 22 h 30 UTC = 23 h 30 a Alger : meme jour.
      expect(
        AlgeriaDate.today(DateTime.utc(2026, 11, 25, 22, 30)),
        DateTime.utc(2026, 11, 25),
      );
      // 23 h 30 UTC = 0 h 30 le lendemain a Alger.
      expect(
        AlgeriaDate.today(DateTime.utc(2026, 11, 25, 23, 30)),
        DateTime.utc(2026, 11, 26),
      );
    });

    test('retard seulement pour une demande encore ouverte', () {
      final today = DateTime.utc(2026, 11, 28);
      final due = DateTime.utc(2026, 11, 26);
      int overdue(RequestStatus? status) => AlgeriaDate.requestOverdueDays(
        status: status,
        neededBy: due,
        today: today,
      );

      expect(overdue(RequestStatus.requested), 2);
      expect(overdue(RequestStatus.validated), 2);
      expect(overdue(RequestStatus.ordered), 2);
      expect(overdue(RequestStatus.partiallyDelivered), 2);
      expect(overdue(RequestStatus.delivered), 0);
      expect(overdue(RequestStatus.received), 0);
      expect(overdue(RequestStatus.cancelled), 0);
      expect(overdue(RequestStatus.rejected), 0);
      expect(overdue(null), 0);
    });
  });
}
