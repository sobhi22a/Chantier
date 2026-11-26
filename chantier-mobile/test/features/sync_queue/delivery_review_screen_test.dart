import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/delivery_review_screen.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/pending_operations_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/api_json.dart';
import '../../support/fixtures.dart';
import '../../support/fake_sync_remote.dart';
import '../../support/materials_harness.dart';
import '../../support/photo_support.dart';
import '../../support/pump_app.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

void screenTest(String name, Future<void> Function(WidgetTester tester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    });

const _user = 'user-chef';
const _site = 'site-uv18';

/// Ids du faux serveur (`requestJson` / `FakeDeliveriesServer`).
const _requestId = 'req-009';

void main() {
  late MaterialsHarness h;
  late FakeSyncRemote remote;
  late SyncEngine engine;
  late PhotoTestBed bed;
  final calls = <String>[];

  setUp(() {
    h = MaterialsHarness();
    bed = PhotoTestBed();
    remote = FakeSyncRemote();
    final monitor = _MockMonitor();
    when(() => monitor.hasNetworkInterface()).thenAnswer((_) async => true);
    engine = SyncEngine(
      database: h.db,
      remote: remote,
      sites: SitesRepository(h.db),
      materials: h.materials,
      currentUserId: () => _user,
      connectivity: monitor,
      backoff: Backoff(),
      now: () => h.clock,
    );
    calls.clear();
  });
  tearDown(() async {
    await engine.dispose();
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

  Future<void> recordDelivery(
    String clientId, {
    required String quantity,
    required MeasureUnit unit,
    List<CapturedPhoto> photos = const [],
  }) => h.deliveries.record(
    clientId: clientId,
    siteId: _site,
    userId: _user,
    recorderName: 'Mourad B.',
    draft: DeliveryDraft(
      request: const RequestRef.server(_requestId),
      supplierId: 'sup-sigma',
      quantity: Quantity(Decimal.parse(quantity), unit),
      deliveryDate: DateTime.utc(2026, 11, 25),
      deliveryNoteNumber: 'BL-4471',
    ),
    label: 'LIV Ciment',
    photoLabel: 'Photo',
    maxPhotos: 5,
    request: null,
    photos: photos,
  );

  /// Commande de 600 sacs, une livraison de 10 T deja envoyee et confirmee (LIV-001).
  Future<DeliveryRow> confirmedDelivery({String status = 'Ordered'}) async {
    await h.seed();
    await h.db.suppliersDao.upsertIfNewer(supplierRow());
    remote.materials.requests[_requestId] = requestJson(
      id: _requestId,
      siteId: _site,
      status: status,
      quantity: 600,
      version: '51000',
    );
    await h.db.materialRequestsDao.upsertIfNewer(
      requestRow(
        id: _requestId,
        siteId: _site,
        status: status,
        quantity: '600',
        requestedById: _user,
      ),
    );
    await recordDelivery('liv-1', quantity: '10', unit: MeasureUnit.tonne);
    await engine.run();
    return (await h.db.deliveriesDao.findByClientId(_site, 'liv-1'))!;
  }

  Future<void> correct(
    DeliveryRow row, {
    required String quantity,
    required String clientId,
  }) => h.deliveries.edit(
    view: DeliveryView.plain(row),
    draft: DeliveryEditDraft(
      quantity: Quantity(Decimal.parse(quantity), MeasureUnit.tonne),
      deliveryDate: row.deliveryDate,
      deliveryNoteNumber: row.deliveryNoteNumber,
    ),
    userId: _user,
    clientId: clientId,
    label: 'LIV-001 · ${row.quantityValue} t',
  );

  Future<void> open(
    WidgetTester tester,
    OutboxRow operation, {
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: DeliveryReviewScreen(
          userId: _user,
          operationId: operation.id,
          outbox: h.outbox,
          deliveries: h.deliveries,
          onRedo: (delivery, draft, op) =>
              calls.add('redo ${draft.quantity.value}'),
          onCorrectCreate: (draft, op) =>
              calls.add('correct ${draft.quantity.value}'),
        ),
      ),
    );
    await tester.pump();
    await settle(tester);
  }

  screenTest(
    'livraison annulee entre-temps : deux versions, un seul choix (le serveur gagne)',
    (tester) async {
      final operation = (await tester.runAsync(() async {
        final row = await confirmedDelivery();
        await correct(row, quantity: '8', clientId: 'u-1');
        remote.deliveries.cancelElsewhere(row.id);
        await engine.run();
        return (await h.db.outboxDao.getByClientId('u-1'))!;
      }))!;
      expect(operation.status, OutboxStatus.conflict);
      await open(tester, operation);

      expect(
        find.text('Cette livraison a été annulée entre-temps.'),
        findsOneWidget,
      );
      expect(find.text('Votre version'), findsOneWidget);
      expect(find.text('Version du serveur'), findsOneWidget);
      expect(findTextContaining('Quantité : 8 T'), findsOneWidget);
      expect(
        findTextContaining('Statut de la livraison sur le serveur : Annulée'),
        findsOneWidget,
      );
      // Rien a refaire : seule la version du serveur peut etre gardee.
      expect(find.text('Refaire ma modification'), findsNothing);

      // Rien n'est supprime sans choix : confirmation d'abord.
      await tester.tap(find.text('Garder la version du serveur'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(
        await tester.runAsync(() => h.db.outboxDao.getByClientId('u-1')),
        isNotNull,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Garder la version du serveur'),
        ),
      );
      await tester.pump();
      await settle(tester);
      expect(
        await tester.runAsync(() => h.db.outboxDao.getByClientId('u-1')),
        isNull,
      );
    },
  );

  screenTest(
    'meme champ corrige des deux cotes : « Refaire ma modification » (CA-MAT-012.5)',
    (tester) async {
      final operation = (await tester.runAsync(() async {
        final row = await confirmedDelivery();
        await correct(row, quantity: '8', clientId: 'u-1');
        remote.deliveries.changeElsewhere(row.id, {
          'quantity': {'value': 9, 'unit': 't'},
        });
        await engine.run();
        return (await h.db.outboxDao.getByClientId('u-1'))!;
      }))!;
      await open(tester, operation);

      expect(
        findTextContaining('Champs en désaccord : Quantité'),
        findsOneWidget,
      );
      expect(findTextContaining('Quantité : 8 T'), findsOneWidget);
      expect(findTextContaining('Quantité : 9 T'), findsOneWidget);
      await tester.tap(find.text('Refaire ma modification'));
      expect(calls, ['redo 8']);
    },
  );

  screenTest('demande receptionnee : message clair, rien n est applique', (
    tester,
  ) async {
    final operation = (await tester.runAsync(() async {
      final row = await confirmedDelivery();
      await correct(row, quantity: '8', clientId: 'u-1');
      remote.materials.setStatus(_requestId, 'Received');
      await engine.run();
      return (await h.db.outboxDao.getByClientId('u-1'))!;
    }))!;
    expect(operation.lastErrorCode, 'DEMANDE_NON_OUVERTE');
    await open(tester, operation);
    expect(
      findTextContaining('La demande est déjà réceptionnée'),
      findsOneWidget,
    );
    expect(find.text('Refaire ma modification'), findsNothing);
  });

  screenTest('creation refusee (unites incompatibles) : « Corriger ma saisie »', (
    tester,
  ) async {
    final operation = (await tester.runAsync(() async {
      await h.seed();
      remote.materials.requests[_requestId] = requestJson(
        id: _requestId,
        siteId: _site,
        status: 'Ordered',
        quantity: 24,
        unit: 'm3',
        version: '51000',
      );
      await h.db.materialRequestsDao.upsertIfNewer(
        requestRow(
          id: _requestId,
          siteId: _site,
          status: 'Ordered',
          quantity: '24',
          unit: 'm3',
          requestedById: _user,
        ),
      );
      await recordDelivery('liv-x', quantity: '10', unit: MeasureUnit.tonne);
      await engine.run();
      return (await h.db.outboxDao.getByClientId('liv-x'))!;
    }))!;
    expect(operation.status, OutboxStatus.rejected);
    await open(tester, operation);
    expect(findTextContaining('Quantité : 10 T'), findsOneWidget);
    await tester.tap(find.text('Corriger ma saisie'));
    expect(calls, ['correct 10']);
    // Abandonner : confirmation, puis la ligne locale disparait avec la saisie.
    await tester.tap(find.text('Abandonner'));
    await tester.pumpWidget(const SizedBox());
  });

  screenTest(
    'photo refusee : motif, « Abandonner » supprime ligne et fichier',
    (tester) async {
      final operation = (await tester.runAsync(() async {
        await confirmedDelivery();
        remote.deliveries.maxPhotos = 0;
        final photo = await bed.capture(owner: _user, clientId: 'ph-1');
        await h.deliveries.addPhotos(
          view: DeliveryView.plain(
            (await h.db.deliveriesDao.findByClientId(_site, 'liv-1'))!,
          ),
          userId: _user,
          photos: [photo],
          photoLabel: 'Photo du bon',
          maxPhotos: 5,
        );
        await engine.run();
        return (await h.db.outboxDao.getByClientId('ph-1'))!;
      }))!;
      expect(operation.status, OutboxStatus.rejected);
      expect(operation.lastErrorCode, 'PHOTOS_TROP_NOMBREUSES');
      await open(tester, operation);
      expect(findTextContaining('Photo du bon prise le'), findsOneWidget);
      expect(find.text('Refaire ma modification'), findsNothing);
      expect(find.text('Corriger ma saisie'), findsNothing);

      await tester.tap(find.text('Abandonner'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Abandonner'),
        ),
      );
      await tester.pump();
      await settle(tester);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      expect(
        await tester.runAsync(() => h.db.outboxDao.getByClientId('ph-1')),
        isNull,
      );
      expect(
        await tester.runAsync(() => h.db.deliveryPhotosDao.getFile('ph-1')),
        isNull,
      );
      expect(
        await tester.runAsync(
          () => h.db.deliveryPhotosDao.findByClientId(_site, 'ph-1'),
        ),
        isNull,
      );
    },
  );

  screenTest('arabe : deux versions, textes arabes', (tester) async {
    final operation = (await tester.runAsync(() async {
      final row = await confirmedDelivery();
      await correct(row, quantity: '8', clientId: 'u-1');
      remote.deliveries.changeElsewhere(row.id, {
        'quantity': {'value': 9, 'unit': 't'},
      });
      await engine.run();
      return (await h.db.outboxDao.getByClientId('u-1'))!;
    }))!;
    await open(tester, operation, locale: const Locale('ar'));
    expect(find.text('نسختك'), findsOneWidget);
    expect(find.text('نسخة الخادم'), findsOneWidget);
    expect(find.text('Refaire ma modification'), findsNothing);
  });

  // ------------------------------------------------------- Envois en attente (photos)

  group('Envois en attente : photos', () {
    Future<void> openPending(
      WidgetTester tester, {
      void Function(PendingPhotoFileRow file)? onAbandon,
    }) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        await h.seed();
        await h.db.deliveryPhotosDao.enqueueFile(
          pendingPhotoFile(clientId: 'f1', owner: _user),
        );
        await h.db.deliveryPhotosDao.enqueueFile(
          pendingPhotoFile(clientId: 'f2', owner: _user),
        );
        await h.db.deliveryPhotosDao.enqueueFile(
          pendingPhotoFile(clientId: 'f3', owner: _user),
        );
        await h.db.deliveryPhotosDao.markFileAttempt(
          'f3',
          errorCode: 'TYPE_FICHIER_REFUSE',
        );
        await h.db.deliveryPhotosDao.enqueueFile(
          pendingPhotoFile(clientId: 'autre', owner: 'user-autre'),
        );
      });
      await tester.pumpWidget(
        testApp(
          home: PendingOperationsScreen(
            userId: _user,
            outbox: h.outbox,
            onCorrect: (_) {},
            pendingFiles: h.deliveries.watchPendingFiles(_user),
            onAbandonFile: (file) async => onAbandon?.call(file),
          ),
          wrap: (app) => BlocProvider<SyncStatusCubit>.value(
            value: fakeSyncStatus(
              const SyncStatusSnapshot(indicator: SyncIndicator.pending),
            ),
            child: app,
          ),
        ),
      );
      await tester.pump();
      await settle(tester);
    }

    screenTest(
      '« Photo en attente d envoi (2) » : seulement les fichiers du compte',
      (tester) async {
        await openPending(tester);
        expect(find.text("Photo en attente d'envoi (2)"), findsOneWidget);
      },
    );

    screenTest('fichier refuse : signale, jamais supprime sans decision', (
      tester,
    ) async {
      PendingPhotoFileRow? abandoned;
      await openPending(tester, onAbandon: (file) => abandoned = file);
      expect(find.text('Photo refusée par le serveur'), findsOneWidget);
      await tester.tap(find.text('Abandonner la photo'));
      await tester.pump();
      expect(abandoned?.clientId, 'f3');
      // Le fichier est toujours la : c'est l'ecran appelant qui confirme puis supprime.
      expect(
        await tester.runAsync(() => h.db.deliveryPhotosDao.getFile('f3')),
        isNotNull,
      );
    });
  });
}
