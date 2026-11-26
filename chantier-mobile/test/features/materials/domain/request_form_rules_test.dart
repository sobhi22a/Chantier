import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/request_listing.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/materials_harness.dart';

void main() {
  group('quantite et unite (CA-MAT-001.5, 001.6)', () {
    test('« 2,5 » avec une unite est valide', () {
      final result = RequestFormRules.checkQuantity('2,5', MeasureUnit.tonne);
      expect(result.error, isNull);
      expect(result.quantity!.value, Decimal.parse('2.5'));
    });

    test('sans unite : UNITE_OBLIGATOIRE, jamais une quantite sans unite', () {
      final result = RequestFormRules.checkQuantity('300', null);
      expect(result.quantity, isNull);
      expect(result.error, 'UNITE_OBLIGATOIRE');
    });

    test('zero, negatif, illisible : QUANTITE_INVALIDE', () {
      for (final text in ['0', '-2', 'abc', '2,', '1,2345']) {
        expect(
          RequestFormRules.checkQuantity(text, MeasureUnit.tonne).error,
          'QUANTITE_INVALIDE',
          reason: text,
        );
      }
    });

    test('decimale avec sac ou u : QUANTITE_ENTIERE_REQUISE', () {
      expect(
        RequestFormRules.checkQuantity('2,5', MeasureUnit.bag).error,
        'QUANTITE_ENTIERE_REQUISE',
      );
      expect(
        RequestFormRules.checkQuantity('2,5', MeasureUnit.piece).error,
        'QUANTITE_ENTIERE_REQUISE',
      );
    });

    test('saisie vide : pas d erreur affichee, pas de quantite', () {
      final result = RequestFormRules.checkQuantity('  ', null);
      expect(result.error, isNull);
      expect(result.quantity, isNull);
    });
  });

  group('autres controles', () {
    test('nom libre : 3 a 100 caracteres', () {
      expect(RequestFormRules.isFreeNameValid('ab'), isFalse);
      expect(RequestFormRules.isFreeNameValid(' abc '), isTrue);
      expect(RequestFormRules.isFreeNameValid('x' * 100), isTrue);
      expect(RequestFormRules.isFreeNameValid('x' * 101), isFalse);
    });

    test(
      'dates proposees : demain, +3 jours, lundi prochain, sans doublon',
      () {
        // Mercredi 25/11/2026.
        final today = DateTime.utc(2026, 11, 25);
        expect(RequestFormRules.neededByChoices(today, 3), [
          DateTime.utc(2026, 11, 26),
          DateTime.utc(2026, 11, 28),
          DateTime.utc(2026, 11, 30),
        ]);
        // Reglage a 1 jour : « demain » et « +1 j » ne forment qu'une pastille.
        expect(RequestFormRules.neededByChoices(today, 1), [
          DateTime.utc(2026, 11, 26),
          DateTime.utc(2026, 11, 30),
        ]);
        // Un lundi : « semaine prochaine » = lundi suivant, pas aujourd'hui.
        expect(
          RequestFormRules.neededByChoices(DateTime.utc(2026, 11, 23), 3).last,
          DateTime.utc(2026, 11, 30),
        );
      },
    );

    test('date passee : avertissement, aujourd hui n en est pas une', () {
      final today = DateTime.utc(2026, 11, 25);
      expect(
        RequestFormRules.isPast(DateTime.utc(2026, 11, 24), today),
        isTrue,
      );
      expect(RequestFormRules.isPast(today, today), isFalse);
    });

    test('unites : celles du produit, unite par defaut d abord', () {
      final cement = productRow(
        allowedUnits: const ['t', 'sac', 'kg'],
        defaultUnit: 'sac',
      );
      expect(RequestFormRules.unitsFor(cement), [
        MeasureUnit.bag,
        MeasureUnit.tonne,
        MeasureUnit.kilogram,
      ]);
      expect(RequestFormRules.unitsFor(null), MeasureUnit.values);
    });

    test('equivalence 300 sacs = 15 T avec la masse du sac du produit', () {
      final equivalent = RequestFormRules.equivalence(
        Quantity(Decimal.parse('300'), MeasureUnit.bag),
        productRow(),
      );
      expect(equivalent, Quantity(Decimal.parse('15'), MeasureUnit.tonne));
      expect(
        RequestFormRules.equivalence(
          Quantity(Decimal.parse('24'), MeasureUnit.cubicMeter),
          productRow(),
        ),
        isNull,
      );
    });
  });

  group('droits sur une demande (la sienne seulement)', () {
    final own = requestRow(requestedById: 'user-equipe');
    final other = requestRow(requestedById: 'user-chef');

    test(
      'chef d equipe : corrige et annule la sienne tant qu elle est demandee',
      () {
        final user = chefEquipe();
        expect(user.canEditRequest(own), isTrue);
        expect(user.canCancelRequest(own), isTrue);
        expect(user.canEditRequest(other), isFalse);
        expect(user.canCancelRequest(other), isFalse);
        expect(user.canApproveRequest(own), isFalse);
      },
    );

    test('chef d equipe : plus de correction apres la validation', () {
      expect(
        chefEquipe().canEditRequest(
          requestRow(requestedById: 'user-equipe', status: 'Validated'),
        ),
        isFalse,
      );
    });

    test(
      'conducteur : valide, annule toutes, corrige date/urgence apres validation',
      () {
        final user = conducteur();
        final validated = requestRow(status: 'Validated', requestedById: 'x');
        expect(user.canApproveRequest(other), isTrue);
        expect(user.canApproveRequest(validated), isFalse);
        expect(user.canCancelRequest(validated), isTrue);
        expect(user.canEditRequest(validated), isTrue);
        expect(user.canEditLockedFields(validated), isFalse);
        expect(user.canEditLockedFields(other), isTrue);
      },
    );

    test(
      'une demande commandee ne s annule plus, archivee ne se modifie plus',
      () {
        final user = conducteur();
        expect(user.canCancelRequest(requestRow(status: 'Ordered')), isFalse);
        expect(
          user.canEditRequest(
            requestRow(archivedAt: DateTime.utc(2026, 11, 25)),
          ),
          isFalse,
        );
      },
    );
  });

  group('liste : vues, recherche, tri', () {
    RequestView view(MaterialRequestRow row, {bool provisional = false}) =>
        RequestView(row: row, stored: row, isStatusProvisional: provisional);

    final items = [
      view(
        requestRow(
          id: 'a',
          number: 'DEM-001',
          status: 'Requested',
          priority: 'Normal',
          neededBy: DateTime.utc(2026, 12, 5),
        ),
      ),
      view(
        requestRow(
          id: 'b',
          number: 'DEM-002',
          status: 'Requested',
          priority: 'Blocking',
          neededBy: DateTime.utc(2026, 12, 9),
        ),
      ),
      view(requestRow(id: 'c', number: 'DEM-003', status: 'Received')),
      view(
        requestRow(
          id: 'd',
          number: 'DEM-004',
          status: 'Cancelled',
          requestedById: 'user-equipe',
        ),
      ),
      view(
        requestRow(
          id: 'e',
          number: 'DEM-005',
          status: 'Rejected',
          archivedAt: DateTime.utc(2026, 11, 24),
        ),
      ),
      view(
        requestRow(
          id: 'f',
          number: 'DEM-006',
          status: 'Ordered',
          productName: 'Sable 0/3',
          productId: 'prod-sable',
        ),
      ),
    ];

    List<String> ids(RequestListView v, {String? mine, String query = ''}) => [
      for (final item in filterRequests(
        items,
        view: v,
        languageCode: 'fr',
        mineUserId: mine,
        query: query,
      ))
        item.id,
    ];

    test('A suivre : bloquante d abord, puis par date de besoin', () {
      expect(ids(RequestListView.toFollow), ['b', 'f', 'a']);
    });

    test('Terminees, Refusees et annulees, Archivees', () {
      expect(ids(RequestListView.received), ['c']);
      expect(ids(RequestListView.closed), ['d']);
      expect(ids(RequestListView.archived), ['e']);
    });

    test('Mes demandes', () {
      expect(ids(RequestListView.closed, mine: 'user-equipe'), ['d']);
      expect(ids(RequestListView.toFollow, mine: 'user-equipe'), isEmpty);
    });

    test('recherche : numero, produit, sans accents ni casse', () {
      expect(ids(RequestListView.toFollow, query: 'dem-006'), ['f']);
      expect(ids(RequestListView.toFollow, query: 'SABLE'), ['f']);
      expect(ids(RequestListView.toFollow, query: 'introuvable'), isEmpty);
    });

    test(
      'une demande annulee hors ligne quitte « A suivre » tout de suite',
      () {
        final row = requestRow(id: 'g', status: 'Requested');
        final cancelled = RequestView(
          row: row.copyWith(status: 'Cancelled'),
          stored: row,
          isStatusProvisional: true,
        );
        expect(
          filterRequests(
            [cancelled],
            view: RequestListView.toFollow,
            languageCode: 'fr',
          ),
          isEmpty,
        );
        expect(
          filterRequests(
            [cancelled],
            view: RequestListView.closed,
            languageCode: 'fr',
          ),
          hasLength(1),
        );
      },
    );

    test(
      '« A valider » suit le statut stocke : la decision en attente reste visible',
      () {
        final row = requestRow(id: 'h', status: 'Requested');
        final approved = RequestView(
          row: row.copyWith(status: 'Validated'),
          stored: row,
          isStatusProvisional: true,
        );
        expect(
          filterRequests(
            [approved],
            view: RequestListView.toApprove,
            languageCode: 'fr',
          ),
          hasLength(1),
        );
      },
    );

    test('doublon possible : meme produit, meme zone, demande ouverte', () {
      final rows = [
        requestRow(id: 'x', productId: 'prod-ciment', zoneId: 'zone-1'),
        requestRow(
          id: 'y',
          productId: 'prod-ciment',
          zoneId: 'zone-2',
          status: 'Received',
        ),
      ];
      expect(
        findPossibleDuplicate(
          rows,
          productId: 'prod-ciment',
          zoneId: 'zone-1',
        )?.id,
        'x',
      );
      expect(
        findPossibleDuplicate(rows, productId: 'prod-ciment', zoneId: 'zone-2'),
        isNull,
        reason: 'une demande receptionnee n est pas ouverte',
      );
      expect(
        findPossibleDuplicate(rows, productId: null, zoneId: 'zone-1'),
        isNull,
      );
    });

    test('historique : evenements tries, illisibles ignores', () {
      final events = parseHistory(
        '[{"type":"Approved","occurredAt":"2026-11-25T09:00:00Z","fromStatus":"Requested","toStatus":"Validated"},'
        '{"type":"Created","occurredAt":"2026-11-25T07:00:00Z"},'
        '{"occurredAt":"2026-11-25T08:00:00Z"},'
        '{"type":"Edited","occurredAt":"2026-11-25T08:00:00Z","changes":[{"field":"quantity","old":"300 sac","new":"400 sac"}]}]',
      );
      expect(events.map((e) => e.type), ['Created', 'Edited', 'Approved']);
      expect(events[1].changes.single.newValue, '400 sac');
      expect(parseHistory('pas du json'), isEmpty);
      expect(parseHistory(null), isEmpty);
    });
  });

  group('charges utiles et surcouche', () {
    final draft = RequestDraft(
      productId: 'p',
      quantity: Quantity(Decimal.parse('2.5'), MeasureUnit.tonne),
      neededBy: DateTime.utc(2026, 12, 1),
      zoneId: 'z-local',
      zoneIsPending: true,
      priority: RequestPriority.urgent,
      note: 'Dalle',
    );

    test(
      'creation : unite, date complete, zone par zoneClientId, jamais de statut',
      () {
        final payload = RequestPayloads.create(
          draft,
          DateTime.utc(2026, 11, 25, 7),
        );
        expect(payload['quantity'], {'value': 2.5, 'unit': 't'});
        expect(payload['neededBy'], '2026-12-01');
        expect(payload['zoneClientId'], 'z-local');
        expect(payload.containsKey('zoneId'), isFalse);
        expect(payload.keys, isNot(containsAll(['status', 'number'])));
      },
    );

    test(
      'differences : seuls les champs modifies partent, avec leur valeur de depart',
      () {
        final shown = requestRow(quantity: '300', unit: 'sac', zoneId: 'z1');
        final edit = RequestEdit.diff(
          shown,
          RequestDraft(
            productId: 'prod-ciment',
            quantity: Quantity(Decimal.parse('400'), MeasureUnit.bag),
            neededBy: shown.neededBy,
            zoneId: 'z1',
          ),
        );
        expect(edit.changes, {
          'quantity': {'value': 400, 'unit': 'sac'},
        });
        expect(edit.base, {
          'quantity': {'value': 300, 'unit': 'sac'},
        });
      },
    );

    test(
      'une operation refusee ou en conflit n est jamais appliquee a l affichage',
      () {
        final row = requestRow(status: 'Requested');
        final op = OutboxRow(
          id: 1,
          clientId: 't1',
          ownerUserId: 'u',
          entity: 'request',
          operation: 'transition',
          siteId: row.siteId,
          label: 'x',
          payloadJson: '{"requestId":"${row.id}","action":"approve"}',
          status: OutboxStatus.conflict,
          attempts: 0,
          createdAt: DateTime.utc(2026, 11, 25),
        );
        final shown = overlayRequest(row, [op]);
        expect(shown.row.status, 'Requested');
        expect(shown.needsCheck, isTrue);
      },
    );

    test('valider une demande deja validee n invente rien', () {
      final row = requestRow(status: 'Validated');
      final op = OutboxRow(
        id: 1,
        clientId: 't1',
        ownerUserId: 'u',
        entity: 'request',
        operation: 'transition',
        siteId: row.siteId,
        label: 'x',
        payloadJson: '{"requestId":"${row.id}","action":"approve"}',
        status: OutboxStatus.pending,
        attempts: 0,
        createdAt: DateTime.utc(2026, 11, 25),
      );
      expect(overlayRequest(row, [op]).isStatusProvisional, isFalse);
    });

    test('refaire sa modification : etat du serveur + mes changements', () {
      final server = requestRow(quantity: '300', unit: 'sac');
      final rebuilt = draftFromRow(
        server,
        changes: {
          'quantity': {'value': 400, 'unit': 'sac'},
          'priority': 'Urgent',
        },
      )!;
      expect(rebuilt.quantity, Quantity(Decimal.parse('400'), MeasureUnit.bag));
      expect(rebuilt.priority, RequestPriority.urgent);
      expect(rebuilt.productId, 'prod-ciment');
      expect(rebuilt.neededBy, server.neededBy);
    });

    test('creation refusee : la saisie est reconstituee', () {
      final rebuilt = draftFromCreatePayload({
        'productId': 'p',
        'quantity': {'value': 12, 'unit': 'sac'},
        'neededBy': '2026-12-02',
        'zoneClientId': 'z-local',
        'priority': 'Blocking',
      })!;
      expect(rebuilt.zoneIsPending, isTrue);
      expect(rebuilt.zoneId, 'z-local');
      expect(rebuilt.neededBy, DateTime.utc(2026, 12, 2));
      expect(draftFromCreatePayload({'quantity': {}}), isNull);
    });
  });
}
