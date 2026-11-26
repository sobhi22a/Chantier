import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/materials/domain/quantity.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/request_form_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/materials_harness.dart';
import '../../../support/pump_app.dart';

/// Test de widget qui, a la fin, demonte l'ecran et laisse partir les minuteurs de Drift
/// (annulation des flux) : sinon Flutter signale « un minuteur est encore en attente ».
void formTest(String name, Future<void> Function(WidgetTester tester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    });

void main() {
  late MaterialsHarness h;
  Object? result;
  String? seenDuplicate;

  setUp(() async {
    h = MaterialsHarness();
    result = null;
    seenDuplicate = null;
  });
  tearDown(() => h.dispose());

  /// Laisse les lectures asynchrones de la base (hors horloge simulee) se terminer.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  Future<void> openForm(
    WidgetTester tester, {
    AuthUser? user,
    Locale locale = const Locale('fr'),
    RequestView? existing,
    RequestDraft? initial,
    OutboxRow? replacing,
    bool withHistory = true,
    Future<void> Function()? beforeOpen,
  }) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await h.seed(withHistory: withHistory);
      await h.zones.rememberZone('user-equipe', 'zone-1');
      await beforeOpen?.call();
    });
    final signedIn = user ?? chefEquipe();
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
                      builder: (_) => RequestFormScreen(
                        siteId: harnessSite,
                        user: signedIn,
                        repository: h.materials,
                        zonesRepository: h.zones,
                        existing: existing,
                        initial: initial,
                        replacing: replacing,
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
        (w.decoration?.labelText == 'Quantité' ||
            w.decoration?.labelText == 'الكمية'),
  );

  Finder sendButton([String label = 'Envoyer']) =>
      find.widgetWithText(FilledButton, label);

  Future<List<OutboxRow>> queue() => h.db.outboxDao.allFor('user-equipe');

  formTest('cas nominal en 4 gestes : materiau, quantite, envoyer', (
    tester,
  ) async {
    await openForm(tester);
    var gestures = 0;

    // Les produits les plus demandes sont des tuiles : 1 geste.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ciment CPJ 42,5'));
    gestures++;
    await tester.pump();
    // Unite preselectionnee : « sac » est choisi sans geste.
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'sac'))
          .selected,
      isTrue,
    );

    // Quantite au clavier numerique : 1 geste.
    await tester.enterText(quantityField(), '300');
    gestures++;
    await tester.pump();
    expect(find.textContaining('15 T'), findsOneWidget, reason: 'equivalence');

    // Date, zone et urgence ont des valeurs par defaut : « Envoyer » : 1 geste.
    await tester.tap(sendButton());
    gestures++;
    await tester.pump();
    await settle(tester);

    expect(gestures, lessThanOrEqualTo(4));
    final operations = await tester.runAsync(queue) ?? [];
    expect(operations, hasLength(1));
    final payload = operations.single.payload;
    expect(payload['productId'], 'prod-ciment');
    expect(payload['quantity'], {'value': 300, 'unit': 'sac'});
    // Valeurs par defaut : aujourd'hui (25/11/2026) + 3 jours, derniere zone, urgence normale.
    expect(payload['neededBy'], '2026-11-28');
    expect(payload['zoneId'], 'zone-1');
    expect(payload['priority'], 'Normal');
    expect(result, isTrue);
    // Une ligne locale « numero en attente ».
    final local = await tester.runAsync(
      () => h.db.materialRequestsDao.findByClientId(
        harnessSite,
        operations.single.clientId,
      ),
    );
    expect(local!.isPending, isTrue);
    expect(local.number, isNull);
  });

  formTest('double appui sur Envoyer : une seule saisie', (tester) async {
    await openForm(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ciment CPJ 42,5'));
    await tester.pump();
    await tester.enterText(quantityField(), '50');
    await tester.pump();
    await tester.tap(sendButton());
    await tester.tap(sendButton(), warnIfMissed: false);
    await tester.pump();
    await settle(tester);
    expect(await tester.runAsync(queue), hasLength(1));
  });

  formTest('recherche tolerante : « cim » retrouve le ciment', (tester) async {
    await openForm(tester, withHistory: false);
    await tester.enterText(
      find.widgetWithText(TextField, 'Chercher un matériau').first,
      'cim',
    );
    await tester.pump();
    expect(find.widgetWithText(ChoiceChip, 'Ciment CPJ 42,5'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Sable 0/3'), findsNothing);
  });

  formTest('quantite decimale avec sac : message clair, Envoyer inactif', (
    tester,
  ) async {
    await openForm(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ciment CPJ 42,5'));
    await tester.pump();
    await tester.enterText(quantityField(), '2,5');
    await tester.pump();
    expect(find.textContaining('entier'), findsOneWidget);
    expect(tester.widget<FilledButton>(sendButton()).onPressed, isNull);

    // Avec une unite qui accepte les decimales : valide.
    await tester.tap(find.widgetWithText(ChoiceChip, 'T'));
    await tester.pump();
    expect(find.textContaining('entier'), findsNothing);
    expect(tester.widget<FilledButton>(sendButton()).onPressed, isNotNull);
  });

  formTest('quantite negative ou nulle : refusee', (tester) async {
    await openForm(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ciment CPJ 42,5'));
    await tester.pump();
    await tester.enterText(quantityField(), '0');
    await tester.pump();
    expect(find.textContaining('supérieure à zéro'), findsOneWidget);
    expect(tester.widget<FilledButton>(sendButton()).onPressed, isNull);
  });

  formTest(
    '« Autre produit » : nom de 3 a 100 caracteres, unite a choisir (jamais libre)',
    (tester) async {
      await openForm(tester, withHistory: false);
      await tester.enterText(
        find.widgetWithText(TextField, 'Chercher un matériau').first,
        'zzz',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Autre produit'));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nom du matériau'),
        'ab',
      );
      await tester.pump();
      expect(find.text('Entrez 3 à 100 caractères.'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Nom du matériau'),
        'Pointes 100 mm',
      );
      await tester.enterText(quantityField(), '5');
      await tester.pump();
      // Aucune unite choisie : « Envoyer » reste inactif et le message le dit.
      expect(tester.widget<FilledButton>(sendButton()).onPressed, isNull);
      expect(find.textContaining('unité'), findsWidgets);

      await tester.tap(find.widgetWithText(ChoiceChip, 'kg'));
      await tester.pump();
      expect(tester.widget<FilledButton>(sendButton()).onPressed, isNotNull);
      await tester.tap(sendButton());
      await tester.pump();
      await settle(tester);

      final payload = (await tester.runAsync(queue))!.single.payload;
      expect(payload['freeProductName'], 'Pointes 100 mm');
      expect(payload.containsKey('productId'), isFalse);
      expect(payload['quantity'], {'value': 5, 'unit': 'kg'});
    },
  );

  formTest('date passee : avertissement, « Envoyer quand meme » enregistre', (
    tester,
  ) async {
    await openForm(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ciment CPJ 42,5'));
    await tester.pump();
    await tester.enterText(quantityField(), '10');
    // La date est choisie dans un calendrier, jamais saisie en texte.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Autre date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('24'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Cette date est déjà passée.'), findsWidgets);

    await tester.tap(sendButton());
    await tester.pumpAndSettle();
    expect(find.text('Envoyer quand même'), findsOneWidget);
    expect(await tester.runAsync(queue), isEmpty, reason: 'rien n est parti');

    await tester.tap(find.text('Envoyer quand même'));
    await tester.pump();
    await settle(tester);
    final operations = await tester.runAsync(queue);
    expect(operations, hasLength(1));
    expect(operations!.single.payload['neededBy'], '2026-11-24');
  });

  formTest(
    'doublon possible : « Voir la demande » ou « C est une autre demande »',
    (tester) async {
      // Une demande ouverte pour le meme materiau et la meme zone existe deja.
      await openForm(
        tester,
        withHistory: false,
        beforeOpen: () => h.db.materialRequestsDao.upsertIfNewer(
          requestRow(id: 'open-1', number: 'DEM-012', zoneId: 'zone-1'),
        ),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Ciment CPJ 42,5'));
      await tester.pump();
      await tester.enterText(quantityField(), '20');
      await tester.pump();
      await tester.tap(sendButton());
      await tester.pumpAndSettle();
      expect(find.textContaining('DEM-012'), findsOneWidget);

      // « Voir la demande » : rien n'est enregistre.
      await tester.tap(find.text('Voir la demande'));
      await tester.pumpAndSettle();
      expect(seenDuplicate, 'open-1');
      expect(await tester.runAsync(queue), isEmpty);

      // « C'est une autre demande » : jamais un blocage.
      await tester.tap(sendButton());
      await tester.pumpAndSettle();
      await tester.tap(find.text("C'est une autre demande"));
      await tester.pump();
      await settle(tester);
      expect(await tester.runAsync(queue), hasLength(1));
    },
  );

  formTest(
    '« Envoyer et ajouter un autre materiau » : formulaire vide, zone gardee',
    (tester) async {
      await openForm(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Ciment CPJ 42,5'));
      await tester.pump();
      await tester.enterText(quantityField(), '10');
      await tester.pump();
      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          'Envoyer et ajouter un autre matériau',
        ),
      );
      await tester.pump();
      await settle(tester);

      expect(result, isNull, reason: 'le formulaire reste ouvert');
      expect(find.text('Chercher un matériau'), findsOneWidget);
      expect(await tester.runAsync(queue), hasLength(1));

      // Deuxieme saisie : autre clientId, donc autre operation.
      await tester.enterText(
        find.widgetWithText(TextField, 'Chercher un matériau').first,
        'sable',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sable 0/3'));
      await tester.pump();
      await tester.enterText(quantityField(), '24');
      await tester.pump();
      await tester.tap(sendButton());
      await tester.pump();
      await settle(tester);
      final operations = (await tester.runAsync(queue))!;
      expect(operations, hasLength(2));
      expect(operations[0].clientId, isNot(operations[1].clientId));
    },
  );

  formTest('correction : le materiau est affiche mais ne se change pas', (
    tester,
  ) async {
    final row = requestRow(
      id: 'srv-1',
      number: 'DEM-020',
      requestedById: 'user-equipe',
      zoneId: 'zone-1',
    );
    await openForm(
      tester,
      existing: RequestView.plain(row),
      withHistory: false,
    );
    await tester.runAsync(() => h.db.materialRequestsDao.upsertIfNewer(row));
    expect(find.text('Corriger la demande'), findsOneWidget);
    expect(
      find.textContaining('annulez la demande puis recréez-la'),
      findsOneWidget,
    );
    expect(find.text('Chercher un matériau'), findsNothing);

    await tester.enterText(quantityField(), '400');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
    await tester.pump();
    await settle(tester);
    final operation = (await tester.runAsync(queue))!.single;
    expect(operation.operation, 'update');
    expect(operation.payload['changes'], {
      'quantity': {'value': 400, 'unit': 'sac'},
    });
    expect(operation.payload['base'], {
      'quantity': {'value': 300, 'unit': 'sac'},
    });
    expect(operation.payload['requestId'], 'srv-1');
  });

  formTest('apres la validation : quantite, unite et zone sont figees', (
    tester,
  ) async {
    final row = requestRow(
      id: 'srv-2',
      status: 'Validated',
      requestedById: 'user-chef',
    );
    await openForm(
      tester,
      user: conducteur(),
      existing: RequestView.plain(row),
      withHistory: false,
    );
    final field = tester.widget<TextField>(quantityField());
    expect(field.enabled, isFalse);
    // Date, urgence et remarque restent modifiables (droit « toutes les demandes »).
    expect(find.widgetWithText(ChoiceChip, 'Urgente'), findsOneWidget);
    await settle(tester);
  });

  formTest(
    'remplacer une saisie refusee : l ancienne disparait avec la nouvelle',
    (tester) async {
      // Une creation refusee par le serveur.
      await tester.runAsync(() async {
        await h.seed();
        await h.materials.createRequest(
          clientId: 'old-create',
          siteId: harnessSite,
          userId: 'user-equipe',
          requesterName: 'Nadir S.',
          draft: RequestDraft(
            productId: 'prod-ciment',
            quantity: Quantity(Decimal.parse('9'), MeasureUnit.bag),
            neededBy: DateTime.utc(2026, 11, 28),
          ),
          label: 'Ciment',
        );
        final op = (await h.db.outboxDao.getByClientId('old-create'))!;
        await h.db.outboxDao.markFailed(
          op.id,
          status: OutboxStatus.rejected,
          errorCode: 'ZONE_HORS_CHANTIER',
        );
      });
      final refused = (await tester.runAsync(
        () => h.db.outboxDao.getByClientId('old-create'),
      ))!;
      await openForm(
        tester,
        initial: draftFromCreatePayload(refused.payload),
        replacing: refused,
      );
      // Preremplie avec ma saisie : 9 sacs.
      expect(tester.widget<TextField>(quantityField()).controller!.text, '9');
      await tester.enterText(quantityField(), '12');
      await tester.pump();
      await tester.tap(sendButton());
      await tester.pump();
      await settle(tester);

      final operations = (await tester.runAsync(queue))!;
      expect(
        operations,
        hasLength(1),
        reason: 'l ancienne saisie est remplacee',
      );
      expect(operations.single.clientId, isNot('old-create'));
      expect(operations.single.payload['quantity'], {
        'value': 12,
        'unit': 'sac',
      });
      expect(
        await tester.runAsync(
          () => h.db.materialRequestsDao.getById('old-create'),
        ),
        isNull,
      );
    },
  );

  group('arabe (RTL)', () {
    formTest('textes arabes, sens de lecture, quantite de gauche a droite', (
      tester,
    ) async {
      await openForm(tester, locale: const Locale('ar'));
      expect(find.text('طلب جديد'), findsOneWidget);
      expect(directionOf(tester, find.text('طلب جديد')), TextDirection.rtl);

      await tester.tap(find.widgetWithText(ChoiceChip, 'إسمنت CPJ 42,5'));
      await tester.pump();
      await tester.enterText(quantityField(), '300');
      await tester.pump();

      final field = tester.widget<TextField>(quantityField());
      expect(field.textDirection, TextDirection.ltr);
      // Unite en arabe, equivalence « 300 كيس = 15 طن », chiffres 0-9.
      expect(find.widgetWithText(ChoiceChip, 'كيس'), findsOneWidget);
      expect(findTextContaining('300'), findsWidgets);
      expect(findTextContaining('15'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && RegExp(r'[٠-٩]').hasMatch(w.data ?? ''),
        ),
        findsNothing,
        reason: 'chiffres 0-9 partout',
      );
      expect(find.widgetWithText(FilledButton, 'إرسال'), findsOneWidget);
    });

    formTest('date complete affichee de gauche a droite', (tester) async {
      await openForm(tester, locale: const Locale('ar'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'إسمنت CPJ 42,5'));
      await tester.pump();
      expect(find.text('28/11/2026'), findsOneWidget);
    });
  });
}
