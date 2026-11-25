import 'package:chantier_mobile/database/app_database.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  group('upsertIfNewer (idempotent par version, ADR 0009)', () {
    test('insere une ligne absente', () async {
      final applied = await db.sitesDao.upsertIfNewer(siteRow(version: 100));

      expect(applied, isTrue);
      expect((await db.sitesDao.getSite('site-uv18'))!.code, 'CH-ECO-UV18');
    });

    test('meme version rejouee : sans effet', () async {
      await db.sitesDao.upsertIfNewer(siteRow(version: 100));

      final again = await db.sitesDao.upsertIfNewer(
        siteRow(version: 100, name: 'Nom different'),
      );

      expect(again, isFalse);
      expect((await db.sitesDao.getSite('site-uv18'))!.name, 'École UV18');
    });

    test('version plus ancienne : ignoree', () async {
      await db.sitesDao.upsertIfNewer(siteRow(version: 100));

      final applied = await db.sitesDao.upsertIfNewer(
        siteRow(version: 99, name: 'Ancien'),
      );

      expect(applied, isFalse);
      expect((await db.sitesDao.getSite('site-uv18'))!.name, 'École UV18');
    });

    test('version plus recente : remplace', () async {
      await db.sitesDao.upsertIfNewer(siteRow(version: 100));

      final applied = await db.sitesDao.upsertIfNewer(
        siteRow(version: 101, name: 'École UV18 bis'),
      );

      expect(applied, isTrue);
      expect((await db.sitesDao.getSite('site-uv18'))!.name, 'École UV18 bis');
      expect(await db.sitesDao.countSites(), 1);
    });

    test('comparaison NUMERIQUE : 10 est plus recent que 9', () async {
      await db.sitesDao.upsertIfNewer(siteRow(version: 9));

      final applied = await db.sitesDao.upsertIfNewer(
        siteRow(version: 10, name: 'dix'),
      );

      expect(applied, isTrue, reason: 'en texte, "10" < "9"');
      expect((await db.sitesDao.getSite('site-uv18'))!.name, 'dix');
    });

    test('grande version de rowversion (> 2^32) conservee', () async {
      const big = 4294967296 * 5 + 7;
      await db.sitesDao.upsertIfNewer(siteRow(version: big));

      expect((await db.sitesDao.getSite('site-uv18'))!.version, big);
    });

    test(
      'rejouer une page de 50 chantiers : meme resultat (idempotent)',
      () async {
        final page = [
          for (var i = 0; i < 50; i++)
            siteRow(id: 'site-$i', code: 'CH-$i', version: 100 + i),
        ];
        for (final row in page) {
          await db.sitesDao.upsertIfNewer(row);
        }
        var appliedOnReplay = 0;
        for (final row in page) {
          if (await db.sitesDao.upsertIfNewer(row)) appliedOnReplay++;
        }

        expect(appliedOnReplay, 0);
        expect(await db.sitesDao.countSites(), 50);
      },
    );
  });

  group('montant du marche (CA-003.5)', () {
    test('conserve avec la permission, sans perte', () async {
      await db.sitesDao.upsertIfNewer(
        siteRow(contractAmount: Decimal.parse('185000000.00')),
      );

      final row = (await db.sitesDao.getSite('site-uv18'))!;

      expect(row.contractAmount, Decimal.parse('185000000.00'));
    });

    test('sans la permission : colonne vide', () async {
      await db.sitesDao.upsertIfNewer(siteRow());

      expect((await db.sitesDao.getSite('site-uv18'))!.contractAmount, isNull);
    });

    test(
      'permission retiree : le montant deja stocke est efface par la version suivante',
      () async {
        await db.sitesDao.upsertIfNewer(
          siteRow(version: 100, contractAmount: Decimal.parse('185000000.00')),
        );

        await db.sitesDao.upsertIfNewer(siteRow(version: 101));

        expect(
          (await db.sitesDao.getSite('site-uv18'))!.contractAmount,
          isNull,
        );
      },
    );
  });

  group('types stockes en texte', () {
    test('dates metier et coordonnees : aller-retour exact', () async {
      await db.sitesDao.upsertIfNewer(
        siteRow(
          odsDate: DateTime.utc(2026, 3, 2),
          contractualEndDate: DateTime.utc(2027, 8, 24),
        ),
      );

      final row = (await db.sitesDao.getSite('site-uv18'))!;

      expect(row.odsDate, DateTime.utc(2026, 3, 2));
      expect(row.contractualEndDate, DateTime.utc(2027, 8, 24));
      expect(row.latitude, Decimal.parse('36.575'));
      expect(row.delayDays, 540);
    });

    test('fin contractuelle absente : null (« A definir »)', () async {
      await db.sitesDao.upsertIfNewer(siteRow());

      expect(
        (await db.sitesDao.getSite('site-uv18'))!.contractualEndDate,
        isNull,
      );
    });

    test('horodatages UTC conserves', () async {
      await db.sitesDao.upsertIfNewer(siteRow());

      final row = (await db.sitesDao.getSite('site-uv18'))!;

      expect(row.createdAt.toUtc(), DateTime.utc(2026, 11, 24, 8));
    });
  });

  group('flux reactifs', () {
    test(
      'watchSites emet a chaque changement, tri par nom sans casse',
      () async {
        final emissions = <List<String>>[];
        final subscription = db.sitesDao.watchSites().listen(
          (rows) => emissions.add([for (final r in rows) r.name]),
        );
        await Future<void>.delayed(Duration.zero);

        await db.sitesDao.upsertIfNewer(
          siteRow(id: 'b', code: 'B', name: 'logements OL40'),
        );
        await db.sitesDao.upsertIfNewer(
          siteRow(id: 'a', code: 'A', name: 'École UV18'),
        );
        await Future<void>.delayed(Duration.zero);

        expect(emissions.first, isEmpty);
        expect(emissions.last, ['logements OL40', 'École UV18']);
        await subscription.cancel();
      },
    );

    test(
      'chantiers archives masques par defaut, visibles avec le filtre',
      () async {
        await db.sitesDao.upsertIfNewer(
          siteRow(id: 'a', code: 'A', name: 'Actif'),
        );
        await db.sitesDao.upsertIfNewer(
          siteRow(
            id: 'z',
            code: 'Z',
            name: 'Archive',
            archivedAt: DateTime.utc(2026, 11, 1),
          ),
        );

        final visible = await db.sitesDao.watchSites().first;
        final all = await db.sitesDao.watchSites(includeArchived: true).first;

        expect(visible.map((r) => r.id), ['a']);
        expect(all.map((r) => r.id), unorderedEquals(['a', 'z']));
      },
    );

    test('watchSite : emet la mise a jour', () async {
      await db.sitesDao.upsertIfNewer(siteRow(version: 100));
      final names = <String?>[];
      final subscription = db.sitesDao
          .watchSite('site-uv18')
          .listen((row) => names.add(row?.name));
      await Future<void>.delayed(Duration.zero);

      await db.sitesDao.upsertIfNewer(siteRow(version: 101, name: 'Renomme'));
      await db.sitesDao.deleteSite('site-uv18');
      await Future<void>.delayed(Duration.zero);

      expect(names, ['École UV18', 'Renomme', null]);
      await subscription.cancel();
    });
  });

  group(
    'suppression en cascade site -> zones et affectations (pierre tombale)',
    () {
      test(
        'supprimer le chantier supprime ses zones et ses affectations',
        () async {
          await db.sitesDao.upsertIfNewer(siteRow(id: 's1', code: 'S1'));
          await db.sitesDao.upsertIfNewer(siteRow(id: 's2', code: 'S2'));
          await db.zonesDao.upsertIfNewer(zoneRow(id: 'z1', siteId: 's1'));
          await db.zonesDao.upsertIfNewer(
            zoneRow(id: 'z2', siteId: 's2', version: 201),
          );
          await db.siteMembersDao.upsertIfNewer(
            memberRow(id: 'm1', siteId: 's1'),
          );
          await db.siteMembersDao.upsertIfNewer(
            memberRow(id: 'm2', siteId: 's2', version: 301),
          );

          final removed = await db.sitesDao.deleteSite('s1');

          expect(removed, 1);
          expect(await db.zonesDao.getById('z1'), isNull);
          expect(await db.siteMembersDao.getById('m1'), isNull);
          expect(
            await db.zonesDao.getById('z2'),
            isNotNull,
            reason: 'autre chantier intact',
          );
          expect(await db.siteMembersDao.getById('m2'), isNotNull);
        },
      );

      test('les cles etrangeres sont actives a l ouverture', () async {
        final result = await db.customSelect('PRAGMA foreign_keys').getSingle();

        expect(result.read<int>('foreign_keys'), 1);
      });

      test('une zone ne peut pas viser un chantier inconnu', () async {
        await expectLater(
          db.zonesDao.upsertIfNewer(zoneRow(siteId: 'inexistant')),
          throwsA(anything),
        );
      });
    },
  );
}
