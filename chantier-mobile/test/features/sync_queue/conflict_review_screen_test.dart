import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/sync/backoff.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/conflict_review_screen.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fake_sync_remote.dart';
import '../../support/materials_harness.dart';
import '../../support/pump_app.dart';

class _MockMonitor extends Mock implements ConnectivityMonitor {}

/// Test de widget qui demonte l'ecran a la fin (minuteurs de Drift).
void screenTest(String name, Future<void> Function(WidgetTester tester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    });

const _user = 'user-equipe';

void main() {
  late MaterialsHarness h;
  late FakeSyncRemote remote;
  late SyncEngine engine;

  setUp(() {
    h = MaterialsHarness();
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
  });
  tearDown(() async {
    await engine.dispose();
    await h.dispose();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  final calls = <String>[];

  /// Cree une demande, l'envoie, la modifie hors ligne (300 -> 400), puis le serveur la valide
  /// (CA-MAT-010.2) : la saisie passe en conflit. Retourne la saisie en conflit.
  Future<OutboxRow> conflictOnQuantity() async {
    await h.seed();
    await h.materials.createRequest(
      clientId: 'c-1',
      siteId: harnessSite,
      userId: _user,
      requesterName: 'Nadir S.',
      draft: RequestDraft(
        productId: 'prod-ciment',
        quantity: Quantity(Decimal.parse('300'), MeasureUnit.bag),
        neededBy: DateTime.utc(2026, 11, 28),
      ),
      label: 'Ciment CPJ 42,5 · 300 sac',
    );
    await engine.run();
    final stored = (await h.db.materialRequestsDao.findByClientId(
      harnessSite,
      'c-1',
    ))!;
    await h.materials.editRequest(
      view: RequestView.plain(stored),
      draft: RequestDraft(
        productId: 'prod-ciment',
        quantity: Quantity(Decimal.parse('400'), MeasureUnit.bag),
        neededBy: DateTime.utc(2026, 11, 28),
      ),
      userId: _user,
      clientId: 'u-1',
      label: 'Ciment CPJ 42,5 · 400 sac',
    );
    remote.materials.setStatus(stored.id, 'Validated');
    await engine.run();
    return (await h.db.outboxDao.getByClientId('u-1'))!;
  }

  Future<void> open(
    WidgetTester tester,
    OutboxRow operation, {
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    calls.clear();
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: ConflictReviewScreen(
          userId: _user,
          operationId: operation.id,
          outbox: h.outbox,
          repository: h.materials,
          zones: h.zones.watchZones(harnessSite),
          onRedo: (request, draft, op) =>
              calls.add('redo ${draft.quantity.value}'),
          onCreateNew: (draft, op) => calls.add('new ${draft.quantity.value}'),
          onCorrectCreate: (draft, op) =>
              calls.add('correct ${draft.quantity.value}'),
        ),
      ),
    );
    await tester.pump();
    await settle(tester);
  }

  screenTest(
    'CA-MAT-010.2 : deux versions cote a cote, deux choix, motif traduit',
    (tester) async {
      final operation = (await tester.runAsync(conflictOnQuantity))!;
      expect(operation.status, OutboxStatus.conflict);
      await open(tester, operation);

      expect(find.text('À vérifier'), findsOneWidget);
      expect(find.text('Votre version'), findsOneWidget);
      expect(find.text('Version du serveur'), findsOneWidget);
      // Ma version : 400 sacs. Version du serveur : validee, 300 sacs (le serveur gagne).
      expect(findTextContaining('Quantité : 400 sac'), findsOneWidget);
      expect(findTextContaining('Quantité : 300 sac'), findsOneWidget);
      expect(find.text('Statut sur le serveur : Validée'), findsOneWidget);
      expect(
        findTextContaining('ne se modifient plus'),
        findsWidgets,
        reason: 'motif DEMANDE_VERROUILLEE traduit par code',
      );
      // Demande verrouillee : « Creer une nouvelle demande », pas « Refaire ».
      expect(
        find.text('Créer une nouvelle demande avec mes valeurs'),
        findsOneWidget,
      );
      expect(find.text('Refaire ma modification'), findsNothing);
      expect(find.text('Garder la version du serveur'), findsOneWidget);
    },
  );

  screenTest(
    '« Creer une nouvelle demande avec mes valeurs » ouvre le formulaire prerempli',
    (tester) async {
      final operation = (await tester.runAsync(conflictOnQuantity))!;
      await open(tester, operation);
      await tester.tap(
        find.text('Créer une nouvelle demande avec mes valeurs'),
      );
      await tester.pump();
      expect(calls, ['new 400']);
    },
  );

  screenTest(
    '« Garder la version du serveur » : confirmation, puis la saisie est abandonnee',
    (tester) async {
      final operation = (await tester.runAsync(conflictOnQuantity))!;
      await open(tester, operation);
      await tester.tap(find.text('Garder la version du serveur'));
      await tester.pumpAndSettle();
      expect(find.text('Garder la version du serveur ?'), findsOneWidget);

      // Renoncer : rien n'est supprime.
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(() => h.db.outboxDao.allFor(_user)),
        hasLength(1),
      );

      await tester.tap(find.text('Garder la version du serveur'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Garder la version du serveur'),
      );
      await tester.pumpAndSettle();
      await settle(tester);
      expect(
        await tester.runAsync(() => h.db.outboxDao.allFor(_user)),
        isEmpty,
      );
      // La demande garde la version du serveur : 300 sacs, validee.
      final local = await tester.runAsync(
        () => h.db.materialRequestsDao.getById('srv-c-1'),
      );
      expect(local!.status, 'Validated');
      expect(local.quantityValue.toString(), '300');
    },
  );

  screenTest(
    'CA-MAT-010.4 : meme champ change ailleurs : « Refaire ma modification », champ signale',
    (tester) async {
      final operation = (await tester.runAsync(() async {
        await h.seed();
        await h.materials.createRequest(
          clientId: 'c-2',
          siteId: harnessSite,
          userId: _user,
          requesterName: 'Nadir S.',
          draft: RequestDraft(
            productId: 'prod-ciment',
            quantity: Quantity(Decimal.parse('300'), MeasureUnit.bag),
            neededBy: DateTime.utc(2026, 11, 28),
          ),
          label: 'Ciment',
        );
        await engine.run();
        final stored = (await h.db.materialRequestsDao.findByClientId(
          harnessSite,
          'c-2',
        ))!;
        await h.materials.editRequest(
          view: RequestView.plain(stored),
          draft: RequestDraft(
            productId: 'prod-ciment',
            quantity: Quantity(Decimal.parse('300'), MeasureUnit.bag),
            neededBy: DateTime.utc(2026, 12, 10),
          ),
          userId: _user,
          clientId: 'u-2',
          label: 'Ciment',
        );
        remote.materials.changeElsewhere(stored.id, {'neededBy': '2026-12-01'});
        await engine.run();
        return (await h.db.outboxDao.getByClientId('u-2'))!;
      }))!;
      expect(operation.lastErrorCode, 'CONFLIT_VERSION');
      await open(tester, operation);

      expect(find.text('Champs en désaccord : Pour le'), findsOneWidget);
      expect(findTextContaining('Pour le : 10/12/2026'), findsOneWidget);
      expect(findTextContaining('Pour le : 01/12/2026'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsNWidgets(2));
      await tester.tap(find.text('Refaire ma modification'));
      await tester.pump();
      expect(calls, ['redo 300']);
    },
  );

  screenTest(
    'creation refusee : « Corriger ma saisie » preremplit le formulaire',
    (tester) async {
      final operation = (await tester.runAsync(() async {
        await h.seed();
        await h.materials.createRequest(
          clientId: 'c-3',
          siteId: harnessSite,
          userId: _user,
          requesterName: 'Nadir S.',
          draft: RequestDraft(
            productId: 'prod-ciment',
            quantity: Quantity(Decimal.parse('300'), MeasureUnit.bag),
            neededBy: DateTime.utc(2026, 11, 28),
          ),
          label: 'Ciment',
        );
        final op = (await h.db.outboxDao.getByClientId('c-3'))!;
        await h.db.outboxDao.markFailed(
          op.id,
          status: OutboxStatus.rejected,
          errorCode: 'ZONE_HORS_CHANTIER',
        );
        return (await h.db.outboxDao.getByClientId('c-3'))!;
      }))!;
      await open(tester, operation);
      expect(find.text('Corriger ma saisie'), findsOneWidget);
      expect(find.text('Version du serveur'), findsNothing);
      await tester.tap(find.text('Corriger ma saisie'));
      await tester.pump();
      expect(calls, ['correct 300']);
    },
  );

  screenTest('arabe : textes arabes, sens RTL', (tester) async {
    final operation = (await tester.runAsync(conflictOnQuantity))!;
    await open(tester, operation, locale: const Locale('ar'));
    expect(find.text('نسختك'), findsOneWidget);
    expect(find.text('نسخة الخادم'), findsOneWidget);
    expect(directionOf(tester, find.text('نسختك')), TextDirection.rtl);
    expect(find.text('الاحتفاظ بنسخة الخادم'), findsOneWidget);
  });

  screenTest('saisie deja traitee : message clair', (tester) async {
    final operation = (await tester.runAsync(conflictOnQuantity))!;
    await tester.runAsync(() => h.outbox.abandon(operation));
    await open(tester, operation);
    expect(find.text("Cette saisie n'est plus à vérifier."), findsOneWidget);
  });
}
