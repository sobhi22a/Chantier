import 'package:drift/drift.dart';

/// Cles de [SyncState] (ADR 0009).
abstract final class SyncStateKeys {
  /// Curseur serveur du dernier pull applique (jamais l'horloge du telephone).
  static const String cursor = 'cursor';

  /// Utilisateur proprietaire des donnees synchronisees.
  static const String ownerUserId = 'owner_user_id';
  static const String lastSuccessAt = 'last_success_at';

  /// Dernier contact reussi avec le serveur : base de la session hors ligne (14 jours).
  static const String lastServerContactAt = 'last_server_contact_at';
  static const String permissionsVersion = 'permissions_version';
  static const String initialSyncDone = 'initial_sync_done';

  /// Rechargement complet en cours (curseur remis a zero) : tant qu'il dure, les lignes recues
  /// **ecrasent** celles de meme version (un champ reserve retire par le serveur, comme le montant
  /// du marche, ne doit pas survivre au rechargement). Efface a la derniere page du pull.
  static const String fullReload = 'full_reload';

  /// Profil de l'utilisateur connecte (JSON : role, permissions, langue...), pour ouvrir la session
  /// **hors ligne**. Purge avec les donnees synchronisees a la deconnexion. Jamais de telephone.
  static const String profile = 'profile_json';
}

/// Etat de la synchronisation : couples cle/valeur (voir [SyncStateKeys]).
@DataClassName('SyncStateRow')
class SyncState extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
