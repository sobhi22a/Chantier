import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/app_settings.dart';
import 'package:drift/drift.dart';

part 'app_settings_dao.g.dart';

/// Reglages du serveur gardes pour le hors ligne (voir [AppSettings]).
@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.attachedDatabase);

  Future<String?> get(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watch(String key) => (select(
    appSettings,
  )..where((t) => t.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  Future<void> set(String key, String value) => into(
    appSettings,
  ).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
}
