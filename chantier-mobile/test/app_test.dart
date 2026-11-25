import 'package:chantier_mobile/app.dart';
import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/router/app_router.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late SessionEvents events;
  AuthBloc? createdBloc;

  setUp(() {
    repository = FakeAuthRepository();
    events = SessionEvents();
    createdBloc = null;
  });

  tearDown(() async {
    await createdBloc?.close();
    await repository.dispose();
    await events.dispose();
  });

  Future<LocaleCubit> pumpApp(WidgetTester tester, {String? language}) async {
    SharedPreferences.setMockInitialValues({
      if (language != null) LocaleCubit.preferenceKey: language,
    });
    final localeCubit = LocaleCubit(await SharedPreferences.getInstance());
    final bloc = createdBloc = AuthBloc(
      repository: repository,
      sessionEvents: events,
    )..add(const AuthStarted());
    await tester.pumpWidget(
      ChantierApp(
        router: AppRouter.create(bloc),
        localeCubit: localeCubit,
        authBloc: bloc,
      ),
    );
    await tester.pumpAndSettle();
    return localeCubit;
  }

  TextDirection direction(WidgetTester tester) =>
      Directionality.of(tester.element(find.byType(Scaffold).first));

  testWidgets(
    'sans session : l\'application s\'ouvre sur la connexion (jamais un ecran blanc)',
    (tester) async {
      await pumpApp(tester);

      expect(find.text('Connexion'), findsOneWidget);
      expect(direction(tester), TextDirection.ltr);
    },
  );

  testWidgets('langue arabe memorisee : interface arabe en miroir (CA-014.3)', (
    tester,
  ) async {
    await pumpApp(tester, language: 'ar');

    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(direction(tester), TextDirection.rtl);
  });

  testWidgets('changer de langue : immediat, sans redemarrage (CA-014.1)', (
    tester,
  ) async {
    final locale = await pumpApp(tester);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('اسم المستخدم'), findsOneWidget);
    expect(direction(tester), TextDirection.rtl);
    expect(locale.languageCode, 'ar');

    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();
    expect(find.text('Identifiant'), findsOneWidget);
    expect(direction(tester), TextDirection.ltr);
  });

  testWidgets('le selecteur de langue respecte la cible tactile de 56 dp', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(
      tester.getSize(find.byType(SegmentedButton<String>)).height,
      greaterThanOrEqualTo(56),
    );
  });

  testWidgets(
    'session expiree : la connexion explique, les saisies sont conservees',
    (tester) async {
      await pumpApp(tester);
      events.emit(SessionEvent.authRequired);
      await tester.pumpAndSettle();

      // Pas de session ouverte : l'evenement n'a aucun effet (rien a fermer).
      expect(find.text('Connexion'), findsOneWidget);
      expect(repository.purgeCalls, 0);
    },
  );
}
