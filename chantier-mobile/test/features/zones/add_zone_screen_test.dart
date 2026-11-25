import 'dart:async';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:chantier_mobile/features/zones/presentation/add_zone_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';
import '../../support/pump_app.dart';

class _MockZonesRepository extends Mock implements ZonesRepository {}

const _site = 'site-uv18';
const _user = 'user-a';

NewZone _fallback() => const NewZone(
  clientId: 'x',
  siteId: _site,
  userId: _user,
  block: 'B',
  label: 'L',
);

void main() {
  late _MockZonesRepository repository;
  late List<NewZone> saved;
  late bool popped;
  late Object? poppedResult;

  setUpAll(() {
    registerFallbackValue(_fallback());
  });

  setUp(() {
    repository = _MockZonesRepository();
    saved = [];
    popped = false;
    poppedResult = null;
  });

  // Zones existantes : Bloc 01, cotes -1,90 / 0,00 / +3,40 ; classes 1 a 6 a +3,40.
  List<ZoneRow> existingZones() => [
    zoneRow(id: 'a', elevation: '-1.90', roomNumber: 1, version: 1),
    zoneRow(id: 'b', elevation: '0.00', roomNumber: 1, version: 2),
    for (var n = 1; n <= 6; n++)
      zoneRow(id: 'c$n', elevation: '3.40', roomNumber: n, version: 10 + n),
    zoneRow(
      id: 'd',
      block: 'Bloc 02',
      elevation: '6.80',
      roomType: 'Office',
      roomNumber: 1,
      version: 30,
    ),
  ];

  Future<void> openForm(
    WidgetTester tester, {
    List<ZoneRow>? zones,
    ZoneRow? last,
    Locale locale = const Locale('fr'),
    OutboxRow? replacing,
    ZoneSaveResult Function(NewZone)? onSave,
    Future<ZoneSaveResult> Function(NewZone)? onSaveAsync,
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final list = zones ?? existingZones();
    when(
      () => repository.watchZones(_site),
    ).thenAnswer((_) => Stream.value(list));
    when(() => repository.lastUsedZone(_user)).thenAnswer(
      (_) async =>
          last ?? (list.isEmpty ? null : list.firstWhere((z) => z.id == 'c6')),
    );
    when(() => repository.rememberZone(any(), any())).thenAnswer((_) async {});
    when(
      () => repository.save(any(), replacing: any(named: 'replacing')),
    ).thenAnswer((invocation) async {
      final zone = invocation.positionalArguments.first as NewZone;
      saved.add(zone);
      if (onSaveAsync != null) return onSaveAsync(zone);
      return onSave != null
          ? onSave(zone)
          : ZoneSaved(zoneRow(id: zone.clientId, isPending: true, version: 0));
    });

    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  poppedResult = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => AddZoneScreen(
                        siteId: _site,
                        userId: _user,
                        repository: repository,
                        replacing: replacing,
                      ),
                    ),
                  );
                  popped = true;
                },
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
  }

  Finder chip(String label) => find.widgetWithText(ChoiceChip, label);

  bool isSelected(WidgetTester tester, String label) =>
      tester.widget<ChoiceChip>(chip(label)).selected;

  group('Valeurs par defaut (CA-011.1)', () {
    testWidgets(
      'bloc et cote de la derniere zone utilisee preselectionnes, type a choisir',
      (tester) async {
        await openForm(tester);

        expect(find.text('Ajouter une zone'), findsOneWidget);
        expect(isSelected(tester, 'Bloc 01'), isTrue);
        expect(isSelected(tester, '+3,40 m'), isTrue);
        expect(isSelected(tester, 'Classe'), isFalse);
      },
    );

    testWidgets(
      'les cotes proposees sont celles du bloc, du plus bas au plus haut',
      (tester) async {
        await openForm(tester);

        final labels = ['−1,90 m', '±0,00 m', '+3,40 m'];
        final tops = [for (final l in labels) tester.getTopLeft(chip(l)).dx];
        expect(tops, [...tops]..sort());
        expect(chip('+6,80 m'), findsNothing, reason: 'cote d\'un autre bloc');
      },
    );

    testWidgets('unite : le metre, toujours affichee, jamais modifiable', (
      tester,
    ) async {
      await openForm(tester);

      await tester.tap(find.text('Autre cote'));
      await tester.pump();

      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Cote (m)'),
      );
      expect(field.decoration?.suffixText, 'm');
    });

    testWidgets('aucune zone encore : on cree le bloc et la cote', (
      tester,
    ) async {
      await openForm(tester, zones: const []);

      expect(find.text('Nom du bloc'), findsOneWidget);
      expect(find.text('Cote (m)'), findsOneWidget);
    });
  });

  group('5 gestes, moins de 30 s (CA-011.1)', () {
    testWidgets(
      'depuis la fiche : type (1), « + » (2), Enregistrer (3) ; les 2 premiers gestes ouvrent la fiche',
      (tester) async {
        await openForm(tester);
        // Geste 3 : le type de local.
        await tester.tap(chip('Classe'));
        await tester.pump();
        // Le numero propose est deja le suivant libre (Classe 07) : on l'ajuste d'un cran.
        expect(find.text('07'), findsOneWidget);
        // Geste 4 : « + ».
        await tester.tap(find.byTooltip('Numéro suivant'));
        await tester.pump();
        expect(find.text('08'), findsOneWidget);
        // Geste 5 : Enregistrer.
        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pumpAndSettle();

        final zone = saved.single;
        expect(zone.siteId, _site);
        expect(zone.userId, _user);
        expect(zone.block, 'Bloc 01');
        expect(zone.elevation, Decimal.parse('3.40'));
        expect(zone.roomType, 'Classroom');
        expect(zone.roomNumber, 8);
        expect(zone.roomLabel, isNull);
        expect(popped, isTrue);
        expect(poppedResult, isTrue);
        expect(
          find.text('Zone enregistrée. En attente d\'envoi.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'le libelle de la file d\'envoi est lisible : « Bloc 01 · +3,40 m · Classe 07 »',
      (tester) async {
        await openForm(tester);

        await tester.tap(chip('Classe'));
        await tester.pump();
        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pumpAndSettle();

        expect(saved.single.label, 'Bloc 01 · +3,40 m · Classe 07');
      },
    );

    testWidgets('numero « − » et « + » : 56 dp, bornes respectees', (
      tester,
    ) async {
      await openForm(
        tester,
        zones: [zoneRow(id: 'z', elevation: '3.40', roomNumber: 1)],
        last: zoneRow(id: 'z', elevation: '3.40', roomNumber: 1),
      );
      await tester.tap(chip('Classe'));
      await tester.pump();

      expect(
        tester.getSize(find.byTooltip('Numéro suivant')).height,
        greaterThanOrEqualTo(56),
      );
      expect(
        tester.getSize(find.byTooltip('Numéro précédent')).width,
        greaterThanOrEqualTo(56),
      );
      // Le numero propose est 02 ; « − » deux fois s'arrete a 01.
      await tester.tap(find.byTooltip('Numéro précédent'));
      await tester.pump();
      expect(find.text('01'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.remove))
            .onPressed,
        isNull,
      );
    });

    testWidgets('les pastilles ont 48 dp de haut au moins (gants)', (
      tester,
    ) async {
      await openForm(tester);

      expect(tester.getSize(chip('Classe')).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSize(find.widgetWithText(FilledButton, 'Enregistrer')).height,
        greaterThanOrEqualTo(56),
      );
    });

    testWidgets(
      'une pastille choisie porte une coche (jamais la couleur seule)',
      (tester) async {
        await openForm(tester);

        await tester.tap(chip('Couloir'));
        await tester.pump();

        final selected = tester.widget<ChoiceChip>(chip('Couloir'));
        expect(selected.selected, isTrue);
        expect(selected.showCheckmark, isTrue);
      },
    );
  });

  group('Anti-doublon (CA-011.4)', () {
    testWidgets(
      'double appui sur Enregistrer : une seule demande, bouton inactif',
      (tester) async {
        final gate = Completer<ZoneSaveResult>();
        await openForm(tester, onSaveAsync: (_) => gate.future);
        await tester.tap(chip('Classe'));
        await tester.pump();

        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pump();
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        await tester.tap(find.byType(FilledButton), warnIfMissed: false);
        await tester.pump();
        gate.complete(ZoneSaved(zoneRow(isPending: true, version: 0)));
        await tester.pumpAndSettle();

        expect(saved, hasLength(1));
      },
    );

    testWidgets(
      'le clientId est cree a l\'ouverture : stable pour ce formulaire, different pour un autre',
      (tester) async {
        await openForm(tester);
        await tester.tap(chip('Classe'));
        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pumpAndSettle();
        final first = saved.single.clientId;
        expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(first), isTrue);

        // Le message de confirmation disparait avant de rouvrir le formulaire.
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ouvrir'));
        await tester.pumpAndSettle();
        await tester.tap(chip('Classe'));
        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pumpAndSettle();

        expect(saved, hasLength(2));
        expect(saved.last.clientId, isNot(first));
      },
    );

    testWidgets(
      'zone deja existante : message, zone existante ouverte, rien d\'ajoute',
      (tester) async {
        final existing = zoneRow(
          id: 'c3',
          elevation: '3.40',
          roomNumber: 3,
          version: 13,
        );
        await openForm(tester, onSave: (_) => ZoneAlreadyExists(existing));
        await tester.tap(chip('Classe'));
        await tester.pump();

        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pumpAndSettle();

        expect(find.text('Cette zone existe déjà.'), findsOneWidget);
        expect(poppedResult, isFalse, reason: 'rien n\'a ete cree');
        verify(() => repository.rememberZone(_user, 'c3')).called(1);
      },
    );

    testWidgets(
      'formulaire deja enregistre (renvoi) : on referme sans rien refaire',
      (tester) async {
        await openForm(tester, onSave: (_) => const ZoneAlreadySaved());
        await tester.tap(chip('Classe'));

        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pumpAndSettle();

        expect(popped, isTrue);
      },
    );
  });

  group('Cote saisie (CA-011.2, CA-011.3)', () {
    Future<void> enterElevation(WidgetTester tester, String text) async {
      await tester.tap(find.text('Autre cote'));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, 'Cote (m)'), text);
      await tester.pump();
    }

    for (final input in ['3,4', '3.4']) {
      testWidgets('« $input » donne +3,40 m', (tester) async {
        await openForm(tester);
        await enterElevation(tester, input);

        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pumpAndSettle();

        expect(saved.single.elevation, Decimal.parse('3.40'));
      });
    }

    testWidgets('clavier numerique decimal avec signe', (tester) async {
      await openForm(tester);
      await tester.tap(find.text('Autre cote'));
      await tester.pump();

      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Cote (m)'),
      );
      expect(
        field.keyboardType,
        const TextInputType.numberWithOptions(decimal: true, signed: true),
      );
    });

    testWidgets('des lettres sont impossibles a saisir', (tester) async {
      await openForm(tester);
      await enterElevation(tester, 'a3b,4c');

      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Cote (m)'))
            .controller
            ?.text,
        '3,4',
      );
    });

    testWidgets('touche +/- : change le signe', (tester) async {
      await openForm(tester);
      await enterElevation(tester, '1,9');

      await tester.tap(find.byTooltip('+ / −'));
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Cote (m)'))
            .controller
            ?.text,
        '-1,9',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pumpAndSettle();
      expect(saved.single.elevation, Decimal.parse('-1.90'));
    });

    testWidgets(
      'hors de -20,00 a +60,00 : refusee avec un message clair, rien d\'enregistre',
      (tester) async {
        await openForm(tester);
        await enterElevation(tester, '75');

        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pump();

        expect(find.textContaining('doit être comprise entre'), findsOneWidget);
        expect(find.textContaining('−20,00'), findsWidgets);
        expect(saved, isEmpty);
      },
    );

    testWidgets('trois decimales ou texte invalide : refuse', (tester) async {
      await openForm(tester);
      await enterElevation(tester, '1,234');

      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pump();

      expect(find.textContaining('Cote invalide'), findsOneWidget);
      expect(saved, isEmpty);
    });

    testWidgets('sans cote : enregistre sans cote', (tester) async {
      await openForm(tester);
      await tester.tap(find.text('Sans cote'));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pumpAndSettle();

      expect(saved.single.elevation, isNull);
    });

    testWidgets('cote existante rechoisie apres une autre cote', (
      tester,
    ) async {
      await openForm(tester);
      await tester.tap(chip('−1,90 m'));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pumpAndSettle();

      expect(saved.single.elevation, Decimal.parse('-1.90'));
    });
  });

  group('Bloc et local', () {
    testWidgets('nouveau bloc : saisi, obligatoire', (tester) async {
      await openForm(tester);
      await tester.tap(find.text('Nouveau bloc'));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pump();
      expect(find.text('Choisissez ou créez un bloc.'), findsOneWidget);
      expect(saved, isEmpty);

      await tester.enterText(
        find.widgetWithText(TextField, 'Nom du bloc'),
        'Bloc 03',
      );
      await tester.pump();
      await tester.tap(find.text('Autre cote'));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, 'Cote (m)'), '0');
      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pumpAndSettle();

      expect(saved.single.block, 'Bloc 03');
      expect(saved.single.elevation, Decimal.zero);
    });

    testWidgets('choisir un autre bloc propose ses propres cotes', (
      tester,
    ) async {
      await openForm(tester);

      await tester.tap(chip('Bloc 02'));
      await tester.pump();

      expect(chip('+6,80 m'), findsOneWidget);
      expect(chip('+3,40 m'), findsNothing);
    });

    testWidgets('type « Autre » : libelle libre obligatoire, pas de numero', (
      tester,
    ) async {
      await openForm(tester);
      await tester.tap(chip('Autre'));
      await tester.pump();

      expect(find.byTooltip('Numéro suivant'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pump();
      expect(find.text('Précisez le local.'), findsOneWidget);
      expect(saved, isEmpty);

      await tester.enterText(
        find.widgetWithText(TextField, 'Libellé du local'),
        'Salle des archives',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pumpAndSettle();

      expect(saved.single.roomType, 'Other');
      expect(saved.single.roomLabel, 'Salle des archives');
      expect(saved.single.roomNumber, isNull);
    });

    testWidgets('aucun local : bloc et cote seuls', (tester) async {
      await openForm(tester);
      await tester.tap(find.text('Aucun local'));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pumpAndSettle();

      expect(saved.single.roomType, isNull);
      expect(saved.single.roomNumber, isNull);
    });

    testWidgets('au-dela de 8 blocs : recherche (CA-011.11)', (tester) async {
      final many = [
        for (var i = 1; i <= 9; i++)
          zoneRow(id: 'z$i', block: 'Bloc 0$i', roomNumber: i, version: i),
      ];
      await openForm(tester, zones: many, last: many.first);

      expect(find.byIcon(Icons.search), findsOneWidget);
      await tester.enterText(
        find.widgetWithIcon(TextField, Icons.search),
        '07',
      );
      await tester.pump();

      expect(chip('Bloc 07'), findsOneWidget);
      expect(chip('Bloc 01'), findsNothing);
    });
  });

  group('Corriger une saisie refusee', () {
    testWidgets(
      'le formulaire reprend les valeurs de la saisie refusee et la remplace',
      (tester) async {
        final rejected = OutboxRow(
          id: 7,
          clientId: 'old',
          ownerUserId: _user,
          entity: 'zone',
          operation: 'create',
          siteId: _site,
          label: 'Bloc 01 · +3,40 m · Classe 07',
          payloadJson:
              '{"block":"Bloc 01","elevation":3.4,"roomType":"Classroom","roomNumber":7}',
          status: OutboxStatus.rejected,
          attempts: 1,
          lastErrorCode: 'VALIDATION',
          createdAt: DateTime.utc(2026, 11, 24, 6, 58),
        );
        await openForm(tester, replacing: rejected);

        expect(isSelected(tester, 'Bloc 01'), isTrue);
        expect(isSelected(tester, '+3,40 m'), isTrue);
        expect(isSelected(tester, 'Classe'), isTrue);
        expect(find.text('07'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
        await tester.pumpAndSettle();

        expect(saved.single.roomNumber, 7);
        final replacing =
            verify(
                  () => repository.save(
                    any(),
                    replacing: captureAny(named: 'replacing'),
                  ),
                ).captured.single
                as OutboxRow;
        expect(replacing.clientId, 'old');
      },
    );
  });

  group('Arabe (RTL)', () {
    testWidgets(
      'formulaire en arabe : textes arabes, sens de lecture, chiffres 0-9',
      (tester) async {
        await openForm(tester, locale: const Locale('ar'));

        expect(
          directionOf(tester, find.byType(AddZoneScreen)),
          TextDirection.rtl,
        );
        expect(find.text('إضافة منطقة'), findsOneWidget);
        expect(find.text('بلوك'), findsOneWidget);
        expect(find.text('المنسوب'), findsOneWidget);
        expect(chip('قسم'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'حفظ'), findsOneWidget);

        await tester.tap(chip('قسم'));
        await tester.pump();
        expect(find.text('07'), findsOneWidget);
        final number = tester.element(find.text('07'));
        expect(
          Directionality.of(number),
          TextDirection.ltr,
          reason: 'le numero reste lisible de gauche a droite',
        );
      },
    );

    testWidgets(
      'la cote en arabe : pastille de gauche a droite, signe devant le nombre',
      (tester) async {
        await openForm(tester, locale: const Locale('ar'));

        final label = tester.element(find.text('+3,40 m'));
        expect(Directionality.of(label), TextDirection.ltr);
      },
    );

    testWidgets('erreur de cote en arabe', (tester) async {
      await openForm(tester, locale: const Locale('ar'));
      await tester.tap(find.text('منسوب آخر'));
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, 'المنسوب (م)'),
        '99',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
      await tester.pump();

      expect(find.textContaining('يجب أن يكون المنسوب بين'), findsOneWidget);
    });
  });
}
