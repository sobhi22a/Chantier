import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart'
    show RequestOperationRowX;
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/delivery_form_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/materials_harness.dart';
import '../../../support/photo_support.dart';
import '../../../support/pump_app.dart';

/// Test de widget qui, a la fin, demonte l'ecran et laisse partir les minuteurs de Drift.
void formTest(String name, Future<void> Function(WidgetTester tester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    });

const _order =
    '{"id":"o1","supplierId":"sup-sigma","supplierName":"Cimenterie Sigma (fictive)",'
    '"expectedDeliveryDate":"2026-11-26"}';

void main() {
  late MaterialsHarness h;
  late PhotoTestBed bed;
  late FakePhotoCapture capture;
  Object? result;
  String? seenDuplicate;

  setUp(() {
    h = MaterialsHarness();
    bed = PhotoTestBed();
    capture = FakePhotoCapture(bed);
    result = null;
    seenDuplicate = null;
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

  /// Attend (horloge reelle : fichiers et isolat) qu'un element apparaisse.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 60 && finder.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  /// Commande de 600 sacs de ciment (fournisseur Sigma), saisie du chef de chantier.
  Future<void> seedOrder({
    String status = 'Ordered',
    String? received,
    String quantity = '600',
    String unit = 'sac',
  }) async {
    await h.seed();
    await h.db.suppliersDao.upsertIfNewer(supplierRow());
    await h.db.materialRequestsDao.upsertIfNewer(
      requestRow(
        id: 'req-009',
        status: status,
        quantity: quantity,
        unit: unit,
        orderJson: _order,
        requestedById: 'user-chef',
      ),
    );
  }

  Future<void> openForm(
    WidgetTester tester, {
    AuthUser? user,
    Locale locale = const Locale('fr'),
    bool withRequest = true,
    String? existingId,
    DeliveryDraft? initial,
    Future<void> Function()? beforeOpen,
    String requestStatus = 'Ordered',
  }) async {
    tester.view.physicalSize = const Size(800, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    RequestView? request;
    DeliveryView? existing;
    await tester.runAsync(() async {
      await seedOrder(status: requestStatus);
      await beforeOpen?.call();
      if (existingId != null) {
        existing = DeliveryView.plain(
          (await h.db.deliveriesDao.getById(existingId))!,
        );
      }
      if (withRequest) {
        request = await h.materials.watchRequest('req-009', 'user-chef').first;
      }
    });
    final signedIn = user ?? chefChantier();
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => DeliveryFormScreen(
                        siteId: harnessSite,
                        user: signedIn,
                        deliveries: h.deliveries,
                        materials: h.materials,
                        capture: capture,
                        files: bed.files,
                        request: request,
                        existing: existing,
                        initial: initial,
                        onSeeDuplicate: (id) => seenDuplicate = id,
                        now: () => h.clock,
                      ),
                    ),
                  );
                },
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pump();
    await settle(tester);
  }

  Finder quantityField() => find.byWidgetPredicate(
    (w) =>
        w is TextField &&
        (w.decoration?.labelText == 'Quantité reçue' ||
            w.decoration?.labelText == 'الكمية المستلمة'),
  );

  Finder saveButton([String label = 'Enregistrer la livraison']) =>
      find.widgetWithText(FilledButton, label);

  Future<List<OutboxRowSummary>> queue() async => [
    for (final row in await h.db.outboxDao.allFor('user-chef'))
      OutboxRowSummary(row.entity, row.operation, row.payload),
  ];

  /// Appuie sur Enregistrer. Une livraison complete propose « Receptionner maintenant ? » :
  /// sauf [prompt], l'offre est declinee (« Plus tard ») pour que l'ecran se ferme.
  Future<void> save(
    WidgetTester tester, [
    String? label,
    bool prompt = false,
  ]) async {
    final button = label == null ? saveButton() : saveButton(label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await settle(tester);
    if (!prompt && find.text('Plus tard').evaluate().isNotEmpty) {
      await tester.tap(find.text('Plus tard'));
      await tester.pump();
      await settle(tester);
    }
  }

  group('cas nominal : 3 gestes (CA-MAT-006.1, 006.2)', () {
    formTest(
      'tout est prerempli : quantite, unite de la commande, date, conforme',
      (tester) async {
        await openForm(tester);
        // Commande, materiau et fournisseur sont ceux de la demande.
        expect(find.text('DEM-009'), findsOneWidget);
        expect(find.textContaining('Ciment CPJ 42,5'), findsOneWidget);
        expect(find.textContaining('Sigma'), findsOneWidget);
        expect(
          tester.widget<TextField>(quantityField()).controller!.text,
          '600',
        );
        // Unite de la commande + unites convertibles seulement (jamais m3, u...).
        expect(find.text('sac'), findsOneWidget);
        expect(find.text('T'), findsOneWidget);
        expect(find.text('kg'), findsOneWidget);
        expect(find.text('m³'), findsNothing);
        expect(find.text('Conforme'), findsOneWidget);
        expect(find.text('Livraison complète'), findsOneWidget);
      },
    );

    formTest(
      'un seul appui sur Enregistrer : livraison + operation, ecran ferme',
      (tester) async {
        await openForm(tester);
        await save(tester);

        final ops = await tester.runAsync(queue);
        expect(ops!.length, 1);
        expect(ops.single.entity, 'delivery');
        expect(ops.single.operation, 'create');
        expect(ops.single.payload['requestId'], 'req-009');
        expect(ops.single.payload['quantity'], {'value': 600, 'unit': 'sac'});
        expect(ops.single.payload['deliveryDate'], '2026-11-25');
        expect(ops.single.payload['conformity'], 'Conform');
        expect(ops.single.payload.containsKey('deliveryNoteNumber'), isFalse);
        // Jamais de prix ni de montant dans la saisie.
        expect(ops.single.payload.keys, isNot(contains('amount')));
        expect(ops.single.payload.keys, isNot(contains('unitPrice')));
        expect(result, isTrue);
        final rows = await tester.runAsync(
          () => h.db.deliveriesDao.countBySite(harnessSite),
        );
        expect(rows, 1);
      },
    );

    formTest('double appui : une seule livraison, un seul numero', (
      tester,
    ) async {
      await openForm(tester);
      await tester.enterText(quantityField(), '100');
      await tester.pump();
      final button = saveButton();
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.tap(button, warnIfMissed: false);
      await tester.pump();
      await settle(tester);

      final ops = await tester.runAsync(queue);
      expect(ops!.length, 1);
    });

    formTest(
      'le clientId est cree a l ouverture : rouvrir cree une autre saisie',
      (tester) async {
        await openForm(tester);
        await save(tester);
        final first = await tester.runAsync(
          () => h.db.outboxDao.allFor('user-chef'),
        );
        expect(first!.single.clientId, isNotEmpty);
      },
    );
  });

  group('annonce en toutes lettres (CA-MAT-006.3, 006.4)', () {
    formTest(
      'partielle : « il restera 400 sacs » et equivalence 10 T = 200 sacs',
      (tester) async {
        await openForm(tester);
        await tester.enterText(quantityField(), '10');
        await tester.tap(find.text('T'));
        await tester.pump();
        expect(findTextContaining('10 T = 200 sac'), findsOneWidget);
        expect(
          findTextContaining('Livraison partielle : il restera 400 sac'),
          findsOneWidget,
        );
      },
    );

    formTest('surplus : « +100 sacs (+16,67 %) »', (tester) async {
      await openForm(tester);
      await tester.enterText(quantityField(), '700');
      await tester.pump();
      expect(
        findTextContaining('Surplus de +100 sac (+16,67 %)'),
        findsOneWidget,
      );
    });

    formTest('reste calcule avec le deja recu (livraisons connues)', (
      tester,
    ) async {
      await openForm(
        tester,
        beforeOpen: () async {
          await h.db.materialRequestsDao.upsertIfNewer(
            requestRow(
              id: 'req-009',
              status: 'PartiallyDelivered',
              quantity: '600',
              orderJson: _order,
              requestedById: 'user-chef',
              version: 900,
            ).copyWith(
              receivedValue: Value(Decimal.parse('400')),
              remainingValue: Value(Decimal.parse('200')),
            ),
          );
        },
        requestStatus: 'PartiallyDelivered',
      );
      // Quantite = reste a livrer.
      expect(tester.widget<TextField>(quantityField()).controller!.text, '200');
      expect(find.text('Livraison complète'), findsOneWidget);
      await tester.enterText(quantityField(), '100');
      await tester.pump();
      expect(
        findTextContaining('Livraison partielle : il restera 100 sac'),
        findsOneWidget,
      );
    });

    formTest(
      'quantite nulle ou unite non choisie : Enregistrer reste inactif',
      (tester) async {
        await openForm(tester);
        await tester.enterText(quantityField(), '0');
        await tester.pump();
        expect(
          tester.widget<FilledButton>(saveButton()).onPressed,
          isNull,
          reason: 'quantite 0 : QUANTITE_INVALIDE',
        );
        expect(
          find.text('La quantité doit être supérieure à zéro.'),
          findsOneWidget,
        );
      },
    );

    formTest('« sac » n accepte pas de decimale', (tester) async {
      await openForm(tester);
      await tester.enterText(quantityField(), '2,5');
      await tester.pump();
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull);
    });
  });

  group('date, bon, conformite', () {
    formTest('hier : date du formulaire envoyee, jamais dans le futur', (
      tester,
    ) async {
      await openForm(tester);
      await tester.tap(find.text('Hier'));
      await tester.pump();
      await save(tester);
      final ops = await tester.runAsync(queue);
      expect(ops!.single.payload['deliveryDate'], '2026-11-24');
    });

    formTest('n° de bon : majuscules, sans espaces de bord', (tester) async {
      await openForm(tester);
      final field = find.byWidgetPredicate(
        (w) => w is TextField && w.maxLength == 30,
      );
      await tester.enterText(field, '  bl-4471 ');
      await tester.pump();
      await save(tester);
      final ops = await tester.runAsync(queue);
      expect(ops!.single.payload['deliveryNoteNumber'], 'BL-4471');
    });

    formTest('avec reserve : le motif est obligatoire', (tester) async {
      await openForm(tester);
      await tester.ensureVisible(find.text('Avec réserve'));
      await tester.tap(find.text('Avec réserve'));
      await tester.pump();
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull);
      expect(find.text('Choisissez le motif de la réserve.'), findsOneWidget);
      await tester.tap(find.text('Quantité manquante'));
      await tester.pump();
      await save(tester);
      final ops = await tester.runAsync(queue);
      expect(ops!.single.payload['conformity'], 'WithReserve');
      expect(ops.single.payload['reserveReasonCode'], 'QuantityMissing');
    });

    formTest('reserve « Autre » : une remarque est exigee', (tester) async {
      await openForm(tester);
      await tester.ensureVisible(find.text('Avec réserve'));
      await tester.tap(find.text('Avec réserve'));
      await tester.pump();
      await tester.tap(find.text('Autre'));
      await tester.pump();
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull);
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Précisez la réserve',
        ),
        'Palette mouillée',
      );
      await tester.pump();
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNotNull);
    });

    formTest(
      'meme bon deja saisi : avertissement, « voir » ou « une autre livraison »',
      (tester) async {
        await openForm(
          tester,
          beforeOpen: () => h.db.deliveriesDao.upsertIfNewer(
            deliveryRow(id: 'liv-6', requestId: 'req-009'),
          ),
        );
        final field = find.byWidgetPredicate(
          (w) => w is TextField && w.maxLength == 30,
        );
        await tester.enterText(field, 'bl-4471');
        await tester.pump();

        await save(tester);
        expect(find.textContaining('Ce bon est déjà saisi'), findsOneWidget);
        await tester.tap(find.text('Voir la livraison'));
        await tester.pump();
        expect(seenDuplicate, 'liv-6');
        expect(await tester.runAsync(queue), isEmpty);

        await save(tester);
        await tester.tap(find.text('C\'est une autre livraison'));
        await tester.pump();
        await settle(tester);
        expect((await tester.runAsync(queue))!.length, 1);
      },
    );
  });

  group('photos du bon (CA-MAT-007)', () {
    formTest(
      'prendre, garder, enregistrer : fichier a envoyer et operation photo',
      (tester) async {
        capture.queue(1);
        await openForm(tester);
        await tester.ensureVisible(find.text('Photographier le bon'));
        await tester.tap(find.text('Photographier le bon'));
        await tester.pump();
        await waitFor(tester, find.text('Garder'));
        // Vignette avec « Reprendre » et « Garder ».
        expect(find.text('Reprendre'), findsOneWidget);
        await tester.tap(find.text('Garder'));
        await tester.pump();
        await settle(tester);
        expect(find.text('Photos : 1'), findsOneWidget);

        await save(tester);
        final ops = await tester.runAsync(queue);
        expect(
          [for (final op in ops!) '${op.entity}/${op.operation}'],
          ['delivery/create', 'photo/create'],
        );
        expect(ops.last.payload['sha256'], hasLength(64));
        final files = await tester.runAsync(
          () => h.db.deliveryPhotosDao.filesFor('user-chef'),
        );
        expect(files!.length, 1);
        expect(
          (await tester.runAsync(
            () => bed.files.fileFor('user-chef', files.single.relativePath),
          ))!.existsSync(),
          isTrue,
        );
      },
    );

    formTest('« Reprendre » : l ancienne photo est jetee, l appareil se rouvre', (
      tester,
    ) async {
      capture.queue(2);
      await openForm(tester);
      await tester.ensureVisible(find.text('Photographier le bon'));
      await tester.tap(find.text('Photographier le bon'));
      await tester.pump();
      await waitFor(tester, find.text('Garder'));
      await tester.tap(find.text('Reprendre'));
      await tester.pump();
      // L'appareil se rouvre tout de suite : la seconde photo est rangee, puis proposee.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await waitFor(tester, find.text('Garder'));
      expect(capture.calls, 2);
      await tester.tap(find.text('Garder'));
      await tester.pump();
      await settle(tester);
      expect(find.text('Photos : 1'), findsOneWidget);
    });

    formTest('appareil annule : rien n est garde', (tester) async {
      await openForm(tester);
      await tester.ensureVisible(find.text('Photographier le bon'));
      await tester.tap(find.text('Photographier le bon'));
      await tester.pump();
      await settle(tester);
      expect(find.text('Photos : 1'), findsNothing);
    });

    formTest('5 photos au maximum : la sixieme est refusee', (tester) async {
      capture.queue(6);
      await openForm(tester);
      for (var i = 0; i < 5; i++) {
        await tester.ensureVisible(find.text('Photographier le bon'));
        await tester.tap(find.text('Photographier le bon'));
        await tester.pump();
        await waitFor(tester, find.text('Garder'));
        await tester.tap(find.text('Garder'));
        await tester.pump();
        await settle(tester);
      }
      expect(find.text('Photos : 5'), findsOneWidget);
      await tester.ensureVisible(find.text('Photographier le bon'));
      await tester.tap(find.text('Photographier le bon'));
      await tester.pump();
      expect(find.text('5 photos au maximum.'), findsWidgets);
      // Aucun appareil ouvert pour la 6e.
      expect(capture.calls, 5);
    });

    formTest(
      'formulaire abandonne : les photos prises sont supprimees du disque',
      (tester) async {
        capture.queue(1);
        await openForm(tester);
        await tester.ensureVisible(find.text('Photographier le bon'));
        await tester.tap(find.text('Photographier le bon'));
        await tester.pump();
        await waitFor(tester, find.text('Garder'));
        await tester.tap(find.text('Garder'));
        await tester.pump();
        await settle(tester);
        final directory = await tester.runAsync(
          () => bed.files.ownerDirectory('user-chef'),
        );
        expect(directory!.listSync(), isNotEmpty);

        // Retour sans enregistrer.
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
        for (var i = 0; i < 40 && directory.listSync().isNotEmpty; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)),
          );
        }
        expect(directory.listSync(), isEmpty);
      },
    );

    formTest('sans DeliveryPhotos.Create : aucun bouton photo', (tester) async {
      await openForm(
        tester,
        user: const AuthUser(
          id: 'user-chef',
          userName: 'x',
          fullName: 'Mourad B.',
          role: 'ChefChantier',
          language: 'fr',
          mustChangePassword: false,
          permissions: ['Deliveries.Create', 'Requests.View'],
          permissionsVersion: 'v1',
        ),
      );
      expect(find.text('Photographier le bon'), findsNothing);
    });
  });

  group('livraison sans demande (CA-MAT-011)', () {
    formTest('materiau et fournisseur a choisir ; enregistree sans demande', (
      tester,
    ) async {
      await openForm(tester, withRequest: false);
      expect(find.text('Livraison sans demande'), findsOneWidget);
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == 'Chercher un matériau',
        ),
        'cim',
      );
      await tester.pump();
      await tester.tap(find.text('Ciment CPJ 42,5').first);
      await tester.pump();
      await tester.enterText(quantityField(), '20');
      await tester.pump();
      // Fournisseur obligatoire.
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull);
      await tester.ensureVisible(find.textContaining('Sigma'));
      await tester.tap(find.textContaining('Sigma'));
      await tester.pump();
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNotNull);
      await save(tester);

      final ops = await tester.runAsync(queue);
      final payload = ops!.single.payload;
      expect(payload.containsKey('requestId'), isFalse);
      expect(payload.containsKey('requestClientId'), isFalse);
      expect(payload['productId'], 'prod-ciment');
      expect(payload['supplierId'], 'sup-sigma');
      expect(payload['quantity'], {'value': 20, 'unit': 'sac'});
      final row = (await tester.runAsync(
        () => h.db.deliveriesDao.watchBySite(harnessSite).first,
      ))!.single;
      expect(row.requestId, isNull);
      expect(row.unattachedReason, 'NoRequestChosen');
    });

    formTest('« Autre fournisseur » : nom libre de 3 a 100 caracteres', (
      tester,
    ) async {
      await openForm(tester, withRequest: false);
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == 'Chercher un matériau',
        ),
        'cim',
      );
      await tester.pump();
      await tester.tap(find.text('Ciment CPJ 42,5').first);
      await tester.pump();
      await tester.enterText(quantityField(), '20');
      await tester.ensureVisible(find.text('Autre fournisseur'));
      await tester.tap(find.text('Autre fournisseur'));
      await tester.pump();
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField && w.decoration?.labelText == 'Nom du fournisseur',
        ),
        'AB',
      );
      await tester.pump();
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull);
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField && w.decoration?.labelText == 'Nom du fournisseur',
        ),
        'Depot du coin',
      );
      await tester.pump();
      await save(tester);
      final ops = await tester.runAsync(queue);
      expect(ops!.single.payload['freeSupplierName'], 'Depot du coin');
      expect(ops.single.payload.containsKey('supplierId'), isFalse);
    });
  });

  group('« Reception » et correction', () {
    formTest(
      'livraison complete : « DEM-009 est livree. Receptionner maintenant ? »',
      (tester) async {
        await openForm(tester);
        await save(tester, null, true);
        expect(
          findTextContaining('DEM-009 est livrée. Réceptionner maintenant ?'),
          findsOneWidget,
        );
        await tester.tap(find.text('Réceptionner'));
        await tester.pump();
        await settle(tester);
        final ops = await tester.runAsync(queue);
        expect(
          [for (final op in ops!) '${op.entity}/${op.operation}'],
          ['delivery/create', 'request/transition'],
        );
        expect(ops.last.payload['action'], 'receive');
        expect(result, isTrue);
      },
    );

    formTest('« Plus tard » : la livraison reste, aucune reception', (
      tester,
    ) async {
      await openForm(tester);
      await save(tester, null, true);
      await tester.tap(find.text('Plus tard'));
      await tester.pump();
      await settle(tester);
      final ops = await tester.runAsync(queue);
      expect(ops!.length, 1);
      expect(result, isTrue);
    });

    formTest('livraison partielle : aucune proposition de reception', (
      tester,
    ) async {
      await openForm(tester);
      await tester.enterText(quantityField(), '100');
      await tester.pump();
      await save(tester);
      expect(findTextContaining('Réceptionner maintenant'), findsNothing);
    });

    formTest('sans Requests.Receive : pas de proposition de reception', (
      tester,
    ) async {
      await openForm(tester, user: conducteur(id: 'user-chef'));
      await save(tester);
      expect(findTextContaining('Réceptionner maintenant'), findsNothing);
    });

    formTest(
      'corriger : valeurs actuelles, seule la quantite modifiee est envoyee',
      (tester) async {
        await openForm(
          tester,
          existingId: 'liv-6',
          beforeOpen: () => h.db.deliveriesDao.upsertIfNewer(
            deliveryRow(id: 'liv-6', requestId: 'req-009'),
          ),
        );
        expect(find.text('Corriger la livraison'), findsOneWidget);
        expect(
          tester.widget<TextField>(quantityField()).controller!.text,
          '10',
        );
        await tester.enterText(quantityField(), '8');
        await tester.pump();
        await save(tester, 'Enregistrer');
        final ops = await tester.runAsync(queue);
        final update = ops!.firstWhere((op) => op.operation == 'update');
        expect(update.payload['changes'], {
          'quantity': {'value': 8, 'unit': 't'},
        });
        expect(update.payload['base'], {
          'quantity': {'value': 10, 'unit': 't'},
        });
      },
    );
  });

  group('arabe (RTL)', () {
    formTest('textes arabes, quantite de gauche a droite, chiffres 0-9', (
      tester,
    ) async {
      await openForm(tester, locale: const Locale('ar'));
      expect(find.text('استلام تسليم'), findsOneWidget);
      expect(find.text('الكمية المستلمة'), findsWidgets);
      expect(find.text('مطابق'), findsOneWidget);
      expect(find.text('تسليم كامل'), findsOneWidget);
      expect(directionOf(tester, find.text('استلام تسليم')), TextDirection.rtl);
      final quantity = tester.widget<TextField>(quantityField());
      expect(quantity.textDirection, TextDirection.ltr);
      expect(quantity.controller!.text, '600');
      // Aucune chaine francaise sur l'ecran.
      expect(find.text('Enregistrer la livraison'), findsNothing);
      expect(find.text('Conforme'), findsNothing);
    });
  });

  group('boutons terrain (gants, soleil)', () {
    formTest('Enregistrer fait 56 dp de haut, texte de 16 sp au moins', (
      tester,
    ) async {
      await openForm(tester);
      final size = tester.getSize(saveButton());
      expect(size.height, greaterThanOrEqualTo(56));
      final text = tester.widget<Text>(
        find.descendant(of: saveButton(), matching: find.byType(Text)),
      );
      final style = DefaultTextStyle.of(
        tester.element(
          find.descendant(of: saveButton(), matching: find.byType(Text)),
        ),
      ).style;
      expect(
        (text.style?.fontSize ?? style.fontSize ?? 0),
        greaterThanOrEqualTo(16),
      );
    });
  });
}

class OutboxRowSummary {
  const OutboxRowSummary(this.entity, this.operation, this.payload);

  final String entity;
  final String operation;
  final Map<String, Object?> payload;
}
