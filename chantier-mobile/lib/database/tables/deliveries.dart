import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/database/converters/decimal_text.dart';
import 'package:chantier_mobile/database/tables/sites.dart';
import 'package:drift/drift.dart';

/// Livraisons d'un chantier (miroir de `DeliverySyncData`). Supprimees avec leur chantier.
///
/// * Une livraison saisie hors ligne : `isPending = true`, `version = 0`, `id = clientId`,
///   `number = null` ; `requestId` peut etre le `clientId` d'une demande encore en attente
///   (rattache a l'identifiant du serveur quand la demande est confirmee).
/// * `photos` et `missingNote` ne sont **pas** stockes : ils se deduisent de `delivery_photos`
///   et du n° de BL (la ligne `photo` change seule, ADR 0012).
/// * **Aucun prix ni montant** : la valeur d'une livraison est calculee par le serveur et
///   reservee a `Prices.View`, hors synchronisation.
@DataClassName('DeliveryRow')
@TableIndex(name: 'idx_deliveries_site_request', columns: {#siteId, #requestId})
class Deliveries extends Table {
  TextColumn get id => text()();
  TextColumn get siteId =>
      text().references(Sites, #id, onDelete: KeyAction.cascade)();
  TextColumn get clientId => text().nullable()();

  /// `LIV-006` ; `null` tant que le serveur n'a pas donne le numero.
  TextColumn get number => text().nullable()();

  /// Demande liee ; `null` = livraison **non rattachee** (fait de chantier).
  TextColumn get requestId => text().nullable()();

  /// `NoRequestChosen`, `RequestNotOpen`, `RequestMissing` : present si `requestId` est vide.
  TextColumn get unattachedReason => text().nullable()();

  TextColumn get supplierId => text().nullable()();
  TextColumn get supplierName => text().nullable()();
  TextColumn get freeSupplierName => text().nullable()();

  TextColumn get productId => text().nullable()();
  TextColumn get productName => text().nullable()();
  TextColumn get productNameAr => text().nullable()();
  TextColumn get freeProductName => text().nullable()();

  /// Quantite recue, dans l'unite de la saisie (valeur **et** unite).
  TextColumn get quantityValue =>
      text().map(const DecimalTextConverter(scale: 3))();
  TextColumn get quantityUnit => text()();

  /// Equivalent dans l'unite de la demande (10 T = 200 sacs), si rattachee.
  TextColumn get quantityInRequestValue =>
      text().nullable().map(const DecimalTextConverter(scale: 3))();
  TextColumn get quantityInRequestUnit => text().nullable()();

  TextColumn get deliveryDate => text().map(const DateOnlyTextConverter())();
  TextColumn get deliveryNoteNumber => text().nullable()();

  /// `Conform`, `WithReserve`.
  TextColumn get conformity => text().withDefault(const Constant('Conform'))();
  TextColumn get reserveReasonCode => text().nullable()();
  TextColumn get reserveNote => text().nullable()();

  /// `Recorded`, `Cancelled`.
  TextColumn get status => text().withDefault(const Constant('Recorded'))();
  TextColumn get cancelReasonCode => text().nullable()();
  TextColumn get cancelReasonNote => text().nullable()();

  TextColumn get possibleDuplicateOfId => text().nullable()();
  TextColumn get possibleDuplicateOfNumber => text().nullable()();

  /// Historique incorpore, sans evenement sensible (`MaterialJsonGuard`).
  TextColumn get historyJson => text().nullable()();

  IntColumn get version => integer()();
  DateTimeColumn get clientCreatedAt => dateTime().nullable()();
  BoolColumn get isPending => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdByName => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get updatedByName => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {siteId, clientId},
  ];
}
