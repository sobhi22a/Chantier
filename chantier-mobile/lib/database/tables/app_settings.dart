import 'package:drift/drift.dart';

/// Reglages du serveur gardes pour le hors ligne (couples cle/valeur) : par exemple les reglages
/// des demandes de materiaux (`GET /settings/materials`, cle `materials`). Aucune donnee
/// personnelle. Efface avec les donnees synchronisees a la deconnexion ; relu a la synchronisation.
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
