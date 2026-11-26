import 'package:drift/drift.dart';

/// Fichiers de photos en attente d'envoi : une ligne par fichier du dossier prive de l'application
/// (ADR 0013). Comme la file d'envoi, cette table n'a **aucune cle etrangere** et n'est **pas
/// videe a la deconnexion** : un fichier prend la route du serveur seulement pour son proprietaire
/// ([ownerUserId]) et n'est supprime qu'apres confirmation de l'envoi.
@DataClassName('PendingPhotoFileRow')
@TableIndex(name: 'idx_pending_photo_files_owner', columns: {#ownerUserId})
class PendingPhotoFiles extends Table {
  /// `clientId` de la photo (cree a la prise, pas a l'envoi).
  TextColumn get clientId => text()();
  TextColumn get ownerUserId => text()();
  TextColumn get siteId => text()();

  /// Livraison portee (identifiant serveur, ou `clientId` d'une livraison en attente).
  TextColumn get deliveryId => text()();

  /// Chemin **relatif** au dossier prive du proprietaire.
  TextColumn get relativePath => text()();
  TextColumn get sha256 => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get contentType =>
      text().withDefault(const Constant('image/jpeg'))();
  DateTimeColumn get takenAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastErrorCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {clientId};
}
