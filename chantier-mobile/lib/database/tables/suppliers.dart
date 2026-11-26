import 'package:chantier_mobile/database/converters/string_list_text.dart';
import 'package:drift/drift.dart';

/// Fournisseurs (**globaux**, ADR 0012). Lecture seule sur mobile.
///
/// **Aucun telephone** : le serveur ne l'envoie jamais dans la synchronisation et il ne doit pas
/// etre stocke tant que la base n'est pas chiffree (SQLCipher, ADR 0008). « Appeler le
/// fournisseur » le lit en ligne et ne l'enregistre pas.
@DataClassName('SupplierRow')
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Identifiants des produits fournis (liste de GUID).
  TextColumn get productIds => text().map(const StringListTextConverter())();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
