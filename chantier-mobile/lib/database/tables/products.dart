import 'package:chantier_mobile/database/converters/decimal_text.dart';
import 'package:chantier_mobile/database/converters/string_list_text.dart';
import 'package:drift/drift.dart';

/// Catalogue des produits (**global** : commun a tous les chantiers, ADR 0012). Lecture seule sur
/// mobile, le serveur gagne ; jamais supprime, seulement desactive (`isActive`).
///
/// Aucune donnee commerciale : ni prix ni prix par defaut.
@DataClassName('ProductRow')
@TableIndex(name: 'idx_products_active', columns: {#isActive})
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get nameFr => text()();
  TextColumn get nameAr => text().nullable()();

  /// `Binders`, `Steel`, `Masonry`, `Aggregates`, `Admixtures`, `FinishingWorks`, `Other`.
  TextColumn get category => text()();

  /// Codes d'unites du referentiel (`sac`, `t`, `kg`...), au moins un.
  TextColumn get allowedUnits => text().map(const StringListTextConverter())();
  TextColumn get defaultUnit => text()();

  /// Masse d'un sac en kg (50 le ciment, 25 le monocouche) ; vide si `sac` n'est pas autorise.
  TextColumn get bagMassKg =>
      text().nullable().map(const DecimalTextConverter(scale: 3))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Version serveur (`rowversion`) : comparee **numeriquement** (ADR 0009).
  IntColumn get version => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
