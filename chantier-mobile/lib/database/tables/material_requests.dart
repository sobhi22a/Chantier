import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/database/converters/decimal_text.dart';
import 'package:chantier_mobile/database/tables/sites.dart';
import 'package:drift/drift.dart';

/// Demandes de materiaux d'un chantier (miroir de `RequestSyncData`, ADR 0011 et 0012).
/// Supprimees avec leur chantier (cascade).
///
/// * Une demande creee hors ligne existe d'abord ici avec `isPending = true`, `version = 0`,
///   `id = clientId` et `number = null` (« numero en attente ») ; la synchronisation la remplace
///   par la version du serveur (meme `clientId`) sans doublon.
/// * Le statut stocke est celui **du serveur** ; le statut provisoire d'une saisie en attente
///   (« a confirmer ») est calcule a l'affichage, jamais ecrit ici.
/// * **Aucun prix, montant, n° de bon de commande ni telephone** : `order_json` est la commande
///   sans `commercial` et `history_json` l'historique sans evenement sensible (garde
///   `MaterialJsonGuard`, ADR 0012).
@DataClassName('MaterialRequestRow')
@TableIndex(
  name: 'idx_material_requests_site_status',
  columns: {#siteId, #status},
)
@TableIndex(
  name: 'idx_material_requests_site_product',
  columns: {#siteId, #productId},
)
class MaterialRequests extends Table {
  TextColumn get id => text()();
  TextColumn get siteId =>
      text().references(Sites, #id, onDelete: KeyAction.cascade)();

  /// `clientId` de creation, unique par chantier (les `NULL` ne s'excluent pas).
  TextColumn get clientId => text().nullable()();

  /// `DEM-014` ; `null` tant que le serveur n'a pas donne le numero.
  TextColumn get number => text().nullable()();

  /// Produit du catalogue (peut etre absent de la table `products` : catalogue pas encore charge).
  TextColumn get productId => text().nullable()();
  TextColumn get productName => text().nullable()();
  TextColumn get productNameAr => text().nullable()();

  /// Nom libre (« Autre produit ») : exactement un de `productId` / `freeProductName`.
  TextColumn get freeProductName => text().nullable()();

  /// Quantite demandee : valeur (3 decimales) **et** unite, toujours ensemble.
  TextColumn get quantityValue =>
      text().map(const DecimalTextConverter(scale: 3))();
  TextColumn get quantityUnit => text()();

  /// Zone du chantier (identifiant serveur, ou `clientId` d'une zone encore en attente).
  TextColumn get zoneId => text().nullable()();
  TextColumn get neededBy => text().map(const DateOnlyTextConverter())();

  /// `Normal`, `Urgent`, `Blocking`.
  TextColumn get priority => text().withDefault(const Constant('Normal'))();
  TextColumn get note => text().nullable()();

  /// `Requested`, `Validated`, `Rejected`, `Ordered`, `PartiallyDelivered`, `Delivered`,
  /// `Received`, `Cancelled` (texte recu : une valeur inconnue est affichee telle quelle).
  TextColumn get status => text()();
  TextColumn get statusReasonCode => text().nullable()();
  TextColumn get statusReasonNote => text().nullable()();

  /// Recu cumule, reste et ecart **dans l'unite de la demande**, calcules par le serveur ;
  /// vides tant que la demande n'est pas commandee.
  TextColumn get receivedValue =>
      text().nullable().map(const DecimalTextConverter(scale: 3))();
  TextColumn get remainingValue =>
      text().nullable().map(const DecimalTextConverter(scale: 3))();
  TextColumn get varianceValue =>
      text().nullable().map(const DecimalTextConverter(scale: 3))();
  TextColumn get variancePercent =>
      text().nullable().map(const DecimalTextConverter())();
  BoolColumn get isSettled => boolean().withDefault(const Constant(false))();

  TextColumn get possibleDuplicateOfId => text().nullable()();
  TextColumn get possibleDuplicateOfNumber => text().nullable()();

  /// Livraison recue sans commande enregistree (badge).
  BoolColumn get hasDeliveryWithoutOrder =>
      boolean().withDefault(const Constant(false))();

  /// Commande incorporee **sans** `commercial` ; `null` sans commande active.
  TextColumn get orderJson => text().nullable()();

  /// Historique incorpore, sans evenement sensible.
  TextColumn get historyJson => text().nullable()();

  TextColumn get requestedById => text().nullable()();
  TextColumn get requestedByName => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  TextColumn get archivedByName => text().nullable()();

  /// Version serveur (`rowversion`) : comparee **numeriquement** (ADR 0009). `0` = locale.
  IntColumn get version => integer()();

  /// « Saisi le » : heure du telephone, affichee, jamais utilisee pour decider.
  DateTimeColumn get clientCreatedAt => dateTime().nullable()();

  /// Vrai tant que le serveur n'a pas confirme la creation.
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
