import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// Ajoute `Accept-Language: fr | ar` : le serveur renvoie `code` + un message francais par
/// defaut, le mobile traduit lui-meme par `code`.
class AcceptLanguageInterceptor extends Interceptor {
  AcceptLanguageInterceptor(this._languageCode);

  final String Function() _languageCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _languageCode();
    handler.next(options);
  }
}

/// Journalise `METHODE chemin -> statut` et rien d'autre : ni en-tetes (jeton), ni corps
/// (mot de passe, donnees), ni parametres de requete (CT-14, CA-017.1).
class SafeLogInterceptor extends Interceptor {
  static final Logger _log = Logger('Http');

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log.fine(
      '${response.requestOptions.method} ${response.requestOptions.path} '
      '-> ${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    _log.info(
      '${err.requestOptions.method} ${err.requestOptions.path} '
      '-> ${status ?? err.type.name}',
    );
    handler.next(err);
  }
}
