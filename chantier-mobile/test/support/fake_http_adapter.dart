import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Reponse scriptee du faux serveur.
class FakeResponse {
  const FakeResponse(this.status, {this.body, this.headers = const {}});

  /// 200 JSON.
  const FakeResponse.ok([Object? body]) : this(200, body: body);

  /// Reponse d'erreur au format Problem Details (RFC 9457).
  FakeResponse.problem(
    int status,
    String code, {
    String traceId = 'trace-test',
    Map<String, Object?> extra = const {},
    Map<String, String> headers = const {},
  }) : this(
         status,
         body: {
           'type': 'https://chantier.local/errors/test',
           'title': 'Erreur',
           'status': status,
           'detail': 'Detail serveur brut (ne doit jamais etre affiche)',
           'code': code,
           'traceId': traceId,
           ...extra,
         },
         headers: {'content-type': 'application/problem+json', ...headers},
       );

  final int status;
  final Object? body;
  final Map<String, String> headers;
}

/// Requete enregistree par le faux serveur (aucun appel reseau reel dans les tests).
class RecordedRequest {
  RecordedRequest({
    required this.method,
    required this.path,
    required this.uri,
    required this.headers,
    required this.body,
  });

  final String method;

  /// Chemin tel que demande au client (`/auth/refresh`) ou chemin de l'URL absolue.
  final String path;
  final Uri uri;
  final Map<String, dynamic> headers;
  final Object? body;

  String? header(String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) {
        return entry.value?.toString();
      }
    }
    return null;
  }

  @override
  String toString() => '$method $path';
}

typedef FakeHandler = FutureOr<FakeResponse> Function(RecordedRequest request);

/// Faux serveur HTTP : branche sur `Dio.httpClientAdapter`. Les reponses sont choisies par
/// `METHODE chemin` ; un gestionnaire peut aussi lever une `DioException` (coupure reseau).
class FakeHttpAdapter implements HttpClientAdapter {
  final Map<String, FakeHandler> _handlers = {};
  final List<RecordedRequest> requests = [];

  /// Declare le gestionnaire de `METHODE chemin` (ex. `GET /sync/changes`).
  void on(String route, FakeHandler handler) => _handlers[route] = handler;

  /// Reponse fixe.
  void respond(String route, FakeResponse response) =>
      on(route, (_) => response);

  /// Requetes recues pour une route (`METHODE chemin`).
  List<RecordedRequest> callsTo(String route) =>
      requests.where((r) => '${r.method} ${r.path}' == route).toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final recorded = RecordedRequest(
      method: options.method,
      path: options.uri.hasAuthority && options.path.startsWith('http')
          ? options.uri.path
          : options.path,
      uri: options.uri,
      headers: Map<String, dynamic>.of(options.headers),
      body: options.data,
    );
    requests.add(recorded);

    final handler = _handlers['${recorded.method} ${recorded.path}'];
    if (handler == null) {
      throw StateError(
        'Aucun gestionnaire pour ${recorded.method} ${recorded.path}',
      );
    }
    final response = await handler(recorded);
    final payload = response.body == null ? '' : jsonEncode(response.body);
    return ResponseBody.fromString(
      payload,
      response.status,
      headers: {
        Headers.contentTypeHeader: [
          response.headers['content-type'] ?? Headers.jsonContentType,
        ],
        for (final entry in response.headers.entries)
          if (entry.key != 'content-type') entry.key: [entry.value],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Coupure reseau : a lever depuis un gestionnaire.
DioException connectionError() => DioException(
  requestOptions: RequestOptions(),
  type: DioExceptionType.connectionError,
  error: 'connection error',
);
