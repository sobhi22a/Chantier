import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/user_prefs.dart';
import 'package:drift/drift.dart';

part 'user_prefs_dao.g.dart';

/// Preferences par utilisateur (chantier courant, derniere zone, langue), cles dans [UserPrefKeys].
@DriftAccessor(tables: [UserPrefs])
class UserPrefsDao extends DatabaseAccessor<AppDatabase>
    with _$UserPrefsDaoMixin {
  UserPrefsDao(super.attachedDatabase);

  Future<String?> get(String userId, String key) async {
    final row =
        await (select(userPrefs)
              ..where((t) => t.userId.equals(userId) & t.key.equals(key)))
            .getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watch(String userId, String key) =>
      (select(userPrefs)
            ..where((t) => t.userId.equals(userId) & t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  Future<void> set(String userId, String key, String value) =>
      into(userPrefs).insertOnConflictUpdate(
        UserPrefsCompanion.insert(userId: userId, key: key, value: value),
      );

  Future<int> remove(String userId, String key) => (delete(
    userPrefs,
  )..where((t) => t.userId.equals(userId) & t.key.equals(key))).go();
}
