import 'package:drift/drift.dart';

/// Cles de [UserPrefs].
abstract final class UserPrefKeys {
  /// Chantier courant (CA-010).
  static const String currentSiteId = 'current_site_id';

  /// Derniere zone utilisee, preselectionnee a la saisie (CA-009.1).
  static const String lastZoneId = 'last_zone_id';
  static const String language = 'language';
}

/// Preferences par utilisateur. **Videes a la deconnexion** (telephone partage, CA-002.4).
@DataClassName('UserPrefRow')
class UserPrefs extends Table {
  TextColumn get userId => text()();
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {userId, key};
}
