import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/database/converters/decimal_text.dart';
import 'package:drift/drift.dart';

/// Chantiers visibles par l'utilisateur (lecture seule sur mobile, le serveur gagne).
///
/// Miroir de `SiteResponse` (`docs/api/socle.md`). [contractAmount] est **nullable** :
/// le serveur ne l'envoie pas sans la permission `ContractAmount.View` (CA-003.5), la
/// colonne reste alors vide.
@DataClassName('SiteRow')
class Sites extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();

  /// `School`, `Housing`, `PublicFacility`, `Other` (chaines stables du contrat).
  TextColumn get type => text()();
  TextColumn get wilaya => text()();
  TextColumn get commune => text()();
  TextColumn get latitude =>
      text().nullable().map(const DecimalTextConverter(scale: 6))();
  TextColumn get longitude =>
      text().nullable().map(const DecimalTextConverter(scale: 6))();
  TextColumn get owner => text()();
  TextColumn get contractNumber => text().nullable()();
  TextColumn get contractAmount =>
      text().nullable().map(const DecimalTextConverter())();
  IntColumn get delayDays => integer().nullable()();
  TextColumn get odsDate =>
      text().nullable().map(const DateOnlyTextConverter())();

  /// Calculee par le serveur (ODS + delai) ; `null` = « A definir ».
  TextColumn get contractualEndDate =>
      text().nullable().map(const DateOnlyTextConverter())();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  /// Version serveur (`rowversion`) : comparee **numeriquement** (ADR 0009).
  IntColumn get version => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdByName => text()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get updatedByName => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
