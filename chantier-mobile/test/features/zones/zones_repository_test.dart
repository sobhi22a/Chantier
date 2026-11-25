import 'dart:convert';

import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/database/tables/user_prefs.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_database.dart';

NewZone newZone({
  String clientId = 'c-1',
  String block = 'Bloc 01',
  String? elevation = '3.40',
  String? roomType = 'Classroom',
  int? roomNumber = 7,
  String? roomLabel,
  String userId = 'user-a',
  String siteId = 'site-uv18',
}) => NewZone(
  clientId: clientId,
  siteId: siteId,
  userId: userId,
  block: block,
  elevation: elevation == null ? null : Decimal.parse(elevation),
  roomType: roomType,
  roomNumber: roomNumber,
  roomLabel: roomLabel,
  label: 'Bloc 01 · +3,40 m · Classe 07',
);

void main() {
  late AppDatabase db;
  late ZonesRepository repository;
  late OutboxRepository outbox;
  late DateTime clock;
  late int localWrites;

  setUp(() async {
    db = createTestDatabase();
    clock = DateTime.utc(2026, 11, 24, 6, 58);
    localWrites = 0;
    outbox = OutboxRepository(db);
    repository = ZonesRepository(
      database: db,
      outbox: outbox,
      now: () => clock,
      onLocalWrite: () => localWrites++,
    );
    await db.sitesDao.upsertIfNewer(siteRow());
  });
  tearDown(() => db.close());

  group('Creation hors ligne (CT-21, CA-011.5)', () {
    test(
      'zone locale « en attente » + operation d\'envoi, dans une seule transaction',
      () async {
        final result = await repository.save(newZone());

        expect(result, isA<ZoneSaved>());
        final zone = (await db.zonesDao.getById('c-1'))!;
        expect(zone.isPending, isTrue);
        expect(zone.version, 0);
        expect(zone.clientId, 'c-1');
        expect(zone.elevation, Decimal.parse('3.40'));
        final op = (await db.outboxDao.getByClientId('c-1'))!;
        expect(op.status, OutboxStatus.pending);
        expect(op.ownerUserId, 'user-a');
        expect(op.entity, 'zone');
        expect(op.operation, 'create');
        expect(op.siteId, 'site-uv18');
        expect(op.label, 'Bloc 01 · +3,40 m · Classe 07');
      },
    );

    test(
      'la zone sert tout de suite dans les autres ecrans (flux local)',
      () async {
        await repository.save(newZone());

        final zones = await repository.watchZones('site-uv18').first;

        expect(zones.map((z) => z.id), ['c-1']);
      },
    );

    test(
      'payload = champs de la ressource, cote en nombre a deux decimales, saisi le',
      () async {
        await repository.save(newZone());

        final op = (await db.outboxDao.getByClientId('c-1'))!;
        final payload = jsonDecode(op.payloadJson) as Map<String, dynamic>;
        expect(payload, {
          'clientCreatedAt': '2026-11-24T06:58:00.000Z',
          'block': 'Bloc 01',
          'elevation': 3.4,
          'roomType': 'Classroom',
          'roomNumber': 7,
        });
        expect(op.createdAt.toUtc(), DateTime.utc(2026, 11, 24, 6, 58));
      },
    );

    test('zone sans cote ni local : seulement le bloc', () async {
      await repository.save(
        newZone(elevation: null, roomType: null, roomNumber: null),
      );

      final payload =
          jsonDecode((await db.outboxDao.getByClientId('c-1'))!.payloadJson)
              as Map<String, dynamic>;
      expect(payload.keys, unorderedEquals(['clientCreatedAt', 'block']));
    });

    test('type « Autre » : libelle libre transmis', () async {
      await repository.save(
        newZone(roomType: 'Other', roomNumber: null, roomLabel: 'Archives'),
      );

      final payload =
          jsonDecode((await db.outboxDao.getByClientId('c-1'))!.payloadJson)
              as Map<String, dynamic>;
      expect(payload['roomLabel'], 'Archives');
      expect(payload.containsKey('roomNumber'), isFalse);
    });

    test('cote negative et nulle conservees (−1,90 / 0,00)', () async {
      await repository.save(
        newZone(clientId: 'a', elevation: '-1.90', roomNumber: 1),
      );
      await repository.save(
        newZone(clientId: 'b', elevation: '0.00', roomNumber: 2),
      );

      final a =
          jsonDecode((await db.outboxDao.getByClientId('a'))!.payloadJson)
              as Map<String, dynamic>;
      final b =
          jsonDecode((await db.outboxDao.getByClientId('b'))!.payloadJson)
              as Map<String, dynamic>;
      expect(a['elevation'], -1.9);
      expect(b['elevation'], 0.0);
    });

    test('declenche l\'envoi differe (2 s) apres l\'enregistrement', () async {
      await repository.save(newZone());

      expect(localWrites, 1);
    });

    test(
      'derniere zone utilisee memorisee pour l\'utilisateur (CA-011.1)',
      () async {
        await repository.save(newZone());

        expect((await repository.lastUsedZone('user-a'))?.id, 'c-1');
        expect(
          await repository.lastUsedZone('user-b'),
          isNull,
          reason: 'propre a chaque utilisateur',
        );
      },
    );

    test('la derniere zone disparue : aucune preselection', () async {
      await db.userPrefsDao.set(
        'user-a',
        UserPrefKeys.lastZoneId,
        'zone-disparue',
      );

      expect(await repository.lastUsedZone('user-a'), isNull);
    });
  });

  group('Anti-doublon (CA-011.4, CA-011.7)', () {
    test(
      'double appui : meme clientId, une seule zone et une seule operation',
      () async {
        final results = await Future.wait([
          repository.save(newZone()),
          repository.save(newZone()),
        ]);

        expect(results.whereType<ZoneSaved>(), hasLength(1));
        expect(results.whereType<ZoneAlreadySaved>(), hasLength(1));
        expect(await db.zonesDao.countBySite('site-uv18'), 1);
        expect(await outbox.countFor('user-a'), 1);
        expect(localWrites, 1);
      },
    );

    test(
      'meme enregistrement renvoye plus tard : toujours une seule fois',
      () async {
        await repository.save(newZone());

        final again = await repository.save(newZone());

        expect(again, isA<ZoneAlreadySaved>());
        expect(await outbox.countFor('user-a'), 1);
      },
    );

    test(
      'meme bloc, meme cote, meme local : « existe deja », on retourne la zone existante',
      () async {
        await db.zonesDao.upsertIfNewer(
          zoneRow(id: 'srv-1', elevation: '3.40', roomNumber: 7),
        );

        final result = await repository.save(newZone(clientId: 'c-2'));

        expect(result, isA<ZoneAlreadyExists>());
        expect((result as ZoneAlreadyExists).existing.id, 'srv-1');
        expect(
          await db.outboxDao.getByClientId('c-2'),
          isNull,
          reason: 'rien n\'est cree',
        );
        expect(localWrites, 0);
      },
    );

    test('doublon avec une zone en attente d\'un autre formulaire', () async {
      await repository.save(newZone(clientId: 'c-1'));

      final result = await repository.save(newZone(clientId: 'c-2'));

      expect(result, isA<ZoneAlreadyExists>());
      expect(await outbox.countFor('user-a'), 1);
    });

    test(
      'doublon aussi avec une zone archivee (le serveur la refuserait)',
      () async {
        await db.zonesDao.upsertIfNewer(
          zoneRow(
            id: 'arch',
            roomNumber: 7,
            archivedAt: DateTime.utc(2026, 11, 1),
          ),
        );

        expect(
          await repository.save(newZone(clientId: 'c-2')),
          isA<ZoneAlreadyExists>(),
        );
      },
    );

    test('une cote ou un numero different : zone distincte', () async {
      await db.zonesDao.upsertIfNewer(
        zoneRow(id: 'srv-1', elevation: '3.40', roomNumber: 7),
      );

      expect(
        await repository.save(newZone(clientId: 'a', elevation: '3.50')),
        isA<ZoneSaved>(),
      );
      expect(
        await repository.save(newZone(clientId: 'b', roomNumber: 8)),
        isA<ZoneSaved>(),
      );
      expect(
        await repository.save(newZone(clientId: 'c', block: 'Bloc 02')),
        isA<ZoneSaved>(),
      );
    });

    test('le meme local dans un autre chantier : autorise', () async {
      await db.sitesDao.upsertIfNewer(
        siteRow(id: 'site-2', code: 'CH-2', version: 101),
      );
      await db.zonesDao.upsertIfNewer(
        zoneRow(id: 'srv-1', siteId: 'site-2', roomNumber: 7),
      );

      expect(await repository.save(newZone()), isA<ZoneSaved>());
    });
  });

  group('« Corriger » une saisie refusee', () {
    test(
      'remplace la saisie refusee et sa zone locale, dans la meme transaction',
      () async {
        await repository.save(newZone(clientId: 'old', roomNumber: 7));
        final old = (await db.outboxDao.getByClientId('old'))!;
        await db.outboxDao.markFailed(
          old.id,
          status: OutboxStatus.rejected,
          errorCode: 'VALIDATION',
        );
        final rejected = (await db.outboxDao.getByClientId('old'))!;

        final result = await repository.save(
          newZone(clientId: 'new', roomNumber: 8),
          replacing: rejected,
        );

        expect(result, isA<ZoneSaved>());
        expect(await db.outboxDao.getByClientId('old'), isNull);
        expect(await db.zonesDao.getById('old'), isNull);
        expect(
          (await db.outboxDao.getByClientId('new'))!.status,
          OutboxStatus.pending,
        );
        expect(await db.zonesDao.getById('new'), isNotNull);
      },
    );

    test(
      'correction identique a la saisie refusee : pas de faux « existe deja »',
      () async {
        await repository.save(newZone(clientId: 'old'));
        final rejected = (await db.outboxDao.getByClientId('old'))!;

        final result = await repository.save(
          newZone(clientId: 'new'),
          replacing: rejected,
        );

        expect(result, isA<ZoneSaved>());
        expect(await db.zonesDao.countBySite('site-uv18'), 1);
      },
    );
  });
}
