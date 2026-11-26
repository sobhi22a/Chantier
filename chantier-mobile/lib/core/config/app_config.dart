import 'package:equatable/equatable.dart';

/// Configuration de l'application, fixee a la compilation par `--dart-define`.
///
/// Aucune bascule sur `kReleaseMode` (defaut de Kardinal, M-3) : l'environnement vise
/// est choisi explicitement par `--dart-define=API_BASE_URL=https://.../api/v1`.
class AppConfig extends Equatable {
  const AppConfig({
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.reachabilityTimeout = const Duration(seconds: 5),
    this.offlineSessionDays = defaultOfflineSessionDays,
    this.fullReloadAfterDays = defaultFullReloadAfterDays,
  });

  /// Valeurs lues depuis `--dart-define` (defaut de developpement : emulateur Android).
  const AppConfig.fromEnvironment()
    : this(
        apiBaseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: defaultDevApiBaseUrl,
        ),
        offlineSessionDays: const int.fromEnvironment(
          'OFFLINE_SESSION_DAYS',
          defaultValue: defaultOfflineSessionDays,
        ),
        fullReloadAfterDays: const int.fromEnvironment(
          'FULL_RELOAD_AFTER_DAYS',
          defaultValue: defaultFullReloadAfterDays,
        ),
      );

  /// Fenetre de synchronisation du serveur (`Sync:ClosedRetentionDays`, 60 jours) : au-dela, les
  /// demandes closes ne sont plus envoyees et aucune pierre tombale ne dit qu'elles ont change.
  static const int defaultFullReloadAfterDays = 60;

  /// Hote de la machine de developpement vu depuis l'emulateur Android.
  static const String defaultDevApiBaseUrl = 'http://10.0.2.2:8195/api/v1';

  /// Une session reste utilisable hors ligne 14 jours apres le dernier contact reussi avec le
  /// serveur (H-05, aligne sur la duree du jeton de rafraichissement ; question Q-07).
  static const int defaultOfflineSessionDays = 14;

  /// URL de base de l'API, prefixe de version compris, sans `/` final.
  final String apiBaseUrl;

  /// Delais courts (ADR 0008) : connexion 10 s, reception 30 s.
  final Duration connectTimeout;
  final Duration receiveTimeout;

  /// Duree de la session hors ligne, en jours (`--dart-define=OFFLINE_SESSION_DAYS`).
  final int offlineSessionDays;

  /// Un telephone qui n'a pas synchronise avec succes depuis plus de ce nombre de jours recharge
  /// **tout** (R3-05, `--dart-define=FULL_RELOAD_AFTER_DAYS`) ; ses saisies en attente sont gardees.
  /// `0` : jamais (le signal `resetRequired` du serveur reste suivi).
  final int fullReloadAfterDays;

  /// Delai de l'appel leger qui confirme que le serveur est joignable.
  final Duration reachabilityTimeout;

  /// Racine du serveur (`https://hote:port`, sans chemin). Les clients generes depuis l'OpenAPI
  /// portent deja le prefixe `/api/v1` dans leurs chemins : ils s'appuient donc sur la racine.
  String get serverRootUrl {
    final base = Uri.parse(apiBaseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
    ).toString();
  }

  /// Adresse de l'appel leger `GET /health/live` (anonyme, a la racine du serveur,
  /// hors prefixe `/api/v1`).
  Uri get healthLiveUri => Uri.parse('$serverRootUrl/health/live');

  /// En production, le trafic doit etre chiffre : refuse `http://` hors developpement.
  /// [isRelease] vaut `kReleaseMode` a l'appel ; parametre pour pouvoir le tester.
  void assertSecureFor({required bool isRelease}) {
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError(
        'API_BASE_URL invalide : fournir --dart-define=API_BASE_URL=https://.../api/v1',
      );
    }
    if (isRelease && uri.scheme != 'https') {
      throw StateError(
        'API_BASE_URL doit etre en https dans une version de production.',
      );
    }
  }

  @override
  List<Object?> get props => [
    apiBaseUrl,
    connectTimeout,
    receiveTimeout,
    reachabilityTimeout,
    offlineSessionDays,
    fullReloadAfterDays,
  ];
}
