import 'package:chantier_mobile/core/utils/collation.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/suppliers.dart';
import 'package:drift/drift.dart';

part 'suppliers_dao.g.dart';

/// Fournisseurs (globaux, lecture seule). **Aucun telephone** n'est stocke (ADR 0012).
@DriftAccessor(tables: [Suppliers])
class SuppliersDao extends DatabaseAccessor<AppDatabase>
    with _$SuppliersDaoMixin {
  SuppliersDao(super.attachedDatabase);

  /// Flux reactif, tri « lecture humaine ». Les fournisseurs desactives sont masques par defaut.
  Stream<List<SupplierRow>> watchAll({bool includeInactive = false}) {
    final query = select(suppliers);
    if (!includeInactive) query.where((t) => t.isActive.equals(true));
    return query.watch().map(
      (rows) => rows..sort((a, b) => compareHuman(a.name, b.name)),
    );
  }

  Future<SupplierRow?> getById(String id) =>
      (select(suppliers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> countAll() async {
    final count = suppliers.id.count();
    final query = selectOnly(suppliers)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Voir `ProductsDao.upsertIfNewer`.
  Future<bool> upsertIfNewer(SupplierRow row, {bool overwrite = false}) =>
      transaction(() async {
        final existing = await getById(row.id);
        if (existing != null &&
            (existing.version > row.version ||
                (existing.version == row.version && !overwrite))) {
          return false;
        }
        await into(suppliers).insertOnConflictUpdate(row.toCompanion(false));
        return true;
      });
}
