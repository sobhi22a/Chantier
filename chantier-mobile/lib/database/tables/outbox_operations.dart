import 'package:drift/drift.dart';

/// Etat d'une operation de la file d'envoi (ADR 0009).
enum OutboxStatus {
  /// En attente d'envoi.
  pending,

  /// Envoi en cours (une operation `sending` trouvee au demarrage est reprise : le
  /// `clientId` rend le renvoi idempotent).
  sending,

  /// Le serveur a repondu `conflict` : a verifier par l'utilisateur, jamais rejouee seule.
  conflict,

  /// Le serveur a repondu `rejected` : a verifier par l'utilisateur, jamais rejouee seule.
  rejected,
}

/// File d'envoi (outbox) : une ligne par saisie a transmettre au serveur.
///
/// Ecrite **dans la meme transaction** que la saisie locale (jamais l'une sans l'autre).
/// Elle n'a **aucune cle etrangere** et n'est pas videe a la deconnexion : les saisies en
/// attente restent a leur proprietaire ([ownerUserId]), qui seul les voit et les envoie.
@DataClassName('OutboxRow')
@TableIndex(name: 'idx_outbox_owner_status', columns: {#ownerUserId, #status})
class OutboxOperations extends Table {
  /// Ordre d'insertion = ordre de creation = ordre d'envoi.
  IntColumn get id => integer().autoIncrement()();

  /// GUID cree a l'ouverture du formulaire (anti-doublon), pas a l'envoi.
  TextColumn get clientId => text().unique()();
  TextColumn get ownerUserId => text()();
  TextColumn get entity => text()();

  /// `create`, `update`, `transition`.
  TextColumn get operation => text()();
  TextColumn get siteId => text().nullable()();

  /// Libelle lisible pour l'ecran « Envois en attente » (ex. `Zone Bloc 01 · +3,40 m`).
  TextColumn get label => text()();
  TextColumn get payloadJson => text()();
  IntColumn get baseVersion => integer().nullable()();
  TextColumn get status => textEnum<OutboxStatus>().withDefault(
    Constant(OutboxStatus.pending.name),
  )();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastErrorCode => text().nullable()();

  /// Heure du telephone a la saisie : affichee (« saisi le »), jamais utilisee pour decider.
  DateTimeColumn get createdAt => dateTime()();
}
