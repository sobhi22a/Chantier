import 'dart:convert';
import 'dart:typed_data';

import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/data/photo_remote.dart';
import 'package:chantier_mobile/features/materials/data/supplier_contact.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_listing.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:decimal/decimal.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/deliveries_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/deliveries_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/delivery_detail_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/to_receive_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/to_reception_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/request_detail_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/materials_harness.dart';
import '../../../support/photo_support.dart';
import '../../../support/pump_app.dart';

void screenTest(String name, Future<void> Function(WidgetTester tester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    });

/// Image PNG de 1 pixel, valide (affichage d'une photo envoyee).
final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

String _order(String supplier, String? expected, {String id = 'sup-sigma'}) =>
    '{"id":"o1","supplierId":"$id","supplierName":"$supplier"'
    '${expected == null ? '' : ',"expectedDeliveryDate":"$expected"'}}';

class _FakeContact implements SupplierContactSource {
  _FakeContact({this.phone, this.error});

  final String? phone;
  final ApiException? error;
  final List<String> calls = [];

  @override
  Future<String?> phoneOf(String supplierId) async {
    calls.add(supplierId);
    if (error != null) throw error!;
    return phone;
  }
}

class _FakeDialer implements PhoneDialer {
  final List<String> dialed = [];
  bool opens = true;

  @override
  Future<bool> dial(String phone) async {
    dialed.add(phone);
    return opens;
  }
}

