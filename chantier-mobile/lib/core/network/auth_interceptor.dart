import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/network/token_refresher.dart';
import 'package:chantier_mobile/core/storage/token_store.dart';
import 'package:dio/dio.dart';

/// Ajoute le jeton d'acces (Bearer) et, sur un 401, rafraichit les jetons puis **rejoue la
/// requete une seule fois** (imite `KM\lib\core\network\dio_client.dart`, jetons corriges).
///
/// * `ACCES_RETIRE` (compte desactive) : pas de rafraichissement ; jetons effaces et
///   [SessionEvent.accessRevoked] emis.
/// * Rafraichissement refuse : [SessionEvent.authRequired] ; la requete echoue en 401.
/// * 403 `MOT_DE_PASSE_A_CHANGER` : [SessionEvent.passwordChangeRequired] ; jetons conserves.
/// * Rafraichissement impossible (hors ligne...) : la requete echoue avec l'erreur reseau
///   et les jetons restent en place.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStore tokenStore,
    required TokenRefresher refresher,
    required SessionEvents events,
  }) : _dio = dio,
       _tokenStore = tokenStore,
       _refresher = refresher,
       _events = events;

  /// Chemin de la deconnexion (le corps porte le jeton de rafraichissement a revoquer).
  static const String logoutPath = '/auth/logout';

  /// `extra` : requete anonyme (connexion, rafraichissement, sante), sans Bearer ni rejeu.
  static const String skipAuthKey = 'skipAuth';

  /// `extra` : requete deja rejouee apres un rafraichissement (jamais deux fois).
  static const String retriedKey = 'retriedAfterRefresh';

  final Dio _dio;
  final TokenStore _tokenStore;
  final TokenRefresher _refresher;
  final SessionEvents _events;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] != true) {
      final tokens = await _tokenStore.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final status = err.response?.statusCode;
    if (status == 403 &&
        ApiException.fromDio(err).code ==
            ApiException.codePasswordChangeRequired) {
      // Mot de passe provisoire : l'authentification prend la main (ecran de changement).
      _events.emit(SessionEvent.passwordChangeRequired);
      return handler.next(err);
    }
    final isUnauthorized = status == 401;
    if (!isUnauthorized || request.extra[skipAuthKey] == true) {
      return handler.next(err);
    }

    final api = ApiException.fromDio(err);
    if (api.isAccessRevoked) {
      await _tokenStore.clear();
      _events.emit(SessionEvent.accessRevoked);
      return handler.next(err);
    }
    if (request.extra[retriedKey] == true) {
      return handler.next(err);
    }

    final staleToken = _bearerOf(request);
    final result = await _refresher.refresh(staleAccessToken: staleToken);
    switch (result) {
      case RefreshSucceeded():
        await _replay(request, err, handler);
      case RefreshSessionEnded():
        handler.next(err);
      case RefreshFailedTemporarily(:final cause):
        handler.reject(
          DioException(
            requestOptions: request,
            type: DioExceptionType.unknown,
            error: cause,
          ),
        );
    }
  }

  Future<void> _replay(
    RequestOptions request,
    DioException original,
    ErrorInterceptorHandler handler,
  ) async {
    final tokens = await _tokenStore.read();
    if (tokens == null) {
      return handler.next(original);
    }
    request.extra[retriedKey] = true;
    request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    if (request.path.endsWith(logoutPath) && request.data is Map) {
      // R1-10 : la deconnexion embarquait le refresh lu AVANT l'appel ; apres la rotation il est
      // revoque et le nouveau resterait actif 14 jours. On presente donc le refresh courant.
      request.data = {
        ...(request.data as Map).cast<String, Object?>(),
        'refreshToken': tokens.refreshToken,
      };
    }
    try {
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (error) {
      handler.reject(error);
    }
  }

  static String? _bearerOf(RequestOptions request) {
    final header = request.headers['Authorization'];
    if (header is String && header.startsWith('Bearer ')) {
      return header.substring('Bearer '.length);
    }
    return null;
  }
}
