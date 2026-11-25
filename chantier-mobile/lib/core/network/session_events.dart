import 'dart:async';

/// Evenements de session emis par la couche reseau, ecoutes par l'authentification (M6).
enum SessionEvent {
  /// Le jeton de rafraichissement n'est plus valide (ou absent) : reconnexion necessaire.
  /// Les jetons sont effaces ; la base locale et la file d'envoi sont **conservees**.
  authRequired,

  /// Compte desactive (`ACCES_RETIRE`) : jetons effaces et donnees chantier a purger
  /// (CA-002.5). La file d'envoi reste intacte pour l'administrateur (question Q-09).
  accessRevoked,

  /// 403 `MOT_DE_PASSE_A_CHANGER` : mot de passe provisoire, le serveur refuse tout sauf le
  /// changement de mot de passe (CA-001.7). Les jetons restent valides ; rien n'est efface.
  passwordChangeRequired,
}

/// Canal de diffusion des [SessionEvent].
///
/// Flux de diffusion (broadcast) : un evenement emis sans ecouteur est perdu, donc
/// l'authentification verifie aussi la presence des jetons au demarrage.
class SessionEvents {
  final StreamController<SessionEvent> _controller =
      StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get stream => _controller.stream;

  void emit(SessionEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  Future<void> dispose() => _controller.close();
}
