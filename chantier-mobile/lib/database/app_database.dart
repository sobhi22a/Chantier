// Les convertisseurs et `decimal` sont utilises par le code genere (`app_database.g.dart`).
import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/database/converters/decimal_text.dart';
import 'package:chantier_mobile/database/converters/string_list_text.dart';
import 'package:chantier_mobile/database/daos/app_settings_dao.dart';
import 'package:chantier_mobile/database/daos/deliveries_dao.dart';
import 'package:chantier_mobile/database/daos/delivery_photos_dao.dart';
import 'package:chantier_mobile/database/daos/material_requests_dao.dart';
import 'package:chantier_mobile/database/daos/outbox_dao.dart';
import 'package:chantier_mobile/database/daos/products_dao.dart';
import 'package:chantier_mobile/database/daos/site_members_dao.dart';
import 'package:chantier_mobile/database/daos/sites_dao.dart';
import 'package:chantier_mobile/database/daos/suppliers_dao.dart';
import 'package:chantier_mobile/database/daos/sync_state_dao.dart';
import 'package:chantier_mobile/database/daos/user_prefs_dao.dart';
import 'package:chantier_mobile/database/daos/zones_dao.dart';
import 'package:chantier_mobile/database/tables/app_settings.dart';
import 'package:chantier_mobile/database/tables/deliveries.dart';
import 'package:chantier_mobile/database/tables/delivery_photos.dart';
import 'package:chantier_mobile/database/tables/material_requests.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/database/tables/pending_photo_files.dart';
import 'package:chantier_mobile/database/tables/products.dart';
import 'package:chantier_mobile/database/tables/site_members.dart';
import 'package:chantier_mobile/database/tables/sites.dart';
import 'package:chantier_mobile/database/tables/suppliers.dart';
import 'package:chantier_mobile/database/tables/sync_state.dart';
import 'package:chantier_mobile/database/tables/user_prefs.dart';
import 'package:chantier_mobile/database/tables/zones.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Base locale (Drift / SQLite) : **seule source de lecture de l'interface** (ADR 0008).
/// Le reseau ne sert qu'a l'alimenter, via le moteur de synchronisation (ADR 0009).
///
/// Pas de chiffrement (SQLCipher) : il ne contient aucune donnee personnelle (noms des affectes
/// seulement, jamais de telephone) et **aucun prix** (demandes de materiaux : ni prix, ni montant,
/// ni telephone de fournisseur, ADR 0012). Le chiffrement est **exige avant** de synchroniser des
/// intervenants ou des telephones (ADR 0008).
@DriftDatabase(
  tables: [
    Sites,
    Zones,
    SiteMembers,
    OutboxOperations,
    SyncState,
    UserPrefs,
    Products,
    Suppliers,
    MaterialRequests,
    Deliveries,
    DeliveryPhotos,
    PendingPhotoFiles,
    AppSettings,
  ],
  daos: [
    SitesDao,
    ZonesDao,
    SiteMembersDao,
    OutboxDao,
    SyncStateDao,
    UserPrefsDao,
    ProductsDao,
    SuppliersDao,
    MaterialRequestsDao,
    DeliveriesDao,
    DeliveryPhotosDao,
    AppSettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Base fournie par l'appelant : en memoire dans les tests (`NativeDatabase.memory()`).
  AppDatabase(super.executor);

  /// Base de production : fichier SQLite dans le dossier de l'application, ouvert dans un
  /// isolat d'arriere-plan (le fil principal reste libre sur un telephone d'entree de gamme).
  AppDatabase.open() : super(driftDatabase(name: databaseName));

  static const String databaseName = 'chantier';

  /// Version du schema. A chaque changement de table : incrementer, ecrire la migration
  /// (`onUpgrade`), puis `dart run drift_dev schema dump` (voir `docs` du dossier `drift_schemas`).
  ///
  /// * 1 : socle (chantiers, zones, affectations, file d'envoi, etat de synchronisation) ;
  /// * 2 : demandes de materiaux et livraisons (catalogue, demandes, livraisons, photos, fichiers
  ///   en attente, reglages) et colonnes de conflit de la file d'envoi.
  static const int currentSchemaVersion = 2;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Additif seulement : aucune donnee existante n'est touchee (la file d'envoi garde ses
        // saisies en attente).
        await migrator.addColumn(
          outboxOperations,
          outboxOperations.conflictJson,
        );
        await migrator.addColumn(
          outboxOperations,
          outboxOperations.conflictFields,
        );
        await migrator.createTable(products);
        await migrator.createIndex(idxProductsActive);
        await migrator.createTable(suppliers);
        await migrator.createTable(materialRequests);
        await migrator.createIndex(idxMaterialRequestsSiteStatus);
        await migrator.createIndex(idxMaterialRequestsSiteProduct);
        await migrator.createTable(deliveries);
        await migrator.createIndex(idxDeliveriesSiteRequest);
        await migrator.createTable(deliveryPhotos);
        await migrator.createIndex(idxDeliveryPhotosDelivery);
        await migrator.createTable(pendingPhotoFiles);
        await migrator.createIndex(idxPendingPhotoFilesOwner);
        await migrator.createTable(appSettings);
      }
    },
    beforeOpen: (details) async {
      // SQLite n'applique les cles etrangeres (suppression en cascade site -> zones et
      // affectations) que si on le demande a chaque ouverture.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Changement de permissions (`permissionsVersion`) ou curseur invalide : repart de zero.
  ///
  /// * [clearRestrictedFields] : efface **immediatement** le montant du marche stocke (R1-03),
  ///   sans attendre le rechargement ;
  /// * le curseur est remis a zero et le drapeau `full_reload` ecrase les lignes de meme version
  ///   pendant le rechargement (un champ retire ne survit pas, un champ accorde apparait).
  /// La file d'envoi n'est jamais touchee.
  Future<void> startFullReload({bool clearRestrictedFields = false}) =>
      transaction(() async {
        if (clearRestrictedFields) await sitesDao.clearRestrictedFields();
        await syncStateDao.resetCursor();
      });

  /// Supprime un chantier **et tout ce qui en depend**, explicitement : pendant un pull, les cles
  /// etrangeres sont suspendues (voir `SitesRepository.applyPullPage`), la cascade de SQLite ne joue
  /// donc pas. Les saisies en attente de la file d'envoi ne sont jamais touchees.
  Future<int> deleteSiteCascade(String siteId) => transaction(() async {
    await (delete(deliveryPhotos)..where((t) => t.siteId.equals(siteId))).go();
    await (delete(deliveries)..where((t) => t.siteId.equals(siteId))).go();
    await (delete(
      materialRequests,
    )..where((t) => t.siteId.equals(siteId))).go();
    await (delete(zones)..where((t) => t.siteId.equals(siteId))).go();
    await (delete(siteMembers)..where((t) => t.siteId.equals(siteId))).go();
    return (delete(sites)..where((t) => t.id.equals(siteId))).go();
  });

  /// **Rechargement complet de la fenetre de synchronisation** (R3-05) : le serveur ne renvoie plus
  /// les demandes closes depuis plus de 60 jours et n'envoie aucune pierre tombale ; un telephone
  /// reste longtemps sans synchroniser en garde une version perimee. On efface donc demandes,
  /// livraisons et photos **confirmees** et on repart de zero. **Les saisies en attente restent**
  /// (lignes locales `is_pending`, file d'envoi, fichiers de photos) : rien n'est perdu. Chantiers,
  /// zones, catalogue et reglages ne sont pas touches (ils sont rechiffres a l'identique).
  Future<void> startWindowReload() => transaction(() async {
    await (delete(
      deliveryPhotos,
    )..where((t) => t.isPending.equals(false))).go();
    await (delete(deliveries)..where((t) => t.isPending.equals(false))).go();
    await (delete(
      materialRequests,
    )..where((t) => t.isPending.equals(false))).go();
    await syncStateDao.resetCursor();
  });

  /// Lignes dont le chantier n'existe pas (parent jamais recu : chantier non visible, ou perdu
  /// avant la fin du pull) : supprimees **a la fin du pull**, quand toutes les pages ont ete
  /// appliquees (l'ordre ENTRE pages n'est pas garanti, ecart 26 du contrat).
  Future<int> deleteOrphans() => transaction(() async {
    // Jamais une saisie en attente : elle garde sa ligne locale tant que l'utilisateur n'a pas
    // decide (« A verifier »).
    const orphan = 'site_id NOT IN (SELECT id FROM sites)';
    var removed = 0;
    for (final table in const [
      'delivery_photos',
      'deliveries',
      'material_requests',
      'zones',
      'site_members',
    ]) {
      removed += await customUpdate(
        'DELETE FROM $table WHERE $orphan'
        '${table == 'site_members' ? '' : ' AND is_pending = 0'}',
        updates: {
          if (table == 'delivery_photos') deliveryPhotos,
          if (table == 'deliveries') deliveries,
          if (table == 'material_requests') materialRequests,
          if (table == 'zones') zones,
          if (table == 'site_members') siteMembers,
        },
        updateKind: UpdateKind.delete,
      );
    }
    return removed;
  });

  /// Purge a la deconnexion ou sur `ACCES_RETIRE` (telephone partage, CA-002.4, CA-002.5) :
  /// chantiers, zones, affectations, demandes, livraisons, metadonnees de photos, catalogue,
  /// fournisseurs, reglages, preferences et etat de synchronisation.
  ///
  /// **La file d'envoi (`outbox_operations`) et les fichiers de photos en attente
  /// (`pending_photo_files`) sont conserves** : les saisies en attente restent a leur
  /// proprietaire (`owner_user_id`) et partiront apres sa reconnexion. Aucun fichier de photo
  /// n'est perdu avant la confirmation du serveur (ADR 0013).
  Future<void> purgeSyncedData() => transaction(() async {
    // Explicite, sans dependre de la cascade : enfants d'abord.
    await delete(deliveryPhotos).go();
    await delete(deliveries).go();
    await delete(materialRequests).go();
    await delete(products).go();
    await delete(suppliers).go();
    await delete(appSettings).go();
    await delete(zones).go();
    await delete(siteMembers).go();
    await delete(sites).go();
    await delete(userPrefs).go();
    await delete(syncState).go();
  });
}
