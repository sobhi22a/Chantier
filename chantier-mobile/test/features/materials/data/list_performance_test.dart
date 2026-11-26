import 'dart:async';

import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/utils/stream_combine.dart';
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/materials_harness.dart';

/// R2-07 : la liste ne relit pas toute la table avec ses textes lourds a chaque emission.
void main() {
  group('throttleLatest', () {
    test(
      'la premiere valeur passe tout de suite, les rafales sont regroupees',
      () {
        fakeAsync((async) {
          final source = StreamController<int>();
          final seen = <int>[];
          throttleLatest(
            source.stream,
            const Duration(milliseconds: 300),
          ).listen(seen.add);

          source.add(1);
          async.flushMicrotasks();
          expect(seen, [1]);

          // 35 pages ecrites a la suite : une seule recomposition a la fin de la fenetre.
          for (var i = 2; i <= 36; i++) {
            source.add(i);
          }
          async.flushMicrotasks();
          expect(seen, [1]);

          async.elapse(const Duration(milliseconds: 300));
          expect(seen, [1, 36]);

          // Apres une fenetre calme, la valeur suivante repasse tout de suite.
          async.elapse(const Duration(seconds: 1));
          source.add(37);
          async.flushMicrotasks();
          expect(seen, [1, 36, 37]);
        });
      },
    );

    test('la derniere valeur n est jamais perdue a la fermeture du flux', () {
      fakeAsync((async) {
        final source = StreamController<int>();
        final seen = <int>[];
        throttleLatest(
          source.stream,
          const Duration(milliseconds: 300),
        ).listen(seen.add);
        source.add(1);
        source.add(2);
        unawaited(source.close());
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        expect(seen, [1, 2]);
      });
    });

    test('fenetre nulle : flux inchange', () async {
      final values = await throttleLatest(
        Stream.fromIterable([1, 2, 3]),
        Duration.zero,
      ).toList();
      expect(values, [1, 2, 3]);
    });
  });

  group('liste legere', () {
    late MaterialsHarness h;
    late DeliveriesRepository deliveries;

    setUp(() async {
      h = MaterialsHarness();
      await h.seed();
      deliveries = DeliveriesRepository(
        database: h.db,
        outbox: OutboxRepository(h.db),
      );
      await h.db.materialRequestsDao.upsertIfNewer(
        requestRow(
          id: 'r-1',
          historyJson:
              '[{"id":"e1","type":"Created","occurredAt":"2026-11-25T07:00:00Z"}]',
          orderJson: '{"id":"o1","supplierName":"Sigma"}',
        ),
      );
      await h.db.deliveriesDao.upsertIfNewer(
        deliveryRow(
          id: 'l-1',
          requestId: 'r-1',
          historyJson:
              '[{"id":"e1","type":"DeliveryRegistered","occurredAt":"2026-11-25T07:00:00Z"}]',
        ),
      );
    });
    tearDown(() => h.dispose());

    test(
      'la liste des demandes ne lit pas l historique (la commande reste, petite)',
      () async {
        final list = await h.materials
            .watchRequests('site-uv18', 'user-chef')
            .first;
        expect(list.single.row.historyJson, isNull);
        expect(list.single.row.orderJson, contains('Sigma'));
        // Le reste de la ligne est intact.
        expect(list.single.row.number, 'DEM-009');
        expect(list.single.row.quantityValue.toString(), '300');
      },
    );

    test('le detail relit l historique et la commande', () async {
      final detail = await h.materials.watchRequest('r-1', 'user-chef').first;
      expect(detail!.row.historyJson, contains('Created'));
      expect(detail.row.orderJson, contains('Sigma'));
    });

    test('la liste des livraisons ne lit pas l historique', () async {
      final list = await deliveries
          .watchDeliveries('site-uv18', 'user-chef')
          .first;
      expect(list.single.row.historyJson, isNull);
      expect(list.single.row.number, 'LIV-006');
      final detail = await deliveries.watchDelivery('l-1', 'user-chef').first;
      expect(detail!.row.historyJson, contains('DeliveryRegistered'));
    });
  });
}
