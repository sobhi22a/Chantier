import 'dart:async';

import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/sync/sync_status.dart';
import 'package:chantier_mobile/core/sync/sync_status_cubit.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/logout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/pump_app.dart';

void main() {
  late FakeAuthRepository repository;
  late SessionEvents events;
  AuthBloc? createdBloc;

  AuthBloc bloc() =>
      createdBloc ??= AuthBloc(repository: repository, sessionEvents: events);

  setUp(() {
    repository = FakeAuthRepository(
      restored: RestoredSession.signedIn(testUser()),
    );
    events = SessionEvents();
    createdBloc = null;
  });

  tearDown(() async {
    await createdBloc?.close();
    await repository.dispose();
    await events.dispose();
  });

  Future<void> pumpLogout(
    WidgetTester tester, {
    required SyncStatusSnapshot status,
    Locale locale = const Locale('fr'),
    Future<SyncOutcome> Function()? onSyncNow,
  }) async {
    final sync = fakeSyncStatus(status, onSyncNow: onSyncNow);
    bloc().add(const AuthStarted());
    await tester.pumpWidget(
      testApp(
        home: const LogoutScreen(),
        locale: locale,
        wrap: (app) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: bloc()),
            BlocProvider<SyncStatusCubit>.value(value: sync),
          ],
          child: app,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const nothing = SyncStatusSnapshot(indicator: SyncIndicator.upToDate);
  const three = SyncStatusSnapshot(indicator: SyncIndicator.pending, toSend: 3);

  testWidgets('rien en attente : simple confirmation', (tester) async {
    await pumpLogout(tester, status: nothing);

    expect(find.textContaining('ne sont pas encore envoyées'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Se déconnecter'), findsOneWidget);
    expect(find.text('Se déconnecter quand même'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Se déconnecter'));
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 1);
    expect(bloc().state.status, AuthStatus.unauthenticated);
  });

  testWidgets(
    'N saisies en attente : avertissement avec le nombre exact (CA-002.3)',
    (tester) async {
      await pumpLogout(tester, status: three);

      expect(
        find.text('3 saisies ne sont pas encore envoyées'),
        findsOneWidget,
      );
      expect(find.text('Envoyer d\'abord'), findsOneWidget);
      expect(find.text('Rester connecté'), findsOneWidget);
      expect(find.text('Se déconnecter quand même'), findsOneWidget);
    },
  );

  testWidgets('une seule saisie : singulier', (tester) async {
    await pumpLogout(
      tester,
      status: const SyncStatusSnapshot(
        indicator: SyncIndicator.pending,
        toSend: 1,
      ),
    );

    expect(find.text('1 saisie n\'est pas encore envoyée'), findsOneWidget);
  });

  testWidgets('les saisies a verifier comptent aussi (refusees, en conflit)', (
    tester,
  ) async {
    await pumpLogout(
      tester,
      status: const SyncStatusSnapshot(
        indicator: SyncIndicator.problem,
        toSend: 1,
        toCheck: 2,
      ),
    );

    expect(find.text('3 saisies ne sont pas encore envoyées'), findsOneWidget);
  });

  testWidgets(
    'les boutons principaux sont gros et en premier, « quand meme » petit et en dernier',
    (tester) async {
      await pumpLogout(tester, status: three);

      final send = tester.getRect(
        find.ancestor(
          of: find.text('Envoyer d\'abord'),
          matching: find.bySubtype<FilledButton>(),
        ),
      );
      final stay = tester.getRect(
        find.widgetWithText(OutlinedButton, 'Rester connecté'),
      );
      final anyway = tester.getRect(
        find.widgetWithText(TextButton, 'Se déconnecter quand même'),
      );

      expect(send.height, greaterThanOrEqualTo(56));
      expect(stay.height, greaterThanOrEqualTo(56));
      expect(send.top, lessThan(stay.top));
      expect(stay.top, lessThan(anyway.top));
      expect(anyway.width, lessThan(send.width));
    },
  );

  testWidgets(
    '« Se deconnecter quand meme » demande une SECONDE confirmation',
    (tester) async {
      await pumpLogout(tester, status: three);

      await tester.tap(find.text('Se déconnecter quand même'));
      await tester.pumpAndSettle();

      expect(
        find.text('Se déconnecter avec des saisies en attente ?'),
        findsOneWidget,
      );
      expect(repository.logoutCalls, 0, reason: 'pas encore deconnecte');
    },
  );

  testWidgets(
    'seconde confirmation : « Rester connecte » en gros, rien n\'est fait',
    (tester) async {
      await pumpLogout(tester, status: three);
      await tester.tap(find.text('Se déconnecter quand même'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Rester connecté'),
        ),
      );
      await tester.pumpAndSettle();

      expect(repository.logoutCalls, 0);
      expect(bloc().state.status, AuthStatus.authenticated);
    },
  );

  testWidgets('seconde confirmation acceptee : deconnexion', (tester) async {
    await pumpLogout(tester, status: three);
    await tester.tap(find.text('Se déconnecter quand même'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Se déconnecter'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 1);
    expect(bloc().state.status, AuthStatus.unauthenticated);
  });

  testWidgets(
    '« Envoyer d\'abord » lance une seule synchronisation meme avec un double appui',
    (tester) async {
      var calls = 0;
      final gate = Completer<SyncOutcome>();
      await pumpLogout(
        tester,
        status: three,
        onSyncNow: () {
          calls++;
          return gate.future;
        },
      );

      await tester.tap(find.text('Envoyer d\'abord'));
      await tester.pump();
      expect(find.text('Envoi en cours…'), findsOneWidget);
      await tester.tap(
        find.bySubtype<FilledButton>().first,
        warnIfMissed: false,
      );
      await tester.pump();
      gate.complete(SyncOutcome.completed);
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(
        repository.logoutCalls,
        0,
        reason: 'l\'envoi ne deconnecte pas tout seul',
      );
    },
  );

  testWidgets(
    'envoi qui echoue : message, saisies conservees, toujours connecte',
    (tester) async {
      await pumpLogout(
        tester,
        status: three,
        onSyncNow: () async => SyncOutcome.offline,
      );

      await tester.tap(find.text('Envoyer d\'abord'));
      await tester.pumpAndSettle();

      expect(
        find.text('L\'envoi n\'a pas abouti. Vos saisies sont conservées.'),
        findsOneWidget,
      );
      expect(bloc().state.status, AuthStatus.authenticated);
    },
  );

  testWidgets('arabe : RTL, pluriel arabe (deux saisies)', (tester) async {
    await pumpLogout(
      tester,
      locale: const Locale('ar'),
      status: const SyncStatusSnapshot(
        indicator: SyncIndicator.pending,
        toSend: 2,
      ),
    );

    expect(directionOf(tester, find.byType(LogoutScreen)), TextDirection.rtl);
    expect(find.text('إدخالان لم يُرسلا بعد'), findsOneWidget);
    expect(find.text('أرسل أولاً'), findsOneWidget);
    expect(find.text('تسجيل الخروج رغم ذلك'), findsOneWidget);
  });
}
