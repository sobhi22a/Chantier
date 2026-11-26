import 'package:chantier_mobile/core/api/generated/export.dart'
    show SyncPullResponse;
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/api_json.dart';
import '../../support/fixtures.dart';
import '../../support/test_database.dart';

const _siteId = '0192a000-0000-7000-8000-0000000000a1';

/// Ecart 26 du contrat : le serveur range une page parents d'abord, mais **entre deux pages aucun
/// ordre n'est garanti** (un chantier retouche apres ses demandes arrive sur une page suivante).
/// Le telephone applique tout le pull avant de controler ses cles etrangeres.
void main() {
  late AppDatabase db;
  late SitesRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = SitesRepository(db);
  });
  tearDown(() => db.close());

  SyncPullResponse page(
    List<Map<String, Object?>> changes, {
    required bool hasMore,
    String cursor = '100',
    List<Map<String, Object?>> deleted = const [],
  }) => SyncPullResponse.fromJson(
    syncPullJson(
      changes: changes,
      deleted: deleted,
      hasMore: hasMore,
      cursor: cursor,
    ),
  );

  final childrenFirst = [
    syncChangeJson(
      'zone',
      zoneJson(id: 'z-1', siteId: _siteId, version: '200'),
      version: '200',
    ),
    syncChangeJson(
      'request',
      requestJson(id: 'r-1', siteId: _siteId, version: '210'),
      version: '210',
    ),
    syncChangeJson(
      'delivery',
      deliveryJson(id: 'l-1', siteId: _siteId, version: '220'),
      version: '220',
    ),
    syncChangeJson(
      'photo',
      photoJson(id: 'p-1', siteId: _siteId, deliveryId: 'l-1', version: '230'),
      version: '230',
    ),
    syncChangeJson(
      'member',
      memberJson(id: 'm-1', siteId: _siteId),
      version: '240',
    ),
  ];

  test(
    'enfants sur la page 1, chantier sur la page 2 : tout est applique',
    () async {
      await repository.applyPullPage(
        page(childrenFirst, hasMore: true, cursor: '240'),
        ownerUserId: 'u',
      );
      // Le chantier n'est pas encore la : les lignes attendent, rien n'est perdu ni refuse.
      expect(await db.zonesDao.getById('z-1'), isNotNull);
      expect(await db.materialRequestsDao.getById('r-1'), isNotNull);

      await repository.applyPullPage(
        page(
          [
            syncChangeJson(
              'site',
              siteJson(id: _siteId, version: '300'),
              version: '300',
            ),
          ],
          hasMore: false,
          cursor: '300',
        ),
        ownerUserId: 'u',
      );

      expect(await db.sitesDao.getSite(_siteId), isNotNull);
      expect(await db.zonesDao.getById('z-1'), isNotNull);
      expect(await db.materialRequestsDao.getById('r-1'), isNotNull);
      expect(await db.deliveriesDao.getById('l-1'), isNotNull);
      expect(await db.deliveryPhotosDao.getById('p-1'), isNotNull);
      expect((await db.siteMembersDao.watchBySite(_siteId).first).length, 1);
    },
  );

  test(
    'le curseur avance avec la page, meme sans le chantier (reprise exacte)',
    () async {
      await repository.applyPullPage(
        page(childrenFirst, hasMore: true, cursor: '240'),
        ownerUserId: 'u',
      );
      expect(await db.syncStateDao.get('cursor'), '240');
    },
  );

  test('ordre inverse (chantier d abord) : meme resultat', () async {
    await repository.applyPullPage(
      page(
        [
          syncChangeJson(
            'site',
            siteJson(id: _siteId, version: '300'),
            version: '300',
          ),
        ],
        hasMore: true,
        cursor: '300',
      ),
      ownerUserId: 'u',
    );
    await repository.applyPullPage(
      page(childrenFirst, hasMore: false, cursor: '400'),
      ownerUserId: 'u',
    );
    expect(await db.deliveriesDao.getById('l-1'), isNotNull);
    expect(await db.deliveryPhotosDao.getById('p-1'), isNotNull);
  });

  test(
    'chantier jamais recu (non visible) : lignes orphelines retirees a la fin du pull',
    () async {
      await repository.applyPullPage(
        page(childrenFirst, hasMore: true, cursor: '240'),
        ownerUserId: 'u',
      );
      // Derniere page sans le chantier : plus rien ne peut arriver, les orphelins disparaissent.
      await repository.applyPullPage(
        page(const [], hasMore: false, cursor: '250'),
        ownerUserId: 'u',
      );

      expect(await db.zonesDao.getById('z-1'), isNull);
      expect(await db.materialRequestsDao.getById('r-1'), isNull);
      expect(await db.deliveriesDao.getById('l-1'), isNull);
      expect(await db.deliveryPhotosDao.getById('p-1'), isNull);
      expect(await db.siteMembersDao.watchBySite(_siteId).first, isEmpty);
    },
  );

  test(
    'les saisies en attente ne sont jamais touchees par le nettoyage',
    () async {
      await db.sitesDao.upsertIfNewer(siteRow(id: _siteId));
      await db.deliveriesDao.insertPending(
        deliveryRow(
          id: 'liv-offline',
          clientId: 'liv-offline',
          siteId: _siteId,
          number: null,
          version: 0,
          isPending: true,
        ),
      );
      await repository.applyPullPage(
        page(const [], hasMore: false, cursor: '10'),
        ownerUserId: 'u',
      );
      expect(await db.deliveriesDao.getById('liv-offline'), isNotNull);
    },
  );

  test(
    'pierre tombale d un chantier : cascade explicite (demandes, livraisons, photos)',
    () async {
      await repository.applyPullPage(
        page(
          [
            syncChangeJson(
              'site',
              siteJson(id: _siteId, version: '300'),
              version: '300',
            ),
            ...childrenFirst,
          ],
          hasMore: false,
          cursor: '400',
        ),
        ownerUserId: 'u',
      );
      expect(await db.deliveriesDao.getById('l-1'), isNotNull);

      await repository.applyPullPage(
        page(
          const [],
          hasMore: false,
          cursor: '500',
          deleted: [
            {
              'entity': 'site',
              'id': _siteId,
              'siteId': _siteId,
              'version': '450',
            },
          ],
        ),
        ownerUserId: 'u',
      );

      expect(await db.sitesDao.getSite(_siteId), isNull);
      expect(await db.zonesDao.getById('z-1'), isNull);
      expect(await db.materialRequestsDao.getById('r-1'), isNull);
      expect(await db.deliveriesDao.getById('l-1'), isNull);
      expect(await db.deliveryPhotosDao.getById('p-1'), isNull);
    },
  );

  test('les cles etrangeres sont reactivees apres chaque page', () async {
    await repository.applyPullPage(
      page(childrenFirst, hasMore: false, cursor: '240'),
      ownerUserId: 'u',
    );
    final rows = await db.customSelect('PRAGMA foreign_keys').get();
    expect(rows.single.data.values.single, 1);
  });
}
