import 'package:chantier_mobile/features/zones/domain/zone_format.dart';
import 'package:decimal/decimal.dart';

/// Regles de saisie d'une zone, verifiees avant l'enregistrement local. Le serveur refuse de toute
/// facon (400 `VALIDATION`) : ces controles evitent un refus bien plus tard, hors ligne.
abstract final class ZoneRules {
  /// Bornes de la cote en metres (H-15), parametrables a la compilation comme cote serveur
  /// (`Zones:ElevationMin/Max`) : `--dart-define=ZONE_ELEVATION_MIN=-20.00`.
  static final Decimal elevationMin = Decimal.parse(
    const String.fromEnvironment('ZONE_ELEVATION_MIN', defaultValue: '-20.00'),
  );
  static final Decimal elevationMax = Decimal.parse(
    const String.fromEnvironment('ZONE_ELEVATION_MAX', defaultValue: '60.00'),
  );

  static const int blockMaxLength = 50;
  static const int roomLabelMaxLength = 100;
  static const int roomNumberMin = 1;
  static const int roomNumberMax = 999;

  /// Bornes affichees dans les messages : `−20,00` et `+60,00`.
  static String get minLabel => signedElevation(elevationMin);
  static String get maxLabel => signedElevation(elevationMax);

  /// Resultat de la lecture d'une cote saisie au clavier.
  static ElevationParse parseElevation(String input) {
    final text = input.trim().replaceAll(',', '.').replaceAll('−', '-');
    if (!RegExp(r'^[+-]?\d+(\.\d{1,2})?$').hasMatch(text)) {
      return const ElevationParse.invalid();
    }
    final value = Decimal.parse(
      text.startsWith('+') ? text.substring(1) : text,
    );
    if (value < elevationMin || value > elevationMax) {
      return const ElevationParse.outOfRange();
    }
    return ElevationParse.ok(value);
  }
}

enum ElevationProblem { invalid, outOfRange }

/// `3,4` et `3.4` donnent `+3,40 m` (CA-011.2) ; des lettres ou plus de deux decimales sont refusees.
class ElevationParse {
  const ElevationParse.ok(Decimal this.value) : problem = null;

  const ElevationParse.invalid()
    : value = null,
      problem = ElevationProblem.invalid;

  const ElevationParse.outOfRange()
    : value = null,
      problem = ElevationProblem.outOfRange;

  final Decimal? value;
  final ElevationProblem? problem;
}
