import 'dart:async';

import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';
import 'package:chantier_mobile/core/network/session_events.dart';
import 'package:chantier_mobile/core/storage/token_pair.dart';
import 'package:chantier_mobile/core/storage/token_store.dart';
import 'package:logging/logging.dart';

/// Resultat d'une tentative de rafraichissement.
sealed class RefreshResult {
  const RefreshResult();
}

/// Nouveaux jetons enregistres : la requete refusee peut etre rejouee **une fois**.
final class RefreshSucceeded extends RefreshResult {
  const RefreshSucceeded();
}

/// Le serveur a refuse le jeton (401) ou il n'y en a plus : jetons effaces, evenement
/// [SessionEvent] emis. La base locale et la file d'envoi ne sont pas touchees.
final class RefreshSessionEnded extends RefreshResult {
  const RefreshSessionEnded();
}

/// Echec temporaire (reseau, delai, 5xx, 429) : **les jetons sont conserves**, la session
/// reste ouverte. Etre hors ligne n'est pas etre deconnecte.
final class RefreshFailedTemporarily extends RefreshResult {
  const RefreshFailedTemporarily(this.cause);

  final ApiException cause;
}

/// Echange le jeton de rafraichissement contre une nouvelle paire (`POST /auth/refresh`,
/// client genere `AuthClient.authRefresh`).
///
/// Le jeton est **rotatif** : une reutilisation de l'ancien revoque toute la chaine cote
/// serveur. D'ou deux protections :
/// * un seul rafraichissement a la fois : les requetes simultanees en 401 partagent le meme ;
/// * si les jetons ont deja change depuis la requete refusee, on ne rappelle pas le serveur.
class TokenRefresher {
  TokenRefresher({
    required AuthClient anonymousAuth,
    required TokenStore tokenStore,
    required SessionEvents events,
  }) : _auth = anonymousAuth,
       _tokenStore = tokenStore,
       _events = events;

  /// Client **nu** (sans intercepteur d'autorisation) : sinon un 401 bouclerait.
  final AuthClient _auth;
  final TokenStore _tokenStore;
  final SessionEvents _events;
  static final Logger _log = Logger('TokenRefresher');

  Future<RefreshResult>? _inFlight;

  /// [staleAccessToken] : jeton d'acces de la requete refusee (pour detecter qu'un autre
  /// appel a deja rafraichi entre-temps).
  Future<RefreshResult> refresh({String? staleAccessToken}) {
    final running = _inFlight;
    if (running != null) return running;
    final future = _run(staleAccessToken).whenComplete(() => _inFlight = null);
    _inFlight = future;
    return future;
  }

  Future<RefreshResult> _run(String? staleAccessToken) async {
    final tokens = await _tokenStore.read();
    if (tokens == null) {
      _log.info('Pas de jeton de rafraichissement : reconnexion necessaire.');
      _events.emit(SessionEvent.authRequired);
      return const RefreshSessionEnded();
    }
    if (staleAccessToken != null && tokens.accessToken != staleAccessToken) {
      // Un autre appel a deja obtenu de nouveaux jetons : ne pas rejouer l'ancien refresh.
      return const RefreshSucceeded();
    }

    try {
      final result = await DioClient.guard(
        () => _auth.authRefresh(
          body: RefreshRequest(refreshToken: tokens.refreshToken),
        ),
      );
      final access = result.accessToken;
      final refresh = result.refreshToken;
      if (access == null ||
          access.isEmpty ||
          refresh == null ||
          refresh.isEmpty) {
        _log.warning(
          'Reponse de rafraichissement inattendue : jetons conserves.',
        );
        return const RefreshFailedTemporarily(UnknownApiException());
      }
      await _tokenStore.save(
        TokenPair(accessToken: access, refreshToken: refresh),
      );
      _log.fine('Jetons rafraichis.');
      return const RefreshSucceeded();
    } on UnauthorizedApiException catch (api) {
      // Refus definitif du serveur (REFRESH_INVALIDE, ACCES_RETIRE...) : seuls les jetons
      // sont effaces.
      await _tokenStore.clear();
      final revoked = api.isAccessRevoked;
      _log.info(
        'Rafraichissement refuse (${api.code ?? 'sans code'}) : '
        '${revoked ? 'acces retire' : 'reconnexion necessaire'}.',
      );
      _events.emit(
        revoked ? SessionEvent.accessRevoked : SessionEvent.authRequired,
      );
      return const RefreshSessionEnded();
    } on ApiException catch (api) {
      _log.info(
        'Rafraichissement impossible pour l\'instant (${api.runtimeType}).',
      );
      return RefreshFailedTemporarily(api);
    }
  }
}
