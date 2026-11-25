// Q1 : en arabe, un nom latin se terminant par un point (« Mourad B. ») doit etre isole de gauche a droite,
// sinon le point passe a gauche du nom (« .Mourad B »). Constate sur la capture mobile-fiche-chantier-ar.png.
import 'package:bloc_test/bloc_test.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_auth_repository.dart';
import '../support/fixtures.dart';
import '../support/pump_app.dart';

class _MockDetailCubit extends MockCubit<SiteDetailState>
    implements SiteDetailCubit {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  testWidgets(
    'fiche en arabe : les noms de personnes (membres, createur) sont isoles de gauche a droite',
    (tester) async {
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final cubit = _MockDetailCubit();
      whenListen(
        cubit,
        const Stream<SiteDetailState>.empty(),
        initialState: SiteDetailState(
          site: siteRow(),
          zones: const [],
          members: [memberRow(fullName: 'Mourad B.')],
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
          locale: const Locale('ar'),
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

      final lri = String.fromCharCode(0x2066);
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .toList();
      final member = texts.firstWhere((t) => t.contains('Mourad B.'));
      final creator = texts.firstWhere((t) => t.contains('Farid L.'));
      expect(
        member,
        contains(lri),
        reason: 'nom du membre isole : « $member »',
      );
      expect(
        creator,
        contains(lri),
        reason: 'nom du createur isole : « $creator »',
      );
    },
  );
}