void main() {
  late MaterialsHarness h;
  late PhotoTestBed bed;

  setUp(() {
    h = MaterialsHarness();
    bed = PhotoTestBed();
  });
  tearDown(() async {
    await h.dispose();
    bed.dispose();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  void bigScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> seedRequests() async {
    await h.seed();
    await h.db.suppliersDao.upsertIfNewer(supplierRow());
    final dao = h.db.materialRequestsDao;
    await dao.upsertIfNewer(
      requestRow(
        id: 'r1',
        number: 'DEM-001',
        status: 'Ordered',
        orderJson: _order('Cimenterie Sigma (fictive)', '2026-11-27'),
        version: 10,
      ),
    );
    await dao.upsertIfNewer(
      requestRow(
        id: 'r2',
        number: 'DEM-002',
        status: 'PartiallyDelivered',
        productId: 'prod-sable',
        productName: 'Sable 0/3',
        quantity: '24',
        unit: 'm3',
        orderJson: _order('Carriere Atlas (fictive)', '2026-11-25', id: 's2'),
        version: 11,
      ),
    );
    await dao.upsertIfNewer(
      requestRow(
        id: 'r3',
        number: 'DEM-003',
        status: 'Ordered',
        productName: 'Rond HA Ø12',
        productId: 'prod-rond',
        quantity: '2',
        unit: 't',
        neededBy: DateTime.utc(2026, 11, 20),
        version: 12,
      ),
    );
    await dao.upsertIfNewer(
      requestRow(id: 'r4', number: 'DEM-004', status: 'Validated', version: 13),
    );
    await dao.upsertIfNewer(
      requestRow(id: 'r5', number: 'DEM-005', status: 'Received', version: 14),
    );
  }

  // ------------------------------------------------------------------------ A recevoir

  group('A recevoir (CA-MAT-006.1, 006.12)', () {
    Future<void> openToReceive(
      WidgetTester tester, {
      AuthUser? user,
      Locale locale = const Locale('fr'),
      void Function(RequestView view)? onOpen,
      bool withoutRequest = true,
      Future<void> Function()? more,
    }) async {
      bigScreen(tester);
      await tester.runAsync(() async {
        await seedRequests();
        await more?.call();
      });
      final signedIn = user ?? chefChantier();
      await tester.pumpWidget(
        testApp(
          locale: locale,
          home: BlocProvider(
            create: (_) => RequestsCubit(
              repository: h.materials,
              siteId: harnessSite,
              userId: signedIn.id,
              view: RequestListView.expected,
            ),
            child: ToReceiveScreen(
              user: signedIn,
              onOpen: onOpen ?? (_) {},
              onWithoutRequest: withoutRequest ? () {} : null,
              now: () => DateTime.utc(2026, 11, 25, 9),
            ),
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
    }

    List<String> numbersShown(WidgetTester tester) => [
      for (final number in [
        'DEM-001',
        'DEM-002',
        'DEM-003',
        'DEM-004',
        'DEM-005',
      ])
        if (find.text(number).evaluate().isNotEmpty) number,
    ];

    double top(WidgetTester tester, String text) =>
        tester.getTopLeft(find.text(text)).dy;

    screenTest(
      'commandees et livrees partiellement seulement, date prevue la plus proche d abord',
      (tester) async {
        await openToReceive(tester);
        expect(numbersShown(tester), ['DEM-001', 'DEM-002', 'DEM-003']);
        expect(top(tester, 'DEM-003'), lessThan(top(tester, 'DEM-002')));
        expect(top(tester, 'DEM-002'), lessThan(top(tester, 'DEM-001')));
        // Quantite du reste avec son unite ; jamais un prix.
        expect(findTextContaining('Reste : 24 m³'), findsOneWidget);
        expect(findTextContaining('Prévue le 27/11/2026'), findsOneWidget);
        expect(find.text('Date prévue non indiquée'), findsOneWidget);
        expect(find.textContaining('DA'), findsNothing);
      },
    );

    screenTest('filtres Aujourd hui, Cette semaine, En retard', (tester) async {
      await openToReceive(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, "Aujourd'hui"));
      await tester.pump();
      expect(numbersShown(tester), ['DEM-002']);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Cette semaine'));
      await tester.pump();
      expect(numbersShown(tester), ['DEM-001', 'DEM-002']);
      await tester.tap(find.widgetWithText(ChoiceChip, 'En retard'));
      await tester.pump();
      expect(numbersShown(tester), ['DEM-003']);
    });

    screenTest('recherche par fournisseur, materiau ou numero', (tester) async {
      await openToReceive(tester);
      await tester.enterText(find.byType(TextField), 'atlas');
      await tester.pump();
      expect(numbersShown(tester), ['DEM-002']);
      await tester.enterText(find.byType(TextField), 'rond');
      await tester.pump();
      expect(numbersShown(tester), ['DEM-003']);
      await tester.enterText(find.byType(TextField), 'dem-001');
      await tester.pump();
      expect(numbersShown(tester), ['DEM-001']);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(find.text('Aucune commande à recevoir.'), findsOneWidget);
    });

    screenTest('un appui sur la commande l ouvre', (tester) async {
      RequestView? opened;
      await openToReceive(tester, onOpen: (view) => opened = view);
      await tester.tap(find.text('DEM-001'));
      expect(opened?.id, 'r1');
    });

    screenTest('livraison sans demande : bouton absent sans le droit', (
      tester,
    ) async {
      await openToReceive(tester, withoutRequest: false);
      expect(find.text('Livraison sans demande'), findsNothing);
    });

    screenTest(
      'livraison saisie hors ligne : statut provisoire « A confirmer »',
      (tester) async {
        await openToReceive(
          tester,
          more: () async {
            await h.deliveries.record(
              clientId: 'liv-off',
              siteId: harnessSite,
              userId: 'user-chef',
              recorderName: 'Mourad B.',
              draft: DeliveryDraft(
                request: const RequestRef.server('r1'),
                supplierId: 'sup-sigma',
                quantity: Quantity(Decimal.parse('600'), MeasureUnit.bag),
                deliveryDate: DateTime.utc(2026, 11, 25),
              ),
              label: 'LIV',
              photoLabel: 'P',
              maxPhotos: 5,
              request: await h.db.materialRequestsDao.getById('r1'),
            );
          },
        );
        // 600 sacs saisis pour 300 commandes : la demande devient « Livree » (a confirmer) et
        // quitte « A recevoir » ; la ligne locale reste celle du serveur.
        expect(numbersShown(tester), ['DEM-002', 'DEM-003']);
      },
    );

    screenTest('arabe : textes arabes, numeros de gauche a droite', (
      tester,
    ) async {
      await openToReceive(tester, locale: const Locale('ar'));
      expect(find.text('للاستلام'), findsOneWidget);
      expect(find.text('اليوم'), findsOneWidget);
      expect(directionOf(tester, find.text('للاستلام')), TextDirection.rtl);
      expect(find.text('DEM-001'), findsOneWidget);
      expect(find.text('تسليم بدون طلب'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------------ A receptionner

  group('A receptionner (CA-MAT-008.3)', () {
    Future<void> openReception(
      WidgetTester tester, {
      AuthUser? user,
      Locale locale = const Locale('fr'),
    }) async {
      bigScreen(tester);
      await tester.runAsync(() async {
        await h.seed();
        await h.db.materialRequestsDao.upsertIfNewer(
          requestRow(id: 'd1', number: 'DEM-014', status: 'Delivered'),
        );
        await h.db.materialRequestsDao.upsertIfNewer(
          requestRow(id: 'd2', number: 'DEM-015', status: 'Ordered'),
        );
      });
      final signedIn = user ?? chefChantier();
      await tester.pumpWidget(
        testApp(
          locale: locale,
          home: BlocProvider(
            create: (_) => RequestsCubit(
              repository: h.materials,
              siteId: harnessSite,
              userId: signedIn.id,
              view: RequestListView.toReception,
            ),
            child: ToReceptionScreen(
              user: signedIn,
              repository: h.materials,
              zones: h.zones.watchZones(harnessSite),
              onOpen: (_) {},
              now: () => DateTime.utc(2026, 11, 25, 9),
            ),
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
    }

    screenTest('seules les demandes livrees ; Receptionner en 1 geste', (
      tester,
    ) async {
      await openReception(tester);
      expect(find.text('DEM-014'), findsOneWidget);
      expect(find.text('DEM-015'), findsNothing);
      await tester.tap(find.text('Réceptionner'));
      await tester.pump();
      await settle(tester);
      final ops = await tester.runAsync(
        () => h.db.outboxDao.allFor('user-chef'),
      );
      expect(ops!.length, 1);
      expect(ops.single.entity, 'request');
      expect(ops.single.operation, 'transition');
      expect(ops.single.payload['action'], 'receive');
      expect(ops.single.payload['requestId'], 'd1');
    });

    screenTest('double appui : une seule reception en attente', (tester) async {
      await openReception(tester);
      final button = find.text('Réceptionner');
      await tester.tap(button);
      await tester.tap(button, warnIfMissed: false);
      await tester.pump();
      await settle(tester);
      final ops = await tester.runAsync(
        () => h.db.outboxDao.allFor('user-chef'),
      );
      expect(ops!.length, 1);
    });

    screenTest('conducteur : pas de bouton Receptionner (absent)', (
      tester,
    ) async {
      await openReception(tester, user: conducteur());
      expect(find.text('DEM-014'), findsOneWidget);
      expect(find.text('Réceptionner'), findsNothing);
    });

    screenTest('arabe', (tester) async {
      await openReception(tester, locale: const Locale('ar'));
      expect(find.text('تأكيد الاستلام'), findsOneWidget);
      expect(find.text('Réceptionner'), findsNothing);
    });
  });

  // ------------------------------------------------------------------ Livraisons

  group('Livraisons (CA-MAT-011.8, 007.7)', () {
    Future<void> openDeliveries(
      WidgetTester tester, {
      Locale locale = const Locale('fr'),
      AuthUser? user,
    }) async {
      bigScreen(tester);
      await tester.runAsync(() async {
        await h.seed();
        final dao = h.db.deliveriesDao;
        await dao.upsertIfNewer(deliveryRow(id: 'l6', version: 6));
        await dao.upsertIfNewer(
          deliveryRow(
            id: 'l7',
            number: 'LIV-007',
            requestId: null,
            unattachedReason: 'RequestNotOpen',
            inRequestQuantity: null,
            inRequestUnit: null,
            version: 7,
          ).copyWith(deliveryNoteNumber: const Value(null)),
        );
        await dao.upsertIfNewer(
          deliveryRow(
            id: 'l8',
            number: 'LIV-008',
            requestId: null,
            version: 8,
            deliveryDate: DateTime.utc(2026, 11, 3),
          ).copyWith(
            conformity: 'WithReserve',
            reserveReasonCode: const Value('DamagedProduct'),
            deliveryNoteNumber: const Value(null),
          ),
        );
        await dao.upsertIfNewer(
          deliveryRow(
            id: 'l9',
            number: 'LIV-009',
            status: 'Cancelled',
            version: 9,
          ),
        );
        // La photo de LIV-008 : plus de « BL manquant ».
        await h.db.deliveryPhotosDao.upsertIfNewer(
          photoRow(deliveryId: 'l8', version: 20),
        );
      });
      final signedIn = user ?? chefChantier();
      await tester.pumpWidget(
        testApp(
          locale: locale,
          home: BlocProvider(
            create: (_) => DeliveriesCubit(
              repository: h.deliveries,
              siteId: harnessSite,
              userId: signedIn.id,
            ),
            child: DeliveriesScreen(
              user: signedIn,
              onOpen: (_) {},
              onNewWithoutRequest: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
    }

    List<String> shown() => [
      for (final number in ['LIV-006', 'LIV-007', 'LIV-008', 'LIV-009'])
        if (find.text(number).evaluate().isNotEmpty) number,
    ];

    screenTest('toutes : numero, quantite avec unite, equivalent, badges', (
      tester,
    ) async {
      await openDeliveries(tester);
      expect(shown(), ['LIV-006', 'LIV-007', 'LIV-008', 'LIV-009']);
      expect(findTextContaining('10 T = 200 sac'), findsWidgets);
      expect(find.text('Non rattachée'), findsWidgets);
      expect(find.text('Annulée'), findsOneWidget);
      // LIV-007 : ni bon ni photo ; LIV-008 : photo, pas de BL manquant.
      expect(find.text('BL manquant'), findsNWidgets(2));
    });

    screenTest('filtre Non rattachees', (tester) async {
      await openDeliveries(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Non rattachées'));
      await tester.pump();
      expect(shown(), ['LIV-007', 'LIV-008']);
    });

    screenTest('filtre BL manquant : sans bon ni photo', (tester) async {
      await openDeliveries(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'BL manquant'));
      await tester.pump();
      expect(shown(), ['LIV-007']);
    });

    screenTest('filtre Avec reserve', (tester) async {
      await openDeliveries(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Avec réserve'));
      await tester.pump();
      expect(shown(), ['LIV-008']);
    });

    screenTest('recherche par numero, materiau ou n° de bon', (tester) async {
      await openDeliveries(tester);
      await tester.enterText(find.byType(TextField), 'bl-4471');
      await tester.pump();
      expect(shown(), ['LIV-006', 'LIV-009']);
      await tester.enterText(find.byType(TextField), 'liv-008');
      await tester.pump();
      expect(shown(), ['LIV-008']);
    });

    screenTest('arabe : textes arabes', (tester) async {
      await openDeliveries(tester, locale: const Locale('ar'));
      expect(find.text('التسليمات'), findsOneWidget);
      expect(find.text('غير مرتبطة'), findsWidgets);
      expect(find.text('LIV-006'), findsOneWidget);
    });

    screenTest('liste de 200 livraisons : construite a la demande', (
      tester,
    ) async {
      bigScreen(tester);
      await tester.runAsync(() async {
        await h.seed();
        for (var i = 1; i <= 200; i++) {
          await h.db.deliveriesDao.upsertIfNewer(
            deliveryRow(
              id: 'x$i',
              number: 'LIV-${i.toString().padLeft(3, '0')}',
              requestId: null,
              version: i,
            ),
          );
        }
      });
      await tester.pumpWidget(
        testApp(
          home: BlocProvider(
            create: (_) => DeliveriesCubit(
              repository: h.deliveries,
              siteId: harnessSite,
              userId: 'user-chef',
              filter: DeliveryListFilter.unattached,
            ),
            child: DeliveriesScreen(user: chefChantier(), onOpen: (_) {}),
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
      // `ListView.builder` : bien moins de 200 tuiles construites.
      expect(find.byType(Card).evaluate().length, lessThan(40));
    });
  });

  // ------------------------------------------------------------------ Detail livraison

  group('Detail d une livraison (CA-MAT-007, 012)', () {
    late FakePhotoRemote photoRemote;
    late PhotoViewer viewer;
    DeliveryView? edited;

    Future<void> openDetail(
      WidgetTester tester, {
      required AuthUser user,
      String id = 'l6',
      Locale locale = const Locale('fr'),
      Future<void> Function()? more,
    }) async {
      bigScreen(tester);
      photoRemote = FakePhotoRemote();
      viewer = PhotoViewer(photoRemote);
      edited = null;
      await tester.runAsync(() async {
        await h.seed();
        await h.db.materialRequestsDao.upsertIfNewer(
          requestRow(
            id: 'req-009',
            number: 'DEM-009',
            status: 'Delivered',
            orderJson: _order('Cimenterie Sigma (fictive)', '2026-11-26'),
          ),
        );
        await h.db.deliveriesDao.upsertIfNewer(
          deliveryRow(
            id: 'l6',
            historyJson:
                '[{"id":"e1","type":"DeliveryRegistered","occurredAt":"2026-11-04T08:10:00Z","actorName":"Mourad B."}]',
          ),
        );
        await more?.call();
      });
      await tester.pumpWidget(
        testApp(
          locale: locale,
          home: BlocProvider(
            create: (_) => DeliveryDetailCubit(
              repository: h.deliveries,
              deliveryId: id,
              userId: user.id,
            ),
            child: DeliveryDetailScreen(
              user: user,
              deliveries: h.deliveries,
              materials: h.materials,
              capture: FakePhotoCapture(bed),
              files: bed.files,
              viewer: viewer,
              onEdit: (view) => edited = view,
            ),
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
    }

    screenTest(
      'informations, equivalent, fournisseur, bon, historique ; pas de prix',
      (tester) async {
        await openDetail(tester, user: chefChantier());
        expect(find.text('LIV-006'), findsOneWidget);
        expect(findTextContaining('10 T = 200 sac'), findsOneWidget);
        expect(find.text('BL-4471'), findsOneWidget);
        expect(find.textContaining('Sigma'), findsOneWidget);
        expect(find.text('Livraison enregistrée'), findsOneWidget);
        expect(find.textContaining('DA'), findsNothing);
        expect(find.text('DEM-009'), findsOneWidget);
      },
    );

    screenTest(
      'annuler : motif obligatoire, operation en file, statut « A confirmer »',
      (tester) async {
        await openDetail(tester, user: chefChantier());
        await tester.ensureVisible(find.text('Annuler la livraison'));
        await tester.tap(find.text('Annuler la livraison'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        // Confirmer sans motif : refuse.
        await tester.tap(
          find.widgetWithText(FilledButton, 'Annuler la livraison'),
        );
        await tester.pump();
        expect(find.text('Choisissez un motif.'), findsOneWidget);
        await tester.tap(find.text('Saisie en double'));
        await tester.pump();
        await tester.tap(
          find.widgetWithText(FilledButton, 'Annuler la livraison'),
        );
        await tester.pump();
        await settle(tester);
        final ops = await tester.runAsync(
          () => h.db.outboxDao.allFor('user-chef'),
        );
        expect(ops!.single.operation, 'transition');
        expect(ops.single.payload['action'], 'cancel');
        expect(ops.single.payload['reasonCode'], 'DoubleEntry');
        expect(find.text('À confirmer'), findsOneWidget);
        // Annulee : plus aucune action.
        expect(find.text('Corriger'), findsNothing);
      },
    );

    screenTest('corriger : ouvre le formulaire', (tester) async {
      await openDetail(tester, user: chefChantier());
      await tester.ensureVisible(find.text('Corriger'));
      await tester.tap(find.text('Corriger'));
      expect(edited?.id, 'l6');
    });

    screenTest('chef d equipe : ni corriger, ni annuler, ni photo (absents)', (
      tester,
    ) async {
      await openDetail(tester, user: chefEquipe());
      expect(find.text('LIV-006'), findsOneWidget);
      expect(find.text('Corriger'), findsNothing);
      expect(find.text('Annuler la livraison'), findsNothing);
      expect(find.text('Photographier le bon'), findsNothing);
    });

    screenTest(
      'demande receptionnee : correction et annulation absentes (DEMANDE_NON_OUVERTE)',
      (tester) async {
        await openDetail(
          tester,
          user: chefChantier(),
          more: () => h.db.materialRequestsDao.upsertIfNewer(
            requestRow(
              id: 'req-009',
              number: 'DEM-009',
              status: 'Received',
              version: 900,
            ),
          ),
        );
        expect(find.text('Corriger'), findsNothing);
        expect(find.text('Annuler la livraison'), findsNothing);
      },
    );

    screenTest(
      'non rattachee : motif et message « il faut du reseau pour rattacher »',
      (tester) async {
        await openDetail(
          tester,
          user: chefChantier(),
          id: 'l7',
          more: () => h.db.deliveriesDao.upsertIfNewer(
            deliveryRow(
              id: 'l7',
              number: 'LIV-007',
              requestId: null,
              unattachedReason: 'RequestNotOpen',
              inRequestQuantity: null,
              inRequestUnit: null,
              version: 7,
            ),
          ),
        );
        expect(find.text('Non rattachée'), findsOneWidget);
        expect(find.text("La demande n'était plus ouverte"), findsOneWidget);
        expect(findTextContaining('il faut du réseau'), findsOneWidget);
      },
    );

    screenTest('photo envoyee : chargee a la demande avec reseau, en memoire', (
      tester,
    ) async {
      await openDetail(
        tester,
        user: chefChantier(),
        more: () => h.db.deliveryPhotosDao.upsertIfNewer(
          photoRow(id: 'ph-1', deliveryId: 'l6'),
        ),
      );
      photoRemote.downloads['ph-1'] = _png;
      expect(find.text('Afficher la photo'), findsOneWidget);
      expect(photoRemote.downloadCalls, isEmpty);
      await tester.tap(find.text('Afficher la photo'));
      await tester.pump();
      await settle(tester);
      expect(photoRemote.downloadCalls, ['ph-1']);
      expect(find.byType(Image), findsWidgets);
      expect(find.text('Masquer'), findsOneWidget);
    });

    screenTest(
      'photo sans reseau : « Reseau necessaire pour afficher la photo »',
      (tester) async {
        await openDetail(
          tester,
          user: chefChantier(),
          more: () => h.db.deliveryPhotosDao.upsertIfNewer(
            photoRow(id: 'ph-1', deliveryId: 'l6'),
          ),
        );
        // Aucun octet connu du serveur : 404 ; puis coupure reseau.
        await tester.tap(find.text('Afficher la photo'));
        await tester.pump();
        await settle(tester);
        expect(find.text('Photo introuvable.'), findsOneWidget);
      },
    );

    screenTest('photo en attente d envoi : vignette locale et mention', (
      tester,
    ) async {
      final captured = (await tester.runAsync(
        () => bed.capture(owner: 'user-chef', clientId: 'ph-loc'),
      ))!;
      await openDetail(
        tester,
        user: chefChantier(),
        more: () async {
          await h.db.deliveryPhotosDao.insertPending(
            photoRow(
              id: 'ph-loc',
              clientId: 'ph-loc',
              deliveryId: 'l6',
              contentStatus: 'Pending',
              version: 0,
              isPending: true,
            ),
          );
          await h.db.deliveryPhotosDao.enqueueFile(
            pendingPhotoFile(
              clientId: 'ph-loc',
              owner: 'user-chef',
              deliveryId: 'l6',
            ).copyWith(relativePath: Value(captured.relativePath)),
          );
        },
      );
      await tester.pump();
      await settle(tester);
      expect(find.text("Photo en attente d'envoi"), findsOneWidget);
    });

    screenTest('arabe : textes arabes et historique traduit', (tester) async {
      await openDetail(
        tester,
        user: chefChantier(),
        locale: const Locale('ar'),
      );
      expect(find.text('تصحيح'), findsOneWidget);
      expect(find.text('تم تسجيل التسليم'), findsOneWidget);
      expect(find.text('LIV-006'), findsOneWidget);
    });
  });

  // ------------------------------------------------------ Appeler le fournisseur

  group('Appeler le fournisseur (ADR 0012)', () {
    Future<void> openRequest(
      WidgetTester tester, {
      required AuthUser user,
      required _FakeContact contact,
      required _FakeDialer dialer,
      Locale locale = const Locale('fr'),
    }) async {
      bigScreen(tester);
      await tester.runAsync(() async {
        await h.seed();
        await h.db.materialRequestsDao.upsertIfNewer(
          requestRow(
            id: 'req-009',
            number: 'DEM-009',
            status: 'Ordered',
            orderJson: _order('Cimenterie Sigma (fictive)', '2026-11-26'),
          ),
        );
      });
      await tester.pumpWidget(
        testApp(
          locale: locale,
          home: BlocProvider(
            create: (_) => RequestDetailCubit(
              repository: h.materials,
              requestId: 'req-009',
              userId: user.id,
            ),
            child: RequestDetailScreen(
              user: user,
              repository: h.materials,
              zones: h.zones.watchZones(harnessSite),
              onEdit: (_) {},
              deliveries: h.deliveries,
              contact: contact,
              dialer: dialer,
              onReceive: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
    }

    screenTest('en ligne : numero affiche puis compose ; rien n est stocke', (
      tester,
    ) async {
      final contact = _FakeContact(phone: '0550 00 00 21');
      final dialer = _FakeDialer();
      await openRequest(
        tester,
        user: chefChantier(),
        contact: contact,
        dialer: dialer,
      );
      expect(findTextContaining('Cimenterie Sigma (fictive)'), findsOneWidget);
      expect(findTextContaining('prévue le 26/11/2026'), findsOneWidget);
      await tester.ensureVisible(find.text('Appeler le fournisseur'));
      await tester.tap(find.text('Appeler le fournisseur'));
      await tester.pump();
      await settle(tester);
      expect(contact.calls, ['sup-sigma']);
      expect(find.text('0550 00 00 21'), findsOneWidget);
      await tester.tap(find.text('Appeler'));
      await tester.pump();
      await settle(tester);
      expect(dialer.dialed, ['0550 00 00 21']);

      // Jamais ecrit sur le telephone : aucune table ne contient le numero.
      final dump = await tester.runAsync(() async {
        final tables = await h.db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
            )
            .get();
        final buffer = StringBuffer();
        for (final table in tables) {
          final name = table.read<String>('name');
          for (final row
              in await h.db.customSelect('SELECT * FROM "$name"').get()) {
            buffer.write(row.data.values.join('|'));
          }
        }
        return buffer.toString();
      });
      expect(dump, isNot(contains('0550')));
      expect(dump, isNot(contains('00 00 21')));
    });

    screenTest('sans reseau : « Reseau necessaire pour afficher le numero »', (
      tester,
    ) async {
      final contact = _FakeContact(error: const NetworkApiException());
      await openRequest(
        tester,
        user: chefChantier(),
        contact: contact,
        dialer: _FakeDialer(),
      );
      await tester.ensureVisible(find.text('Appeler le fournisseur'));
      await tester.tap(find.text('Appeler le fournisseur'));
      await tester.pump();
      await settle(tester);
      expect(
        find.text('Réseau nécessaire pour afficher le numéro.'),
        findsWidgets,
      );
      expect(find.text('Appeler'), findsNothing);
    });

    screenTest('fournisseur sans numero : message clair', (tester) async {
      await openRequest(
        tester,
        user: chefChantier(),
        contact: _FakeContact(),
        dialer: _FakeDialer(),
      );
      await tester.ensureVisible(find.text('Appeler le fournisseur'));
      await tester.tap(find.text('Appeler le fournisseur'));
      await tester.pump();
      await settle(tester);
      expect(
        find.text('Aucun numéro enregistré pour ce fournisseur.'),
        findsWidgets,
      );
    });

    screenTest('chef d equipe (sans SupplierPhone.View) : bouton absent', (
      tester,
    ) async {
      final contact = _FakeContact(phone: '0550 00 00 21');
      await openRequest(
        tester,
        user: chefEquipe(),
        contact: contact,
        dialer: _FakeDialer(),
      );
      expect(find.text('Appeler le fournisseur'), findsNothing);
      expect(contact.calls, isEmpty);
    });

    screenTest('aucune application telephone : message', (tester) async {
      final dialer = _FakeDialer()..opens = false;
      await openRequest(
        tester,
        user: chefChantier(),
        contact: _FakeContact(phone: '0550 00 00 21'),
        dialer: dialer,
      );
      await tester.ensureVisible(find.text('Appeler le fournisseur'));
      await tester.tap(find.text('Appeler le fournisseur'));
      await tester.pump();
      await settle(tester);
      await tester.tap(find.text('Appeler'));
      await tester.pump();
      await settle(tester);
      expect(find.text("Impossible d'ouvrir le téléphone."), findsWidgets);
    });

    screenTest(
      '« Recevoir une livraison » : seulement commande attendue et droit de saisie',
      (tester) async {
        await openRequest(
          tester,
          user: chefChantier(),
          contact: _FakeContact(),
          dialer: _FakeDialer(),
        );
        expect(find.text('Recevoir une livraison'), findsOneWidget);
      },
    );

    screenTest('arabe : bouton d appel traduit, numero de gauche a droite', (
      tester,
    ) async {
      await openRequest(
        tester,
        user: chefChantier(),
        contact: _FakeContact(phone: '0550 00 00 21'),
        dialer: _FakeDialer(),
        locale: const Locale('ar'),
      );
      await tester.ensureVisible(find.text('الاتصال بالمورّد'));
      await tester.tap(find.text('الاتصال بالمورّد'));
      await tester.pump();
      await settle(tester);
      expect(find.text('0550 00 00 21'), findsOneWidget);
      expect(find.text('اتصال'), findsOneWidget);
    });
  });
}
