import 'dart:math';

/// Delai de reprise apres un echec de synchronisation : **exponentiel avec aleas** (ADR 0009 :
/// 5 s a 5 min), pour ne pas marteler un serveur ou un reseau en difficulte ni synchroniser en
/// boucle (batterie et donnees).
///
/// Echec n°1 : ~5 s, n°2 : ~10 s, n°3 : ~20 s... plafonne a [max]. L'aleas retire jusqu'a la
/// moitie du delai (`delai x [0,5 ; 1,0]`) pour desynchroniser les telephones d'une meme equipe.
class Backoff {
  Backoff({
    this.base = const Duration(seconds: 5),
    this.max = const Duration(minutes: 5),
    Random? random,
  }) : _random = random ?? Random();

  final Duration base;
  final Duration max;
  final Random _random;

  /// Delai avant la tentative suivante, apres [failures] echecs consecutifs (>= 1).
  /// [minimum] (`Retry-After` d'un 429) est un plancher : jamais reessayer plus tot.
  Duration delay(int failures, {Duration? minimum}) {
    final exponent = (failures < 1 ? 1 : failures) - 1;
    // Evite le debordement : au-dela de 30 doublements le plafond est de toute facon atteint.
    final capped = exponent > 30
        ? max
        : Duration(
            milliseconds: min(
              max.inMilliseconds,
              base.inMilliseconds * (1 << exponent),
            ),
          );
    final jittered = Duration(
      milliseconds: (capped.inMilliseconds * (0.5 + _random.nextDouble() * 0.5))
          .round(),
    );
    if (minimum != null && minimum > jittered) return minimum;
    return jittered;
  }
}
