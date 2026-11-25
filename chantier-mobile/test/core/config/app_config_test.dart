import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test(
      'valeurs par defaut : emulateur Android, delais courts (ADR 0008)',
      () {
        const config = AppConfig.fromEnvironment();

        expect(config.apiBaseUrl, AppConfig.defaultDevApiBaseUrl);
        expect(config.connectTimeout, const Duration(seconds: 10));
        expect(config.receiveTimeout, const Duration(seconds: 30));
      },
    );

    test('healthLiveUri : racine du serveur, hors prefixe /api/v1', () {
      const config = AppConfig(
        apiBaseUrl: 'https://api.exemple.test:8443/api/v1',
      );

      expect(
        config.healthLiveUri.toString(),
        'https://api.exemple.test:8443/health/live',
      );
    });

    test('healthLiveUri sans port explicite', () {
      const config = AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1');

      expect(
        config.healthLiveUri.toString(),
        'https://api.exemple.test/health/live',
      );
    });

    test('production : http en clair refuse', () {
      const config = AppConfig(apiBaseUrl: 'http://10.0.2.2:8195/api/v1');

      expect(() => config.assertSecureFor(isRelease: true), throwsStateError);
    });

    test('developpement : http en clair accepte', () {
      const config = AppConfig(apiBaseUrl: 'http://10.0.2.2:8195/api/v1');

      expect(() => config.assertSecureFor(isRelease: false), returnsNormally);
    });

    test('production : https accepte', () {
      const config = AppConfig(apiBaseUrl: 'https://api.exemple.test/api/v1');

      expect(() => config.assertSecureFor(isRelease: true), returnsNormally);
    });

    test('URL invalide refusee', () {
      const config = AppConfig(apiBaseUrl: 'pas une url');

      expect(() => config.assertSecureFor(isRelease: false), throwsStateError);
    });
  });
}
