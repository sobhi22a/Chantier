/// Cle de tri « lecture humaine » : minuscules et sans accents, pour que « École UV18 » se range
/// a E et non apres Z. SQLite (`COLLATE NOCASE`) ne plie que les lettres ASCII, le tri des noms
/// francais se fait donc ici.
String collationKey(String text) {
  const from = 'àâäáãçéèêëíìîïñóòôöõúùûüýÿœæ';
  const to = 'aaaaaceeeeiiiinooooouuuuyyoa';
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final character = String.fromCharCode(rune);
    final index = from.indexOf(character);
    buffer.write(index < 0 ? character : to[index]);
  }
  return buffer.toString();
}

/// Compare deux textes selon [collationKey].
int compareHuman(String a, String b) =>
    collationKey(a).compareTo(collationKey(b));
