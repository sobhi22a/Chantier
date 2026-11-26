import 'package:chantier_mobile/core/api/api_clients.dart';
import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/storage/secure_token_store.dart';
import 'package:chantier_mobile/core/storage/token_store.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_remote.dart';
import 'package:chantier_mobile/core/sync/sync_scheduler.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:chantier_mobile/features/auth/domain/auth_repository.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/materials/data/deliveries_repository.dart';
import 'package:chantier_mobile/features/materials/data/history_remote.dart';
import 'package:chantier_mobile/features/materials/data/materials_repository.dart';
import 'package:chantier_mobile/features/materials/data/photo_capture.dart';
import 'package:chantier_mobile/features/materials/data/photo_files.dart';
import 'package:chantier_mobile/features/materials/data/photo_remote.dart';
import 'package:chantier_mobile/features/materials/data/photo_upload_service.dart';
import 'package:chantier_mobile/features/materials/data/supplier_contact.dart';
import 'package:chantier_mobile/features/sites/data/sites_remote_source.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Localisateur de services (GetIt), comme Kardinal.
final GetIt sl = GetIt.instance;

/// Enregistre les dependances de l'application. Appele une seule fois par `main`.
/// [config], [database] et [tokenStore] sont injectables pour les tests (base en memoire, jetons
/// en memoire) ; par defaut : valeurs de `--dart-define`, fichier SQLite et Keystore Android.
Future<void> initializeDependencies({
  AppConfig config = const AppConfig.fromEnvironment(),
  AppDatabase? database,
  TokenStore? tokenStore,
}) async {
  final preferences = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl()))
    // Reseau et session
    ..registerLazySingleton<TokenStore>(() => tokenStore ?? SecureTokenStore())
    ..registerLazySingleton<SessionEvents>(SessionEvents.new)
    ..registerLazySingleton<DioClient>(
      () => DioClient(
        config: sl(),
        tokenStore: sl(),
        events: sl(),
        languageCode: () => sl<LocaleCubit>().languageCode,
      ),
    )
    ..registerLazySingleton<ApiClients>(
      () => ApiClients(config: sl(), dioClient: sl()),
    )
    ..registerLazySingleton<ConnectivityMonitor>(
      () => ConnectivityMonitor(
        connectivity: Connectivity(),
        bareDio: sl<DioClient>().bareDio,
        config: sl(),
      ),
    )
    // Base locale : seule source de lecture de l'interface.
    ..registerLazySingleton<AppDatabase>(() => database ?? AppDatabase.open())
    ..registerLazySingleton<SitesRepository>(() => SitesRepository(sl()))
    ..registerLazySingleton<OutboxRepository>(() => OutboxRepository(sl()))
    ..registerLazySingleton<ZonesRepository>(
      () => ZonesRepository(
        database: sl(),
        outbox: sl(),
        // 2 s apres un enregistrement local : envoi des saisies rapprochees en un lot.
        onLocalWrite: () => sl<SyncScheduler>().notifyLocalWrite(),
      ),
    )
    ..registerLazySingleton<MaterialsRepository>(
      () => MaterialsRepository(
        database: sl(),
        outbox: sl(),
        onLocalWrite: () => sl<SyncScheduler>().notifyLocalWrite(),
        listThrottle: const Duration(milliseconds: 300),
      ),
    )
    ..registerLazySingleton<DeliveriesRepository>(
      () => DeliveriesRepository(
        database: sl(),
        outbox: sl(),
        onLocalWrite: () => sl<SyncScheduler>().notifyLocalWrite(),
        listThrottle: const Duration(milliseconds: 300),
      ),
    )
    // Photos des bons de livraison (ADR 0013) : fichiers dans le dossier prive de l'application
    // (jamais de stockage large), appareil photo sans permission, envoi un fichier a la fois.
    ..registerLazySingleton<PhotoFiles>(
      () => PhotoFiles(rootProvider: getApplicationSupportDirectory),
    )
    ..registerLazySingleton<PhotoCapture>(ImagePickerCapture.new)
    ..registerLazySingleton<PhotoRemote>(() => PhotoRemoteSource(sl()))
    ..registerLazySingleton<PhotoViewer>(() => PhotoViewer(sl()))
    // Historique lu a la demande, en ligne (R2-02) : copie en memoire seulement.
    ..registerLazySingleton<HistorySource>(() => HistoryRemoteSource(sl()))
    ..registerLazySingleton<PhotoUploadService>(
      () => PhotoUploadService(database: sl(), remote: sl(), files: sl()),
    )
    // Contact fournisseur : numero lu en ligne, jamais stocke (ADR 0012).
    ..registerLazySingleton<SupplierContactSource>(
      () => SupplierContactRemote(sl()),
    )
    ..registerLazySingleton<PhoneDialer>(UrlLauncherDialer.new)
    // Authentification
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        api: sl(),
        tokenStore: sl(),
        database: sl(),
        preferences: sl(),
        config: sl(),
        onLocalDataPurged: () {
          sl<PhotoViewer>().clear();
          sl<HistorySource>().clear();
        },
      ),
    )
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(repository: sl(), sessionEvents: sl()),
    )
    // Synchronisation
    ..registerLazySingleton<SyncRemote>(() => SitesRemoteSource(sl()))
    ..registerLazySingleton<SyncEngine>(
      () => SyncEngine(
        database: sl(),
        remote: sl(),
        sites: sl(),
        materials: sl(),
        photoUploads: sl(),
        currentUserId: () => sl<AuthRepository>().currentUser?.id,
        connectivity: sl(),
        onProfile: sl<AuthRepository>().applyProfile,
        fullReloadAfterDays: sl<AppConfig>().fullReloadAfterDays,
      ),
    )
    ..registerLazySingleton<SyncScheduler>(
      () => SyncScheduler(engine: sl(), connectivity: sl()),
    );
}
