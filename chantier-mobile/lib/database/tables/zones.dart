import 'package:chantier_mobile/database/converters/decimal_text.dart';
import 'package:chantier_mobile/database/tables/sites.dart';
import 'package:drift/drift.dart';

/// Zones d'un chantier : bloc, cote, local. Supprimees avec leur chantier (cascade).
///
/// Une zone creee hors ligne existe d'abord ici avec `isPending = true`, `version = 0` et
/// `id = clientId` ; la synchronisation la remplace par la version du serveur (meme
/// `clientId`, identifiant serveur) sans doublon.
@DataClassName('ZoneRow')
@TableIndex(name: 'idx_zones_site_id', columns: {#siteId})
class Zones extends Table {
  TextColumn get id => text()();
  TextColumn get siteId =>
      text().references(Sites, #id, onDelete: KeyAction.cascade)();

  /// `clientId` de creation (zones creees sur un telephone), unique par chantier.
  TextColumn get clientId => text().nullable()();
  TextColumn get block => text()();

  /// Cote en metres, 2 decimales (−1.90, 0.00, 3.40).
  TextColumn get elevation =>
      text().nullable().map(const DecimalTextConverter())();
  TextColumn get roomType => text().nullable()();
  IntColumn get roomNumber => integer().nullable()();
  TextColumn get roomLabel => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  IntColumn get version => integer()();

  /// Vrai tant que le serveur n'a pas confirme la creation.
  BoolColumn get isPending => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdByName => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// Un `clientId` ne designe qu'une zone par chantier (les `NULL` ne s'excluent pas).
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {siteId, clientId},
  ];
}
