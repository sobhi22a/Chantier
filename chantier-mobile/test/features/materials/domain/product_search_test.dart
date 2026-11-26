import 'package:chantier_mobile/features/materials/domain/product_search.dart';
import 'package:flutter_test/flutter_test.dart';

/// Catalogue fictif de 13 produits (jeu de test du document metier), repete jusqu'a 300.
const _base = <(String, String?)>[
  ('Ciment CPJ 42,5', 'إسمنت CPJ 42,5'),
  ('Monocouche', 'طلاء أحادي الطبقة'),
  ('Rond HA Ø8', 'حديد التسليح HA Ø8'),
  ('Rond HA Ø10', 'حديد التسليح HA Ø10'),
  ('Rond HA Ø12', 'حديد التسليح HA Ø12'),
  ('Rond HA Ø14', 'حديد التسليح HA Ø14'),
  ('Brique creuse 12 trous', 'آجر مجوف 12 ثقب'),
  ('Brique creuse 8 trous', 'آجر مجوف 8 ثقوب'),
  ('Sable de maçonnerie', 'رمل'),
  ('Gravier 8/15', 'حصى'),
  ('Gravier 15/25', 'حصى'),
  ('Adjuvant plastifiant', 'مادة مضافة'),
  ('Parpaing 20', null),
];

List<SearchableProduct> _catalog({int size = 13}) => [
  for (var i = 0; i < size; i++)
    SearchableProduct(
      id: 'p$i',
      nameFr: i < _base.length ? _base[i].$1 : 'Produit divers n°$i',
      nameAr: i < _base.length ? _base[i].$2 : null,
    ),
];

List<String> _names(ProductSearchIndex index, String query) => [
  for (final product in index.search(query)) product.nameFr,
];

void main() {
  final index = ProductSearchIndex(_catalog());

  group('normalisation', () {
    test('minuscules, sans accents, sans Ø, espaces compactes', () {
      expect(normalizeSearchText('  Rond  HA Ø12 '), 'rond ha 12');
      expect(normalizeSearchText('Maçonnerie'), 'maconnerie');
      expect(normalizeSearchText('ÉCOLE'), 'ecole');
      expect(normalizeSearchText('Ciment CPJ 42,5'), 'ciment cpj 42 5');
    });

    test('arabe : diacritiques, alif, chiffres orientaux', () {
      expect(normalizeSearchText('إسمنت'), normalizeSearchText('اسمنت'));
      expect(normalizeSearchText('مَادّة'), normalizeSearchText('مادة'));
      expect(normalizeSearchText('مَادّة'), 'ماده');
      expect(normalizeSearchText('١٢'), '12');
    });
  });

  group('recherche tolerante, sans reseau (CA-MAT-001.12)', () {
    test('« cim » trouve le ciment (prefixe)', () {
      expect(_names(index, 'cim'), ['Ciment CPJ 42,5']);
    });

    test('« ha 12 » trouve le rond HA Ø12 en premier', () {
      expect(_names(index, 'ha 12').first, 'Rond HA Ø12');
      expect(_names(index, 'ha 12'), ['Rond HA Ø12']);
    });

    test('« brik 12 » : une faute tolérée, brique creuse 12 trous', () {
      expect(_names(index, 'brik 12'), ['Brique creuse 12 trous']);
    });

    test('accents et casse indifferents : « MACONNERIE »', () {
      expect(_names(index, 'MACONNERIE'), ['Sable de maçonnerie']);
      expect(_names(index, 'maçon'), ['Sable de maçonnerie']);
    });

    test('un nombre ne tolere aucune faute : « 13 » ne trouve pas Ø12', () {
      expect(_names(index, 'ha 13'), isEmpty);
      expect(_names(index, 'rond 11'), isEmpty);
    });

    test('faute de frappe : lettre oubliee, ajoutee, echangee', () {
      expect(_names(index, 'cimnt'), ['Ciment CPJ 42,5']);
      expect(_names(index, 'cimeent'), ['Ciment CPJ 42,5']);
      expect(_names(index, 'cimnet'), ['Ciment CPJ 42,5']);
    });

    test('un mot trop court ne tolere pas de faute', () {
      expect(_names(index, 'cem'), isEmpty);
    });

    test('tous les mots doivent correspondre', () {
      expect(_names(index, 'gravier 25'), ['Gravier 15/25']);
      expect(_names(index, 'ciment sable'), isEmpty);
    });

    test('recherche en arabe', () {
      expect(_names(index, 'اسمنت'), ['Ciment CPJ 42,5']);
      expect(_names(index, 'حديد'), hasLength(4));
    });

    test('saisie vide : aucun resultat (l ecran montre les tuiles)', () {
      expect(index.search(''), isEmpty);
      expect(index.search('   '), isEmpty);
    });

    test('exact avant prefixe avant faute', () {
      final local = ProductSearchIndex([
        const SearchableProduct(id: '1', nameFr: 'Ciments speciaux'),
        const SearchableProduct(id: '2', nameFr: 'Ciment'),
        const SearchableProduct(id: '3', nameFr: 'Ciments'),
      ]);

      expect([for (final p in local.search('ciment')) p.id], ['2', '3', '1']);
    });

    test('limite de resultats', () {
      final large = ProductSearchIndex(_catalog(size: 300));
      expect(large.search('produit', limit: 20), hasLength(20));
    });
  });

  test('300 produits : index et recherche en moins de 100 ms', () {
    final stopwatch = Stopwatch()..start();
    final large = ProductSearchIndex(_catalog(size: 300));
    final built = stopwatch.elapsedMilliseconds;
    stopwatch
      ..reset()
      ..start();
    for (final query in ['cim', 'ha 12', 'brik 12', 'produit divers 250']) {
      large.search(query);
    }
    final searched = stopwatch.elapsedMilliseconds;

    expect(built, lessThan(100), reason: 'index : $built ms');
    expect(searched / 4, lessThan(100), reason: 'recherche : $searched ms / 4');
  });
}
