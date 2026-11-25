import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/sites.dart';
import 'package:drift/drift.dart';

part 'sites_dao.g.dart';

/// Acces aux chantiers synchronises. L'interface les lit ici, **jamais** sur le reseau.
@DriftAccessor(tables: [Sites])
class SitesDao extends DatabaseAccessor<AppDatabase> with _$SitesDaoMixin {
  SitesDao(super.attachedDatabase);

  /// Flux reactif des chantiers, tries par nom. Les archives sont masques par defaut.
  Stream<List<SiteRow>> watchSites({bool includeArchived = false}) {
    final query = select(sites)
      ..orderBy([(t) => OrderingTerm.asc(t.name.collate(Collate.noCase))]);
    if (!includeArchived) {
      query.where((t) => t.archivedAt.isNull());
    }
    return query.watch();
  }

  Stream<SiteRow?> watchSite(String id) =>
      (select(sites)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<SiteRow?> getSite(String id) =>
      (select(sites)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> countSites() async {
    final count = sites.id.count();
    final query = selectOnly(sites)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Applique une ligne recue du serveur **seulement si sa version est plus recente**
  /// (comparaison numerique, ADR 0009) : rejouer une page est sans effet.
  /// Retourne `true` si la ligne a ete ecrite.
  ///
  /// [overwrite] (rechargement complet, voir `SyncStateKeys.fullReload`) : une ligne de **meme**
  /// version est aussi ecrite. Indispensable apres un changement de permissions : le chantier n'a
  /// pas change cote serveur, mais ses champs visibles oui (le montant du marche retire doit
  /// disparaitre, R1-03). Une version plus ancienne n'ecrase jamais une plus recente.
  ///
  /// La ligne remplace entierement l'ancienne : un montant absent efface celui qui etait stocke.
  Future<bool> upsertIfNewer(
    SiteRow row, {
    bool overwrite = false,
  }) => transaction(() async {
    final existing = await getSite(row.id);
    if (existing != null &&
        (existing.version > row.version ||
            (existing.version == row.version && !overwrite))) {
      return false;
    }
    // toCompanion(false) : un `null` recu (montant retire, archivage leve) ECRASE l'ancienne valeur.
    await into(sites).insertOnConflictUpdate(row.toCompanion(false));
    return true;
  });

  /// Efface les champs **reserves** (montant du marche) de tous les chantiers, tout de suite, sans
  /// attendre le rechargement : si les permissions ont change, ils ne doivent pas rester lisibles
  /// meme si le reseau ne revient pas. Le rechargement les rend a ceux qui y ont encore droit.
  Future<int> clearRestrictedFields() =>
      (update(sites)).write(const SitesCompanion(contractAmount: Value(null)));

  /// Pierre tombale `deleted: site` : supprime le chantier **et** ses zones et affectations
  /// (cascade). Retourne le nombre de chantiers supprimes.
  Future<int> deleteSite(String id) =>
      (delete(sites)..where((t) => t.id.equals(id))).go();
}
