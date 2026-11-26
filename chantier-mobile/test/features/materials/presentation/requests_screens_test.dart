import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/presentation/approvals/approvals_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/request_detail_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/materials_harness.dart';
import '../../../support/pump_app.dart';

/// Test de widget qui, a la fin, demonte l'ecran et laisse partir les minuteurs de Drift.
void screenTest(String name, Future<void> Function(WidgetTester tester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    });

/// Bouton plein (y compris `FilledButton.icon`, dont le type exact est un sous-type) portant [text].
Finder filledButton(String text) => find.ancestor(
  of: find.text(text),
  matching: find.byWidgetPredicate((widget) => widget is FilledButton),
);

void main() {
  late MaterialsHarness h;

  setUp(() => h = MaterialsHarness());
  tearDown(() => h.dispose());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  void bigScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<List<OutboxRow>> queue(String userId) => h.db.outboxDao.allFor(userId);

  // ---------------------------------------------------------------------------------- liste

  Future<void> openList(
    WidgetTester tester, {
    required AuthUser user,
    Locale locale = const Locale('fr'),
    bool mineOnly = false,
    Future<void> Function()? seed,
  }) async {
    bigScreen(tester);
    await tester.runAsync(() async {
      await h.seed();
      await seed?.call();
    });
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: BlocProvider(
          create: (_) => RequestsCubit(
            repository: h.materials,
            siteId: harnessSite,
            userId: user.id,
            mineOnly: mineOnly,
          ),
          child: RequestsScreen(
            user: user,
            zones: h.zones.watchZones(harnessSite),
            onOpen: (_) {},
            onNew: user.can('Requests.Create') ? () {} : null,
            onOpenApprovals: user.can('Requests.Approve') ? () {} : null,
            now: () => DateTime.utc(2026, 11, 25, 9),
          ),
        ),
      ),
    );
    await tester.pump();
    await settle(tester);
  }

  Future<void> sampleRequests() async {
    await h.db.materialRequestsDao.upsertIfNewer(
      requestRow(
        id: 'r1',
        number: 'DEM-001',
        status: 'Requested',
        priority: 'Blocking',
        neededBy: DateTime.utc(2026, 11, 23),
        requestedById: 'user-equipe',
      ),
    );
    await h.db.materialRequestsDao.upsertIfNewer(
      requestRow(
        id: 'r2',
        number: 'DEM-002',
        status: 'Ordered',
        productId: 'prod-sable',
        productName: 'Sable 0/3',
        quantity: '24',
        unit: 'm3',
        requestedById: 'user-chef',
        neededBy: DateTime.utc(2026, 12, 2),
      ),
    );
    await h.db.materialRequestsDao.upsertIfNewer(
      requestRow(
        id: 'r3',
        number: 'DEM-003',
        status: 'Received',
        requestedById: 'user-chef',
      ),
    );
    await h.db.materialRequestsDao.upsertIfNewer(
      requestRow(
        id: 'r4',
        number: 'DEM-004',
        status: 'Cancelled',
        requestedById: 'user-equipe',
      ),
    );
  }

  group('liste des demandes (CA-MAT-002)', () {
    screenTest(
      'A suivre : bloquante d abord, quantite avec unite, retard, statut',
      (tester) async {
        await openList(tester, user: conducteur(), seed: sampleRequests);

        final numbers = [
          for (final text in tester.widgetList<Text>(
            find.byWidgetPredicate(
              (w) =>
                  w is Text && RegExp(r'^DEM-[0-9]+$').hasMatch(w.data ?? ''),
            ),
          ))
            text.data!,
        ];
        expect(numbers, ['DEM-001', 'DEM-002']);
        // Jamais une quantite sans unite.
        expect(findTextContaining('300 sac'), findsOneWidget);
        expect(findTextContaining('24 m³'), findsOneWidget);
        // En retard de 2 jours (besoin le 23/11, aujourd'hui le 25/11).
        expect(find.text('En retard de 2 j'), findsOneWidget);
        expect(find.text('Demandée'), findsOneWidget);
        expect(find.text('Commandée'), findsOneWidget);
        expect(find.text('Bloquante'), findsOneWidget);
        // Les demandes terminees ou annulees ne sont pas dans « A suivre ».
        expect(find.text('DEM-003'), findsNothing);
      },
    );

    screenTest('Terminees, Refusees et annulees', (tester) async {
      await openList(tester, user: conducteur(), seed: sampleRequests);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Terminées'));
      await tester.pump();
      expect(find.text('DEM-003'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Refusées et annulées'));
      await tester.pump();
      expect(find.text('DEM-004'), findsOneWidget);
      expect(find.text('Annulée'), findsOneWidget);
    });

    screenTest(
      'chef d equipe : « Mes demandes » par defaut, bouton + Nouvelle demande',
      (tester) async {
        await openList(
          tester,
          user: chefEquipe(),
          mineOnly: true,
          seed: sampleRequests,
        );
        expect(find.text('DEM-001'), findsOneWidget);
        expect(
          find.text('DEM-002'),
          findsNothing,
          reason: 'celle d un collegue',
        );
        expect(
          tester
              .widget<ChoiceChip>(
                find.widgetWithText(ChoiceChip, 'Mes demandes'),
              )
              .selected,
          isTrue,
        );
        expect(filledButton('Nouvelle demande'), findsOneWidget);
        // Pas de file « A valider » pour lui : le bouton est absent, pas grise.
        expect(find.text('À valider'), findsNothing);

        await tester.tap(find.widgetWithText(ChoiceChip, 'Mes demandes'));
        await tester.pump();
        expect(find.text('DEM-002'), findsOneWidget);
      },
    );

    screenTest('recherche par numero, materiau ou remarque', (tester) async {
      await openList(tester, user: conducteur(), seed: sampleRequests);
      await tester.enterText(find.byType(TextField), 'sable');
      await tester.pump();
      expect(find.text('DEM-002'), findsOneWidget);
      expect(find.text('DEM-001'), findsNothing);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(find.text('Aucune demande ici.'), findsOneWidget);
    });

    screenTest(
      'hors ligne : demande jamais envoyee = « Numero en attente » + « En attente d envoi »',
      (tester) async {
        await openList(
          tester,
          user: chefEquipe(),
          mineOnly: true,
          seed: () async {
            await h.materials.createRequest(
              clientId: 'c-1',
              siteId: harnessSite,
              userId: 'user-equipe',
              requesterName: 'Nadir S.',
              draft: RequestDraft(
                productId: 'prod-ciment',
                quantity: Quantity(Decimal.parse('300'), MeasureUnit.bag),
                neededBy: DateTime.utc(2026, 11, 28),
              ),
              label: 'Ciment',
            );
          },
        );
        expect(find.text('Numéro en attente'), findsOneWidget);
        expect(find.text("En attente d'envoi"), findsOneWidget);
      },
    );

    screenTest(
      'une annulation en attente : statut « A confirmer », classee dans les annulees',
      (tester) async {
        await openList(
          tester,
          user: chefEquipe(),
          mineOnly: true,
          seed: () async {
            await sampleRequests();
            final view = (await h.materials
                .watchRequest('r1', 'user-equipe')
                .first)!;
            await h.materials.cancel(
              view: view,
              userId: 'user-equipe',
              clientId: 't-1',
              label: 'x',
              reasonCode: 'EntryError',
            );
          },
        );
        expect(
          find.text('DEM-001'),
          findsNothing,
          reason: 'sortie de « A suivre »',
        );
        await tester.tap(
          find.widgetWithText(ChoiceChip, 'Refusées et annulées'),
        );
        await tester.pump();
        expect(find.text('DEM-001'), findsOneWidget);
        expect(find.text('À confirmer'), findsOneWidget);
      },
    );

    screenTest('arabe : textes, sens RTL, numero et quantite lisibles', (
      tester,
    ) async {
      await openList(
        tester,
        user: conducteur(),
        locale: const Locale('ar'),
        seed: sampleRequests,
      );
      expect(find.text('طلبات المواد'), findsOneWidget);
      expect(directionOf(tester, find.text('طلبات المواد')), TextDirection.rtl);
      // Numero de gauche a droite, chiffres 0-9.
      expect(directionOf(tester, find.text('DEM-001')), TextDirection.ltr);
      expect(findTextContaining('300 كيس'), findsOneWidget);
      expect(find.text('معطِّلة للورشة'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------------------- A valider

  Future<void> openApprovals(
    WidgetTester tester, {
    Locale locale = const Locale('fr'),
  }) async {
    bigScreen(tester);
    final user = conducteur();
    await tester.runAsync(() async {
      await h.seed();
      await h.db.materialRequestsDao.upsertIfNewer(
        requestRow(
          id: 'a1',
          number: 'DEM-010',
          status: 'Requested',
          quantity: '300',
          requestedById: 'user-chef',
        ),
      );
      await h.db.materialRequestsDao.upsertIfNewer(
        requestRow(id: 'a2', number: 'DEM-011', status: 'Validated'),
      );
    });
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: BlocProvider(
          create: (_) => RequestsCubit(
            repository: h.materials,
            siteId: harnessSite,
            userId: user.id,
            view: RequestListView.toApprove,
          ),
          child: ApprovalsScreen(
            user: user,
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

  group('A valider (CA-MAT-003)', () {
    screenTest('seules les demandes « Demandee » sont proposees', (
      tester,
    ) async {
      await openApprovals(tester);
      expect(find.text('DEM-010'), findsOneWidget);
      expect(find.text('DEM-011'), findsNothing);
    });

    screenTest(
      'Valider en 2 gestes : operation en file, « Validation en attente d envoi »',
      (tester) async {
        await openApprovals(tester);
        // Geste 1 : ouvrir l'ecran (deja fait) ; geste 2 : « Valider ».
        await tester.tap(filledButton('Valider'));
        await tester.pump();
        await settle(tester);

        final operation = (await tester.runAsync(
          () => queue('user-conducteur'),
        ))!.single;
        expect(operation.operation, 'transition');
        expect(operation.payload['action'], 'approve');
        expect(operation.payload['requestId'], 'a1');
        expect(operation.baseVersion, 500);
        expect(find.text("Validation en attente d'envoi"), findsOneWidget);
        expect(filledButton('Valider'), findsNothing);
        // La demande reste dans la file (le serveur n'a pas encore confirme).
        expect(find.text('DEM-010'), findsOneWidget);
        expect(find.text('À confirmer'), findsOneWidget);
      },
    );

    screenTest('Refuser : motif obligatoire, « Autre » exige une remarque', (
      tester,
    ) async {
      await openApprovals(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Refuser'));
      await tester.pumpAndSettle();

      // Sans motif : rien ne part.
      await tester.tap(filledButton('Refuser'));
      await tester.pump();
      expect(find.text('Choisissez un motif.'), findsOneWidget);

      // « Autre » sans remarque : refuse.
      await tester.tap(find.widgetWithText(ChoiceChip, 'Autre'));
      await tester.pump();
      await tester.tap(filledButton('Refuser'));
      await tester.pump();
      expect(find.text('Précisez le motif (Autre).'), findsOneWidget);
      expect(await tester.runAsync(() => queue('user-conducteur')), isEmpty);

      await tester.tap(
        find.widgetWithText(ChoiceChip, 'Stock suffisant sur le chantier'),
      );
      await tester.pump();
      await tester.tap(filledButton('Refuser'));
      await tester.pumpAndSettle();
      await settle(tester);

      final operation = (await tester.runAsync(
        () => queue('user-conducteur'),
      ))!.single;
      expect(operation.payload['action'], 'reject');
      expect(operation.payload['reasonCode'], 'StockSufficient');
    });

    screenTest('Valider avec une autre quantite : meme unite, quantite > 0', (
      tester,
    ) async {
      await openApprovals(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Autre quantité'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '0');
      await tester.tap(find.text('Valider cette quantité'));
      await tester.pump();
      expect(
        find.text('La quantité doit être supérieure à zéro.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).last, '2,5');
      await tester.tap(find.text('Valider cette quantité'));
      await tester.pump();
      expect(find.text('Nombre entier requis.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, '200');
      await tester.tap(find.text('Valider cette quantité'));
      await tester.pumpAndSettle();
      await settle(tester);

      final operation = (await tester.runAsync(
        () => queue('user-conducteur'),
      ))!.single;
      expect(operation.payload['quantity'], {'value': 200, 'unit': 'sac'});
    });

    screenTest('arabe : boutons de 56 dp, textes arabes', (tester) async {
      await openApprovals(tester, locale: const Locale('ar'));
      expect(find.text('للمصادقة'), findsOneWidget);
      final button = filledButton('مصادقة');
      expect(button, findsOneWidget);
      expect(tester.getSize(button).height, greaterThanOrEqualTo(56));
    });
  });

  // ---------------------------------------------------------------------------- detail

  Future<void> openDetail(
    WidgetTester tester, {
    required AuthUser user,
    required String requestId,
    Locale locale = const Locale('fr'),
    Future<void> Function()? seed,
    void Function(RequestEditCall call)? onEdit,
  }) async {
    bigScreen(tester);
    await tester.runAsync(() async {
      await h.seed();
      await seed?.call();
    });
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: BlocProvider(
          create: (_) => RequestDetailCubit(
            repository: h.materials,
            requestId: requestId,
            userId: user.id,
          ),
          child: RequestDetailScreen(
            user: user,
            repository: h.materials,
            zones: h.zones.watchZones(harnessSite),
            onEdit: (view) => onEdit?.call(RequestEditCall(view.id)),
            onReview: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await settle(tester);
  }

  const history =
      '[{"id":"e1","type":"Created","occurredAt":"2026-11-25T07:00:00Z","actorName":"Mourad B.","source":"Api"},'
      '{"id":"e2","type":"QuantityAdjusted","occurredAt":"2026-11-25T08:30:00Z","actorName":"Karim A.","changes":[{"field":"quantity","old":"300 sac","new":"200 sac"}]},'
      '{"id":"e3","type":"Approved","occurredAt":"2026-11-25T08:31:00Z","fromStatus":"Requested","toStatus":"Validated","actorName":"Karim A."}]';

  group('detail d une demande (CA-MAT-002, 004)', () {
    screenTest(
      'informations, historique (qui, quand, ancien -> nouveau), pas de prix',
      (tester) async {
        await openDetail(
          tester,
          user: conducteur(),
          requestId: 'd1',
          seed: () => h.db.materialRequestsDao.upsertIfNewer(
            requestRow(
              id: 'd1',
              number: 'DEM-020',
              status: 'Validated',
              zoneId: 'zone-1',
              historyJson: history,
              orderJson:
                  '{"id":"o1","supplierName":"Sigma","commercial":{"unitPrice":780}}',
            ),
          ),
        );
        expect(find.text('DEM-020'), findsWidgets);
        expect(find.text('Validée'), findsWidgets);
        expect(find.text('Historique'), findsOneWidget);
        expect(find.text('Demande créée'), findsOneWidget);
        expect(find.text('Quantité ajustée'), findsOneWidget);
        expect(
          findTextContaining('Quantité : 300 sac → 200 sac'),
          findsOneWidget,
        );
        expect(findTextContaining('Demandée → Validée'), findsOneWidget);
        expect(find.textContaining('780'), findsNothing);
        // La commande montre son fournisseur (jamais un prix, ADR 0012).
        expect(find.textContaining('Sigma'), findsOneWidget);
      },
    );

    screenTest(
      'chef d equipe : corrige et annule la sienne, rien sur celle d un collegue',
      (tester) async {
        await openDetail(
          tester,
          user: chefEquipe(),
          requestId: 'own',
          seed: () async {
            await h.db.materialRequestsDao.upsertIfNewer(
              requestRow(id: 'own', requestedById: 'user-equipe'),
            );
          },
        );
        expect(find.text('Corriger'), findsOneWidget);
        expect(find.text('Annuler la demande'), findsOneWidget);
      },
    );

    screenTest('celle d un collegue : aucune action (absentes, pas grisees)', (
      tester,
    ) async {
      await openDetail(
        tester,
        user: chefEquipe(),
        requestId: 'other',
        seed: () => h.db.materialRequestsDao.upsertIfNewer(
          requestRow(id: 'other', requestedById: 'user-chef'),
        ),
      );
      expect(find.text('Corriger'), findsNothing);
      expect(find.text('Annuler la demande'), findsNothing);
    });

    screenTest(
      'annuler : motif obligatoire, operation en file, statut « A confirmer »',
      (tester) async {
        await openDetail(
          tester,
          user: chefEquipe(),
          requestId: 'own',
          seed: () => h.db.materialRequestsDao.upsertIfNewer(
            requestRow(id: 'own', requestedById: 'user-equipe'),
          ),
        );
        await tester.tap(find.text('Annuler la demande'));
        await tester.pumpAndSettle();
        // Sans motif : refuse.
        await tester.tap(filledButton('Annuler la demande'));
        await tester.pump();
        expect(find.text('Choisissez un motif.'), findsOneWidget);

        await tester.tap(find.widgetWithText(ChoiceChip, 'Erreur de saisie'));
        await tester.pump();
        await tester.tap(filledButton('Annuler la demande'));
        await tester.pumpAndSettle();
        await settle(tester);

        final operation = (await tester.runAsync(
          () => queue('user-equipe'),
        ))!.single;
        expect(operation.payload['action'], 'cancel');
        expect(operation.payload['reasonCode'], 'EntryError');
        expect(find.text('Annulée'), findsWidgets);
        expect(find.text('À confirmer'), findsOneWidget);
        // Plus d'action possible sur une demande dont l'annulation est en cours.
        expect(find.text('Annuler la demande'), findsNothing);
      },
    );

    screenTest(
      'saisie en conflit : bouton « Voir » vers « A verifier », pas de correction',
      (tester) async {
        await openDetail(
          tester,
          user: chefEquipe(),
          requestId: 'own',
          seed: () async {
            await h.db.materialRequestsDao.upsertIfNewer(
              requestRow(id: 'own', requestedById: 'user-equipe'),
            );
            await h.db.outboxDao.enqueue(
              OutboxOperationsCompanion.insert(
                clientId: 'u-1',
                ownerUserId: 'user-equipe',
                entity: 'request',
                operation: 'update',
                label: 'x',
                payloadJson:
                    '{"requestId":"own","changes":{"note":"x"},"base":{"note":null}}',
                createdAt: DateTime.utc(2026, 11, 25),
              ),
            );
            final op = (await h.db.outboxDao.getByClientId('u-1'))!;
            await h.db.outboxDao.markFailed(
              op.id,
              status: OutboxStatus.conflict,
              errorCode: 'CONFLIT_VERSION',
            );
          },
        );
        expect(filledButton('Voir'), findsOneWidget);
        expect(find.text('À vérifier'), findsOneWidget);
        expect(find.text('Corriger'), findsNothing);
      },
    );

    screenTest('demande introuvable : message clair', (tester) async {
      await openDetail(tester, user: chefEquipe(), requestId: 'absente');
      expect(
        find.text("Cette demande n'est plus sur ce téléphone."),
        findsOneWidget,
      );
    });

    screenTest('arabe : historique et statut traduits', (tester) async {
      await openDetail(
        tester,
        user: conducteur(),
        requestId: 'd2',
        locale: const Locale('ar'),
        seed: () => h.db.materialRequestsDao.upsertIfNewer(
          requestRow(id: 'd2', status: 'Validated', historyJson: history),
        ),
      );
      expect(find.text('السجل'), findsOneWidget);
      expect(find.text('تم إنشاء الطلب'), findsOneWidget);
      expect(directionOf(tester, find.text('السجل')), TextDirection.rtl);
    });
  });
}

/// Appel de correction recu par le test.
class RequestEditCall {
  const RequestEditCall(this.requestId);

  final String requestId;
}
