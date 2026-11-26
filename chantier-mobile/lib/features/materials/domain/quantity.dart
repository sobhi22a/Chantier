import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Unites du referentiel (skill `metier-chantier`, contrat `Quantity.unit`). Codes stables :
/// ce sont eux qui voyagent entre le serveur et la base locale.
enum MeasureUnit {
  piece('u', integerOnly: true),
  linearMeter('ml'),
  squareMeter('m2'),
  cubicMeter('m3'),
  kilogram('kg'),
  tonne('t'),
  bag('sac', integerOnly: true),
  liter('l'),
  hour('h'),
  day('j'),
  manDay('pj'),
  lumpSum('ft');

  const MeasureUnit(this.code, {this.integerOnly = false});

  final String code;

  /// `sac` et `u` : jamais de decimale (« Nombre entier requis »).
  final bool integerOnly;

  /// Unite de la famille convertible `sac` <-> `kg` <-> `t` (seules conversions autorisees).
  bool get isMass => this == bag || this == kilogram || this == tonne;

  /// Un code absent ou inconnu rend `null` : la valeur est alors affichee telle que recue.
  static MeasureUnit? tryParse(String? code) {
    for (final unit in values) {
      if (unit.code == code) return unit;
    }
    return null;
  }
}

/// Quantite **avec** son unite : jamais l'une sans l'autre (regle metier n°1). Le nombre est un
/// `Decimal` (jamais un `double`).
class Quantity extends Equatable {
  const Quantity(this.value, this.unit);

  /// Texte decimal (`'2.5'`) + code d'unite (`'kg'`), comme en base locale. Une unite inconnue
  /// declenche une `FormatException` : l'appelant garde alors la valeur telle que recue.
  factory Quantity.parse(String value, String unitCode) {
    final unit = MeasureUnit.tryParse(unitCode);
    if (unit == null) {
      throw FormatException('Unite inconnue', unitCode);
    }
    return Quantity(Decimal.parse(value), unit);
  }

  final Decimal value;
  final MeasureUnit unit;

  @override
  List<Object?> get props => [value, unit];

  @override
  String toString() => '${value.toString()} ${unit.code}';
}

/// Regle de calcul ou de saisie violee. [code] est un code du catalogue
/// `docs/api/codes-erreur.md` (`UNITES_INCOMPATIBLES`, `QUANTITE_INVALIDE`...), traduit pour
/// l'utilisateur par `errorMessageForCode`.
class QuantityException implements Exception {
  const QuantityException(this.code);

  final String code;

  @override
  String toString() => 'QuantityException($code)';
}
