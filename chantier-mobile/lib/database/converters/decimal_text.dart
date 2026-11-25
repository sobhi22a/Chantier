import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Decimal stocke **en texte** (`-1.90`, `0.00`, `185000000.00`) : jamais de `double`
/// (regle 3, ADR 0008). Aucune arithmetique n'est faite sur ces valeurs cote mobile ;
/// `Decimal` sert a valider et a comparer.
///
/// L'ecriture respecte le nombre de decimales [scale] du contrat (cote `2`, montant `2`,
/// latitude `6`) : le JSON du serveur perd les zeros finaux (`3.40` arrive en `3.4`),
/// le texte stocke les retablit. Une valeur plus precise que [scale] est conservee
/// telle quelle (aucune perte silencieuse).
class DecimalTextConverter extends TypeConverter<Decimal, String> {
  const DecimalTextConverter({this.scale = 2});

  final int scale;

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) =>
      value.scale <= scale ? value.toStringAsFixed(scale) : value.toString();
}
