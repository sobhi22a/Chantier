import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  group('produits (catalogue global)', () {
    test('idempotent par version, comparee numeriquement', () async {
      expect(
        await db.productsDao.upsertIfNewer(productRow(version: 9)),
        isTrue,
      );
      expect(
        await db.productsDao.upsertIfNewer(productRow(version: 9)),
        isFalse,
      );
      expect(
        await db.productsDao.upsertIfNewer(productRow(version: 8)),
        isFalse,
      );
      // 10 > 9 numeriquement (« 10 » < « 9 » en tri alphabetique).
      expect(
        await db.productsDao.upsertIfNewer(
          productRow(version: 10, nameFr: 'Ciment CPJ 42,5 R'),
        ),
        isTrue,
      );

      expect(
        (await db.productsDao.getById('prod-ciment'))!.nameFr,
        'Ciment CPJ 42,5 R',
      );
      expect(await db.productsDao.countAll(), 1);
    });

    test('rechargement complet : une version egale est aussi ecrite', () async {
      await db.productsDao.upsertIfNewer(productRow(version: 9));

      expect(
        await db.productsDao.upsertIfNewer(
          productRow(version: 9, isActive: false),
          overwrite: true,
        ),
        isTrue,
      );
      expect((await db.productsDao.getById('prod-ciment'))!.isActive, isFalse);
    });

    test(
      'unites autorisees, unite par defaut et masse du sac conservees',
      () async {
        await db.productsDao.upsertIfNewer(productRow());
        await db.productsDao.upsertIfNewer(
          productRow(
            id: 'prod-mono',
            nameFr: 'Monocouche',
            bagMassKg: '25',
            allowedUnits: const ['sac', 't'],
          ),
        );
        await db.productsDao.upsertIfNewer(
          productRow(
            id: 'prod-sable',
            nameFr: 'Sable de maçonnerie',
            category: 'Aggregates',
            allowedUnits: const ['m3', 't'],
            defaultUnit: 'm3',
            bagMassKg: null,
          ),
        );

        final ciment = (await db.productsDao.getById('prod-ciment'))!;
        expect(ciment.allowedUnits, ['sac', 't', 'kg']);
        expect(ciment.allowedMeasureUnits.map((u) => u.code), [
          'sac',
          't',
          'kg',
        ]);
        expect(ciment.defaultMeasureUnit!.code, 'sac');
        expect(ciment.bagMassKg, Decimal.fromInt(50));
        expect(
          (await db.productsDao.getById('prod-mono'))!.bagMassKg,
          Decimal.fromInt(25),
        );
        expect((await db.productsDao.getById('prod-sable'))!.bagMassKg, isNull);
      },
    );

    test(
      'unite inconnue (ajoutee par le serveur) : ignoree sans erreur',
      () async {
        await db.productsDao.upsertIfNewer(
          productRow(allowedUnits: const ['sac', 'barre']),
        );

        final row = (await db.productsDao.getById('prod-ciment'))!;
        expect(row.allowedUnits, ['sac', 'barre']);
        expect(row.allowedMeasureUnits.map((u) => u.code), ['sac']);
      },
    );

    test(
      'desactive : masque de la liste, toujours lisible par identifiant',
      () async {
        await db.productsDao.upsertIfNewer(productRow());
        await db.productsDao.upsertIfNewer(
          productRow(id: 'prod-old', nameFr: 'Ancien produit', isActive: false),
        );

        expect((await db.productsDao.getAll()).map((p) => p.id), [
          'prod-ciment',
        ]);
        expect((await db.productsDao.getAll(includeInactive: true)).length, 2);
        expect(await db.productsDao.getById('prod-old'), isNotNull);
      },
    );

    test(
      'tri « lecture humaine » : « Ecole » avant « Zinc », accents pliés',
      () async {
        for (final (id, name) in [
          ('p1', 'Zinc'),
          ('p2', 'Étanchéité'),
          ('p3', 'Brique'),
        ]) {
          await db.productsDao.upsertIfNewer(productRow(id: id, nameFr: name));
        }

        expect((await db.productsDao.watchAll().first).map((p) => p.nameFr), [
          'Brique',
          'Étanchéité',
          'Zinc',
        ]);
      },
    );
  });

  group('fournisseurs (globaux)', () {
    test('idempotent par version et produits fournis conserves', () async {
      expect(
        await db.suppliersDao.upsertIfNewer(
          supplierRow(productIds: const ['prod-ciment', 'prod-mono']),
        ),
        isTrue,
      );
      expect(await db.suppliersDao.upsertIfNewer(supplierRow()), isFalse);

      final row = (await db.suppliersDao.getById('sup-sigma'))!;
      expect(row.productIds, ['prod-ciment', 'prod-mono']);
      expect(await db.suppliersDao.countAll(), 1);
    });

    test('desactive : masque de la liste', () async {
      await db.suppliersDao.upsertIfNewer(supplierRow());
      await db.suppliersDao.upsertIfNewer(
        supplierRow(id: 'sup-old', name: 'Ancien', isActive: false),
      );

      expect((await db.suppliersDao.watchAll().first).map((s) => s.id), [
        'sup-sigma',
      ]);
    });
  });

  group('reglages gardes pour le hors ligne', () {
    test('ecrit, relit, remplace', () async {
      expect(await db.appSettingsDao.get('materials'), isNull);

      await db.appSettingsDao.set('materials', '{"a":1}');
      await db.appSettingsDao.set('materials', '{"a":2}');

      expect(await db.appSettingsDao.get('materials'), '{"a":2}');
      expect(await db.appSettingsDao.watch('materials').first, '{"a":2}');
    });
  });

  test(
    'unite inconnue d une demande : lecture typee nulle, jamais d erreur',
    () async {
      // Unite venue d'une version plus recente du serveur : affichee telle que recue.
      await db.sitesDao.upsertIfNewer(siteRow());
      await db.materialRequestsDao.upsertIfNewer(requestRow(unit: 'barre'));

      final row = (await db.materialRequestsDao.getById('req-009'))!;
      expect(row.quantity, isNull);
      expect(row.quantityUnit, 'barre');
      expect(row.quantityValue, Decimal.fromInt(300));
      expect(() => Quantity.parse('300', 'barre'), throwsFormatException);
    },
  );
}
