import 'dart:convert';

import 'package:drift/drift.dart';

/// Liste de textes (unites autorisees d'un produit, produits d'un fournisseur) stockee en JSON
/// dans une colonne texte : `["sac","t","kg"]`. Un texte illisible rend une liste vide plutot que
/// de faire echouer la lecture de l'ecran.
class StringListTextConverter extends TypeConverter<List<String>, String> {
  const StringListTextConverter();

  @override
  List<String> fromSql(String fromDb) {
    try {
      final decoded = jsonDecode(fromDb);
      if (decoded is List) {
        return [
          for (final item in decoded)
            if (item is String) item,
        ];
      }
    } on FormatException {
      // Texte illisible : liste vide.
    }
    return const [];
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
