import 'dart:io';

import 'package:dio/dio.dart';

/// Erreur typee de l'API (Problem Details RFC 9457, `docs/api/codes-erreur.md`).
///
/// Ne conserve volontairement ni `title` ni `detail` : l'interface traduit le `code`
/// (`core/l10n/error_messages.dart`), elle n'affiche jamais le texte brut du serveur (M-9).
/// Aucun jeton, mot de passe ni corps de requete n'est conserve ici ni dans [toString].
sealed class ApiException implements Exception {
  const ApiException({this.status, this.code, this.traceId});

  /// Statut HTTP, absent pour une erreur de transport.
  final int? status;

  /// Code metier stable (`ZONE_EXISTANTE`, `ACCES_RETIRE`...), absent hors Problem Details.
  final String? code;

  /// Identifiant de support, a communiquer a l'administrateur.
  final String? traceId;

  /// Compte desactive alors qu'une session existait : le mobile efface les donnees chantier.
  bool get isAccessRevoked => code == codeAccessRevoked;

  /// Jeton de rafraichissement expire, revoque ou reutilise.
  bool get isRefreshInvalid => code == codeRefreshInvalid;

  /// Mot de passe provisoire : seul le changement de mot de passe est autorise (CA-001.7).
  bool get isPasswordChangeRequired => code == codePasswordChangeRequired;

  /// Vrai si la meme operation peut reussir plus tard sans changement : reseau, delai,
  /// erreur serveur, trop de requetes. Une erreur de validation ou de regle metier ne l'est pas.
  bool get isRetryable => switch (this) {
    NetworkApiException() ||
    TimeoutApiException() ||
    ServerApiException() ||
    TooManyRequestsApiException() => true,
    _ => false,
  };

  static const String codeAccessRevoked = 'ACCES_RETIRE';
  static const String codeRefreshInvalid = 'REFRESH_INVALIDE';
  static const String codePasswordChangeRequired = 'MOT_DE_PASSE_A_CHANGER';

  /// Convertit toute erreur Dio. Une erreur deja typee (posee par un intercepteur) est conservee.
  factory ApiException.fromDio(DioException error) {
    final inner = error.error;
    if (inner is ApiException) return inner;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutApiException();
      case DioExceptionType.connectionError:
        return const NetworkApiException();
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) return ApiException.fromResponse(response);
        return const UnknownApiException();
      case DioExceptionType.unknown:
        // Hors ligne : Dio remonte souvent une SocketException sous `unknown`.
        if (inner is SocketException || inner is HttpException) {
          return const NetworkApiException();
        }
        return const UnknownApiException();
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        // Un certificat invalide n'est jamais ignore : l'echec est definitif.
        return const UnknownApiException();
    }
  }

  /// Convertit une reponse HTTP en erreur. Corps non conforme (page HTML d'un proxy...) :
  /// le statut seul decide.
  factory ApiException.fromResponse(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    final body = response.data;
    String? code;
    String? traceId;
    Map<String, List<String>> errors = const {};
    Map<String, dynamic>? current;

    if (body is Map) {
      code = _stringOrNull(body['code']);
      traceId = _stringOrNull(body['traceId']);
      errors = _parseErrors(body['errors']);
      final rawCurrent = body['current'];
      if (rawCurrent is Map) {
        current = Map<String, dynamic>.from(rawCurrent);
      }
    }

    return switch (status) {
      400 => ValidationApiException(
        status: status,
        code: code,
        traceId: traceId,
        errors: errors,
      ),
      401 => UnauthorizedApiException(
        status: status,
        code: code,
        traceId: traceId,
      ),
      403 => ForbiddenApiException(
        status: status,
        code: code,
        traceId: traceId,
      ),
      404 => NotFoundApiException(status: status, code: code, traceId: traceId),
      409 => ConflictApiException(
        status: status,
        code: code,
        traceId: traceId,
        current: current,
      ),
      413 => PayloadTooLargeApiException(
        status: status,
        code: code,
        traceId: traceId,
      ),
      422 => BusinessRuleApiException(
        status: status,
        code: code,
        traceId: traceId,
        errors: errors,
      ),
      429 => TooManyRequestsApiException(
        status: status,
        code: code,
        traceId: traceId,
        retryAfter: _parseRetryAfter(response.headers.value('retry-after')),
      ),
      >= 500 => ServerApiException(
        status: status,
        code: code,
        traceId: traceId,
      ),
      _ => UnknownApiException(status: status, code: code, traceId: traceId),
    };
  }

  static String? _stringOrNull(Object? value) =>
      value is String && value.isNotEmpty ? value : null;

  static Map<String, List<String>> _parseErrors(Object? raw) {
    if (raw is! Map) return const {};
    return {
      for (final entry in raw.entries)
        entry.key.toString(): entry.value is List
            ? [for (final item in entry.value as List) item.toString()]
            : [entry.value.toString()],
    };
  }

  /// `Retry-After` en secondes (la forme « date HTTP » est ignoree).
  static Duration? _parseRetryAfter(String? value) {
    final seconds = int.tryParse(value ?? '');
    return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
  }

  @override
  String toString() =>
      '$runtimeType(status: $status, code: $code, traceId: $traceId)';
}

