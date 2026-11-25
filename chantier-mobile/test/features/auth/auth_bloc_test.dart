import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late SessionEvents events;

  setUp(() {
    repository = FakeAuthRepository();
    events = SessionEvents();
  });

  tearDown(() async {
    await repository.dispose();
    await events.dispose();
  });

  AuthBloc build() => AuthBloc(repository: repository, sessionEvents: events);

  group('Verifier la session (CA-002.1, CA-002.2)', () {
    blocTest<AuthBloc, AuthState>(
      'aucune session : connexion demandee',
      build: build,
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'session recente restauree hors ligne : directement connecte',
      setUp: () => repository.restored = RestoredSession.signedIn(testUser()),
      build: build,
      act: (bloc) => bloc.add(const AuthStarted()),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.user, testUser());
      },
    );

    blocTest<AuthBloc, AuthState>(
      'session trop ancienne : reconnexion avec message, saisies conservees',
      setUp: () => repository.restored = const RestoredSession.signedOut(
        SessionEnd.expired,
      ),
      build: build,
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        const AuthState.unauthenticated(notice: AuthNotice.sessionExpired),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'mot de passe provisoire a la restauration : changement obligatoire',
      setUp: () => repository.restored = RestoredSession.signedIn(
        testUser(mustChangePassword: true),
      ),
      build: build,
      act: (bloc) => bloc.add(const AuthStarted()),
      verify: (bloc) =>
          expect(bloc.state.status, AuthStatus.passwordChangeRequired),
    );
  });

  group('Connexion (CT-1)', () {
    blocTest<AuthBloc, AuthState>(
      'succes : envoi en cours puis connecte',
      setUp: () => repository.loginResult = testUser(),
      build: build,
      act: (bloc) => bloc.add(
        const AuthLoginSubmitted(userName: ' chef.dev ', password: 'secret'),
      ),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(
          repository.loginAttempts.single.$1,
          'chef.dev',
          reason: 'identifiant nettoye',
        );
      },
      expect: () => [
        isA<AuthState>().having((s) => s.isSubmitting, 'submitting', true),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.authenticated,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'mot de passe provisoire : changement obligatoire avant d\'aller plus loin (CA-001.7)',
      setUp: () => repository.loginResult = testUser(mustChangePassword: true),
      build: build,
      act: (bloc) => bloc.add(
        const AuthLoginSubmitted(userName: 'chef.dev', password: 'provisoire'),
      ),
      verify: (bloc) =>
          expect(bloc.state.status, AuthStatus.passwordChangeRequired),
    );

    blocTest<AuthBloc, AuthState>(
      'identifiants invalides : meme etat d\'echec, rien ne revele l\'identifiant (CA-001.3)',
      setUp: () => repository.loginError = const UnauthorizedApiException(
        status: 401,
        code: 'IDENTIFIANTS_INVALIDES',
      ),
      build: build,
      act: (bloc) => bloc.add(
        const AuthLoginSubmitted(userName: 'inconnu', password: 'x'),
      ),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.unauthenticated);
        expect(bloc.state.isSubmitting, isFalse);
        expect(bloc.state.failure?.code, 'IDENTIFIANTS_INVALIDES');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'trop d\'essais (429) : conserve le code',
      setUp: () => repository.loginError = const TooManyRequestsApiException(
        status: 429,
        code: 'TROP_D_ESSAIS',
        retryAfter: Duration(minutes: 15),
      ),
      build: build,
      act: (bloc) => bloc.add(
        const AuthLoginSubmitted(userName: 'chef.dev', password: 'x'),
      ),
      verify: (bloc) => expect(bloc.state.failure?.code, 'TROP_D_ESSAIS'),
    );

    blocTest<AuthBloc, AuthState>(
      'premiere connexion hors ligne : echec reseau (« reseau necessaire »), pas d\'ecran bloque',
      setUp: () => repository.loginError = const NetworkApiException(),
      build: build,
      act: (bloc) => bloc.add(
        const AuthLoginSubmitted(userName: 'chef.dev', password: 'x'),
      ),
      verify: (bloc) {
        expect(bloc.state.failure, isA<NetworkApiException>());
        expect(bloc.state.isSubmitting, isFalse);
      },
    );

    test('double appui : une seule demande part (CA-001.6)', () async {
      repository
        ..loginResult = testUser()
        ..loginGate = Completer<void>();
      final bloc = build();

      bloc
        ..add(const AuthLoginSubmitted(userName: 'chef.dev', password: 'x'))
        ..add(const AuthLoginSubmitted(userName: 'chef.dev', password: 'x'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      repository.loginGate!.complete();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(repository.loginCalls, 1);
      await bloc.close();
    });

    test(
      'le mot de passe n\'apparait jamais dans la description de l\'evenement',
      () {
        const event = AuthLoginSubmitted(
          userName: 'chef.dev',
          password: 'MotDePasse-Secret',
        );

        expect(event.toString(), isNot(contains('MotDePasse-Secret')));
        expect(
          const AuthPasswordChangeSubmitted(
            currentPassword: 'a-secret',
            newPassword: 'b-secret',
          ).toString(),
          isNot(contains('secret')),
        );
      },
    );
  });

  group('Mot de passe provisoire (CA-001.7)', () {
    blocTest<AuthBloc, AuthState>(
      'changement reussi : connecte',
      setUp: () => repository.restored = RestoredSession.signedIn(
        testUser(mustChangePassword: true),
      ),
      build: build,
      act: (bloc) async {
        bloc.add(const AuthStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          const AuthPasswordChangeSubmitted(
            currentPassword: 'provisoire',
            newPassword: 'NouveauMotDePasse-1',
          ),
        );
      },
      verify: (bloc) => expect(bloc.state.status, AuthStatus.authenticated),
    );

    blocTest<AuthBloc, AuthState>(
      'mot de passe faible (422) : reste sur le changement, avec le code',
      setUp: () {
        repository
          ..restored = RestoredSession.signedIn(
            testUser(mustChangePassword: true),
          )
          ..changePasswordError = const BusinessRuleApiException(
            status: 422,
            code: 'MOT_DE_PASSE_FAIBLE',
          );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const AuthStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          const AuthPasswordChangeSubmitted(
            currentPassword: 'a',
            newPassword: 'b',
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.passwordChangeRequired);
        expect(bloc.state.failure?.code, 'MOT_DE_PASSE_FAIBLE');
        expect(bloc.state.isSubmitting, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      '403 MOT_DE_PASSE_A_CHANGER recu pendant l\'usage : redirige vers le changement de mot de passe',
      setUp: () => repository.restored = RestoredSession.signedIn(testUser()),
      build: build,
      act: (bloc) async {
        bloc.add(const AuthStarted());
        await Future<void>.delayed(Duration.zero);
        events.emit(SessionEvent.passwordChangeRequired);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.passwordChangeRequired);
        expect(bloc.state.user?.mustChangePassword, isTrue);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'profil recu du serveur avec mot de passe provisoire : meme redirection',
      setUp: () => repository.restored = RestoredSession.signedIn(testUser()),
      build: build,
      act: (bloc) async {
        bloc.add(const AuthStarted());
        await Future<void>.delayed(Duration.zero);
        repository.pushProfile(testUser(mustChangePassword: true));
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) =>
          expect(bloc.state.status, AuthStatus.passwordChangeRequired),
    );

    blocTest<AuthBloc, AuthState>(
      'profil mis a jour (permissions) : l\'utilisateur est remplace',
      setUp: () => repository.restored = RestoredSession.signedIn(testUser()),
      build: build,
      act: (bloc) async {
        bloc.add(const AuthStarted());
        await Future<void>.delayed(Duration.zero);
        repository.pushProfile(
          testUser(permissions: const ['Sites.View'], permissionsVersion: 'b'),
        );
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        expect(bloc.state.user?.permissionsVersion, 'b');
        expect(bloc.state.user?.can('Zones.Create'), isFalse);
      },
    );
  });

  group('Evenements de session de la couche reseau', () {
    Future<AuthBloc> signedIn() async {
      repository.restored = RestoredSession.signedIn(testUser());
      final bloc = build()..add(const AuthStarted());
      await Future<void>.delayed(Duration.zero);
      return bloc;
    }

    test(
      'jetons refuses : reconnexion, SANS purge (saisies et donnees conservees)',
      () async {
        final bloc = await signedIn();

        events.emit(SessionEvent.authRequired);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(bloc.state.status, AuthStatus.unauthenticated);
        expect(bloc.state.notice, AuthNotice.sessionExpired);
        expect(repository.purgeCalls, 0);
        await bloc.close();
      },
    );

    test(
      'compte retire : donnees chantier effacees, message dedie (CA-002.5)',
      () async {
        final bloc = await signedIn();

        events.emit(SessionEvent.accessRevoked);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(bloc.state.status, AuthStatus.unauthenticated);
        expect(bloc.state.notice, AuthNotice.accessRevoked);
        expect(repository.purgeCalls, 1);
        await bloc.close();
      },
    );

    test('evenement recu sans session : ignore', () async {
      final bloc = build()..add(const AuthStarted());
      await Future<void>.delayed(Duration.zero);

      events.emit(SessionEvent.accessRevoked);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.purgeCalls, 0);
      await bloc.close();
    });
  });

  group('Deconnexion', () {
    test('deconnecte et efface la session', () async {
      repository.restored = RestoredSession.signedIn(testUser());
      final bloc = build()..add(const AuthStarted());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const AuthLogoutRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.logoutCalls, 1);
      expect(bloc.state.status, AuthStatus.unauthenticated);
      expect(bloc.state.user, isNull);
      await bloc.close();
    });
  });
}
