import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/auth_interceptor.dart';
import 'package:chantier_mobile/core/network/request_interceptors.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/network/token_refresher.dart';
import 'package:chantier_mobile/core/storage/token_store.dart';
import 'package:dio/dio.dart';

/// Client HTTP unique de l'application (comme `DioClient` de Kardinal, defauts corriges).
///
/// * Bearer + **un seul rejeu** apres rafraichissement sur 401 ([AuthInterceptor]).
/// * Toute erreur ressort en [ApiException] typee (Problem Details) ; jamais de `DioException`
///   ni de texte brut pour l'interface.
/// * [bareDio] : client **nu** (sans jeton ni rejeu) pour le rafraichissement et l'appel de sante.
class DioClient {
  DioClient({
    required AppConfig config,
    required TokenStore tokenStore,
    required SessionEvents events,
    required String Function() languageCode,
    HttpClientAdapter? adapter,
  }) {
    _dio = _build(config, languageCode, adapter);
    _bareDio = _build(config, languageCode, adapter);
    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        tokenStore: tokenStore,
        refresher: TokenRefresher(
          anonymousAuth: AuthClient(_bareDio, baseUrl: config.serverRootUrl),
          tokenStore: tokenStore,
          events: events,
        ),
        events: events,
      ),
    );
  }

  late final Dio _dio;
  late final Dio _bareDio;

  Dio get dio => _dio;

  Dio get bareDio => _bareDio;

  static Dio _build(
    AppConfig config,
    String Function() languageCode,
    HttpClientAdapter? adapter,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.receiveTimeout,
        headers: const {
          Headers.contentTypeHeader: Headers.jsonContentType,
          Headers.acceptHeader: Headers.jsonContentType,
        },
        responseType: ResponseType.json,
      ),
    );
    if (adapter != null) dio.httpClientAdapter = adapter;
    dio.interceptors
      ..add(AcceptLanguageInterceptor(languageCode))
      ..add(SafeLogInterceptor());
    return dio;
  }

  /// [authenticated] = `false` pour les appels anonymes (connexion) : ni Bearer ni rejeu.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool authenticated = true,
  }) => guard(
    () => _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _options(options, authenticated),
      cancelToken: cancelToken,
    ),
  );

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool authenticated = true,
  }) => guard(
    () => _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _options(options, authenticated),
      cancelToken: cancelToken,
    ),
  );

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool authenticated = true,
  }) => guard(
    () => _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _options(options, authenticated),
      cancelToken: cancelToken,
    ),
  );

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool authenticated = true,
  }) => guard(
    () => _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _options(options, authenticated),
      cancelToken: cancelToken,
    ),
  );

  static Options _options(Options? options, bool authenticated) {
    final base = options ?? Options();
    return base.copyWith(
      extra: {...?base.extra, AuthInterceptor.skipAuthKey: !authenticated},
    );
  }

  /// Execute un appel Dio (ou un client genere) et convertit toute erreur en [ApiException].
  /// Une reponse dont le corps n'a pas la forme du contrat (champ requis absent...) ressort en
  /// [UnknownApiException] : jamais une `TypeError` brute jusqu'a l'interface.
  static Future<T> guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on TypeError {
      throw const UnknownApiException();
    } on FormatException {
      throw const UnknownApiException();
    }
  }
}
