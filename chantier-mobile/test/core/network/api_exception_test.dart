import 'dart:io';

import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> _response(
  int status, {
  Object? body,
  Map<String, List<String>> headers = const {},
}) => Response<dynamic>(
  requestOptions: RequestOptions(path: '/x'),
  statusCode: status,
  data: body,
  headers: Headers.fromMap(headers),
);

void main() {
  group('statut HTTP -> type', () {
    final cases = <int, Matcher>{
      400: isA<ValidationApiException>(),
      401: isA<UnauthorizedApiException>(),
      403: isA<ForbiddenApiException>(),
      404: isA<NotFoundApiException>(),
      409: isA<ConflictApiException>(),
      413: isA<PayloadTooLargeApiException>(),
      422: isA<BusinessRuleApiException>(),
      429: isA<TooManyRequestsApiException>(),
      500: isA<ServerApiException>(),
      503: isA<ServerApiException>(),
      418: isA<UnknownApiException>(),
    };
    cases.forEach((status, matcher) {
      test('$status', () {
        expect(ApiException.fromResponse(_response(status)), matcher);
      });
    });
  });

  group('Problem Details (RFC 9457)', () {
    test('lit code, traceId et statut', () {
      final error = ApiException.fromResponse(
        _response(
          422,
          body: {
            'type': 'https://chantier.local/errors/zone-existante',
            'title': 'Zone deja existante',
            'status': 422,
            'detail': 'Une zone identique existe deja sur ce chantier.',
            'code': 'ZONE_EXISTANTE',
            'traceId': '00-4bf9',
          },
        ),
      );

      expect(error.code, 'ZONE_EXISTANTE');
      expect(error.traceId, '00-4bf9');
      expect(error.status, 422);
    });

    test('VALIDATION : erreurs par champ', () {
      final error = ApiException.fromResponse(
        _response(
          400,
          body: {
            'code': 'VALIDATION',
            'errors': {
              'block': ['Le bloc est obligatoire.'],
              'elevation': ['Hors plage.', 'Deux decimales.'],
            },
          },
        ),
      );

      expect(error, isA<ValidationApiException>());
      expect((error as ValidationApiException).errors, {
        'block': ['Le bloc est obligatoire.'],
        'elevation': ['Hors plage.', 'Deux decimales.'],
      });
    });

    test('CONFLIT_VERSION : etat courant du serveur', () {
      final error = ApiException.fromResponse(
        _response(
          409,
          body: {
            'code': 'CONFLIT_VERSION',
            'current': {'id': 'z1', 'version': '48230'},
          },
        ),
      );

      expect(error, isA<ConflictApiException>());
      expect((error as ConflictApiException).current, {
        'id': 'z1',
        'version': '48230',
      });
    });

    test(
      'corps non Problem Details (page HTML d un proxy) : le statut seul decide',
      () {
        final error = ApiException.fromResponse(
          _response(502, body: '<html>Bad gateway</html>'),
        );

        expect(error, isA<ServerApiException>());
        expect(error.code, isNull);
        expect(error.traceId, isNull);
      },
    );

    test('Retry-After en secondes', () {
      final error = ApiException.fromResponse(
        _response(
          429,
          body: {'code': 'TROP_D_ESSAIS'},
          headers: {
            'retry-after': ['60'],
          },
        ),
      );

      expect(
        (error as TooManyRequestsApiException).retryAfter,
        const Duration(seconds: 60),
      );
    });

    test('Retry-After illisible : ignore', () {
      final error = ApiException.fromResponse(
        _response(
          429,
          headers: {
            'retry-after': ['Wed, 21 Oct 2026 07:28:00 GMT'],
          },
        ),
      );

      expect((error as TooManyRequestsApiException).retryAfter, isNull);
    });

    test('ACCES_RETIRE et REFRESH_INVALIDE reconnus', () {
      final revoked = ApiException.fromResponse(
        _response(401, body: {'code': 'ACCES_RETIRE'}),
      );
      final refresh = ApiException.fromResponse(
        _response(401, body: {'code': 'REFRESH_INVALIDE'}),
      );

      expect(revoked.isAccessRevoked, isTrue);
      expect(revoked.isRefreshInvalid, isFalse);
      expect(refresh.isRefreshInvalid, isTrue);
    });
  });

  group('erreurs de transport', () {
    DioException transport(DioExceptionType type, {Object? error}) =>
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: type,
          error: error,
        );

    test('delais depasses : TimeoutApiException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          ApiException.fromDio(transport(type)),
          isA<TimeoutApiException>(),
        );
      }
    });

    test('pas de connexion : NetworkApiException', () {
      expect(
        ApiException.fromDio(transport(DioExceptionType.connectionError)),
        isA<NetworkApiException>(),
      );
      expect(
        ApiException.fromDio(
          transport(
            DioExceptionType.unknown,
            error: const SocketException('offline'),
          ),
        ),
        isA<NetworkApiException>(),
      );
    });

    test('certificat invalide ou annulation : jamais contourne', () {
      expect(
        ApiException.fromDio(transport(DioExceptionType.badCertificate)),
        isA<UnknownApiException>(),
      );
      expect(
        ApiException.fromDio(transport(DioExceptionType.cancel)),
        isA<UnknownApiException>(),
      );
    });

    test('une erreur deja typee est conservee', () {
      const typed = ServerApiException(status: 503);

      expect(
        ApiException.fromDio(transport(DioExceptionType.unknown, error: typed)),
        same(typed),
      );
    });
  });

  group('retentable ?', () {
    test('reseau, delai, 5xx, 429 : oui', () {
      expect(const NetworkApiException().isRetryable, isTrue);
      expect(const TimeoutApiException().isRetryable, isTrue);
      expect(const ServerApiException(status: 500).isRetryable, isTrue);
      expect(
        const TooManyRequestsApiException(status: 429).isRetryable,
        isTrue,
      );
    });

    test('validation, regle metier, conflit, droits : non', () {
      expect(const ValidationApiException(status: 400).isRetryable, isFalse);
      expect(const BusinessRuleApiException(status: 422).isRetryable, isFalse);
      expect(const ConflictApiException(status: 409).isRetryable, isFalse);
      expect(const ForbiddenApiException(status: 403).isRetryable, isFalse);
      expect(const NotFoundApiException(status: 404).isRetryable, isFalse);
    });
  });

  test('toString ne contient que statut, code et traceId', () {
    const error = BusinessRuleApiException(
      status: 422,
      code: 'ZONE_EXISTANTE',
      traceId: 't-1',
    );

    expect(
      error.toString(),
      'BusinessRuleApiException(status: 422, code: ZONE_EXISTANTE, traceId: t-1)',
    );
  });
}
