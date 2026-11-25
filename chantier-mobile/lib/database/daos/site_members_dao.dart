import 'package:chantier_mobile/database/app_database.dart';
import 'package:chantier_mobile/database/tables/site_members.dart';
import 'package:drift/drift.dart';

part 'site_members_dao.g.dart';

/// Acces aux affectations d'un chantier (noms et roles, lecture seule).
@DriftAccessor(tables: [SiteMembers])
class SiteMembersDao extends DatabaseAccessor<AppDatabase>
    with _$SiteMembersDaoMixin {
  SiteMembersDao(super.attachedDatabase);

  Stream<List<SiteMemberRow>> watchBySite(String siteId) =>
      (select(siteMembers)
            ..where((t) => t.siteId.equals(siteId))
            ..orderBy([
              (t) => OrderingTerm.asc(t.fullName.collate(Collate.noCase)),
            ]))
          .watch();

  Future<SiteMemberRow?> getById(String id) =>
      (select(siteMembers)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Ecrite seulement si la version recue est plus recente (ADR 0009).
  Future<bool> upsertIfNewer(SiteMemberRow row, {bool overwrite = false}) =>
      transaction(() async {
        final existing = await getById(row.id);
        if (existing != null && existing.version > row.version) return false;
        if (existing != null && existing.version == row.version && !overwrite) {
          return false;
        }
        await into(siteMembers).insertOnConflictUpdate(row.toCompanion(false));
        return true;
      });

  /// Pierre tombale `deleted: member`.
  Future<int> deleteMember(String id) =>
      (delete(siteMembers)..where((t) => t.id.equals(id))).go();
}
