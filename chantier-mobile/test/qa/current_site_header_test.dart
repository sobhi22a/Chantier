// Q1 : CA-010.1 / CA-010.3 / CA-014.6 sur l'en-tete « chantier courant » de la coquille (aucun test n'existait).
import 'package:bloc_test/bloc_test.dart';
import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/widgets/current_site_header.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/fixtures.dart';
import '../support/pump_app.dart';

void main() {
  final uv18 = siteRow(nameAr: 'مدرسة UV18');
  final ol40 = siteRow(
    id: 'ol40',
    code: 'CH-LOG-OL40',
    name: '40 logements Les Oliviers',
  );

  Future<MockCurrentSiteCubit> pumpHeader(
    WidgetTester tester,
    CurrentSiteState state, {
    Locale locale = const Locale('fr'),
  }) async {
    final cubit = MockCurrentSiteCubit();
    whenListen(
      cubit,
      const Stream<CurrentSiteState>.empty(),
      initialState: state,
    );
    when(() => cubit.select(any())).thenAnswer((_) async {});
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: const Scaffold(body: CurrentSiteHeader()),
        wrap: (app) =>
            BlocProvider<CurrentSiteCubit>.value(value: cubit, child: app),
      ),
    );
    await tester.pump();
    return cubit;
  }

  testWidgets('affiche le code et le nom du chantier courant (CA-010.1)', (
    tester,
  ) async {
    await pumpHeader(
      tester,
      CurrentSiteState(loaded: true, site: uv18, sites: [uv18, ol40]),
    );

    expect(find.widgetWithText(LtrText, 'CH-ECO-UV18'), findsOneWidget);
    expect(find.text('École UV18'), findsOneWidget);
  });

  testWidgets('en arabe : nom arabe, code de gauche a droite (CA-014.6)', (
    tester,
  ) async {
    await pumpHeader(
      tester,
      CurrentSiteState(loaded: true, site: uv18, sites: [uv18, ol40]),
      locale: const Locale('ar'),
    );

    expect(find.text('مدرسة UV18'), findsOneWidget);
    expect(find.widgetWithText(LtrText, 'CH-ECO-UV18'), findsOneWidget);
  });

  testWidgets(
    'changer de chantier courant : 2 gestes (toucher l\'en-tete, toucher un chantier), sans reseau (CA-010.3)',
    (tester) async {
      final cubit = await pumpHeader(
        tester,
        CurrentSiteState(loaded: true, site: uv18, sites: [uv18, ol40]),
      );

      await tester.tap(find.byType(CurrentSiteHeader)); // geste 1
      await tester.pumpAndSettle();
      await tester.tap(find.text('40 logements Les Oliviers')); // geste 2
      await tester.pumpAndSettle();

      verify(() => cubit.select('ol40')).called(1);
      expect(
        find.text('40 logements Les Oliviers'),
        findsNothing,
        reason: 'la liste se ferme',
      );
    },
  );

  testWidgets(
    'un seul chantier : rien a changer, l\'en-tete n\'ouvre aucune liste',
    (tester) async {
      await pumpHeader(
        tester,
        CurrentSiteState(loaded: true, site: uv18, sites: [uv18]),
      );

      await tester.tap(find.byType(CurrentSiteHeader));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byIcon(Icons.unfold_more), findsNothing);
    },
  );

  testWidgets(
    'aucun chantier courant et plusieurs chantiers : invitation a choisir (CA-010.2)',
    (tester) async {
      await pumpHeader(
        tester,
        CurrentSiteState(loaded: true, sites: [uv18, ol40]),
      );

      expect(find.text('Choisir un chantier'), findsWidgets);
    },
  );

  testWidgets('aucun chantier affecte : l\'en-tete disparait', (tester) async {
    await pumpHeader(tester, const CurrentSiteState(loaded: true));

    expect(find.byType(InkWell), findsNothing);
  });
}
