import 'package:chantier_mobile/database/tables/sites.dart';
import 'package:drift/drift.dart';

/// Personnes affectees a un chantier (lecture seule) : nom et role, **jamais de telephone**
/// (CA-017.4). Supprimees avec leur chantier (cascade).
@DataClassName('SiteMemberRow')
@TableIndex(name: 'idx_site_members_site_id', columns: {#siteId})
class SiteMembers extends Table {
  TextColumn get id => text()();
  TextColumn get siteId =>
      text().references(Sites, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text()();
  TextColumn get fullName => text()();
  TextColumn get role => text()();
  DateTimeColumn get assignedAt => dateTime()();
  IntColumn get version => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
