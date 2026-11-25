// Q1 : ecrans principaux sur un petit telephone (320 x 568 dp) avec la police systeme agrandie (x2),
// en francais et en arabe (RTL), avec des textes longs : aucun debordement, l'action principale reste atteignable.
import 'package:bloc_test/bloc_test.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/core/widgets/sync_status_bar.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_screen.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_screen.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/pending_operations_screen.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:chantier_mobile/features/zones/presentation/add_zone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_auth_repository.dart';
import '../support/fixtures.dart';
import '../support/pump_app.dart';

class _MockSitesCubit extends MockCubit<SitesState> implements SitesCubit {}

class _MockDetailCubit extends MockCubit<SiteDetailState>
    implements SiteDetailCubit {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockOutbox extends Mock implements OutboxRepository {}

class _MockZonesRepository extends Mock implements ZonesRepository {}

/// 100 lettres arabes : nom ou libelle tres long, sans espace pour forcer le pire cas du retour a la ligne.
final _longArabic = List.filled(100, 'ع').join();

/// Petit telephone Android (320 dp de large) et police systeme au maximum (x2).
void _smallScreenLargeFont(WidgetTester tester, {double fontScale = 2.0}) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = fontScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

const _locales = [Locale('fr'), Locale('ar')];

void main() {
  // Sans la vraie police, flutter_test mesure avec « Ahem » (chaque caractere = 1 em) : de faux debordements.
  // Cairo est la police de l'application (assets/fonts) : les mesures sont celles du telephone.
  setUpAll(() async {
    final loader = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Variable.ttf'));
    await loader.load();
  });

  for (final locale in _locales) {
    final lang = locale.languageCode;

    group('Petit ecran + police x2 ($lang)', () {
      testWidgets(
        'connexion : pas de debordement, le bouton reste atteignable',
        (tester) async {
          _smallScreenLargeFont(tester);
          SharedPreferences.setMockInitialValues({});
          final repository = FakeAuthRepository();
          final events = SessionEvents();
          final bloc = AuthBloc(repository: repository, sessionEvents: events);
          addTearDown(() async {
            await bloc.close();
            await repository.dispose();
            await events.dispose();
          });
          final localeCubit = LocaleCubit(
            await SharedPreferences.getInstance(),
          );

          await tester.pumpWidget(
            testApp(
              locale: locale,
              home: const LoginScreen(),
              wrap: (app) => MultiBlocProvider(
                providers: [
                  BlocProvider<AuthBloc>.value(value: bloc),
                  BlocProvider<LocaleCubit>.value(value: localeCubit),
                ],
                child: app,
              ),
            ),
          );
          await tester.pumpAndSettle();

          final button = find.byType(FilledButton);
          await tester.ensureVisible(button);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'debordement');
          expect(button, findsOneWidget);
          final rect = tester.getRect(button);
          expect(
            rect.bottom,
            lessThanOrEqualTo(568),
            reason: 'bouton principal visible',
          );
          expect(rect.height, greaterThanOrEqualTo(56));
        },
      );

      testWidgets('Mes chantiers : noms tres longs, pas de debordement', (
        tester,
      ) async {
        _smallScreenLargeFont(tester);
        final sites = _MockSitesCubit();
        final list = [
          for (var i = 0; i < 8; i++)
            siteRow(
              id: 's$i',
              code: 'CH-LONG-$i',
              name: 'École des Oliviers de la commune $i',
              nameAr: _longArabic,
            ),
        ];
        whenListen(
          sites,
          const Stream<SitesState>.empty(),
          initialState: SitesState(
            sites: list,
            totalCount: list.length,
            query: '',
            showArchived: false,
            loaded: true,
          ),
        );
        when(() => sites.setQuery(any())).thenReturn(null);
        when(
          () => sites.setShowArchived(value: any(named: 'value')),
        ).thenReturn(null);
        final current = MockCurrentSiteCubit();
        whenListen(
          current,
          const Stream<CurrentSiteState>.empty(),
          initialState: const CurrentSiteState(loaded: true),
        );

        await tester.pumpWidget(
          testApp(
            locale: locale,
            home: Scaffold(body: SitesView(onOpenSite: (_) {})),
            wrap: (app) => MultiBlocProvider(
              providers: [
                BlocProvider<SitesCubit>.value(value: sites),
                BlocProvider<SyncStatusCubit>.value(
                  value: fakeSyncStatus(
                    const SyncStatusSnapshot(
                      indicator: SyncIndicator.pending,
                      toSend: 123,
                    ),
                  ),
                ),
                BlocProvider<CurrentSiteCubit>.value(value: current),
              ],
              child: app,
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull, reason: 'debordement');
        expect(find.byType(SitesView), findsOneWidget);
      });

      testWidgets(
        'fiche chantier : zones et personnes longues, pas de debordement',
        (tester) async {
          _smallScreenLargeFont(tester);
          final cubit = _MockDetailCubit();
          final state = SiteDetailState(
            site: siteRow(name: 'École UV18', nameAr: _longArabic),
            zones: [
              zoneRow(id: 'z1'),
              zoneRow(
                id: 'z2',
                block: 'Bloc 02',
                roomType: 'Other',
                roomNumber: null,
                roomLabel: _longArabic,
              ),
              zoneRow(id: 'z3', block: _longArabic, elevation: '-1.90'),
            ],
            members: [
              memberRow(fullName: _longArabic),
              memberRow(id: 'm2', userId: 'u2', fullName: 'Toufik G.'),
            ],
            loaded: true,
          );
          whenListen(
            cubit,
            const Stream<SiteDetailState>.empty(),
            initialState: state,
          );
          final auth = _MockAuthBloc();
          whenListen(
            auth,
            const Stream<AuthState>.empty(),
            initialState: AuthState.authenticated(testUser()),
          );

          await tester.pumpWidget(
            testApp(
              locale: locale,
              home: SiteDetailScreen(onAddZone: (_) {}),
              wrap: (app) => MultiBlocProvider(
                providers: [
                  BlocProvider<SiteDetailCubit>.value(value: cubit),
                  BlocProvider<AuthBloc>.value(value: auth),
                ],
                child: app,
              ),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull, reason: 'debordement');
        },
      );

      testWidgets(
        'envois en attente : libelle tres long et motif, pas de debordement',
        (tester) async {
          _smallScreenLargeFont(tester);
          final outbox = _MockOutbox();
          final rows = [
            OutboxRow(
              id: 1,
              clientId: 'c-1',
              ownerUserId: 'user-a',
              entity: 'zone',
              operation: 'create',
              siteId: 'site-uv18',
              label: _longArabic,
              payloadJson: '{}',
              status: OutboxStatus.pending,
              attempts: 0,
              lastErrorCode: null,
              createdAt: DateTime.utc(2026, 11, 24, 6, 58),
            ),
            OutboxRow(
              id: 2,
              clientId: 'c-2',
              ownerUserId: 'user-a',
              entity: 'zone',
              operation: 'create',
              siteId: 'site-uv18',
              label: 'Bloc 01 · +3,40 m · Classe 07',
              payloadJson: '{}',
              status: OutboxStatus.rejected,
              attempts: 1,
              lastErrorCode: 'ZONE_EXISTANTE',
              createdAt: DateTime.utc(2026, 11, 24, 6, 59),
            ),
          ];
          when(
            () => outbox.watch('user-a'),
          ).thenAnswer((_) => Stream.value(rows));

          await tester.pumpWidget(
            testApp(
              locale: locale,
              home: PendingOperationsScreen(
                userId: 'user-a',
                outbox: outbox,
                onCorrect: (_) {},
              ),
              wrap: (app) => BlocProvider<SyncStatusCubit>.value(
                value: fakeSyncStatus(
                  const SyncStatusSnapshot(
                    indicator: SyncIndicator.problem,
                    toSend: 1,
                    toCheck: 1,
                  ),
                ),
                child: app,
              ),
            ),
          );
          await tester.pump();
          await tester.pump();

          expect(tester.takeException(), isNull, reason: 'debordement');
        },
      );

      testWidgets('ajout de zone : le bouton Enregistrer reste atteignable', (
        tester,
      ) async {
        _smallScreenLargeFont(tester);
        final repository = _MockZonesRepository();
        final zones = [
          zoneRow(id: 'a', elevation: '-1.90', roomNumber: 1),
          zoneRow(id: 'b', elevation: '0.00', roomNumber: 1),
          zoneRow(id: 'c', elevation: '3.40', roomNumber: 2),
          zoneRow(id: 'd', block: 'Bloc 02', elevation: '6.80'),
        ];
        when(
          () => repository.watchZones('site-uv18'),
        ).thenAnswer((_) => Stream.value(zones));
        when(
          () => repository.lastUsedZone('user-a'),
        ).thenAnswer((_) async => zones[2]);
        when(
          () => repository.rememberZone(any(), any()),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(
          testApp(
            locale: locale,
            home: AddZoneScreen(
              siteId: 'site-uv18',
              userId: 'user-a',
              repository: repository,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'debordement');
        final save = find.byType(FilledButton);
        expect(save, findsWidgets);
        await tester.ensureVisible(save.last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.getRect(save.last).bottom, lessThanOrEqualTo(568));
      });

      testWidgets(
        'barre de synchronisation : compteur a 3 chiffres, pas de debordement',
        (tester) async {
          _smallScreenLargeFont(tester);
          await tester.pumpWidget(
            testApp(
              locale: locale,
              home: Scaffold(
                body: SyncStatusBar(onTap: () {}, now: DateTime.now),
              ),
              wrap: (app) => BlocProvider<SyncStatusCubit>.value(
                value: fakeSyncStatus(
                  const SyncStatusSnapshot(
                    indicator: SyncIndicator.offline,
                    toSend: 200,
                  ),
                ),
                child: app,
              ),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull, reason: 'debordement');
        },
      );
    });
  }
}
