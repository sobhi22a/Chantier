import 'package:chantier_mobile/database/app_database.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await db.sitesDao.upsertIfNewer(siteRow());
    await db.sitesDao.upsertIfNewer(
      siteRow(
        id: 'site-ol40',
        code: 'CH-LOG-OL40',
        name: 'Logements OL40',
        version: 101,
      ),
    );
  });
  tearDown(() => db.close());

  group('upsertIfNewer', () {
    test('idempotent par version', () async {
      expect(await db.zonesDao.upsertIfNewer(zoneRow(version: 200)), isTrue);
      expect(await db.zonesDao.upsertIfNewer(zoneRow(version: 200)), isFalse);
      expect(await db.zonesDao.upsertIfNewer(zoneRow(version: 199)), isFalse);
      expect(
        await db.zonesDao.upsertIfNewer(
          zoneRow(version: 201, block: 'Bloc 02'),
        ),
        isTrue,
      );

      expect((await db.zonesDao.getById('zone-1'))!.block, 'Bloc 02');
      expect(await db.zonesDao.countBySite('site-uv18'), 1);
    });

    test(
      'zone restauree : un null recu ecrase l archivage et la cote',
      () async {
        await db.zonesDao.upsertIfNewer(
          zoneRow(version: 200, archivedAt: DateTime.utc(2026, 11, 20)),
        );

        await db.zonesDao.upsertIfNewer(zoneRow(version: 201, elevation: null));

        final row = (await db.zonesDao.getById('zone-1'))!;
        expect(row.archivedAt, isNull);
        expect(row.elevation, isNull);
      },
    );

    test('cote -1.90, 0.00 et 3.40 conservees sans perte', () async {
      await db.zonesDao.upsertIfNewer(zoneRow(id: 'a', elevation: '-1.90'));
      await db.zonesDao.upsertIfNewer(zoneRow(id: 'b', elevation: '0.00'));
      await db.zonesDao.upsertIfNewer(zoneRow(id: 'c', elevation: '3.40'));

      expect(
        (await db.zonesDao.getById('a'))!.elevation,
        Decimal.parse('-1.90'),
      );
      expect((await db.zonesDao.getById('b'))!.elevation, Decimal.zero);
      expect(
        (await db.zonesDao.getById('c'))!.elevation,
        Decimal.parse('3.40'),
      );
    });

    test('zone sans cote : null', () async {
      await db.zonesDao.upsertIfNewer(
        zoneRow(elevation: null, roomType: null, roomNumber: null),
      );

      expect((await db.zonesDao.getById('zone-1'))!.elevation, isNull);
    });
  });

  group('tri : du plus bas au plus haut (CT-17)', () {
    test('tri numerique sur la cote, pas alphabetique', () async {
      for (final (id, cote) in [
        ('z-3-40', '3.40'),
        ('z-m1-90', '-1.90'),
        ('z-10', '10.00'),
        ('z-zero', '0.00'),
        ('z-m10-5', '-10.50'),
      ]) {
        await db.zonesDao.upsertIfNewer(
          zoneRow(id: id, elevation: cote, roomType: null, roomNumber: null),
        );
      }

      final rows = await db.zonesDao.watchBySite('site-uv18').first;

      expect(rows.map((r) => r.elevation.toString()), [
        '-10.5',
        '-1.9',
        '0',
        '3.4',
        '10',
      ]);
    });

    test('par bloc, puis cote, puis local et numero', () async {
      await db.zonesDao.upsertIfNewer(
        zoneRow(id: 'b2', block: 'Bloc 02', elevation: '0.00', roomNumber: 1),
      );
      await db.zonesDao.upsertIfNewer(
        zoneRow(
          id: 'b1-c2',
          block: 'Bloc 01',
          elevation: '3.40',
          roomNumber: 2,
        ),
      );
      await db.zonesDao.upsertIfNewer(
        zoneRow(
          id: 'b1-c1',
          block: 'Bloc 01',
          elevation: '3.40',
          roomNumber: 1,
        ),
      );
      await db.zonesDao.upsertIfNewer(
        zoneRow(
          id: 'b1-bas',
          block: 'Bloc 01',
          elevation: '0.00',
          roomNumber: 1,
        ),
      );

      final ids = (await db.zonesDao.watchBySite('site-uv18').first).map(
        (r) => r.id,
      );

      expect(ids, ['b1-bas', 'b1-c1', 'b1-c2', 'b2']);
    });

    test('seulement les zones du chantier demande', () async {
      await db.zonesDao.upsertIfNewer(zoneRow(id: 'uv18'));
      await db.zonesDao.upsertIfNewer(zoneRow(id: 'ol40', siteId: 'site-ol40'));

      final rows = await db.zonesDao.watchBySite('site-ol40').first;

      expect(rows.map((r) => r.id), ['ol40']);
    });

    test('zones archivees masquees par defaut', () async {
      await db.zonesDao.upsertIfNewer(zoneRow(id: 'actif'));
      await db.zonesDao.upsertIfNewer(
        zoneRow(
          id: 'archive',
          archivedAt: DateTime.utc(2026, 11, 20),
          roomNumber: 9,
        ),
      );

      expect(
        (await db.zonesDao.watchBySite('site-uv18').first).map((r) => r.id),
        ['actif'],
      );
      expect(
        (await db.zonesDao
                .watchBySite('site-uv18', includeArchived: true)
                .first)
            .length,
        2,
      );
    });

    test(
      'flux reactif : une zone creee hors ligne apparait aussitot',
      () async {
        final counts = <int>[];
        final subscription = db.zonesDao
            .watchBySite('site-uv18')
            .listen((rows) => counts.add(rows.length));
        await Future<void>.delayed(Duration.zero);

        await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-1'));
        await Future<void>.delayed(Duration.zero);

        expect(counts, [0, 1]);
        await subscription.cancel();
      },
    );
  });

  group('zone creee hors ligne', () {
    test('insertPending : id = clientId, version 0, en attente', () async {
      await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-7'));

      final row = (await db.zonesDao.getById('c-7'))!;

      expect(row.isPending, isTrue);
      expect(row.version, 0);
      expect(row.clientId, 'c-7');
    });

    test(
      'la confirmation du serveur REMPLACE la zone locale (meme clientId), sans doublon',
      () async {
        await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-7'));

        final applied = await db.zonesDao.upsertIfNewer(
          zoneRow(
            id: 'serveur-42',
            clientId: 'c-7',
            roomNumber: 7,
            version: 500,
          ),
        );

        expect(applied, isTrue);
        expect(await db.zonesDao.countBySite('site-uv18'), 1);
        expect(await db.zonesDao.getById('c-7'), isNull);
        final confirmed = (await db.zonesDao.getById('serveur-42'))!;
        expect(confirmed.isPending, isFalse);
        expect(confirmed.version, 500);
      },
    );

    test(
      'la meme confirmation rejouee (pull puis push) : toujours une seule zone',
      () async {
        await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-7'));
        final confirmation = zoneRow(
          id: 'serveur-42',
          clientId: 'c-7',
          version: 500,
        );

        await db.zonesDao.upsertIfNewer(confirmation);
        final replay = await db.zonesDao.upsertIfNewer(confirmation);

        expect(replay, isFalse);
        expect(await db.zonesDao.countBySite('site-uv18'), 1);
      },
    );

    test('un clientId ne designe qu une zone par chantier', () async {
      await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-7'));

      await expectLater(
        db.into(db.zones).insert(zoneRow(id: 'autre', clientId: 'c-7')),
        throwsA(anything),
      );
    });

    test('meme clientId sur un autre chantier : autorise', () async {
      await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-7'));

      await db.zonesDao.upsertIfNewer(
        zoneRow(
          id: 'autre',
          siteId: 'site-ol40',
          clientId: 'c-7',
          version: 600,
        ),
      );

      expect(await db.zonesDao.countBySite('site-ol40'), 1);
      expect(await db.zonesDao.countBySite('site-uv18'), 1);
    });

    test('findByClientId', () async {
      await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-7'));

      expect((await db.zonesDao.findByClientId('site-uv18', 'c-7'))!.id, 'c-7');
      expect(await db.zonesDao.findByClientId('site-ol40', 'c-7'), isNull);
      expect(await db.zonesDao.findByClientId('site-uv18', 'inconnu'), isNull);
    });

    test('abandon : la zone locale en attente peut etre supprimee', () async {
      await db.zonesDao.insertPending(pendingZoneRow(clientId: 'c-7'));

      expect(await db.zonesDao.deleteZone('c-7'), 1);
      expect(await db.zonesDao.countBySite('site-uv18'), 0);
    });
  });
}
