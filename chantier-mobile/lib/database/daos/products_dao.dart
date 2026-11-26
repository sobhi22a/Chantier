import 'package:chantier_mobile/core/utils/collation.dart';
import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/products.dart';
import 'package:drift/drift.dart';

part 'products_dao.g.dart';

/// Catalogue des produits (global, lecture seule). L'ecran de saisie le lit ici, **jamais** sur le
/// reseau : tuiles, recherche tolerante et unites autorisees fonctionnent sans connexion.
@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.attachedDatabase);

  /// Flux reactif du catalogue, tri « lecture humaine » (sans accents). Les produits
  /// desactives sont masques par defaut : ils restent lisibles dans l'historique via [getById].
  Stream<List<ProductRow>> watchAll({bool includeInactive = false}) {
    final query = select(products);
    if (!includeInactive) query.where((t) => t.isActive.equals(true));
    return query.watch().map(
      (rows) => rows..sort((a, b) => compareHuman(a.nameFr, b.nameFr)),
    );
  }

  Future<List<ProductRow>> getAll({bool includeInactive = false}) async {
    final query = select(products);
    if (!includeInactive) query.where((t) => t.isActive.equals(true));
    final rows = await query.get();
    return rows..sort((a, b) => compareHuman(a.nameFr, b.nameFr));
  }

  Future<ProductRow?> getById(String id) =>
      (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<ProductRow?> watchById(String id) =>
      (select(products)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> countAll() async {
    final count = products.id.count();
    final query = selectOnly(products)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Ecrit une ligne recue **seulement si sa version est plus recente** (comparaison
  /// numerique, ADR 0009). [overwrite] : rechargement complet, une version egale est aussi
  /// ecrite. Retourne `true` si une ligne a ete ecrite.
  Future<bool> upsertIfNewer(ProductRow row, {bool overwrite = false}) =>
      transaction(() async {
        final existing = await getById(row.id);
        if (existing != null &&
            (existing.version > row.version ||
                (existing.version == row.version && !overwrite))) {
          return false;
        }
        await into(products).insertOnConflictUpdate(row.toCompanion(false));
        return true;
      });
}
