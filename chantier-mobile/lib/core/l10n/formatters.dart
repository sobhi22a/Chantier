/// Formats d'affichage (CA-014.7, H-10) : identiques en francais et en arabe.
/// Dates JJ/MM/AAAA, heures sur 24 h (fuseau Africa/Algiers), virgule decimale,
/// espace comme separateur de milliers, **chiffres 0 a 9** dans les deux langues.
///
/// Volontairement independant de la locale `intl` : `ar` donnerait des chiffres
/// arabes orientaux. En arabe, ces valeurs s'affichent dans un `LtrText`.
abstract final class Formatters {
  /// L'Algerie est a UTC+1 toute l'annee (pas d'heure d'ete) : decalage fixe.
  static const Duration algiersOffset = Duration(hours: 1);

  /// Espace insecable fine : separateur de milliers.
  static const String thousandsSeparator = ' ';

  /// Isole [text] en gauche-a-droite dans un texte arabe (Unicode LRI ... PDI) : `+3,40 m` ne devient
  /// jamais `3,40+ m`, une date ne s'inverse pas (CA-014.4). Invisible, sans effet en francais.
  static String isolateLtr(String text) => '\u2066$text\u2069';

  /// Nom de personne dans une phrase de l'interface : un nom **latin** (« Mourad B. ») est isole de
  /// gauche a droite, sinon en arabe le point final passe a gauche (« .Mourad B »). Un nom deja
  /// ecrit en arabe suit le sens de la langue et reste tel quel.
  static String isolateName(String name) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(name) ? name : isolateLtr(name);

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Date metier (sans fuseau) : `24/11/2026`.
  static String date(DateTime date) =>
      '${_two(date.day)}/${_two(date.month)}/${date.year.toString().padLeft(4, '0')}';

  /// Horodatage UTC affiche a l'heure d'Alger : `24/11/2026 11:15`.
  static String dateTime(DateTime utc) {
    final local = utc.toUtc().add(algiersOffset);
    return '${date(local)} ${_two(local.hour)}:${_two(local.minute)}';
  }

  /// Affiche un decimal recu **sous forme de texte** (jamais converti en `double` :
  /// aucune arithmetique cote mobile, regle 3) : `185000000.00` -> `185 000 000,00`.
  /// Un texte qui n'est pas un decimal est rendu tel quel.
  static String decimal(String value) {
    final match = RegExp(r'^(-?)(\d+)(?:\.(\d+))?$').firstMatch(value);
    if (match == null) return value;
    final sign = match.group(1)!;
    final integer = match.group(2)!;
    final fraction = match.group(3);
    final grouped = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) {
        grouped.write(thousandsSeparator);
      }
      grouped.write(integer[i]);
    }
    return '$sign$grouped${fraction == null ? '' : ',$fraction'}';
  }
}
