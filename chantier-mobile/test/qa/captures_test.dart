// Q1 : captures FR / AR des ecrans principaux pour le controle visuel (RTL, contraste, tailles).
// Ne fait rien sans la variable d'environnement QA_CAPTURES (dossier de sortie) : le test est alors ignore.
// Rendu reel de la police Cairo ; telephone 360 x 720 dp, densite x2 ; aucune donnee reelle (jeu « Ecole UV18 »).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bloc_test/bloc_test.dart';
import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_screen.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_screen.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/pending_operations_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

final String? _out = Platform.environment['QA_CAPTURES'];

void main() {
  setUpAll(() async {
    final loader = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Variable.ttf'));
    await loader.load();
  });

  final key = GlobalKey();

  Future<void> save(WidgetTester tester, String name) async {
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_out/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
    });
  }

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget framed(Widget app) => RepaintBoundary(key: key, child: app);

  for (final lang in ['fr', 'ar']) {
    final locale = Locale(lang);

    testWidgets('capture connexion ($lang)', (tester) async {
      phone(tester);
      SharedPreferences.setMockInitialValues({});
      final repository = FakeAuthRepository();
      final events = SessionEvents();
      final bloc = AuthBloc(repository: repository, sessionEvents: events);
      addTearDown(() async {
        await bloc.close();
        await repository.dispose();
        await events.dispose();
      });
      final localeCubit = LocaleCubit(await SharedPreferences.getInstance());
      await tester.pumpWidget(
        testApp(
          locale: locale,
          home: const LoginScreen(),
          wrap: (app) => framed(
            MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: bloc),
                BlocProvider<LocaleCubit>.value(value: localeCubit),
              ],
              child: app,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await save(tester, 'mobile-connexion-$lang');
    }, skip: _out == null);

    testWidgets('capture Mes chantiers ($lang)', (tester) async {
      phone(tester);
      final sites = _MockSitesCubit();
      final list = [
        siteRow(nameAr: 'مدرسة UV18'),
        siteRow(
          id: 'ol40',
          code: 'CH-LOG-OL40',
          name: '40 logements Les Oliviers',
          nameAr: '40 مسكنًا الزيتون',
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
        initialState: CurrentSiteState(
          loaded: true,
          site: list.first,
          sites: list,
        ),
      );
      await tester.pumpWidget(
        testApp(
          locale: locale,
          home: Scaffold(body: SitesView(onOpenSite: (_) {})),
          wrap: (app) => framed(
            MultiBlocProvider(
              providers: [
                BlocProvider<SitesCubit>.value(value: sites),
                BlocProvider<SyncStatusCubit>.value(
                  value: fakeSyncStatus(
                    const SyncStatusSnapshot(
                      indicator: SyncIndicator.pending,
                      toSend: 3,
                      initialSyncDone: true,
                    ),
                  ),
                ),
                BlocProvider<CurrentSiteCubit>.value(value: current),
              ],
              child: app,
            ),
          ),
        ),
      );
      await tester.pump();
      await save(tester, 'mobile-mes-chantiers-$lang');
    }, skip: _out == null);

    testWidgets('capture fiche chantier ($lang)', (tester) async {
      phone(tester);
      tester.view.physicalSize = const Size(360, 1400);
      final cubit = _MockDetailCubit();
      whenListen(
        cubit,
        const Stream<SiteDetailState>.empty(),
        initialState: SiteDetailState(
          site: siteRow(
            nameAr: 'مدرسة UV18',
            contractAmount: Decimal.parse('185000000.00'),
            odsDate: DateTime.utc(2026, 3, 2),
            contractualEndDate: DateTime.utc(2027, 8, 24),
          ),
          zones: [
            zoneRow(
              id: 'z1',
              elevation: '-1.90',
              roomType: null,
              roomNumber: null,
            ),
            zoneRow(
              id: 'z2',
              elevation: '0.00',
              roomType: 'Corridor',
              roomNumber: null,
            ),
            zoneRow(id: 'z3'),
            zoneRow(
              id: 'z4',
              block: 'Bloc 02',
              elevation: '0.00',
              roomType: 'Canteen',
              roomNumber: null,
            ),
          ],
          members: [
            memberRow(),
            memberRow(
              id: 'm2',
              userId: 'u2',
              fullName: 'Toufik G.',
              role: 'ChefEquipe',
            ),
          ],
          loaded: true,
        ),
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
          wrap: (app) => framed(
            MultiBlocProvider(
              providers: [
                BlocProvider<SiteDetailCubit>.value(value: cubit),
                BlocProvider<AuthBloc>.value(value: auth),
              ],
              child: app,
            ),
          ),
        ),
      );
      await tester.pump();
      await save(tester, 'mobile-fiche-chantier-$lang');
    }, skip: _out == null);

    testWidgets('capture envois en attente ($lang)', (tester) async {
      phone(tester);
      final outbox = _MockOutbox();
      final rows = [
        OutboxRow(
          id: 1,
          clientId: 'c-1',
          ownerUserId: 'user-a',
          entity: 'zone',
          operation: 'create',
          siteId: 'site-uv18',
          label: 'Bloc 01 · +3,40 m · Classe 07',
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
          label: 'Bloc 02 · ±0,00 m · Cantine',
          payloadJson: '{}',
          status: OutboxStatus.rejected,
          attempts: 1,
          lastErrorCode: 'ZONE_EXISTANTE',
          createdAt: DateTime.utc(2026, 11, 24, 6, 59),
        ),
      ];
      when(() => outbox.watch('user-a')).thenAnswer((_) => Stream.value(rows));
      await tester.pumpWidget(
        testApp(
          locale: locale,
          home: PendingOperationsScreen(
            userId: 'user-a',
            outbox: outbox,
            onCorrect: (_) {},
          ),
          wrap: (app) => framed(
            BlocProvider<SyncStatusCubit>.value(
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
        ),
      );
      await tester.pump();
      await tester.pump();
      await save(tester, 'mobile-envois-en-attente-$lang');
    }, skip: _out == null);
  }
}
