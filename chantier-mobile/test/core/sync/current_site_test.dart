import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/user_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  CurrentSiteCubit? cubit;

  setUp(() => db = createTestDatabase());
  tearDown(() async {
    await cubit?.close();
    await db.close();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  CurrentSiteCubit build({String userId = 'user-a'}) =>
      cubit = CurrentSiteCubit(database: db, userId: userId);

  Future<void> addSite(String id, {DateTime? archivedAt, int version = 100}) =>
      db.sitesDao.upsertIfNewer(
        siteRow(
          id: id,
          code: 'CH-$id',
          name: 'Chantier $id',
          version: version,
          archivedAt: archivedAt,
        ),
      );

  test(
    'un seul chantier affecte : courant des la premiere connexion (CA-010.2)',
    () async {
      await addSite('s1');

      build();
      await settle();

      expect(cubit!.state.siteId, 's1');
      expect(cubit!.state.needsChoice, isFalse);
      expect(
        await db.userPrefsDao.get('user-a', UserPrefKeys.currentSiteId),
        's1',
      );
    },
  );

  test(
    'plusieurs chantiers et aucun courant : choix exige avant toute saisie',
    () async {
      await addSite('s1');
      await addSite('s2');

      build();
      await settle();

      expect(cubit!.state.site, isNull);
      expect(cubit!.state.needsChoice, isTrue);
      expect(cubit!.state.siteCount, 2);
    },
  );

  test('ouvrir un chantier le rend courant (CA-010.1)', () async {
    await addSite('s1');
    await addSite('s2');
    build();
    await settle();

    await cubit!.select('s2');
    await settle();

    expect(cubit!.state.siteId, 's2');
    expect(cubit!.state.needsChoice, isFalse);
  });

  test(
    'changer de chantier courant : un appui, sans reseau (CA-010.3)',
    () async {
      await addSite('s1');
      await addSite('s2');
      build();
      await cubit!.select('s1');
      await settle();

      await cubit!.select('s2');
      await settle();

      expect(cubit!.state.siteId, 's2');
    },
  );

  test(
    'retrait d\'affectation : plus courant, message, nouveau choix (CA-010.4)',
    () async {
      await addSite('s1');
      await addSite('s2');
      await addSite('s3');
      build();
      await cubit!.select('s1');
      await settle();
      expect(cubit!.state.siteId, 's1');

      await db.sitesDao.deleteSite('s1');
      await settle();

      expect(cubit!.state.site, isNull);
      expect(cubit!.state.removed, isTrue);
      expect(cubit!.state.needsChoice, isTrue);
      expect(
        await db.userPrefsDao.get('user-a', UserPrefKeys.currentSiteId),
        isNull,
      );
    },
  );

  test(
    'retrait alors quun seul chantier reste : message, et ce chantier devient courant (CA-010.2)',
    () async {
      await addSite('s1');
      await addSite('s2');
      build();
      await cubit!.select('s1');
      await settle();

      await db.sitesDao.deleteSite('s1');
      await settle();

      expect(cubit!.state.removed, isTrue);
      expect(cubit!.state.siteId, 's2');
    },
  );

  test('le message « chantier retire » disparait une fois lu', () async {
    await addSite('s1');
    await addSite('s2');
    build();
    await cubit!.select('s1');
    await settle();
    await db.sitesDao.deleteSite('s1');
    await settle();

    cubit!.acknowledgeRemoved();
    await settle();

    expect(cubit!.state.removed, isFalse);
  });

  test('chantier courant archive : traite comme retire', () async {
    await addSite('s1');
    await addSite('s2');
    await addSite('s3');
    build();
    await cubit!.select('s1');
    await settle();

    await addSite('s1', archivedAt: DateTime.utc(2026, 11, 20), version: 200);
    await settle();

    expect(cubit!.state.site, isNull);
    expect(cubit!.state.removed, isTrue);
  });

  test(
    'propre a chaque utilisateur : B ne reprend jamais le chantier de A (CA-010.5)',
    () async {
      await addSite('s1');
      await addSite('s2');
      await db.userPrefsDao.set('user-a', UserPrefKeys.currentSiteId, 's1');

      build(userId: 'user-b');
      await settle();

      expect(cubit!.state.site, isNull);
      expect(cubit!.state.needsChoice, isTrue);
    },
  );

  test(
    'un seul chantier apparait apres la synchro : devient courant',
    () async {
      build();
      await settle();
      expect(cubit!.state.siteCount, 0);

      await addSite('s1');
      await settle();

      expect(cubit!.state.siteId, 's1');
    },
  );

  test('aucun chantier : rien a choisir', () async {
    build();
    await settle();

    expect(cubit!.state.needsChoice, isFalse);
    expect(cubit!.state.loaded, isTrue);
  });
}
