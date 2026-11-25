import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/zones/presentation/zone_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/pump_app.dart';

void main() {
  late List<ZoneRow?> choices;

  setUp(() => choices = []);

  // Bloc 01 : -1,90 (Classe 1), 0,00 (Classe 1, Couloir), +3,40 (Classe 1 a 3) ; Bloc 02 : +6,80 (Bureau 1).
  List<ZoneRow> zones() => [
    zoneRow(id: 'a', elevation: '-1.90', roomNumber: 1, version: 1),
    zoneRow(id: 'b', elevation: '0.00', roomNumber: 1, version: 2),
    zoneRow(
      id: 'b2',
      elevation: '0.00',
      roomType: 'Corridor',
      roomNumber: null,
      version: 3,
    ),
    for (var n = 1; n <= 3; n++)
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

  Future<void> pumpPicker(
    WidgetTester tester, {
    List<ZoneRow>? list,
    ZoneRow? initial,
    bool allowNone = false,
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ZonePicker(
              zones: list ?? zones(),
              initial: initial,
              allowNone: allowNone,
              onChanged: choices.add,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder chip(String label) => find.widgetWithText(ChoiceChip, label);

  testWidgets(
    'Bloc, puis Cote, puis Local : la liste se precise a chaque etape',
    (tester) async {
      await pumpPicker(tester);

      expect(chip('Bloc 01'), findsOneWidget);
      expect(chip('Bloc 02'), findsOneWidget);
      expect(find.text('Cote'), findsNothing, reason: 'pas avant le bloc');

      await tester.tap(chip('Bloc 01'));
      await tester.pump();
      expect(find.text('Cote'), findsOneWidget);
      expect(chip('−1,90 m'), findsOneWidget);
      expect(
        chip('+6,80 m'),
        findsNothing,
        reason: 'cote d\'un autre bloc (CA-009.5)',
      );

      await tester.tap(chip('+3,40 m'));
      await tester.pump();
      expect(chip('Classe 01'), findsOneWidget);
      expect(chip('Classe 03'), findsOneWidget);
      expect(choices, isEmpty, reason: 'aucune zone choisie avant le local');

      await tester.tap(chip('Classe 02'));
      await tester.pump();
      expect(choices.single?.id, 'c2');
    },
  );

  testWidgets('3 gestes au plus pour changer de local (CA-009.1)', (
    tester,
  ) async {
    await pumpPicker(tester, initial: zones().first);

    await tester.tap(chip('Bloc 01'));
    await tester.tap(chip('±0,00 m'));
    await tester.pump();
    await tester.tap(
      chip('Corridor').evaluate().isEmpty ? chip('Couloir') : chip('Corridor'),
    );
    await tester.pump();

    expect(choices.single?.id, 'b2');
  });

  testWidgets(
    'derniere zone preselectionnee : « Valider » suffit (1 geste, CA-009.1)',
    (tester) async {
      final initial = zones()[3]; // c1
      await pumpPicker(tester, initial: initial);

      expect(tester.widget<ChoiceChip>(chip('Bloc 01')).selected, isTrue);
      expect(tester.widget<ChoiceChip>(chip('+3,40 m')).selected, isTrue);
      expect(tester.widget<ChoiceChip>(chip('Classe 01')).selected, isTrue);
    },
  );

  testWidgets(
    'les zones archivees ne sont pas proposees : l\'appelant ne les fournit pas (CA-009.6)',
    (tester) async {
      final active = zones().where((z) => z.id != 'c3').toList();
      await pumpPicker(tester, list: active, initial: active[3]);

      expect(chip('Classe 03'), findsNothing);
    },
  );

  testWidgets('« Non precisee » quand la zone est facultative (CA-009.7)', (
    tester,
  ) async {
    await pumpPicker(tester, allowNone: true);

    await tester.tap(chip('Non précisée'));
    await tester.pump();

    expect(choices.single, isNull);
    expect(choices, hasLength(1));
    expect(tester.widget<ChoiceChip>(chip('Non précisée')).selected, isTrue);
  });

  testWidgets('pas de « Non precisee » par defaut', (tester) async {
    await pumpPicker(tester);

    expect(chip('Non précisée'), findsNothing);
  });

  group('300 zones, 10 blocs (CA-009.4)', () {
    List<ZoneRow> many() => [
      for (var b = 1; b <= 10; b++)
        for (var n = 1; n <= 30; n++)
          zoneRow(
            id: 'z-$b-$n',
            block: 'Bloc ${b.toString().padLeft(2, '0')}',
            roomNumber: n,
            version: b * 100 + n,
          ),
    ];

    testWidgets('recherche libre « cl 02 » retrouve « Classe 02 »', (
      tester,
    ) async {
      await pumpPicker(tester, list: many());

      await tester.enterText(
        find.widgetWithIcon(TextField, Icons.search).first,
        'cl 02',
      );
      await tester.pump();

      expect(find.textContaining('Classe 02'), findsWidgets);
      // Les resultats sont plafonnes (20) : la liste reste fluide.
      expect(find.byType(ListTile).evaluate().length, lessThanOrEqualTo(20));
    });

    testWidgets('choisir un resultat de la recherche', (tester) async {
      await pumpPicker(tester, list: many());
      await tester.enterText(
        find.widgetWithIcon(TextField, Icons.search).first,
        'bloc 07 classe 15',
      );
      await tester.pump();

      await tester.tap(find.byType(ListTile).first);
      await tester.pump();

      expect(choices.single?.id, 'z-7-15');
    });

    testWidgets('recherche sans resultat', (tester) async {
      await pumpPicker(tester, list: many());

      await tester.enterText(
        find.widgetWithIcon(TextField, Icons.search).first,
        'xyz',
      );
      await tester.pump();

      expect(find.text('Aucune zone ne correspond.'), findsOneWidget);
    });

    testWidgets('moins de 9 zones : pas de recherche generale', (tester) async {
      await pumpPicker(tester, list: zones().take(5).toList());

      expect(find.byIcon(Icons.search), findsNothing);
    });
  });

  testWidgets(
    'arabe : RTL, types de local arabes, cotes lisibles de gauche a droite',
    (tester) async {
      await pumpPicker(tester, locale: const Locale('ar'), initial: zones()[3]);

      expect(directionOf(tester, find.byType(ZonePicker)), TextDirection.rtl);
      expect(find.text('بلوك'), findsOneWidget);
      expect(find.text('المنسوب'), findsOneWidget);
      expect(chip('قسم 01'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('+3,40 m'))),
        TextDirection.ltr,
      );
    },
  );

  testWidgets('feuille de selection : « Valider » renvoie la zone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    ZoneRow? result;
    var closed = false;
    await tester.pumpWidget(
      testApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showZonePicker(
                  context,
                  zones: zones(),
                  initial: zones()[3],
                );
                closed = true;
              },
              child: const Text('choisir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('choisir'));
    await tester.pumpAndSettle();
    expect(find.text('Choisir une zone'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Valider'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result?.id, 'c1');
  });
}
