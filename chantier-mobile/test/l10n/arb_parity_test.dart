import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync())
        as Map<String, dynamic>;

Map<String, String> _messages(Map<String, dynamic> arb) => {
  for (final entry in arb.entries)
    if (!entry.key.startsWith('@')) entry.key: entry.value as String,
};

void main() {
  final fr = _messages(_load('app_fr.arb'));
  final ar = _messages(_load('app_ar.arb'));

  test('memes cles en francais et en arabe (CA-014.5)', () {
    expect(ar.keys.toSet(), fr.keys.toSet());
  });

  test('aucun texte vide', () {
    for (final entry in {...fr, ...ar}.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });

  test('le texte arabe est bien en arabe (sauf les noms de langue)', () {
    final arabicLetters = RegExp(r'[؀-ۿ]');
    for (final entry in ar.entries) {
      if (entry.key == 'languageFrench') continue;
      expect(
        arabicLetters.hasMatch(entry.value),
        isTrue,
        reason: '${entry.key} : ${entry.value}',
      );
    }
  });

  test('chiffres latins uniquement (H-10)', () {
    final arabicIndic = RegExp(r'[٠-٩۰-۹]');
    for (final entry in {...fr, ...ar}.entries) {
      expect(arabicIndic.hasMatch(entry.value), isFalse, reason: entry.key);
    }
  });

  test('memes parametres {nom} dans les deux langues', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    for (final key in fr.keys) {
      final inFr = placeholder
          .allMatches(fr[key]!)
          .map((m) => m.group(1))
          .toSet();
      final inAr = placeholder
          .allMatches(ar[key]!)
          .map((m) => m.group(1))
          .toSet();
      expect(inAr, inFr, reason: key);
    }
  });
}
