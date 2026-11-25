import 'package:drift/drift.dart';

/// Date metier (`DateOnly` du serveur) stockee en texte `yyyy-MM-dd`, sans fuseau ni heure
/// (ADR 0008). Cote Dart, c'est un `DateTime` UTC a minuit : seuls annee, mois et jour comptent.
///
/// Une date incomplete ou impossible (`../03/2026`, `2026-02-30`) est refusee
/// (`FormatException`) : regle metier n°2.
class DateOnlyTextConverter extends TypeConverter<DateTime, String> {
  const DateOnlyTextConverter();

  static final RegExp _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  @override
  DateTime fromSql(String fromDb) => parse(fromDb);

  @override
  String toSql(DateTime value) => format(value);

  /// `2026-11-24` -> `DateTime.utc(2026, 11, 24)`.
  static DateTime parse(String text) {
    final match = _pattern.firstMatch(text);
    if (match == null) {
      throw FormatException(
        'Date incomplete ou invalide : attendu yyyy-MM-dd',
        text,
      );
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime.utc(year, month, day);
    // DateTime accepte 2026-02-30 (devient mars) : on exige la date exacte.
    if (date.year != year || date.month != month || date.day != day) {
      throw FormatException('Date impossible', text);
    }
    return date;
  }

  /// Annee, mois et jour du [value] (heure et fuseau ignores).
  static String format(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
