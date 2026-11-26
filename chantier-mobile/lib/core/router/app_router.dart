import 'package:chantier_mobile/core/di/injection.dart';
import 'package:chantier_mobile/core/utils/client_id.dart';
import 'package:chantier_mobile/core/router/go_router_refresh_stream.dart';
import 'package:chantier_mobile/core/sync/current_site.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_scheduler.dart';
import 'package:chantier_mobile/core/widgets/authenticated_shell.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/features/auth/domain/auth_user.dart';
import 'package:chantier_mobile/features/auth/domain/auth_repository.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/change_password_screen.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/logout_screen.dart';
import 'package:chantier_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:chantier_mobile/features/materials/data/history_remote.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/data/photo_capture.dart';
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/data/photo_remote.dart';
import 'package:chantier_mobile/features/materials/data/supplier_contact.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_form_rules.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_listing.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_operations.dart';
import 'package:chantier_mobile/features/materials/domain/delivery_overlay.dart';
import 'package:chantier_mobile/features/materials/domain/request_operations.dart';
import 'package:chantier_mobile/features/materials/domain/request_overlay.dart';
import 'package:chantier_mobile/features/materials/presentation/approvals/approvals_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/deliveries_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/deliveries_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/delivery_detail_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/delivery_form_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/to_receive_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/deliveries/to_reception_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/request_detail_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/request_form_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_cubit.dart';
import 'package:chantier_mobile/features/materials/presentation/requests/requests_screen.dart';
import 'package:chantier_mobile/features/materials/presentation/widgets/request_labels.dart';
import 'package:chantier_mobile/features/settings/presentation/settings_screen.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/site_detail_screen.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_cubit.dart';
import 'package:chantier_mobile/features/sites/presentation/sites_screen.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/conflict_review_screen.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/delivery_review_screen.dart';
import 'package:chantier_mobile/features/sync_queue/presentation/pending_operations_screen.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:chantier_mobile/features/zones/presentation/add_zone_screen.dart';
import 'package:chantier_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart'
    show
        AlertDialog,
        CircularProgressIndicator,
        FilledButton,
        ScaffoldMessenger,
        SnackBar,
        Text,
        TextButton,
        showDialog;
