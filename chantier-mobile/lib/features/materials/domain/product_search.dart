import 'package:chantier_mobile/core/utils/collation.dart';

/// Texte de recherche normalise : minuscules, sans accents ni diacritiques arabes, `Ø` retire
/// (« Rond HA Ø12 » -> `rond ha 12`), ponctuation en espaces, chiffres arabes en chiffres 0-9,
/// espaces compactes. Sert aux produits **et** a la saisie, pour qu'ils se rencontrent.
String normalizeSearchText(String text) {
  const accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'ç': 'c', 'é': 'e', //
    'è': 'e', 'ê': 'e', 'ë': 'e', 'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n', 'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', 'ú': 'u',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y', 'ÿ': 'y', 'œ': 'oe', 'æ': 'ae',
    // Diametres d'acier : « Ø12 » se tape « 12 ».
    'ø': ' ', '⌀': ' ', '∅': ' ',
    // Arabe : variantes de l'alif, ya, ta marbuta.
    'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا', 'ى': 'ي', 'ة': 'ه',
  };
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    // Diacritiques arabes (tashkeel) et tatweel : ignores.
    if ((rune >= 0x064B && rune <= 0x065F) ||
        rune == 0x0670 ||
        rune == 0x0640) {
      continue;
    }
    // Chiffres arabes orientaux -> 0-9.
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(0x30 + rune - 0x0660);
      continue;
    }
    if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(0x30 + rune - 0x06F0);
      continue;
    }
    final character = String.fromCharCode(rune);
    buffer.write(accents[character] ?? character);
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim();
}

/// Produit minimal necessaire a la recherche (nom francais et nom arabe facultatif).
class SearchableProduct {
  const SearchableProduct({
    required this.id,
    required this.nameFr,
    this.nameAr,
  });

  final String id;
  final String nameFr;
  final String? nameAr;
}

class _Entry {
  _Entry(this.product)
    : normalizedFr = normalizeSearchText(product.nameFr),
      tokens = _tokens(product.nameFr, product.nameAr);

  final SearchableProduct product;
  final String normalizedFr;
  final List<String> tokens;

  static List<String> _tokens(String nameFr, String? nameAr) => [
    ...normalizeSearchText(nameFr).split(' '),
    if (nameAr != null) ...normalizeSearchText(nameAr).split(' '),
  ].where((token) => token.isNotEmpty).toList(growable: false);
}

/// Recherche de produits **sans reseau** (CA-MAT-001.12) : index construit une fois (300 produits
/// reperes en quelques millisecondes), recherche tolerante.
///
/// Regles : chaque mot tape doit retrouver un mot du produit, par **prefixe** (« cim » ->
/// ciment) ; un mot d'au moins 4 lettres tolere **une faute** (« brik » -> brique : une lettre
/// changee, ajoutee, oubliee ou deux lettres echangees) ; un nombre ne tolere aucune faute (12 n'est
/// pas 13). L'ordre : mots exacts d'abord, puis prefixes, puis fautes ; a egalite, le nom qui
/// commence par la saisie, puis l'ordre alphabetique humain.
class ProductSearchIndex {
  ProductSearchIndex(Iterable<SearchableProduct> products)
    : _entries = [for (final product in products) _Entry(product)];

  final List<_Entry> _entries;

  static const int _exact = 0;
  static const int _prefix = 1;
  static const int _fuzzy = 3;

  /// Produits correspondant a [query], les meilleurs d'abord, au plus [limit]. Saisie vide : liste
  /// vide (l'ecran montre alors les tuiles des produits les plus demandes).
  List<SearchableProduct> search(String query, {int limit = 20}) {
    final normalizedQuery = normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return const [];
    final queryTokens = normalizedQuery.split(' ');

    final scored = <({_Entry entry, int score, bool startsWith})>[];
    for (final entry in _entries) {
      var score = 0;
      var matched = true;
      for (final token in queryTokens) {
        final level = _bestLevel(token, entry.tokens);
        if (level == null) {
          matched = false;
          break;
        }
        score += level;
      }
      if (matched) {
        scored.add((
          entry: entry,
          score: score,
          startsWith: entry.normalizedFr.startsWith(normalizedQuery),
        ));
      }
    }

    scored.sort((a, b) {
      final byScore = a.score.compareTo(b.score);
      if (byScore != 0) return byScore;
      if (a.startsWith != b.startsWith) return a.startsWith ? -1 : 1;
      return compareHuman(a.entry.product.nameFr, b.entry.product.nameFr);
    });
    return [for (final item in scored.take(limit)) item.entry.product];
  }

  /// Meilleur niveau d'appariement du mot [query] parmi [tokens] (`null` = aucun).
  static int? _bestLevel(String query, List<String> tokens) {
    int? best;
    final allowFault = query.length >= 4 && !_isNumber(query);
    for (final token in tokens) {
      if (token == query) return _exact;
      if (token.startsWith(query)) {
        best = best == null || _prefix < best ? _prefix : best;
      } else if (allowFault && (best == null || _fuzzy < best)) {
        if (_matchesWithOneFault(query, token)) best = _fuzzy;
      }
    }
    return best;
  }

  static bool _isNumber(String text) => RegExp(r'^\d+$').hasMatch(text);

  /// Le mot tape ressemble au debut de [token] a une faute pres.
  static bool _matchesWithOneFault(String query, String token) {
    for (var length = query.length - 1; length <= query.length + 1; length++) {
      if (length < 1 || length > token.length) continue;
      if (_withinOneEdit(query, token.substring(0, length))) return true;
    }
    return false;
  }

  /// Distance de Damerau-Levenshtein (transposition comprise) au plus egale a 1.
  static bool _withinOneEdit(String a, String b) {
    final lengthA = a.length;
    final lengthB = b.length;
    if ((lengthA - lengthB).abs() > 1) return false;
    var i = 0;
    while (i < lengthA && i < lengthB && a[i] == b[i]) {
      i++;
    }
    if (i == lengthA && i == lengthB) return true;
    if (lengthA == lengthB) {
      if (a.substring(i + 1) == b.substring(i + 1)) return true;
      return i + 1 < lengthA &&
          a[i] == b[i + 1] &&
          a[i + 1] == b[i] &&
          a.substring(i + 2) == b.substring(i + 2);
    }
    return lengthA > lengthB
        ? a.substring(i + 1) == b.substring(i)
        : b.substring(i + 1) == a.substring(i);
  }
}
