// Les convertisseurs et `decimal` sont utilises par le code genere (`app_database.g.dart`).
import 'package:chantier_mobile/database/converters/date_only_text.dart';
import 'package:chantier_mobile/database/converters/decimal_text.dart';
import 'package:chantier_mobile/database/daos/outbox_dao.dart';
import 'package:chantier_mobile/database/daos/site_members_dao.dart';
import 'package:chantier_mobile/database/daos/sites_dao.dart';
import 'package:chantier_mobile/database/daos/sync_state_dao.dart';
import 'package:chantier_mobile/database/daos/user_prefs_dao.dart';
import 'package:chantier_mobile/database/daos/zones_dao.dart';
import 'package:chantier_mobile/database/tables/outbox_operations.dart';
import 'package:chantier_mobile/database/tables/site_members.dart';
import 'package:chantier_mobile/database/tables/sites.dart';
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
/// Pas de chiffrement (SQLCipher) au socle : il ne contient aucune donnee personnelle
/// (noms des affectes seulement, jamais de telephone). Il est **exige avant** de synchroniser
/// des intervenants ou des telephones (ADR 0008).
@DriftDatabase(
  tables: [Sites, Zones, SiteMembers, OutboxOperations, SyncState, UserPrefs],
  daos: [
    SitesDao,
    ZonesDao,
    SiteMembersDao,
    OutboxDao,
    SyncStateDao,
    UserPrefsDao,
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
  static const int currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
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

  /// Purge a la deconnexion ou sur `ACCES_RETIRE` (telephone partage, CA-002.4, CA-002.5) :
  /// chantiers, zones, affectations, preferences et etat de synchronisation.
  ///
  /// **La file d'envoi (`outbox_operations`) est conservee** : les saisies en attente restent
  /// a leur proprietaire (`owner_user_id`) et partiront apres sa reconnexion.
  Future<void> purgeSyncedData() => transaction(() async {
    // Explicite, sans dependre de la cascade : enfants d'abord.
    await delete(zones).go();
    await delete(siteMembers).go();
    await delete(sites).go();
    await delete(userPrefs).go();
    await delete(syncState).go();
  });
}