import 'package:flutter/widgets.dart';
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

  static String requests(String siteId) => '/sites/$siteId/requests';

  static String newRequest(String siteId) => '/sites/$siteId/requests/new';

  static String approvals(String siteId) => '/sites/$siteId/requests/approvals';

  static String requestDetail(String siteId, String requestId) =>
      '/sites/$siteId/requests/$requestId';

  static String editRequest(String siteId, String requestId) =>
      '/sites/$siteId/requests/$requestId/edit';

  static String toReceive(String siteId) => '/sites/$siteId/receive';

  /// « Recevoir » une livraison pour une commande (la demande passe en `extra`).
  static String receive(String siteId, String requestId) =>
      '/sites/$siteId/receive/$requestId';

  static String toReception(String siteId) => '/sites/$siteId/reception';

  static String deliveries(String siteId) => '/sites/$siteId/deliveries';

  /// Livraison sans demande (fait de chantier, enregistree « Non rattachee »).
  static String newDelivery(String siteId) => '/sites/$siteId/deliveries/new';

  static String deliveryDetail(String siteId, String deliveryId) =>
      '/sites/$siteId/deliveries/$deliveryId';

  static String editDelivery(String siteId, String deliveryId) =>
      '/sites/$siteId/deliveries/$deliveryId/edit';

  /// « A verifier » : une saisie de demande refusee ou en conflit.
  static String review(int operationId) => '/review/$operationId';

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
                    onOpenRequests: (site) => context.push(requests(site.id)),
                    onNewRequest: (site) => context.push(newRequest(site.id)),
                    onOpenApprovals: (site) => context.push(approvals(site.id)),
                    onOpenToReceive: (site) => context.push(toReceive(site.id)),
                    onOpenToReception: (site) =>
                        context.push(toReception(site.id)),
                    onOpenDeliveries: (site) =>
                        context.push(deliveries(site.id)),
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
                  GoRoute(
                    path: 'receive',
                    builder: (context, state) {
                      final siteId = state.pathParameters['siteId']!;
                      final user = authBloc.state.user!;
                      return BlocProvider(
                        create: (_) => RequestsCubit(
                          repository: sl<MaterialsRepository>(),
                          siteId: siteId,
                          userId: user.id,
                          view: RequestListView.expected,
                        ),
                        child: ToReceiveScreen(
                          user: user,
                          onOpen: (view) => context.push(
                            // Sans le droit de saisir une livraison : le detail de la demande.
                            user.canRecordDelivery
                                ? receive(siteId, view.id)
                                : requestDetail(siteId, view.id),
                            extra: view,
                          ),
                          onWithoutRequest: user.canRecordDelivery
                              ? () => context.push(newDelivery(siteId))
                              : null,
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':requestId',
                        // Sans la demande (lien direct) : retour a la liste.
                        redirect: (context, state) => state.extra is RequestView
                            ? null
                            : toReceive(state.pathParameters['siteId']!),
                        builder: (context, state) => _deliveryForm(
                          context,
                          authBloc.state.user!,
                          state.pathParameters['siteId']!,
                          request: state.extra! as RequestView,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'reception',
                    builder: (context, state) {
                      final siteId = state.pathParameters['siteId']!;
                      final user = authBloc.state.user!;
                      return BlocProvider(
                        create: (_) => RequestsCubit(
                          repository: sl<MaterialsRepository>(),
                          siteId: siteId,
                          userId: user.id,
                          view: RequestListView.toReception,
                        ),
                        child: ToReceptionScreen(
                          user: user,
                          repository: sl<MaterialsRepository>(),
                          zones: sl<SitesRepository>().watchZones(siteId),
                          onOpen: (view) =>
                              context.push(requestDetail(siteId, view.id)),
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'deliveries',
                    builder: (context, state) {
                      final siteId = state.pathParameters['siteId']!;
                      final user = authBloc.state.user!;
                      return BlocProvider(
                        create: (_) => DeliveriesCubit(
                          repository: sl<DeliveriesRepository>(),
                          siteId: siteId,
                          userId: user.id,
                          filter: state.extra is DeliveryListFilter
                              ? state.extra! as DeliveryListFilter
                              : DeliveryListFilter.all,
                        ),
                        child: DeliveriesScreen(
                          user: user,
                          onOpen: (view) =>
                              context.push(deliveryDetail(siteId, view.id)),
                          onNewWithoutRequest: user.canRecordDelivery
                              ? () => context.push(newDelivery(siteId))
                              : null,
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) {
                          final args = state.extra is DeliveryFormArgs
                              ? state.extra! as DeliveryFormArgs
                              : null;
                          return _deliveryForm(
                            context,
                            authBloc.state.user!,
                            state.pathParameters['siteId']!,
                            initial: args?.initial,
                            replacing: args?.replacing,
                          );
                        },
                      ),
                      GoRoute(
                        path: ':deliveryId',
                        builder: (context, state) {
                          final siteId = state.pathParameters['siteId']!;
                          final deliveryId =
                              state.pathParameters['deliveryId']!;
                          final user = authBloc.state.user!;
                          return BlocProvider(
                            create: (_) => DeliveryDetailCubit(
                              repository: sl<DeliveriesRepository>(),
                              deliveryId: deliveryId,
                              userId: user.id,
                            ),
                            child: DeliveryDetailScreen(
                              user: user,
                              deliveries: sl<DeliveriesRepository>(),
                              materials: sl<MaterialsRepository>(),
                              capture: sl<PhotoCapture>(),
                              files: sl<PhotoFiles>(),
                              viewer: sl<PhotoViewer>(),
                              history: sl<HistorySource>(),
                              onEdit: (view) => context.push(
                                editDelivery(siteId, deliveryId),
                                extra: DeliveryFormArgs(existing: view),
                              ),
                              onOpenRequest: (id) =>
                                  context.push(requestDetail(siteId, id)),
                              onReview: (view) async {
                                final operation = await _firstDeliveryToCheck(
                                  user.id,
                                  view,
                                );
                                if (operation != null && context.mounted) {
                                  await context.push(review(operation.id));
                                }
                              },
                            ),
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'edit',
                            // Sans les parametres (lien direct) : retour au detail.
                            redirect: (context, state) =>
                                state.extra is DeliveryFormArgs
                                ? null
                                : deliveryDetail(
                                    state.pathParameters['siteId']!,
                                    state.pathParameters['deliveryId']!,
                                  ),
                            builder: (context, state) {
                              final args = state.extra! as DeliveryFormArgs;
                              return _deliveryForm(
                                context,
                                authBloc.state.user!,
                                state.pathParameters['siteId']!,
                                existing: args.existing,
                                initial: args.initial,
                                replacing: args.replacing,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'requests',
                    builder: (context, state) {
                      final siteId = state.pathParameters['siteId']!;
                      final user = authBloc.state.user!;
                      return BlocProvider(
                        create: (_) => RequestsCubit(
                          repository: sl<MaterialsRepository>(),
                          siteId: siteId,
                          userId: user.id,
                          // Un chef d'equipe voit d'abord « Mes demandes » (CA-MAT-002.2).
                          mineOnly: user.role == 'ChefEquipe',
                        ),
                        child: RequestsScreen(
                          user: user,
                          zones: sl<SitesRepository>().watchZones(siteId),
                          onOpen: (view) =>
                              context.push(requestDetail(siteId, view.id)),
                          onNew: user.can(Permissions.requestsCreate)
                              ? () => context.push(newRequest(siteId))
                              : null,
                          onOpenApprovals: user.can(Permissions.requestsApprove)
                              ? () => context.push(approvals(siteId))
                              : null,
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) {
                          final siteId = state.pathParameters['siteId']!;
                          final args = state.extra is RequestFormArgs
                              ? state.extra! as RequestFormArgs
                              : null;
                          return RequestFormScreen(
                            siteId: siteId,
                            user: authBloc.state.user!,
                            repository: sl<MaterialsRepository>(),
                            zonesRepository: sl<ZonesRepository>(),
                            initial: args?.initial,
                            replacing: args?.replacing,
                            onSeeDuplicate: (id) =>
                                context.push(requestDetail(siteId, id)),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'approvals',
                        builder: (context, state) {
                          final siteId = state.pathParameters['siteId']!;
                          final user = authBloc.state.user!;
                          return BlocProvider(
                            create: (_) => RequestsCubit(
                              repository: sl<MaterialsRepository>(),
                              siteId: siteId,
                              userId: user.id,
                              view: RequestListView.toApprove,
                            ),
                            child: ApprovalsScreen(
                              user: user,
                              repository: sl<MaterialsRepository>(),
                              zones: sl<SitesRepository>().watchZones(siteId),
                              onOpen: (view) =>
                                  context.push(requestDetail(siteId, view.id)),
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        path: ':requestId',
                        builder: (context, state) {
                          final siteId = state.pathParameters['siteId']!;
                          final requestId = state.pathParameters['requestId']!;
                          final user = authBloc.state.user!;
                          return BlocProvider(
                            create: (_) => RequestDetailCubit(
                              repository: sl<MaterialsRepository>(),
                              requestId: requestId,
                              userId: user.id,
                            ),
                            child: RequestDetailScreen(
                              user: user,
                              repository: sl<MaterialsRepository>(),
                              zones: sl<SitesRepository>().watchZones(siteId),
                              onEdit: (view) => context.push(
                                editRequest(siteId, requestId),
                                extra: RequestFormArgs(existing: view),
                              ),
                              deliveries: sl<DeliveriesRepository>(),
                              history: sl<HistorySource>(),
                              contact: sl<SupplierContactSource>(),
                              dialer: sl<PhoneDialer>(),
                              onReceive: (view) => context.push(
                                receive(siteId, view.id),
                                extra: view,
                              ),
                              onOpenDelivery: (delivery) => context.push(
                                deliveryDetail(siteId, delivery.id),
                              ),
                              onReception: (view) =>
                                  _receiveNow(context, user.id, view),
                              onReview: (view) async {
                                final operation = await _firstToCheck(
                                  user.id,
                                  view,
                                );
                                if (operation != null && context.mounted) {
                                  await context.push(review(operation.id));
                                }
                              },
                            ),
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'edit',
                            // Sans les parametres (lien direct) : retour au detail.
                            redirect: (context, state) =>
                                state.extra is RequestFormArgs
                                ? null
                                : requestDetail(
                                    state.pathParameters['siteId']!,
                                    state.pathParameters['requestId']!,
                                  ),
                            builder: (context, state) {
                              final args = state.extra! as RequestFormArgs;
                              return RequestFormScreen(
                                siteId: state.pathParameters['siteId']!,
                                user: authBloc.state.user!,
                                repository: sl<MaterialsRepository>(),
                                zonesRepository: sl<ZonesRepository>(),
                                existing: args.existing,
                                initial: args.initial,
                                replacing: args.replacing,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
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
              onCorrect: (row) => row.entity == 'zone'
                  ? context.push(newZone(row.siteId ?? ''), extra: row)
                  : context.push(review(row.id)),
              pendingFiles: sl<DeliveriesRepository>().watchPendingFiles(
                authBloc.state.user!.id,
              ),
              onAbandonFile: (file) =>
                  _abandonPhotoFile(context, authBloc.state.user!.id, file),
            ),
          ),
          GoRoute(
            path: '/review/:operationId',
            builder: (context, state) {
              final operationId =
                  int.tryParse(state.pathParameters['operationId']!) ?? -1;
              final userId = authBloc.state.user!.id;
              // Demande, livraison ou photo : chaque entite a son ecran « A verifier ».
              return FutureBuilder<OutboxRow?>(
                future: sl<AppDatabase>().outboxDao.getById(operationId),
                builder: (context, snapshot) {
                  final operation = snapshot.data;
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return operation != null &&
                          (operation.isDeliveryOperation ||
                              operation.isPhotoOperation)
                      ? _deliveryReviewScreen(context, userId, operationId)
                      : _reviewScreen(context, userId, operationId);
                },
              );
            },
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

  /// Formulaire « Recevoir » / « Livraison sans demande » / « Corriger la livraison ».
  static Widget _deliveryForm(
    BuildContext context,
    AuthUser user,
    String siteId, {
    RequestView? request,
    DeliveryView? existing,
    DeliveryDraft? initial,
    OutboxRow? replacing,
  }) => DeliveryFormScreen(
    siteId: siteId,
    user: user,
    deliveries: sl<DeliveriesRepository>(),
    materials: sl<MaterialsRepository>(),
    capture: sl<PhotoCapture>(),
    files: sl<PhotoFiles>(),
    request: request,
    existing: existing,
    initial: initial,
    replacing: replacing,
    onSeeDuplicate: (id) => context.push(deliveryDetail(siteId, id)),
  );

  /// « Receptionner » en 1 geste depuis le detail d'une demande livree.
  static Future<void> _receiveNow(
    BuildContext context,
    String userId,
    RequestView view,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await sl<MaterialsRepository>().receive(
      view: view,
      userId: userId,
      clientId: generateClientId(),
      label: requestOperationLabel(l10n, view.row),
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result == QueueResult.queued
              ? l10n.requestActionQueued
              : l10n.requestActionAlreadyQueued,
        ),
      ),
    );
  }

  /// « Abandonner » un fichier de photo refuse (apres confirmation de l'ecran).
  static Future<void> _abandonPhotoFile(
    BuildContext context,
    String userId,
    PendingPhotoFileRow file,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.photoAbandon),
        content: Text(l10n.photoAbandonBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.pendingAbandon),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final files = sl<PhotoFiles>();
    await sl<DeliveriesRepository>().abandonPhotoFile(
      ownerUserId: userId,
      file: file,
      deleteFile: (path) => files.delete(userId, path),
    );
  }

  /// Premiere saisie de la livraison [view] a verifier (refusee ou en conflit).
  static Future<OutboxRow?> _firstDeliveryToCheck(
    String userId,
    DeliveryView view,
  ) async {
    final operations = await sl<AppDatabase>().outboxDao.allFor(userId);
    for (final operation in operations) {
      final toCheck =
          operation.status == OutboxStatus.conflict ||
          operation.status == OutboxStatus.rejected;
      if (toCheck && operation.targetsDelivery(view.stored)) return operation;
    }
    return null;
  }

  /// Premiere saisie de [view] a verifier (refusee ou en conflit) du compte connecte.
  static Future<OutboxRow?> _firstToCheck(
    String userId,
    RequestView view,
  ) async {
    final operations = await sl<AppDatabase>().outboxDao.allFor(userId);
    for (final operation in operations) {
      final toCheck =
          operation.status == OutboxStatus.conflict ||
          operation.status == OutboxStatus.rejected;
      if (toCheck && operation.targets(view.stored)) return operation;
    }
    return null;
  }

  /// Zones du chantier d'une saisie de la file d'envoi (vide si elle a disparu).
  static Stream<List<ZoneRow>> _zonesOf(int operationId) async* {
    final operation = await sl<AppDatabase>().outboxDao.getById(operationId);
    final siteId = operation?.siteId;
    if (siteId == null) {
      yield const [];
      return;
    }
    yield* sl<SitesRepository>().watchZones(siteId);
  }

  /// « A verifier » d'une livraison ou d'une photo : les choix ouvrent le formulaire, qui remplace
  /// la saisie refusee.
  static Widget _deliveryReviewScreen(
    BuildContext context,
    String userId,
    int operationId,
  ) {
    Future<void> openForm(DeliveryFormArgs args, String path) async {
      final done = await context.push<bool>(path, extra: args);
      if (done == true && context.mounted) context.pop();
    }

    return DeliveryReviewScreen(
      userId: userId,
      operationId: operationId,
      outbox: sl<OutboxRepository>(),
      deliveries: sl<DeliveriesRepository>(),
      onRedo: (delivery, draft, operation) => openForm(
        DeliveryFormArgs(
          existing: DeliveryView.plain(delivery),
          initial: draft,
          replacing: operation,
        ),
        editDelivery(delivery.siteId, delivery.id),
      ),
      onCorrectCreate: (draft, operation) => openForm(
        DeliveryFormArgs(initial: draft, replacing: operation),
        newDelivery(operation.siteId ?? ''),
      ),
    );
  }

  /// « A verifier » : les choix ouvrent le formulaire, qui remplace la saisie refusee.
  static Widget _reviewScreen(
    BuildContext context,
    String userId,
    int operationId,
  ) {
    Future<void> openForm(RequestFormArgs args, String path) async {
      final done = await context.push<bool>(path, extra: args);
      if (done == true && context.mounted) context.pop();
    }

    return ConflictReviewScreen(
      userId: userId,
      operationId: operationId,
      outbox: sl<OutboxRepository>(),
      repository: sl<MaterialsRepository>(),
      zones: _zonesOf(operationId),
      onRedo: (request, draft, operation) async {
        final view = await sl<MaterialsRepository>()
            .watchRequest(request.id, userId)
            .first;
        if (view == null || !context.mounted) return;
        await openForm(
          RequestFormArgs(existing: view, initial: draft, replacing: operation),
          editRequest(request.siteId, request.id),
        );
      },
      onCreateNew: (draft, operation) => openForm(
        RequestFormArgs(initial: draft, replacing: operation),
        newRequest(operation.siteId ?? ''),
      ),
      onCorrectCreate: (draft, operation) => openForm(
        RequestFormArgs(initial: draft, replacing: operation),
        newRequest(operation.siteId ?? ''),
      ),
    );
  }
}
