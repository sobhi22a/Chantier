import 'package:chantier_mobile/core/router/app_router.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Redirection selon l\'authentification', () {
    test('restauration en cours : ecran de demarrage', () {
      expect(AppRouter.redirectFor(AuthStatus.unknown, '/'), AppRouter.splash);
      expect(
        AppRouter.redirectFor(AuthStatus.unknown, AppRouter.splash),
        isNull,
      );
    });

    test('pas de session : connexion, depuis n\'importe quel ecran', () {
      for (final location in [
        '/',
        '/sites/abc',
        '/pending',
        '/settings',
        AppRouter.splash,
      ]) {
        expect(
          AppRouter.redirectFor(AuthStatus.unauthenticated, location),
          AppRouter.login,
          reason: location,
        );
      }
      expect(
        AppRouter.redirectFor(AuthStatus.unauthenticated, AppRouter.login),
        isNull,
      );
    });

    test(
      'mot de passe provisoire : changement obligatoire, rien d\'autre n\'est accessible (CA-001.7)',
      () {
        for (final location in [
          '/',
          '/sites/abc',
          '/pending',
          AppRouter.login,
        ]) {
          expect(
            AppRouter.redirectFor(AuthStatus.passwordChangeRequired, location),
            AppRouter.changePassword,
            reason: location,
          );
        }
        expect(
          AppRouter.redirectFor(
            AuthStatus.passwordChangeRequired,
            AppRouter.changePassword,
          ),
          isNull,
        );
      },
    );

    test('connecte : l\'application, jamais les ecrans de connexion', () {
      for (final location in [
        AppRouter.splash,
        AppRouter.login,
        AppRouter.changePassword,
      ]) {
        expect(
          AppRouter.redirectFor(AuthStatus.authenticated, location),
          AppRouter.sites,
        );
      }
      for (final location in [
        '/',
        '/sites/abc',
        '/sites/abc/zones/new',
        '/pending',
        '/settings',
        '/logout',
      ]) {
        expect(
          AppRouter.redirectFor(AuthStatus.authenticated, location),
          isNull,
          reason: location,
        );
      }
    });

    test('chemins des ecrans', () {
      expect(AppRouter.siteDetail('s1'), '/sites/s1');
      expect(AppRouter.newZone('s1'), '/sites/s1/zones/new');
    });
  });
}
