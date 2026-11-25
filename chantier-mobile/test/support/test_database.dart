import 'dart:ffi';
import 'dart:io';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';

/// Les tests Drift utilisent SQLite natif en memoire. Sous Windows 10/11, `winsqlite3.dll`
/// (fournie par le systeme) est trouvee d'elle-meme ; sous Linux (CI), `libsqlite3`
/// (`apt-get install libsqlite3-dev`). Pour forcer une autre bibliotheque, definir
/// `SQLITE3_DLL=<chemin de sqlite3.dll>` (surcharge facultative).
void ensureSqliteForTests() {
  final path = Platform.environment['SQLITE3_DLL'];
  if (Platform.isWindows && path != null && path.isNotEmpty) {
    open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open(path));
  }
}

/// Base vide en memoire, schema courant. A fermer avec `await db.close()` dans `tearDown`.
AppDatabase createTestDatabase() {
  ensureSqliteForTests();
  return AppDatabase(NativeDatabase.memory());
}
