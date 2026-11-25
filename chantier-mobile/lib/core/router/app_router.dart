import 'package:chantier_mobile/core/di/injection.dart';
import 'package:chantier_mobile/core/router/go_router_refresh_stream.dart';
import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_scheduler.dart';
import 'package:chantier_mobile/core/widgets/authenticated_shell.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/domain/auth_repository.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/change_password_screen.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/logout_screen.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:chantier_mobile/features/settings/presentation/settings_screen.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_screen.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_screen.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/pending_operations_screen.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:chantier_mobile/features/zones/presentation/add_zone_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Routes de l'application. La redirection suit l'etat d'authentification
/// (`refreshListenable` + `redirect`, comme Kardinal) : pas de session -> connexion ; mot de passe
/// provisoire -> changement obligatoire ; sinon l'application.
abstract final class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String changePassword = '/change-password';
  static const String sites = '/';
  static const String pending = '/pending';
  static const String settings = '/settings';
  static const String logout = '/logout';

  static String siteDetail(String siteId) => '/sites/$siteId';

  static String newZone(String siteId) => '/sites/$siteId/zones/new';

  /// Redirection selon l'etat d'authentification (fonction pure, testee seule).
  static String? redirectFor(AuthStatus status, String location) {
    switch (status) {
      case AuthStatus.unknown:
        return location == splash ? null : splash;
      case AuthStatus.unauthenticated:
        return location == login ? null : login;
      case AuthStatus.passwordChangeRequired:
        return location == changePassword ? null : changePassword;
      case AuthStatus.authenticated:
        const authScreens = {splash, login, changePassword};
        return authScreens.contains(location) ? sites : null;
    }
  }

  static GoRouter create(AuthBloc authBloc) => GoRouter(
    initialLocation: splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) =>
        redirectFor(authBloc.state.status, state.matchedLocation),
    routes: [
      GoRoute(path: splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: changePassword,
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AuthenticatedShell(
          userId: authBloc.state.user!.id,
          database: sl<AppDatabase>(),
          engine: sl<SyncEngine>(),
          scheduler: sl<SyncScheduler>(),
          onOpenPending: () => context.push(pending),
          child: child,
        ),
        routes: [
          GoRoute(
            path: sites,
            builder: (context, state) => BlocProvider(
              create: (_) => SitesCubit(sl<SitesRepository>()),
              child: SitesScreen(
                onOpenSite: (site) async {
                  // Ouvrir un chantier le rend courant (CA-010.1).
                  final current = context.read<CurrentSiteCubit>();
                  await current.select(site.id);
                  if (context.mounted) await context.push(siteDetail(site.id));
                },
                onOpenSettings: () => context.push(settings),
              ),
            ),
            routes: [
              GoRoute(
                path: 'sites/:siteId',
                builder: (context, state) => BlocProvider(
                  create: (_) => SiteDetailCubit(
                    repository: sl<SitesRepository>(),
                    siteId: state.pathParameters['siteId']!,
                  ),
                  child: SiteDetailScreen(
                    onAddZone: (site) => context.push(newZone(site.id)),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'zones/new',
                    builder: (context, state) => AddZoneScreen(
                      siteId: state.pathParameters['siteId']!,
                      userId: authBloc.state.user!.id,
                      repository: sl<ZonesRepository>(),
                      replacing: state.extra is OutboxRow
                          ? state.extra! as OutboxRow
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: pending,
            builder: (context, state) => PendingOperationsScreen(
              userId: authBloc.state.user!.id,
              outbox: sl<OutboxRepository>(),
              onCorrect: (row) =>
                  context.push(newZone(row.siteId ?? ''), extra: row),
            ),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => SettingsScreen(
              authRepository: sl<AuthRepository>(),
              onLogout: () => context.push(logout),
            ),
          ),
          GoRoute(path: logout, builder: (_, _) => const LogoutScreen()),
        ],
      ),
    ],
  );
}
