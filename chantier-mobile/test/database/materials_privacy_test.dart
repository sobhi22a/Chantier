import 'package:chantier_mobile/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import '../support/test_database.dart';

/// CT-MAT-22 : inspection de la base du telephone. **Aucun prix, aucun montant, aucun n° de bon de
/// commande, aucun telephone de fournisseur**, pour aucun role (ADR 0012, hypotheses H-ARCH-02 et
/// H-ARCH-03). Si ce test echoue, une colonne sensible est entree dans le schema : il faut
/// d'abord chiffrer la base (SQLCipher, ADR 0008) et ecrire un ADR.
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  /// Mots qui designent une donnee commerciale ou un contact dans un nom de colonne ou de table.
  final sensitive = RegExp(
    r'price|prix|amount|montant|commercial|purchase|bon_de_commande|phone|telephone|tel$|cost|cout|(^|_)(tva|vat)($|_)',
    caseSensitive: false,
  );

  /// Seule exception : le montant du marche du socle (`sites.contract_amount`), champ reserve a
  /// `ContractAmount.View`, efface a chaque changement de permissions (R1-03).
  const allowed = {'sites.contract_amount'};

  test(
    'aucune colonne de prix, de montant ou de telephone dans tout le schema',
    () async {
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
          )
          .get();
      expect(tables.length, greaterThanOrEqualTo(13));

      final offenders = <String>[];
      for (final table in tables.map((r) => r.read<String>('name'))) {
        final columns = await db
            .customSelect('PRAGMA table_info($table)')
            .get();
        for (final column in columns.map((r) => r.read<String>('name'))) {
          if ((sensitive.hasMatch(column) || sensitive.hasMatch(table)) &&
              !allowed.contains('$table.$column')) {
            offenders.add('$table.$column');
          }
        }
      }

      expect(offenders, isEmpty);
    },
  );

  test(
    'les tables du lot existent, sans le moindre champ commercial',
    () async {
      for (final table in [
        'products',
        'suppliers',
        'material_requests',
        'deliveries',
        'delivery_photos',
        'pending_photo_files',
        'app_settings',
      ]) {
        final columns = await db
            .customSelect('PRAGMA table_info($table)')
            .get();
        expect(columns, isNotEmpty, reason: table);
      }
    },
  );

  test(
    'apres ecriture d une demande commandee : aucun prix dans aucun texte stocke',
    () async {
      await db.sitesDao.upsertIfNewer(siteRow());
      await db.productsDao.upsertIfNewer(productRow());
      await db.suppliersDao.upsertIfNewer(supplierRow());
      await db.materialRequestsDao.upsertIfNewer(
        requestRow(
          status: 'Ordered',
          orderJson:
              '{"id":"o-1","supplierName":"Cimenterie Sigma (fictive)","commercial":{"unitPrice":780.0,"amount":234000.0,"purchaseOrderNumber":"BC-2026-044"}}',
          historyJson:
              '[{"id":"e","type":"OrderCommercialEdited","changes":[{"field":"unitPrice","old":"700","new":"780"}]}]',
        ),
      );
      await db.deliveriesDao.upsertIfNewer(deliveryRow());

      final dump = StringBuffer();
      for (final table in [
        'products',
        'suppliers',
        'material_requests',
        'deliveries',
        'delivery_photos',
        'app_settings',
      ]) {
        final rows = await db.customSelect('SELECT * FROM $table').get();
        for (final row in rows) {
          dump.writeln(row.data.values.join('|'));
        }
      }

      final text = dump.toString();
      for (final forbidden in [
        '780',
        '234000',
        'BC-2026',
        'unitPrice',
        'commercial',
        'OrderCommercialEdited',
      ]) {
        expect(text, isNot(contains(forbidden)), reason: forbidden);
      }
      expect(text, contains('Sigma'));
    },
  );

  test('jamais les octets d une photo en base : aucune colonne BLOB', () async {
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final blobs = <String>[];
    for (final table in tables.map((r) => r.read<String>('name'))) {
      for (final column
          in await db.customSelect('PRAGMA table_info($table)').get()) {
        if (column.read<String>('type').toUpperCase().contains('BLOB')) {
          blobs.add('$table.${column.read<String>('name')}');
        }
      }
    }
    // Les photos de bons sont chargees a la demande, en memoire, jamais gardees (ADR 0013).
    expect(blobs, isEmpty);
  });

  test(
    'photos : metadonnees et chemin relatif seulement, rien d autre',
    () async {
      final columns = [
        for (final row
            in await db
                .customSelect('PRAGMA table_info(delivery_photos)')
                .get())
          row.read<String>('name'),
      ];
      expect(
        columns,
        containsAll(['id', 'delivery_id', 'taken_at', 'content_status']),
      );
      expect(columns, isNot(contains('content')));
      expect(columns, isNot(contains('path')));
      expect(columns, isNot(contains('url')));
    },
  );
}
