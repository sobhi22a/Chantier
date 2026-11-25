import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late SitesRepository repository;
  SitesCubit? cubit;
  SiteDetailCubit? detail;

  setUp(() {
    db = createTestDatabase();
    repository = SitesRepository(db);
  });
  tearDown(() async {
    await cubit?.close();
    await detail?.close();
    await db.close();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  Future<void> addSite(
    String id,
    String name, {
    String? nameAr,
    DateTime? archivedAt,
  }) => db.sitesDao.upsertIfNewer(
    siteRow(
      id: id,
      code: 'CH-$id',
      name: name,
      nameAr: nameAr,
      archivedAt: archivedAt,
    ),
  );

  group('Mes chantiers (lecture locale seulement)', () {
    test(
      'liste triee par nom, archives masques par defaut (CA-006.8)',
      () async {
        await addSite('b', 'Logements OL40');
        await addSite('a', 'École UV18');
        await addSite(
          'z',
          'Ancien chantier',
          archivedAt: DateTime.utc(2026, 11, 1),
        );
        cubit = SitesCubit(repository);
        await settle();

        expect(cubit!.state.loaded, isTrue);
        expect(cubit!.state.sites.map((s) => s.id), ['a', 'b']);
      },
    );

    test('filtre « Afficher les archives »', () async {
      await addSite('a', 'Actif');
      await addSite('z', 'Archive', archivedAt: DateTime.utc(2026, 11, 1));
      cubit = SitesCubit(repository);
      await settle();

      cubit!.setShowArchived(value: true);
      await settle();

      expect(cubit!.state.sites.map((s) => s.id), unorderedEquals(['a', 'z']));
      expect(cubit!.state.showArchived, isTrue);

      cubit!.setShowArchived(value: false);
      await settle();
      expect(cubit!.state.sites.map((s) => s.id), ['a']);
    });

    test('recherche par nom, nom arabe ou code, sans casse', () async {
      await addSite('1', 'École UV18', nameAr: 'مدرسة UV18');
      await addSite('2', 'Logements OL40');
      cubit = SitesCubit(repository);
      await settle();

      cubit!.setQuery('uv18');
      expect(cubit!.state.sites.map((s) => s.id), ['1']);
      cubit!.setQuery('مدرسة');
      expect(cubit!.state.sites.map((s) => s.id), ['1']);
      cubit!.setQuery('CH-2');
      expect(cubit!.state.sites.map((s) => s.id), ['2']);
      cubit!.setQuery('rien');
      expect(cubit!.state.sites, isEmpty);
      cubit!.setQuery('');
      expect(cubit!.state.sites, hasLength(2));
    });

    test('la recherche n\'apparait qu\'au-dela de 5 chantiers', () async {
      for (var i = 1; i <= 5; i++) {
        await addSite('$i', 'Chantier $i');
      }
      cubit = SitesCubit(repository);
      await settle();
      expect(cubit!.state.showSearch, isFalse);

      await addSite('6', 'Chantier 6');
      await settle();

      expect(cubit!.state.showSearch, isTrue);
    });

    test(
      '50 chantiers : tous disponibles localement, rapidement (CA-006.6)',
      () async {
        for (var i = 0; i < 50; i++) {
          await addSite('s$i', 'Chantier ${i.toString().padLeft(2, '0')}');
        }
        final stopwatch = Stopwatch()..start();
        cubit = SitesCubit(repository);
        await settle();

        expect(cubit!.state.sites, hasLength(50));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      },
    );

    test('mise a jour en direct apres une synchronisation', () async {
      cubit = SitesCubit(repository);
      await settle();
      expect(cubit!.state.sites, isEmpty);

      await addSite('a', 'École UV18');
      await settle();

      expect(cubit!.state.sites.single.name, 'École UV18');
    });

    test(
      'chantier retire par pierre tombale : disparait de la liste',
      () async {
        await addSite('a', 'École UV18');
        cubit = SitesCubit(repository);
        await settle();

        await db.sitesDao.deleteSite('a');
        await settle();

        expect(cubit!.state.sites, isEmpty);
      },
    );
  });

  group('Fiche d\'un chantier (hors ligne)', () {
    test('chantier, zones et affectations lus localement', () async {
      await addSite('s1', 'École UV18');
      await db.zonesDao.upsertIfNewer(zoneRow(id: 'z1', siteId: 's1'));
      await db.siteMembersDao.upsertIfNewer(memberRow(id: 'm1', siteId: 's1'));
      detail = SiteDetailCubit(repository: repository, siteId: 's1');
      await settle();

      expect(detail!.state.loaded, isTrue);
      expect(detail!.state.site?.name, 'École UV18');
      expect(detail!.state.zones.map((z) => z.id), ['z1']);
      expect(detail!.state.members.map((m) => m.fullName), ['Mourad B.']);
    });

    test('chantier absent : fiche vide, jamais un autre chantier', () async {
      await addSite('s1', 'École UV18');
      detail = SiteDetailCubit(repository: repository, siteId: 'autre');
      await settle();

      expect(detail!.state.loaded, isTrue);
      expect(detail!.state.site, isNull);
      expect(detail!.state.zones, isEmpty);
    });

    test('seules les zones de CE chantier', () async {
      await addSite('s1', 'A');
      await addSite('s2', 'B');
      await db.zonesDao.upsertIfNewer(zoneRow(id: 'z1', siteId: 's1'));
      await db.zonesDao.upsertIfNewer(
        zoneRow(id: 'z2', siteId: 's2', roomNumber: 9),
      );
      detail = SiteDetailCubit(repository: repository, siteId: 's1');
      await settle();

      expect(detail!.state.zones.map((z) => z.id), ['z1']);
    });
  });
}