/// Pas de reseau (aucune connexion, DNS, socket fermee) : la saisie reste en file d'envoi.
final class NetworkApiException extends ApiException {
  const NetworkApiException();
}

/// Le serveur n'a pas repondu a temps.
final class TimeoutApiException extends ApiException {
  const TimeoutApiException();
}

/// 400 : corps ou parametres invalides ; [errors] donne le detail par champ.
final class ValidationApiException extends ApiException {
  const ValidationApiException({
    super.status,
    super.code,
    super.traceId,
    this.errors = const {},
  });

  final Map<String, List<String>> errors;
}

/// 401 : `NON_AUTHENTIFIE`, `IDENTIFIANTS_INVALIDES`, `REFRESH_INVALIDE`, `ACCES_RETIRE`.
final class UnauthorizedApiException extends ApiException {
  const UnauthorizedApiException({super.status, super.code, super.traceId});
}

/// 403 : role sans la permission sur une ressource visible.
final class ForbiddenApiException extends ApiException {
  const ForbiddenApiException({super.status, super.code, super.traceId});
}

/// 404 : ressource absente **ou chantier non affecte** (reponse identique, volontairement).
final class NotFoundApiException extends ApiException {
  const NotFoundApiException({super.status, super.code, super.traceId});
}

/// 409 `CONFLIT_VERSION` : [current] est l'etat actuel de la ressource cote serveur.
final class ConflictApiException extends ApiException {
  const ConflictApiException({
    super.status,
    super.code,
    super.traceId,
    this.current,
  });

  final Map<String, dynamic>? current;
}

/// 413 `LOT_TROP_GRAND`.
final class PayloadTooLargeApiException extends ApiException {
  const PayloadTooLargeApiException({super.status, super.code, super.traceId});
}

/// 422 : regle metier violee ; le [code] dit laquelle (`ZONE_EXISTANTE`, `CHANTIER_ARCHIVE`...).
final class BusinessRuleApiException extends ApiException {
  const BusinessRuleApiException({
    super.status,
    super.code,
    super.traceId,
    this.errors = const {},
  });

  final Map<String, List<String>> errors;
}

/// 429 `TROP_D_ESSAIS` / `TROP_DE_REQUETES` ; [retryAfter] vient de l'en-tete `Retry-After`.
final class TooManyRequestsApiException extends ApiException {
  const TooManyRequestsApiException({
    super.status,
    super.code,
    super.traceId,
    this.retryAfter,
  });

  final Duration? retryAfter;
}

/// 5xx : erreur du serveur (aucun detail technique n'est jamais renvoye).
final class ServerApiException extends ApiException {
  const ServerApiException({super.status, super.code, super.traceId});
}

/// Tout le reste (annulation, certificat invalide, statut inattendu, corps illisible).
final class UnknownApiException extends ApiException {
  const UnknownApiException({super.status, super.code, super.traceId});
}
