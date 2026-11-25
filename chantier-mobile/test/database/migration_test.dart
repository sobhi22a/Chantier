import 'dart:io';

import 'package:chantier_mobile/database/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated_migrations/schema.dart';
import '../support/test_database.dart';

void main() {
  setUpAll(ensureSqliteForTests);

  late SchemaVerifier verifier;

  setUp(() => verifier = SchemaVerifier(GeneratedHelper()));

  test(
    'le schema Dart correspond au schema exporte de la version courante',
    () async {
      const version = AppDatabase.currentSchemaVersion;
      final connection = await verifier.startAt(version);
      final db = AppDatabase(connection);
      addTearDown(db.close);

      // Echoue si une table ou une colonne a change sans `dart run drift_dev schema dump`.
      await verifier.migrateAndValidate(db, version);
    },
  );

  test(
    'chaque version du schema a son export JSON (aucune migration oubliee)',
    () {
      final dumps =
          Directory('drift_schemas')
              .listSync()
              .whereType<File>()
              .map(
                (f) => RegExp(r'drift_schema_v(\d+)\.json$').firstMatch(f.path),
              )
              .whereType<RegExpMatch>()
              .map((m) => int.parse(m.group(1)!))
              .toList()
            ..sort();

      expect(dumps, isNotEmpty);
      expect(
        dumps.last,
        AppDatabase.currentSchemaVersion,
        reason:
            'schemaVersion change : relancer `dart run drift_dev schema dump '
            'lib/database/app_database.dart drift_schemas/` puis `schema generate`',
      );
      expect(dumps, [
        for (var v = 1; v <= dumps.last; v++) v,
      ], reason: 'pas de trou');
    },
  );
}
