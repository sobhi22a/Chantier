import 'dart:convert';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_listing.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/material_enums.dart';
import 'package:chantier_mobile/features/materials/domain/material_row_extensions.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/to_receive_listing.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';

Quantity q(String value, MeasureUnit unit) =>
    Quantity(Decimal.parse(value), unit);

OutboxRow fakeOutbox(
  String clientId,
  String operation,
  Map<String, Object?> payload, {
  OutboxStatus status = OutboxStatus.pending,
}) => OutboxRow(
  id: clientId.hashCode,
  clientId: clientId,
  ownerUserId: 'user-a',
  entity: 'delivery',
  operation: operation,
  siteId: 'site-uv18',
  label: 'LIV',
  payloadJson: jsonEncode(payload),
  status: status,
  attempts: 0,
  createdAt: DateTime.utc(2026, 11, 25),
);

extension on DeliveryRow {
  DeliveryRow copyWithNote(String? note) =>
      copyWith(deliveryNoteNumber: Value(note));
  DeliveryRow copyWithStatus(String status) => copyWith(status: status);
  DeliveryRow copyWithConformity(String value) => copyWith(conformity: value);
}

void main() {
  final bag = Decimal.parse('50');

  group('annonce en toutes lettres (CA-MAT-006.3, 008.1, 008.6, 008.7)', () {
    DeliveryAnnouncement? announce(
      String ordered,
      List<String> already,
      String receiving, {
      MeasureUnit receivingUnit = MeasureUnit.bag,
      Decimal? tolerance,
      bool settled = false,
    }) => DeliveryFormRules.announce(
      ordered: q(ordered, MeasureUnit.bag),
      alreadyReceived: [for (final value in already) q(value, MeasureUnit.bag)],
      receiving: q(receiving, receivingUnit),
      bagMassKg: bag,
      tolerancePercent: tolerance,
      isSettled: settled,
    );

    test('partielle : il restera 100 sacs', () {
      final a = announce('600', ['400'], '100')!;
      expect(a.outcome, DeliveryOutcome.partial);
      expect(a.amount, q('100', MeasureUnit.bag));
    });

    test('complete', () {
      expect(
        announce('600', ['400'], '200')!.outcome,
        DeliveryOutcome.complete,
      );
    });

    test('surplus : +20 sacs (+5,00 %) sur 400', () {
      final a = announce('400', const [], '420')!;
      expect(a.outcome, DeliveryOutcome.surplus);
      expect(a.amount, q('20', MeasureUnit.bag));
      expect(a.percent, Decimal.parse('5'));
    });

    test('en tonnes : 10 T = 200 sacs, il restera 400 sacs', () {
      final a = announce(
        '600',
        const [],
        '10',
        receivingUnit: MeasureUnit.tonne,
      )!;
      expect(a.outcome, DeliveryOutcome.partial);
      expect(a.amount, q('400', MeasureUnit.bag));
    });

    test('tolerance de 1 % : 19,85 T pour 20 T = complete (vecteur 008.7)', () {
      final a = DeliveryFormRules.announce(
        ordered: q('20', MeasureUnit.tonne),
        alreadyReceived: const [],
        receiving: q('19.85', MeasureUnit.tonne),
        tolerancePercent: Decimal.one,
      )!;
      expect(a.outcome, DeliveryOutcome.complete);
      final strict = DeliveryFormRules.announce(
        ordered: q('20', MeasureUnit.tonne),
        alreadyReceived: const [],
        receiving: q('19.85', MeasureUnit.tonne),
      )!;
      expect(strict.outcome, DeliveryOutcome.partial);
      expect(strict.amount, q('0.15', MeasureUnit.tonne));
    });

    test('unite non convertible (sable m3 / T) : aucune annonce inventee', () {
      expect(
        DeliveryFormRules.announce(
          ordered: q('24', MeasureUnit.cubicMeter),
          alreadyReceived: const [],
          receiving: q('10', MeasureUnit.tonne),
        ),
        isNull,
      );
    });
  });

  group('unites proposees et equivalence (CA-MAT-006.4)', () {
    final cement = productRow();
    final sand = productRow(
      id: 'prod-sable',
      allowedUnits: const ['m3', 't'],
      defaultUnit: 'm3',
      bagMassKg: null,
    );

    test('ciment commande en sacs : sac, kg, T', () {
      expect(DeliveryFormRules.unitsFor(MeasureUnit.bag, cement), [
        MeasureUnit.bag,
        MeasureUnit.tonne,
        MeasureUnit.kilogram,
      ]);
    });

    test('sable commande en m3 : jamais la tonne', () {
      expect(DeliveryFormRules.unitsFor(MeasureUnit.cubicMeter, sand), [
        MeasureUnit.cubicMeter,
      ]);
    });

    test(
      'equivalence 10 T = 200 sacs, rien pour la meme unite ou le sable',
      () {
        expect(
          DeliveryFormRules.equivalenceInOrderUnit(
            q('10', MeasureUnit.tonne),
            MeasureUnit.bag,
            cement,
          ),
          q('200', MeasureUnit.bag),
        );
        expect(
          DeliveryFormRules.equivalenceInOrderUnit(
            q('10', MeasureUnit.bag),
            MeasureUnit.bag,
            cement,
          ),
          isNull,
        );
        expect(
          DeliveryFormRules.equivalenceInOrderUnit(
            q('10', MeasureUnit.tonne),
            MeasureUnit.cubicMeter,
            sand,
          ),
          isNull,
        );
      },
    );
  });

  group('n° de bon (CA-MAT-007.6)', () {
    test('majuscules, sans espace de bord, 30 caracteres au plus', () {
      expect(DeliveryFormRules.normalizeNoteNumber('  bl-4471 '), 'BL-4471');
      expect(DeliveryFormRules.normalizeNoteNumber('   '), isNull);
      expect(
        DeliveryFormRules.normalizeNoteNumber('a' * 40),
        hasLength(DeliveryFormRules.noteNumberMaxLength),
      );
      expect(normalizeNoteNumber(null), isNull);
    });

    test(
      'doublon : meme bon, meme fournisseur, meme produit, hors annulee',
      () {
        final rows = [
          deliveryRow(id: 'a', number: 'LIV-001'),
          deliveryRow(id: 'b', number: 'LIV-002', status: 'Cancelled'),
        ];
        expect(
          DeliveryFormRules.findDuplicateNote(
            rows,
            noteNumber: 'BL-4471',
            supplierKey: 'sup-sigma',
            productKey: 'prod-ciment',
          )?.id,
          'a',
        );
        expect(
          DeliveryFormRules.findDuplicateNote(
            rows,
            noteNumber: 'BL-4471',
            supplierKey: 'autre',
            productKey: 'prod-ciment',
          ),
          isNull,
        );
        expect(
          DeliveryFormRules.findDuplicateNote(
            [rows[1]],
            noteNumber: 'BL-4471',
            supplierKey: 'sup-sigma',
            productKey: 'prod-ciment',
          ),
          isNull,
        );
        expect(
          DeliveryFormRules.findDuplicateNote(
            rows,
            noteNumber: 'BL-4471',
            supplierKey: 'sup-sigma',
            productKey: 'prod-ciment',
            ignoringId: 'a',
          ),
          isNull,
        );
      },
    );

    test(
      'date : jamais dans le futur, anterieure a la demande = avertissement',
      () {
        final today = DateTime.utc(2026, 11, 25);
        expect(
          DeliveryFormRules.isFuture(DateTime.utc(2026, 11, 26), today),
          isTrue,
        );
        expect(DeliveryFormRules.isFuture(today, today), isFalse);
        expect(
          DeliveryFormRules.isBeforeRequest(DateTime.utc(2026, 11, 1), today),
          isTrue,
        );
      },
    );
  });

  group('operation `delivery` : charge utile (ADR 0011)', () {
    test(
      'create : requete, fournisseur, quantite avec unite, date complete, bon en majuscules',
      () {
        final draft = DeliveryDraft(
          request: const RequestRef.server('req-1'),
          supplierId: 'sup-1',
          quantity: q('10', MeasureUnit.tonne),
          deliveryDate: DateTime.utc(2026, 11, 25),
          deliveryNoteNumber: ' bl-1 ',
          conformity: Conformity.withReserve,
          reserveReasonCode: 'DamagedProduct',
        );
        final payload = DeliveryPayloads.create(
          draft,
          DateTime.utc(2026, 11, 25, 9),
        );
        expect(payload['requestId'], 'req-1');
        expect(payload['supplierId'], 'sup-1');
        expect(payload['quantity'], {'value': 10, 'unit': 't'});
        expect(payload['deliveryDate'], '2026-11-25');
        expect(payload['deliveryNoteNumber'], 'BL-1');
        expect(payload['conformity'], 'WithReserve');
        expect(payload['reserveReasonCode'], 'DamagedProduct');
        expect(payload.containsKey('productId'), isFalse);
        expect(payload['clientCreatedAt'], '2026-11-25T09:00:00.000Z');
      },
    );

    test('create sans demande : produit et fournisseur libres', () {
      final payload = DeliveryPayloads.create(
        DeliveryDraft(
          freeSupplierName: 'Depot',
          freeProductName: 'Parpaing',
          quantity: q('200', MeasureUnit.piece),
          deliveryDate: DateTime.utc(2026, 11, 25),
        ),
        DateTime.utc(2026, 11, 25),
      );
      expect(payload.containsKey('requestId'), isFalse);
      expect(payload['freeProductName'], 'Parpaing');
      expect(payload['freeSupplierName'], 'Depot');
      expect(payload['quantity'], {'value': 200, 'unit': 'u'});
    });

    test('create : une demande en attente est designee par son clientId', () {
      final payload = DeliveryPayloads.create(
        DeliveryDraft(
          request: const RequestRef.client('c-9'),
          quantity: q('1', MeasureUnit.bag),
          deliveryDate: DateTime.utc(2026, 11, 25),
        ),
        DateTime.utc(2026, 11, 25),
      );
      expect(payload['requestClientId'], 'c-9');
      expect(payload.containsKey('requestId'), isFalse);
    });

    test('photo : empreinte, taille, JPEG, livraison par clientId', () {
      final payload = DeliveryPayloads.photo(
        delivery: const DeliveryRef.client('liv-1'),
        now: DateTime.utc(2026, 11, 25, 9),
        takenAt: DateTime.utc(2026, 11, 25, 8, 10),
        sizeBytes: 1480000,
        sha256: 'a' * 64,
      );
      expect(payload['deliveryClientId'], 'liv-1');
      expect(payload['contentType'], 'image/jpeg');
      expect(payload['sizeBytes'], 1480000);
      expect(payload['sha256'], 'a' * 64);
      expect(payload['takenAt'], '2026-11-25T08:10:00.000Z');
    });

    test(
      'annulation : action cancel, motif, remarque seulement si presente',
      () {
        final payload = DeliveryPayloads.cancel(
          ref: const DeliveryRef.server('l-1'),
          now: DateTime.utc(2026, 11, 25),
          reasonCode: 'DoubleEntry',
        );
        expect(payload['action'], 'cancel');
        expect(payload['deliveryId'], 'l-1');
        expect(payload['reasonCode'], 'DoubleEntry');
        expect(payload.containsKey('reasonNote'), isFalse);
      },
    );
  });

  group(
    'correction : seuls les champs modifies, avec leur valeur de depart',
    () {
      final shown = deliveryRow();

      DeliveryEditDraft draft({
        String quantity = '10',
        String? note = 'BL-4471',
        Conformity conformity = Conformity.conform,
        String? reason,
        DateTime? date,
      }) => DeliveryEditDraft(
        quantity: q(quantity, MeasureUnit.tonne),
        deliveryDate: date ?? shown.deliveryDate,
        deliveryNoteNumber: note,
        conformity: conformity,
        reserveReasonCode: reason,
      );

      test('rien de change : rien a envoyer', () {
        expect(DeliveryEdit.diff(shown, draft()).isEmpty, isTrue);
      });

      test('quantite', () {
        final edit = DeliveryEdit.diff(shown, draft(quantity: '8'));
        expect(edit.changes, {
          'quantity': {'value': 8, 'unit': 't'},
        });
        expect(edit.base, {
          'quantity': {'value': 10, 'unit': 't'},
        });
      });

      test('date', () {
        final edit = DeliveryEdit.diff(
          shown,
          draft(date: DateTime.utc(2026, 11, 3)),
        );
        expect(edit.changes, {'deliveryDate': '2026-11-03'});
        expect(edit.base, {'deliveryDate': '2026-11-04'});
      });

      test(
        'n° de bon ajoute : la valeur de depart vide part en chaine vide',
        () {
          final noBon = deliveryRow().copyWithNote(null);
          final edit = DeliveryEdit.diff(noBon, draft(note: 'bl-9'));
          expect(edit.changes, {'deliveryNoteNumber': 'BL-9'});
          expect(edit.base, {'deliveryNoteNumber': ''});
        },
      );

      test(
        'un n° de bon efface n est pas envoye (le serveur ne sait pas effacer)',
        () {
          expect(DeliveryEdit.diff(shown, draft(note: null)).isEmpty, isTrue);
        },
      );

      test('passage « Avec reserve » : conformite et motif', () {
        final edit = DeliveryEdit.diff(
          shown,
          draft(conformity: Conformity.withReserve, reason: 'WrongProduct'),
        );
        expect(edit.changes, {
          'conformity': 'WithReserve',
          'reserveReasonCode': 'WrongProduct',
        });
        expect(edit.base, {'conformity': 'Conform', 'reserveReasonCode': ''});
      });

      test(
        '« Refaire ma modification » : valeurs du serveur + mes changements',
        () {
          final draftFromChanges = draftFromDeliveryChanges(
            shown,
            changes: {
              'quantity': {'value': 8, 'unit': 't'},
            },
          )!;
          expect(draftFromChanges.quantity, q('8', MeasureUnit.tonne));
          expect(draftFromChanges.deliveryDate, shown.deliveryDate);
          expect(draftFromChanges.deliveryNoteNumber, 'BL-4471');
        },
      );
    },
  );

  group('surcouche des saisies en attente (CA-MAT-010.11)', () {
    final stored = deliveryRow();

    test('correction en attente : quantite affichee, « modifiee »', () {
      final view = overlayDelivery(stored, [
        fakeOutbox('u-1', 'update', {
          'deliveryId': 'liv-006',
          'changes': {
            'quantity': {'value': 8, 'unit': 't'},
          },
          'base': {
            'quantity': {'value': 10, 'unit': 't'},
          },
        }),
      ]);
      expect(view.row.quantityValue, Decimal.parse('8'));
      expect(view.hasPendingChanges, isTrue);
      expect(view.stored.quantityValue, Decimal.parse('10'));
    });

    test('annulation en attente : provisoire, motif garde', () {
      final view = overlayDelivery(stored, [
        fakeOutbox('c-1', 'transition', {
          'deliveryId': 'liv-006',
          'action': 'cancel',
          'reasonCode': 'DoubleEntry',
        }),
      ]);
      expect(view.row.isCancelled, isTrue);
      expect(view.isProvisional, isTrue);
      expect(view.row.cancelReasonCode, 'DoubleEntry');
    });

    test('saisie refusee ou en conflit : jamais appliquee, signalee', () {
      final view = overlayDelivery(stored, [
        fakeOutbox('u-1', 'update', {
          'deliveryId': 'liv-006',
          'changes': {
            'quantity': {'value': 8, 'unit': 't'},
          },
        }, status: OutboxStatus.conflict),
      ]);
      expect(view.row.quantityValue, Decimal.parse('10'));
      expect(view.needsCheck, isTrue);
    });

    test('operation d une autre livraison : ignoree', () {
      final view = overlayDelivery(stored, [
        fakeOutbox('c-1', 'transition', {
          'deliveryId': 'autre',
          'action': 'cancel',
          'reasonCode': 'DoubleEntry',
        }),
      ]);
      expect(view.row.isCancelled, isFalse);
    });

    test(
      'statut provisoire de la demande : livraison en attente = a confirmer',
      () {
        final request = RequestView.plain(
          requestRow(id: 'r1', status: 'Ordered', quantity: '600', unit: 'sac'),
        );
        final pending = DeliveryView.plain(
          pendingDeliveryRow(clientId: 'liv-x', requestId: 'r1'),
        );
        final shown = applyDeliveries(request, [pending], bagMassKg: bag);
        expect(shown.isStatusProvisional, isTrue);
        expect(shown.row.status, 'PartiallyDelivered');
        expect(shown.row.receivedValue, Decimal.parse('200'));
        expect(shown.row.remainingValue, Decimal.parse('400'));
        // Annuler cette livraison en attente fait redescendre le statut (dans les deux sens).
        final cancelled = DeliveryView.plain(
          pendingDeliveryRow(
            clientId: 'liv-x',
            requestId: 'r1',
          ).copyWithStatus('Cancelled'),
        );
        final back = applyDeliveries(request, [cancelled]);
        expect(back.row.status, 'Ordered');
      },
    );

    test(
      'rien en attente : la demande est rendue telle quelle (le serveur fait foi)',
      () {
        final request = RequestView.plain(
          requestRow(id: 'r1', status: 'Ordered'),
        );
        final confirmed = DeliveryView.plain(deliveryRow(requestId: 'r1'));
        expect(applyDeliveries(request, [confirmed]), same(request));
      },
    );

    test('demande receptionnee : jamais recalculee', () {
      final request = RequestView.plain(
        requestRow(id: 'r1', status: 'Received'),
      );
      final pending = DeliveryView.plain(
        pendingDeliveryRow(clientId: 'liv-x', requestId: 'r1'),
      );
      expect(applyDeliveries(request, [pending]), same(request));
    });

    test('regroupement par demande : serveur et clientId', () {
      final a = DeliveryView.plain(deliveryRow(id: 'a', requestId: 'r1'));
      final b = DeliveryView.plain(deliveryRow(id: 'b', requestId: 'c-1'));
      final groups = groupByRequest([a, b]);
      final request = RequestView.plain(requestRow(id: 'r1', clientId: 'c-1'));
      final mine = deliveriesOfRequest(groups, request);
      expect(mine.map((d) => d.id), ['a', 'b']);
      mine.add(a); // liste modifiable (l'ecran la trie)
    });
  });

  group('« A recevoir » (CA-MAT-006.1)', () {
    final today = DateTime.utc(2026, 11, 25);

    RequestView view(
      String id,
      String status, {
      String? expected,
      DateTime? neededBy,
      bool archived = false,
    }) => RequestView.plain(
      requestRow(
        id: id,
        number: id.toUpperCase(),
        status: status,
        neededBy: neededBy,
        orderJson: expected == null
            ? null
            : '{"supplierName":"Sigma","expectedDeliveryDate":"$expected"}',
        archivedAt: archived ? DateTime.utc(2026, 11, 1) : null,
      ),
    );

    List<String> ids(
      Iterable<RequestView> all, {
      ReceiveFilter filter = ReceiveFilter.all,
      String query = '',
    }) => [
      for (final item in filterToReceive(
        all,
        filter: filter,
        today: today,
        languageCode: 'fr',
        query: query,
      ))
        item.id,
    ];

    test('seulement commandees et livrees partiellement, hors archivees', () {
      final all = [
        view('a', 'Ordered', expected: '2026-11-27'),
        view('b', 'PartiallyDelivered', expected: '2026-11-26'),
        view('c', 'Validated'),
        view('d', 'Delivered'),
        view('e', 'Ordered', archived: true),
      ];
      expect(ids(all), ['b', 'a']);
    });

    test('a defaut de date prevue : date de besoin', () {
      final all = [
        view('a', 'Ordered', expected: '2026-11-27'),
        view('b', 'Ordered', neededBy: DateTime.utc(2026, 11, 20)),
      ];
      expect(ids(all), ['b', 'a']);
      expect(ids(all, filter: ReceiveFilter.late), ['b']);
    });

    test('filtres du jour, de la semaine, en retard', () {
      final all = [
        view('a', 'Ordered', expected: '2026-11-25'),
        view('b', 'Ordered', expected: '2026-12-01'),
        view('c', 'Ordered', expected: '2026-12-02'),
        view('d', 'Ordered', expected: '2026-11-24'),
      ];
      expect(ids(all, filter: ReceiveFilter.today), ['a']);
      expect(ids(all, filter: ReceiveFilter.week), ['a', 'b']);
      expect(ids(all, filter: ReceiveFilter.late), ['d']);
    });

    test('recherche : fournisseur, sans accents ni casse', () {
      final all = [view('a', 'Ordered', expected: '2026-11-25')];
      expect(ids(all, query: 'SIGMA'), ['a']);
      expect(ids(all, query: 'atlas'), isEmpty);
    });
  });

  group('liste des livraisons', () {
    DeliveryView v(
      String id, {
      String? requestId = 'r1',
      String status = 'Recorded',
      String? note = 'BL-1',
      int photos = 0,
      String conformity = 'Conform',
    }) => DeliveryView.plain(
      deliveryRow(
        id: id,
        number: id.toUpperCase(),
        requestId: requestId,
        status: status,
      ).copyWithNote(note).copyWithConformity(conformity),
    ).withPhotoCount(photos);

    List<String> ids(
      Iterable<DeliveryView> all,
      DeliveryListFilter filter, {
      String query = '',
    }) => [
      for (final item in filterDeliveries(
        all,
        filter: filter,
        languageCode: 'fr',
        query: query,
      ))
        item.id,
    ];

    test('filtres', () {
      final all = [
        v('a'),
        v('b', requestId: null),
        v('c', note: null),
        v('d', note: null, photos: 1),
        v('e', conformity: 'WithReserve'),
        v('f', note: null, status: 'Cancelled'),
      ];
      expect(ids(all, DeliveryListFilter.unattached), ['b']);
      expect(ids(all, DeliveryListFilter.noteMissing), ['c']);
      expect(ids(all, DeliveryListFilter.withReserve), ['e']);
      expect(ids(all, DeliveryListFilter.all), hasLength(6));
    });

    test('une demande disparue du telephone : traitee comme non rattachee', () {
      final all = [v('a', requestId: 'inconnue')];
      expect(
        [
          for (final item in filterDeliveries(
            all,
            filter: DeliveryListFilter.unattached,
            languageCode: 'fr',
            knownRequestIds: {'r1'},
          ))
            item.id,
        ],
        ['a'],
      );
    });

    test('recherche par n° de bon et par numero', () {
      final all = [v('a'), v('b', note: 'XY-9')];
      expect(ids(all, DeliveryListFilter.all, query: 'xy-9'), ['b']);
      expect(ids(all, DeliveryListFilter.all, query: 'a'), contains('a'));
    });
  });
}
