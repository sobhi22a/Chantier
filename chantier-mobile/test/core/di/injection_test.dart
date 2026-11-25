import 'package:chantier_mobile/core/api/api_clients.dart';
import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/di/injection.dart';
import 'package:chantier_mobile/core/l10n/locale_cubit.dart';
import 'package:chantier_mobile/core/network/connectivity_monitor.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/core/sync/outbox_repository.dart';
import 'package:chantier_mobile/core/sync/sync_engine.dart';
import 'package:chantier_mobile/core/sync/sync_scheduler.dart';
import 'package:chantier_mobile/features/auth/domain/auth_repository.dart';
import 'package:chantier_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chantier_mobile/features/sites/data/sites_repository.dart';
import 'package:chantier_mobile/features/zones/data/zones_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/memory_token_store.dart';
import '../../support/test_database.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
  });
  tearDown(() => sl.reset());

  test(
    'tout le graphe de dependances se construit (main.dart ne le verifie qu\'a l\'execution)',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);

      await initializeDependencies(
        config: const AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1'),
        database: db,
        tokenStore: MemoryTokenStore(),
      );

      expect(sl<AppConfig>().serverRootUrl, 'https://api.exemple.test');
      expect(sl<LocaleCubit>(), isNotNull);
      expect(sl<DioClient>(), isNotNull);
      expect(sl<ApiClients>(), isNotNull);
      expect(sl<ConnectivityMonitor>(), isNotNull);
      expect(sl<SitesRepository>(), isNotNull);
      expect(sl<OutboxRepository>(), isNotNull);
      expect(sl<ZonesRepository>(), isNotNull);
      expect(sl<AuthRepository>(), isNotNull);
      expect(sl<AuthBloc>(), isNotNull);
      expect(sl<SyncEngine>(), isNotNull);
      expect(sl<SyncScheduler>(), isNotNull);
      await sl<AuthBloc>().close();
    },
  );

  test(
    'les singletons sont uniques (un seul moteur, un seul AuthBloc, une seule base)',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await initializeDependencies(
        config: const AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1'),
        database: db,
        tokenStore: MemoryTokenStore(),
      );

      expect(identical(sl<SyncEngine>(), sl<SyncEngine>()), isTrue);
      expect(identical(sl<AuthBloc>(), sl<AuthBloc>()), isTrue);
      expect(sl<ZonesRepository>(), same(sl<ZonesRepository>()));
      await sl<AuthBloc>().close();
    },
  );

  test('personne de connecte : le moteur ne synchronise rien', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    await initializeDependencies(
      config: const AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1'),
      database: db,
      tokenStore: MemoryTokenStore(),
    );

    final outcome = await sl<SyncEngine>().run();

    expect(outcome.name, 'notSignedIn');
    await sl<AuthBloc>().close();
  });
}
