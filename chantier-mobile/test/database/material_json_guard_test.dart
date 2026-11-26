import 'dart:convert';

import 'package:chantier_mobile/database/converters/material_json_guard.dart';
import 'package:flutter_test/flutter_test.dart';

/// Seconde barriere contre la fuite d'un prix sur le telephone (ADR 0012, CT-MAT-22) : meme si le
/// serveur ou un decodeur laissait passer un champ commercial, il n'atteint pas le disque.
void main() {
  group('commande incorporee', () {
    test(
      'garde les champs terrain, retire `commercial` et toute cle inconnue',
      () {
        final json = MaterialJsonGuard.sanitizeOrder(
          jsonEncode({
            'id': 'o-1',
            'supplierId': 'sup-sigma',
            'supplierName': 'Cimenterie Sigma (fictive)',
            'orderDate': '2026-11-25',
            'expectedDeliveryDate': '2026-11-26',
            'plannedAfterNeedDays': 0,
            'note': null,
            'version': '51002',
            'commercial': {
              'unitPrice': 780.00,
              'amount': 234000.00,
              'purchaseOrderNumber': 'BC-2026-044',
            },
            'unitPrice': 780,
            'amount': 234000,
            'purchaseOrderNumber': 'BC-2026-044',
            'supplierPhone': '0550 00 00 21',
          }),
        )!;

        final order = jsonDecode(json) as Map<String, Object?>;
        expect(order.keys.toSet(), MaterialJsonGuard.orderKeys);
        expect(order['supplierName'], 'Cimenterie Sigma (fictive)');
        for (final forbidden in [
          '780',
          '234000',
          'BC-2026',
          'commercial',
          '0550',
          'Price',
          'amount',
        ]) {
          expect(json, isNot(contains(forbidden)), reason: forbidden);
        }
      },
    );

    test('absente ou illisible : null', () {
      expect(MaterialJsonGuard.sanitizeOrder(null), isNull);
      expect(MaterialJsonGuard.sanitizeOrder('pas du json'), isNull);
      expect(MaterialJsonGuard.sanitizeOrder('[1]'), isNull);
    });
  });

  group('historique', () {
    final history = jsonEncode([
      {
        'id': 'e-1',
        'type': 'Created',
        'toStatus': 'Requested',
        'actorName': 'Mourad B.',
        'occurredAt': '2026-11-25T07:00:00Z',
        'source': 'Api',
      },
      {
        'id': 'e-2',
        'type': 'OrderCommercialEdited',
        'changes': [
          {'field': 'unitPrice', 'old': '700', 'new': '780'},
        ],
        'actorName': 'Samir K.',
      },
      {
        'id': 'e-3',
        'type': 'QuantityAdjusted',
        'changes': [
          {'field': 'quantity', 'old': '300 sac', 'new': '200 sac'},
          {'field': 'unitPrice', 'old': '700', 'new': '780'},
          {'field': 'purchaseOrderNumber', 'old': 'A', 'new': 'B'},
          {'field': 'supplierPhone', 'old': '1', 'new': '2'},
        ],
        'amount': 156000,
        'actorName': 'Karim A.',
      },
    ]);

    test('evenement sensible retire, changements commerciaux retires', () {
      final events =
          jsonDecode(MaterialJsonGuard.sanitizeHistory(history)!) as List;

      expect(events.map((e) => (e as Map)['id']), ['e-1', 'e-3']);
      final adjusted = events[1] as Map<String, Object?>;
      expect(adjusted.containsKey('amount'), isFalse);
      expect(adjusted['changes'], [
        {'field': 'quantity', 'old': '300 sac', 'new': '200 sac'},
      ]);
    });

    test('rien de commercial dans le texte stocke', () {
      final stored = MaterialJsonGuard.sanitizeHistory(history)!;
      for (final forbidden in [
        'unitPrice',
        'OrderCommercialEdited',
        '780',
        '156000',
        'purchaseOrder',
        'Phone',
      ]) {
        expect(stored, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('absent, illisible ou pas une liste : null', () {
      expect(MaterialJsonGuard.sanitizeHistory(null), isNull);
      expect(MaterialJsonGuard.sanitizeHistory('{'), isNull);
      expect(MaterialJsonGuard.sanitizeHistory('{"a":1}'), isNull);
    });

    test('historique vide : liste vide', () {
      expect(MaterialJsonGuard.sanitizeHistory('[]'), '[]');
    });
  });
}
