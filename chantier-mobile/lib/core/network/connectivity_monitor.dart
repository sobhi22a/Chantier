import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// Surveille le reseau **comme declencheur de synchronisation seulement** (ADR 0008).
///
/// Un reseau detecte ne garantit pas l'acces a internet (Wi-Fi sans sortie, forfait epuise) :
/// [confirmOnline] ajoute un appel leger (`GET /health/live`). La verite reste le resultat
/// des vraies requetes.
class ConnectivityMonitor {
  ConnectivityMonitor({
    required Connectivity connectivity,
    required Dio bareDio,
    required AppConfig config,
  }) : _connectivity = connectivity,
       _bareDio = bareDio,
       _config = config;

  final Connectivity _connectivity;

  /// Client nu : l'appel de sante est anonyme et ne declenche aucun rafraichissement.
  final Dio _bareDio;
  final AppConfig _config;
  static final Logger _log = Logger('ConnectivityMonitor');

  /// Emet a chaque passage de « aucune interface reseau » a « au moins une » (Wi-Fi, mobile...).
  /// Le consommateur doit alors appeler [confirmOnline] avant de synchroniser.
  Stream<void> get onNetworkAvailable => _connectivity.onConnectivityChanged
      .map(_hasInterface)
      .distinct()
      .where((available) => available)
      .map((_) {});

  /// Vrai si le telephone a au moins une interface reseau active.
  Future<bool> hasNetworkInterface() async =>
      _hasInterface(await _connectivity.checkConnectivity());

  /// Vrai seulement si le serveur repond (2xx) a l'appel leger, dans le delai court de la config.
  Future<bool> isServerReachable() async {
    try {
      final response = await _bareDio.getUri<dynamic>(
        _config.healthLiveUri,
        options: Options(
          sendTimeout: _config.reachabilityTimeout,
          receiveTimeout: _config.reachabilityTimeout,
        ),
      );
      final status = response.statusCode ?? 0;
      return status >= 200 && status < 300;
    } on DioException catch (error) {
      _log.fine('Serveur injoignable (${error.type.name}).');
      return false;
    }
  }

  /// Interface reseau presente **et** serveur joignable.
  Future<bool> confirmOnline() async =>
      await hasNetworkInterface() && await isServerReachable();

  static bool _hasInterface(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
