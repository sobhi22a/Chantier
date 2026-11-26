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

  test(
    'v1 -> v2 : la file d envoi et les chantiers sont conserves, les tables du lot sont creees',
    () async {
      final schema = await verifier.schemaAt(1);
      // Donnees d'un telephone en service sous le schema 1 : une saisie en attente.
      schema.rawDatabase.execute("""
        INSERT INTO outbox_operations
          (client_id, owner_user_id, entity, operation, site_id, label, payload_json,
           base_version, status, attempts, last_error_code, created_at)
        VALUES
          ('c-1', 'user-a', 'zone', 'create', 'site-uv18', 'Zone Bloc 01', '{}',
           NULL, 'rejected', 2, 'CHANTIER_ARCHIVE', 1795600000)
      """);

      final db = AppDatabase(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 2);

      final kept = (await db.outboxDao.getByClientId('c-1'))!;
      expect(kept.ownerUserId, 'user-a');
      expect(kept.lastErrorCode, 'CHANTIER_ARCHIVE');
      expect(kept.attempts, 2);
      expect(kept.conflictJson, isNull);
      expect(kept.conflictFields, isNull);

      for (final table in [
        'products',
        'suppliers',
        'material_requests',
        'deliveries',
        'delivery_photos',
        'pending_photo_files',
        'app_settings',
      ]) {
        final rows = await db
            .customSelect('SELECT COUNT(*) AS n FROM $table')
            .getSingle();
        expect(rows.read<int>('n'), 0, reason: table);
      }
      // Les index du lot existent aussi (migrateAndValidate compare au schema attendu).
      final indexes = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
          )
          .get();
      expect(
        indexes.map((r) => r.read<String>('name')),
        containsAll([
          'idx_material_requests_site_status',
          'idx_material_requests_site_product',
          'idx_deliveries_site_request',
          'idx_delivery_photos_delivery',
          'idx_pending_photo_files_owner',
          'idx_products_active',
        ]),
      );
    },
  );
}
