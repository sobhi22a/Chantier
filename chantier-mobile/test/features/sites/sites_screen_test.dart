import 'package:bloc_test/bloc_test.dart';
import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';
import '../../support/pump_app.dart';

class _MockSitesCubit extends MockCubit<SitesState> implements SitesCubit {}

const _synced = SyncStatusSnapshot(
  indicator: SyncIndicator.upToDate,
  initialSyncDone: true,
);

SiteRow _site(String id, String name, {String? nameAr, DateTime? archivedAt}) =>
    siteRow(
      id: id,
      code: 'CH-$id',
      name: name,
      nameAr: nameAr,
      archivedAt: archivedAt,
    );

void main() {
  late _MockSitesCubit sites;
  late int syncCalls;
  late List<SiteRow> opened;

  setUp(() {
    sites = _MockSitesCubit();
    syncCalls = 0;
    opened = [];
  });

  Future<void> pumpList(
    WidgetTester tester, {
    required SitesState state,
    SyncStatusSnapshot sync = _synced,
    CurrentSiteState current = const CurrentSiteState(loaded: true),
    Locale locale = const Locale('fr'),
    CurrentSiteCubit? currentCubit,
  }) async {
    whenListen(sites, const Stream<SitesState>.empty(), initialState: state);
    when(() => sites.setQuery(any())).thenReturn(null);
    when(
      () => sites.setShowArchived(value: any(named: 'value')),
    ).thenReturn(null);
    final syncCubit = fakeSyncStatus(
      sync,
      onSyncNow: () async {
        syncCalls++;
        return SyncOutcome.completed;
      },
    );
    final currentSite = currentCubit ?? MockCurrentSiteCubit();
    if (currentCubit == null) {
      whenListen(
        currentSite,
        const Stream<CurrentSiteState>.empty(),
        initialState: current,
      );
    }
    await tester.pumpWidget(
      testApp(
        locale: locale,
        home: Scaffold(body: SitesView(onOpenSite: opened.add)),
        wrap: (app) => MultiBlocProvider(
          providers: [
            BlocProvider<SitesCubit>.value(value: sites),
            BlocProvider<SyncStatusCubit>.value(value: syncCubit),
            BlocProvider<CurrentSiteCubit>.value(value: currentSite),
          ],
          child: app,
        ),
      ),
    );
    await tester.pump();
  }

  SitesState loaded(
    List<SiteRow> list, {
    int? total,
    String query = '',
    bool archived = false,
  }) => SitesState(
    sites: list,
    totalCount: total ?? list.length,
    query: query,
    showArchived: archived,
    loaded: true,
  );

  group('Liste (CA-006)', () {
    testWidgets(
      'chaque ligne : code, nom, commune et wilaya ; un appui ouvre (1 geste)',
      (tester) async {
        final uv18 = _site('uv18', 'École UV18');
        await pumpList(tester, state: loaded([uv18]));

        expect(find.text('CH-uv18'), findsOneWidget);
        expect(find.text('École UV18'), findsOneWidget);
        expect(find.text('Boufarik · Blida'), findsOneWidget);

        await tester.tap(find.text('École UV18'));
        expect(opened.single.id, 'uv18');
      },
    );

    testWidgets('le code reste de gauche a droite (LtrText)', (tester) async {
      await pumpList(tester, state: loaded([_site('uv18', 'École UV18')]));

      expect(find.widgetWithText(LtrText, 'CH-uv18'), findsOneWidget);
    });

    testWidgets('chantier courant : marque et premier de la liste (CA-006.7)', (
      tester,
    ) async {
      final a = _site('a', 'Alpha');
      final b = _site('b', 'Beta');
      await pumpList(
        tester,
        state: loaded([a, b]),
        current: CurrentSiteState(site: b, sites: [a, b], loaded: true),
      );

      expect(find.text('Chantier courant'), findsOneWidget);
      expect(
        find.byIcon(Icons.push_pin),
        findsOneWidget,
        reason: 'icone ET texte',
      );
      final firstTop = tester.getTopLeft(find.text('Beta')).dy;
      final secondTop = tester.getTopLeft(find.text('Alpha')).dy;
      expect(firstTop, lessThan(secondTop));
    });

    testWidgets('archives : badge « Archive » (icone et texte)', (
      tester,
    ) async {
      await pumpList(
        tester,
        state: loaded([
          _site('z', 'Ancien', archivedAt: DateTime.utc(2026, 11, 1)),
        ], archived: true),
      );

      expect(find.text('Archivé'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });

    testWidgets(
      'arabe : nom arabe s\'il existe, sinon nom francais ; RTL ; code a gauche-droite (CA-014.6)',
      (tester) async {
        await pumpList(
          tester,
          locale: const Locale('ar'),
          state: loaded([
            _site('1', 'École UV18', nameAr: 'مدرسة UV18'),
            _site('2', 'Logements OL40'),
          ]),
        );

        expect(find.text('مدرسة UV18'), findsOneWidget);
        expect(find.text('Logements OL40'), findsOneWidget);
        expect(directionOf(tester, find.byType(SitesView)), TextDirection.rtl);
        final code = tester.element(find.text('CH-1'));
        expect(Directionality.of(code), TextDirection.ltr);
      },
    );

    testWidgets('liste vide : message et bouton Actualiser (CA-006.3)', (
      tester,
    ) async {
      await pumpList(tester, state: loaded(const []));

      expect(
        find.text(
          'Aucun chantier ne vous est affecté. Contactez votre administrateur.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Actualiser'));
      await tester.pump();
      expect(syncCalls, 1);
    });

    testWidgets('liste vide en arabe', (tester) async {
      await pumpList(
        tester,
        locale: const Locale('ar'),
        state: loaded(const []),
      );

      expect(
        find.text('لا توجد ورشة معينة لك. اتصل بالمسؤول.'),
        findsOneWidget,
      );
      expect(find.text('تحديث'), findsOneWidget);
    });

    testWidgets(
      'chargement local en cours : indicateur, jamais un ecran blanc',
      (tester) async {
        await pumpList(tester, state: const SitesState());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });

  group('Recherche et filtre', () {
    testWidgets('au-dela de 5 chantiers : champ de recherche', (tester) async {
      final many = [for (var i = 0; i < 6; i++) _site('$i', 'Chantier $i')];
      await pumpList(tester, state: loaded(many));

      expect(find.byIcon(Icons.search), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'uv18');
      verify(() => sites.setQuery('uv18')).called(1);
    });

    testWidgets('5 chantiers ou moins : pas de recherche', (tester) async {
      await pumpList(
        tester,
        state: loaded([for (var i = 0; i < 5; i++) _site('$i', 'Chantier $i')]),
      );

      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('« Afficher les archives »', (tester) async {
      await pumpList(tester, state: loaded([_site('a', 'Alpha')]));

      await tester.tap(find.byType(Switch));
      verify(() => sites.setShowArchived(value: true)).called(1);
    });

    testWidgets('recherche sans resultat', (tester) async {
      await pumpList(
        tester,
        state: const SitesState(
          sites: [],
          totalCount: 8,
          query: 'zzz',
          loaded: true,
        ),
      );

      expect(find.text('Aucun chantier ne correspond.'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Actualiser'), findsNothing);
    });
  });

  group('Hors ligne et premiere preparation', () {
    testWidgets(
      'premiere preparation : « Preparation de vos chantiers… » avec l\'avancement (CA-012.2)',
      (tester) async {
        await pumpList(
          tester,
          state: loaded(const []),
          sync: const SyncStatusSnapshot(
            indicator: SyncIndicator.syncing,
            itemsReceived: 12,
          ),
        );

        expect(find.text('Préparation de vos chantiers…'), findsOneWidget);
        expect(find.text('12 éléments reçus'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'premiere preparation hors ligne : message clair + Reessayer, pas de chargement sans fin',
      (tester) async {
        await pumpList(
          tester,
          state: loaded(const []),
          sync: const SyncStatusSnapshot(indicator: SyncIndicator.offline),
        );

        expect(find.textContaining('Pas de réseau'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.tap(find.widgetWithText(OutlinedButton, 'Réessayer'));
        await tester.pump();
        expect(syncCalls, 1);
      },
    );

    testWidgets('premiere preparation en arabe', (tester) async {
      await pumpList(
        tester,
        locale: const Locale('ar'),
        state: loaded(const []),
        sync: const SyncStatusSnapshot(
          indicator: SyncIndicator.syncing,
          itemsReceived: 2,
        ),
      );

      expect(find.text('جارٍ تجهيز ورشاتك…'), findsOneWidget);
      expect(find.text('تم استلام عنصرين'), findsOneWidget);
    });

    testWidgets(
      'hors ligne apres une synchro : la liste reste lisible avec « Donnees du ... » (CA-006.5)',
      (tester) async {
        await pumpList(
          tester,
          state: loaded([_site('uv18', 'École UV18')]),
          sync: SyncStatusSnapshot(
            indicator: SyncIndicator.offline,
            initialSyncDone: true,
            lastSuccessAt: DateTime.utc(2026, 11, 24, 9, 30),
          ),
        );

        expect(find.text('École UV18'), findsOneWidget);
        expect(
          findTextContaining('Données du 24/11/2026 10:30'),
          findsOneWidget,
        );
      },
    );

    testWidgets('en ligne : pas de « Donnees du ... » dans la liste', (
      tester,
    ) async {
      await pumpList(
        tester,
        state: loaded([_site('a', 'Alpha')]),
        sync: _synced,
      );

      expect(find.textContaining('Données du'), findsNothing);
    });

    testWidgets('tirer pour synchroniser : une synchronisation', (
      tester,
    ) async {
      await pumpList(tester, state: loaded([_site('a', 'Alpha')]));

      await tester.fling(find.text('Alpha'), const Offset(0, 400), 1000);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(syncCalls, 1);
    });
  });

  group('Chantier courant (CA-010)', () {
    testWidgets('chantier courant retire : message, avec fermeture', (
      tester,
    ) async {
      final current = MockCurrentSiteCubit();
      whenListen(
        current,
        const Stream<CurrentSiteState>.empty(),
        initialState: const CurrentSiteState(loaded: true, removed: true),
      );
      when(current.acknowledgeRemoved).thenReturn(null);
      await pumpList(
        tester,
        state: loaded([_site('a', 'Alpha'), _site('b', 'Beta')]),
        currentCubit: current,
      );

      expect(
        find.text(
          'Votre chantier courant ne vous est plus affecté. Choisissez-en un autre.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.close));
      verify(current.acknowledgeRemoved).called(1);
    });

    testWidgets(
      'plusieurs chantiers et aucun courant : invitation a choisir (CA-010.2)',
      (tester) async {
        final a = _site('a', 'Alpha');
        final b = _site('b', 'Beta');
        await pumpList(
          tester,
          state: loaded([a, b]),
          current: CurrentSiteState(sites: [a, b], loaded: true),
        );

        expect(
          find.text('Choisissez votre chantier avant de faire une saisie.'),
          findsOneWidget,
        );
      },
    );
  });
}
