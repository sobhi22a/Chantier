import 'dart:async';

import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/change_password_screen.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/pump_app.dart';

void main() {
  late FakeAuthRepository repository;
  late SessionEvents events;
  AuthBloc? createdBloc;

  // Le bloc est cree DANS le test (zone de `testWidgets`) : cree dans `setUp`, ses evenements
  // asynchrones ne seraient jamais avances par `pump`.
  AuthBloc bloc() =>
      createdBloc ??= AuthBloc(repository: repository, sessionEvents: events);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = FakeAuthRepository();
    events = SessionEvents();
    createdBloc = null;
  });

  tearDown(() async {
    await createdBloc?.close();
    await repository.dispose();
    await events.dispose();
  });

  Future<void> pumpLogin(
    WidgetTester tester, {
    Locale locale = const Locale('fr'),
    Widget home = const LoginScreen(),
  }) async {
    final localeCubit = LocaleCubit(await SharedPreferences.getInstance());
    await tester.pumpWidget(
      testApp(
        home: home,
        locale: locale,
        wrap: (app) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: bloc()),
            BlocProvider<LocaleCubit>.value(value: localeCubit),
          ],
          child: app,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  group('Ecran de connexion (CA-001)', () {
    testWidgets('francais : titre, champs, bouton principal de 56 dp', (
      tester,
    ) async {
      await pumpLogin(tester);

      expect(find.text('Connexion'), findsOneWidget);
      expect(field('Identifiant'), findsOneWidget);
      expect(field('Mot de passe'), findsOneWidget);
      final button = tester.getSize(
        find.widgetWithText(FilledButton, 'Se connecter'),
      );
      expect(button.height, greaterThanOrEqualTo(56));
    });

    testWidgets('arabe : interface en miroir (RTL), textes arabes (CA-014.3)', (
      tester,
    ) async {
      await pumpLogin(tester, locale: const Locale('ar'));

      expect(directionOf(tester, find.byType(LoginScreen)), TextDirection.rtl);
      expect(field('اسم المستخدم'), findsOneWidget);
      expect(field('كلمة المرور'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'تسجيل الدخول'), findsOneWidget);
    });

    testWidgets(
      'la langue se choisit avant la connexion et s applique tout de suite (CA-001.8)',
      (tester) async {
        final localeCubit = LocaleCubit(await SharedPreferences.getInstance());
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: bloc()),
              BlocProvider<LocaleCubit>.value(value: localeCubit),
            ],
            child: BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) =>
                  testApp(home: const LoginScreen(), locale: locale),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Se connecter'), findsOneWidget);
        expect(
          directionOf(tester, find.byType(LoginScreen)),
          TextDirection.ltr,
        );

        await tester.tap(find.text('العربية'));
        await tester.pumpAndSettle();

        expect(find.text('اسم المستخدم'), findsOneWidget);
        expect(
          directionOf(tester, find.byType(LoginScreen)),
          TextDirection.rtl,
        );
        expect(
          localeCubit.languageCode,
          'ar',
          reason: 'memorise pour la prochaine ouverture',
        );

        await tester.tap(find.text('Français'));
        await tester.pumpAndSettle();

        expect(find.text('Identifiant'), findsOneWidget);
        expect(
          directionOf(tester, find.byType(LoginScreen)),
          TextDirection.ltr,
        );
      },
    );

    testWidgets('dernier identifiant prerempli : reste 3 gestes (CA-001.2)', (
      tester,
    ) async {
      repository.lastUserName = 'chef.dev';
      await pumpLogin(tester);

      expect(
        tester.widget<TextFormField>(field('Identifiant')).controller?.text,
        'chef.dev',
      );
    });

    testWidgets(
      'champs vides : message « Champ obligatoire », aucune demande',
      (tester) async {
        await pumpLogin(tester);

        await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
        await tester.pump();

        expect(find.text('Champ obligatoire'), findsNWidgets(2));
        expect(repository.loginCalls, 0);
      },
    );

    testWidgets('mot de passe masque, avec un bouton « afficher » (CA-001.9)', (
      tester,
    ) async {
      await pumpLogin(tester);
      EditableText password() => tester.widget<EditableText>(
        find.descendant(
          of: field('Mot de passe'),
          matching: find.byType(EditableText),
        ),
      );
      expect(password().obscureText, isTrue);

      await tester.tap(find.byTooltip('Afficher le mot de passe'));
      await tester.pump();

      expect(password().obscureText, isFalse);
      expect(find.byTooltip('Masquer le mot de passe'), findsOneWidget);
    });

    testWidgets('connexion : envoie l\'identifiant et le mot de passe', (
      tester,
    ) async {
      repository.loginResult = testUser();
      await pumpLogin(tester);

      await tester.enterText(field('Identifiant'), 'chef.dev');
      await tester.enterText(field('Mot de passe'), 'secret');
      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pumpAndSettle();

      expect(repository.loginAttempts.single, ('chef.dev', 'secret'));
      expect(bloc().state.status, AuthStatus.authenticated);
    });

    testWidgets(
      'bouton inactif pendant l\'envoi : un double appui = une demande (CA-001.6)',
      (tester) async {
        repository
          ..loginResult = testUser()
          ..loginGate = Completer<void>();
        await pumpLogin(tester);
        await tester.enterText(field('Identifiant'), 'chef.dev');
        await tester.enterText(field('Mot de passe'), 'secret');

        await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
        await tester.pump();
        final disabled = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(disabled.onPressed, isNull);
        expect(find.text('Connexion en cours…'), findsOneWidget);
        await tester.tap(find.byType(FilledButton), warnIfMissed: false);
        await tester.pump();

        repository.loginGate!.complete();
        await tester.pumpAndSettle();
        expect(repository.loginCalls, 1);
      },
    );

    testWidgets(
      'echec : message UNIQUE, identique pour tous les cas (CA-001.3)',
      (tester) async {
        repository.loginError = const UnauthorizedApiException(
          status: 401,
          code: 'IDENTIFIANTS_INVALIDES',
        );
        await pumpLogin(tester);
        await tester.enterText(field('Identifiant'), 'inconnu');
        await tester.enterText(field('Mot de passe'), 'x');

        await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Identifiant ou mot de passe incorrect, ou compte inactif. Contactez votre administrateur.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('trop d\'essais : message traduit', (tester) async {
      repository.loginError = const TooManyRequestsApiException(
        status: 429,
        code: 'TROP_D_ESSAIS',
      );
      await pumpLogin(tester);
      await tester.enterText(field('Identifiant'), 'chef.dev');
      await tester.enterText(field('Mot de passe'), 'x');

      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Trop d\'essais, réessayez plus tard.'), findsOneWidget);
    });

    testWidgets('echec en arabe : message arabe', (tester) async {
      repository.loginError = const UnauthorizedApiException(
        status: 401,
        code: 'IDENTIFIANTS_INVALIDES',
      );
      await pumpLogin(tester, locale: const Locale('ar'));
      await tester.enterText(field('اسم المستخدم'), 'x');
      await tester.enterText(field('كلمة المرور'), 'x');

      await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.textContaining('غير صحيحة'), findsOneWidget);
    });

    testWidgets(
      'premiere connexion hors ligne : message clair + « Reessayer », jamais un ecran blanc (CA-001.5)',
      (tester) async {
        repository.loginError = const NetworkApiException();
        await pumpLogin(tester);
        await tester.enterText(field('Identifiant'), 'chef.dev');
        await tester.enterText(field('Mot de passe'), 'x');

        await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
        await tester.pumpAndSettle();

        expect(
          find.text('Première connexion : réseau nécessaire'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(OutlinedButton, 'Réessayer'),
          findsOneWidget,
        );

        repository.loginError = null;
        repository.loginResult = testUser();
        await tester.tap(find.widgetWithText(OutlinedButton, 'Réessayer'));
        await tester.pumpAndSettle();

        expect(repository.loginCalls, 2);
        expect(bloc().state.status, AuthStatus.authenticated);
      },
    );

    testWidgets('premiere connexion hors ligne en arabe', (tester) async {
      repository.loginError = const TimeoutApiException();
      await pumpLogin(tester, locale: const Locale('ar'));
      await tester.enterText(field('اسم المستخدم'), 'x');
      await tester.enterText(field('كلمة المرور'), 'x');

      await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.text('أول تسجيل دخول: الشبكة ضرورية'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('session expiree : message, saisies conservees', (
      tester,
    ) async {
      repository.restored = const RestoredSession.signedOut(SessionEnd.expired);
      bloc().add(const AuthStarted());
      await pumpLogin(tester);

      expect(
        find.text(
          'Votre session a expiré. Reconnectez-vous : vos saisies en attente sont conservées.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'compte retire : « Acces retire, contactez votre administrateur »',
      (tester) async {
        repository.restored = const RestoredSession.signedOut(
          SessionEnd.accessRevoked,
        );
        bloc().add(const AuthStarted());
        await pumpLogin(tester);

        expect(
          find.text('Accès retiré, contactez votre administrateur.'),
          findsOneWidget,
        );
      },
    );
  });

  group('Changement du mot de passe provisoire (CA-001.7)', () {
    Future<void> pumpChange(
      WidgetTester tester, {
      Locale locale = const Locale('fr'),
    }) async {
      repository.restored = RestoredSession.signedIn(
        testUser(mustChangePassword: true),
      );
      bloc().add(const AuthStarted());
      await pumpLogin(
        tester,
        locale: locale,
        home: const ChangePasswordScreen(),
      );
    }

    testWidgets('trois champs et une explication', (tester) async {
      await pumpChange(tester);

      expect(find.text('Nouveau mot de passe'), findsWidgets);
      expect(field('Mot de passe provisoire'), findsOneWidget);
      expect(field('Confirmer le nouveau mot de passe'), findsOneWidget);
    });

    testWidgets('deux mots de passe differents : refuse', (tester) async {
      await pumpChange(tester);
      await tester.enterText(field('Mot de passe provisoire'), 'provisoire');
      await tester.enterText(field('Nouveau mot de passe'), 'Nouveau-1');
      await tester.enterText(
        field('Confirmer le nouveau mot de passe'),
        'Autre-2',
      );

      await tester.tap(
        find.widgetWithText(FilledButton, 'Enregistrer le mot de passe'),
      );
      await tester.pump();

      expect(
        find.text('Les deux mots de passe sont différents.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'mot de passe faible (422) : message traduit, reste sur l\'ecran',
      (tester) async {
        repository.changePasswordError = const BusinessRuleApiException(
          status: 422,
          code: 'MOT_DE_PASSE_FAIBLE',
        );
        await pumpChange(tester);
        await tester.enterText(field('Mot de passe provisoire'), 'provisoire');
        await tester.enterText(field('Nouveau mot de passe'), 'abc');
        await tester.enterText(
          field('Confirmer le nouveau mot de passe'),
          'abc',
        );

        await tester.tap(
          find.widgetWithText(FilledButton, 'Enregistrer le mot de passe'),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Mot de passe trop faible'), findsOneWidget);
        expect(bloc().state.status, AuthStatus.passwordChangeRequired);
      },
    );

    testWidgets('succes : connecte', (tester) async {
      await pumpChange(tester);
      await tester.enterText(field('Mot de passe provisoire'), 'provisoire');
      await tester.enterText(field('Nouveau mot de passe'), 'Nouveau-1');
      await tester.enterText(
        field('Confirmer le nouveau mot de passe'),
        'Nouveau-1',
      );

      await tester.tap(
        find.widgetWithText(FilledButton, 'Enregistrer le mot de passe'),
      );
      await tester.pumpAndSettle();

      expect(bloc().state.status, AuthStatus.authenticated);
    });

    testWidgets('arabe : RTL et textes arabes', (tester) async {
      await pumpChange(tester, locale: const Locale('ar'));

      expect(
        directionOf(tester, find.byType(ChangePasswordScreen)),
        TextDirection.rtl,
      );
      expect(find.text('كلمة مرور جديدة'), findsOneWidget);
    });
  });
}
