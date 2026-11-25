import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/features/sites/data/sync_decoder.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/api_json.dart';

SyncChange _change(String entity, Map<String, Object?> data, String version) =>
    SyncChange.fromJson(syncChangeJson(entity, data, version: version));

void main() {
  group('desérialisation des exemples du contrat (docs/api/socle.md)', () {
    test('SiteResponse', () {
      final site = SiteResponse.fromJson(siteJson(contractAmount: 185000000));

      expect(site.code, 'CH-ECO-UV18');
      expect(site.type, SiteType.school);
      expect(site.contractAmount, 185000000);
      expect(site.delayDays, 540);
      expect(site.version, '48213');
      expect(site.createdAt, DateTime.utc(2026, 11, 24, 8));
    });

    test('SiteResponse sans montant (permission absente)', () {
      final site = SiteResponse.fromJson(siteJson());

      expect(site.contractAmount, isNull);
    });

    test('ZoneResponse', () {
      final zone = ZoneResponse.fromJson(zoneJson());

      expect(zone.block, 'Bloc 01');
      expect(zone.elevation, 3.4);
      expect(zone.roomType, RoomType.classroom);
      expect(zone.roomNumber, 2);
    });

    test(
      'ZoneResponse : type de local inconnu = valeur de repli, pas de plantage',
      () {
        final zone = ZoneResponse.fromJson(zoneJson(roomType: 'Gymnasium'));

        expect(zone.roomType, RoomType.$unknown);
      },
    );

    test('réponse de synchronisation', () {
      final page = SyncPullResponse.fromJson(
        syncPullJson(
          changes: [
            syncChangeJson('site', siteJson(), version: '48213'),
            syncChangeJson('zone', zoneJson(), version: '48230'),
          ],
          deleted: [
            {
              'entity': 'member',
              'id': '0192a000-0000-7000-8000-0000000000c1',
              'siteId': '0192a000-0000-7000-8000-0000000000a1',
              'version': '48301',
            },
          ],
        ),
      );

      expect(page.changes, hasLength(2));
      expect(page.deleted.single.entity, 'member');
      expect(page.cursor, '48301');
      expect(page.hasMore, isFalse);
    });

    test('résultat de push : applied, duplicate merged, rejected', () {
      final response = SyncPushResponse.fromJson({
        'results': [
          {'clientId': 'a', 'status': 'applied', 'resource': zoneJson()},
          {
            'clientId': 'b',
            'status': 'duplicate',
            'merged': true,
            'resource': zoneJson(),
          },
          {
            'clientId': 'c',
            'status': 'rejected',
            'code': 'VALIDATION',
            'errors': {
              'block': ['Le bloc est obligatoire.'],
            },
          },
        ],
      });

      expect(response.results.map((r) => r.status), [
        'applied',
        'duplicate',
        'rejected',
      ]);
      expect(response.results[1].merged, isTrue);
      expect(response.results[2].errors, {
        'block': ['Le bloc est obligatoire.'],
      });
    });
  });

  group('decodeChange : `data` decode selon `entity`', () {
    test(
      'site -> ligne locale (montant en décimal texte, dates métier UTC)',
      () {
        final decoded = decodeChange(
          _change('site', siteJson(contractAmount: 185000000), '48213'),
        );

        expect(decoded, isA<SiteChange>());
        final row = (decoded as SiteChange).row;
        expect(row.version, 48213);
        expect(row.type, 'School');
        expect(row.contractAmount, Decimal.parse('185000000.00'));
        expect(row.latitude, Decimal.parse('36.575'));
        expect(row.odsDate, DateTime.utc(2026, 3, 2));
        expect(row.contractualEndDate, DateTime.utc(2027, 8, 24));
      },
    );

    test('site sans montant : colonne vide (CA-012.7)', () {
      final row =
          (decodeChange(_change('site', siteJson(), '1')) as SiteChange).row;

      expect(row.contractAmount, isNull);
    });

    test('site sans fin contractuelle : null (« À définir »)', () {
      final row =
          (decodeChange(
                    _change(
                      'site',
                      siteJson(odsDate: null, contractualEndDate: null),
                      '1',
                    ),
                  )
                  as SiteChange)
              .row;

      expect(row.contractualEndDate, isNull);
      expect(row.odsDate, isNull);
    });

    test('zone : cote -1.90, 0.00 et 3.40 sans perte, version numérique', () {
      for (final (value, text) in <(num, String)>[
        (-1.9, '-1.90'),
        (0, '0.00'),
        (3.4, '3.40'),
      ]) {
        final row =
            (decodeChange(_change('zone', zoneJson(elevation: value), '48230'))
                    as ZoneChange)
                .row;

        expect(row.elevation, Decimal.parse(text), reason: text);
        expect(row.version, 48230);
        expect(row.isPending, isFalse);
      }
    });

    test('zone : cote entière JSON (3) et absente', () {
      final entiere =
          (decodeChange(_change('zone', zoneJson(elevation: 3), '1'))
                  as ZoneChange)
              .row;
      final absente =
          (decodeChange(_change('zone', zoneJson(elevation: null), '1'))
                  as ZoneChange)
              .row;

      expect(entiere.elevation, Decimal.parse('3.00'));
      expect(absente.elevation, isNull);
    });

    test('zone : type de local inconnu conservé tel que reçu', () {
      final row =
          (decodeChange(_change('zone', zoneJson(roomType: 'Gymnasium'), '1'))
                  as ZoneChange)
              .row;

      expect(row.roomType, 'Gymnasium');
    });

    test('member', () {
      final decoded = decodeChange(_change('member', memberJson(), '48300'));

      expect(decoded, isA<MemberChange>());
      expect((decoded as MemberChange).row.fullName, 'Mourad B.');
      expect(decoded.row.version, 48300);
    });

    test('entité inconnue (wilaya...) : ignorée, sans erreur', () {
      final decoded = decodeChange(
        _change('wilaya', {
          'id': '0192a000-0000-7000-8000-0000000000d1',
          'siteId': '0192a000-0000-7000-8000-0000000000a1',
        }, '7'),
      );

      expect(decoded, isA<UnknownEntityChange>());
      expect((decoded as UnknownEntityChange).entity, 'wilaya');
    });

    test(
      'version non numérique : la ligne est refusée (pas de perte silencieuse)',
      () {
        expect(
          () => decodeChange(_change('zone', zoneJson(), 'abc')),
          throwsA(isA<SyncDecodeException>()),
        );
      },
    );

    test('champ requis absent : SyncDecodeException', () {
      final broken = zoneJson()..remove('block');

      expect(
        () => decodeChange(_change('zone', broken, '5')),
        throwsA(isA<SyncDecodeException>()),
      );
    });

    test('data qui n\'est pas un objet : SyncDecodeException', () {
      const change = SyncChange(
        entity: 'site',
        id: 'x',
        siteId: 'x',
        version: '1',
        data: 'texte',
      );

      expect(() => decodeChange(change), throwsA(isA<SyncDecodeException>()));
    });
  });

  test('decodeZoneResource : ressource d\'un résultat de push', () {
    final row = decodeZoneResource(zoneJson(clientId: 'c-7', version: '500'));

    expect(row.clientId, 'c-7');
    expect(row.version, 500);
  });
}
